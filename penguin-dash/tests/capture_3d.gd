extends SceneTree


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(540, 960)
	var game = load("res://main_3d.tscn").instantiate()
	root.add_child(game)
	for i in range(8):
		await process_frame
	var menu_image := root.get_texture().get_image()
	if menu_image == null or menu_image.save_png("/tmp/penguin_dash_3d_menu.png") != OK:
		push_error("Could not save 3D menu preview")
		quit(1)
		return

	game._start_run()
	game.set_process(false)
	game.distance = 42.0
	game._place_player(true)
	game._update_camera(1.0, true)
	game._update_ui()
	for i in range(6):
		await process_frame
	var run_image := root.get_texture().get_image()
	if run_image == null or run_image.save_png("/tmp/penguin_dash_3d_gameplay.png") != OK:
		push_error("Could not save 3D gameplay preview")
		quit(1)
		return
	print("Saved 3D menu and gameplay previews in /tmp")
	game.queue_free()
	await process_frame
	quit(0)

