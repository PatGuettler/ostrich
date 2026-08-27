extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _fail(message: String) -> void:
	push_error("3D SMOKE TEST FAILED: " + message)
	quit(1)


func _run() -> void:
	root.size = Vector2i(540, 960)
	var packed: PackedScene = load("res://main_3d.tscn")
	if packed == null:
		_fail("3D scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	game.set_process(false)
	await process_frame

	if game.player == null or game.camera == null:
		_fail("3D player or follow camera was not created")
		return
	if game.player.get_node_or_null("Model/MeshyPenguin") == null:
		_fail("Meshy penguin model was not instanced")
		return
	if game.get_node_or_null("PaintedIceChute") == null:
		_fail("procedural track mesh was not created")
		return
	if game.get_node_or_null("ConnectedMountainTerrainLeft") == null or game.get_node_or_null("ConnectedMountainTerrainRight") == null:
		_fail("connected mountain terrain was not created on both sides")
		return

	game._start_run()
	game._hop()
	var peak := 0.0
	for i in range(100):
		game._update_run(1.0 / 60.0)
		peak = maxf(peak, game.jump_height)
	if peak < 1.2:
		_fail("3D hop did not reach obstacle-clearing height")
		return
	if game.distance < 18.0:
		_fail("3D course distance did not advance")
		return

	var stale_node := Node3D.new()
	game.obstacle_root.add_child(stale_node)
	game.obstacles.append({"node": stale_node, "at": game.distance - 20.0, "kind": "fish", "checked": false})
	stale_node.queue_free()
	await process_frame
	game._update_obstacles()
	for obstacle in game.obstacles:
		if obstacle.get("node") == stale_node:
			_fail("freed obstacles were not removed safely")
			return

	for obstacle in game.obstacles:
		var old_node = obstacle.get("node")
		if is_instance_valid(old_node):
			old_node.free()
	game.obstacles.clear()
	var collision_node := Node3D.new()
	game.obstacle_root.add_child(collision_node)
	game.obstacles.append({"node": collision_node, "at": game.distance + 0.5, "kind": "ice", "checked": false})
	game.jump_height = 0.0
	game._update_obstacles()
	if game.state != 2:
		_fail("3D grounded collision did not end the run")
		return

	game._start_run()
	if game.state != 1 or game.distance != 0.0:
		_fail("3D retry did not reset the run")
		return
	for i in range(900):
		game.jump_height = 2.0
		game.jump_velocity = 0.0
		game._update_run(1.0 / 30.0)
	if game.state != 1 or game.distance < 300.0:
		_fail("extended obstacle spawn and cleanup run did not remain healthy")
		return

	print("3D SMOKE TEST PASSED: mesh, camera, hop, collision, retry, and extended obstacle cleanup")
	game.queue_free()
	await process_frame
	quit(0)
