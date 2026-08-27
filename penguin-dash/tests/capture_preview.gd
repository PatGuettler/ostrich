extends SceneTree


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(540, 960)
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	for i in range(6):
		await process_frame
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Preview capture unavailable with the active display driver")
		quit(1)
		return
	var result := image.save_png("/tmp/penguin_dash_preview.png")
	if result != OK:
		push_error("Could not save preview image")
		quit(1)
		return

	game._start_run()
	game.set_process(false)
	game.distance = 386.0
	game.bank = 0.62
	game.fish_count = 4
	game.obstacles.append({"kind": "gate", "progress": 0.28, "checked": false, "spawn_distance": 0.0, "travel_distance": 105.0, "seed": 0.0})
	game.obstacles.append({"kind": "sea_lion", "progress": 0.57, "checked": false, "spawn_distance": 0.0, "travel_distance": 105.0, "seed": 0.0})
	game.obstacles.append({"kind": "fish", "progress": 0.76, "checked": false, "spawn_distance": 0.0, "travel_distance": 105.0, "seed": 0.0})
	game.queue_redraw()
	for i in range(3):
		await process_frame
	var run_image := root.get_texture().get_image()
	if run_image == null or run_image.save_png("/tmp/penguin_dash_gameplay.png") != OK:
		push_error("Could not save gameplay preview")
		quit(1)
		return
	game.state = 2
	game.game_over_age = 1.0
	game.new_best = true
	game.queue_redraw()
	for i in range(3):
		await process_frame
	var medal_image := root.get_texture().get_image()
	if medal_image == null or medal_image.save_png("/tmp/penguin_dash_medal.png") != OK:
		push_error("Could not save medal preview")
		quit(1)
		return
	print("Saved menu, gameplay, and medal previews in /tmp")
	quit(0)
