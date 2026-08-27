extends SceneTree

func _initialize() -> void:
	call_deferred("_run")


func _fail(message: String) -> void:
	push_error("SMOKE TEST FAILED: " + message)
	quit(1)


func _run() -> void:
	root.size = Vector2i(540, 960)
	var packed: PackedScene = load("res://main.tscn")
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	game.set_process(false)

	await process_frame
	await process_frame
	if root.size != Vector2i(540, 960):
		_fail("portrait viewport was not configured")
		return

	game._start_run()
	game.next_spawn_at = 99999.0
	game._hop()
	var peak := 0.0
	for i in range(130):
		game._update_run(1.0 / 60.0)
		peak = maxf(peak, game.jump_height)
	if peak < 80.0 or game.jump_height != 0.0:
		_fail("hop arc did not rise and land")
		return
	if game.distance < 70.0:
		_fail("distance did not advance")
		return

	game.obstacles.clear()
	game.obstacles.append({"kind": "ice", "progress": 0.95, "checked": false, "spawn_distance": game.distance - 100.0, "travel_distance": 105.0, "seed": 0.0})
	game.jump_height = 0.0
	game._check_collisions()
	if game.state != 2:
		_fail("grounded obstacle collision did not end the run")
		return

	game._start_run()
	if game.state != 1 or game.distance != 0.0:
		_fail("retry did not reset the run")
		return

	print("SMOKE TEST PASSED: scene load, hop, distance, collision, and retry")
	for child in game.get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
			child.free()
	game.queue_free()
	await process_frame
	quit(0)
