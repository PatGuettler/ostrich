extends SceneTree

const OUTPUT_DIR := "user://art_audit"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var error := change_scene_to_file("res://scenes/main.tscn")
	if error != OK:
		push_error(error_string(error))
		quit(1)
		return
	for i in range(12):
		await process_frame
	var game = current_scene
	game.audio_enabled = false
	root.get_node("GameManager").save_enabled = false
	game.mobile_mode = false
	game._start_run()
	game.state = game.GameState.PAUSED
	game.pause_layer.visible = false
	game.hud.visible = true
	game._clear_run_objects()
	game._spawn_obstacle("wall", 0, -8.5)
	game._spawn_obstacle("drone", 2, -13.0)
	for i in range(5):
		game._spawn_feather(1, -6.0 - i * 3.0)
	for biome_index in range(game.BIOMES.size()):
		game.current_biome = biome_index
		game._apply_biome(biome_index, true)
		game.toast_label.visible = false
		for i in range(8):
			await process_frame
		_save_frame("biome_%d_%s.png" % [biome_index, game.BIOMES[biome_index].name.to_lower().replace(" ", "_")])
	game._apply_biome(0, true)
	game._apply_biome(1)
	game._update_biome_transition(game.BIOME_TRANSITION_DURATION * 0.5)
	game.toast_label.visible = false
	for i in range(8):
		await process_frame
	_save_frame("biome_transition_midpoint.png")
	game._apply_biome(0, true)
	game.toast_label.visible = false
	game.player.visible = false
	game._clear_run_objects()
	game._spawn_obstacle("wall", 0, -5.0)
	game._spawn_obstacle("cone", 1, -5.0)
	game._spawn_obstacle("bar", 2, -5.0)
	for i in range(8):
		await process_frame
	_save_frame("obstacles_ground.png")
	game._clear_run_objects()
	game._spawn_obstacle("drone", 0, -5.0)
	game._spawn_obstacle("slip", 1, -5.0)
	game._spawn_obstacle("rival", 2, -5.0)
	for i in range(8):
		await process_frame
	_save_frame("obstacles_special.png")
	game.player.visible = true
	game._spawn_puff(Vector3(0.0, 2.3, -0.3), Color("#fff0cf"), 24)
	for i in range(16):
		await process_frame
	_save_frame("effects.png")
	game._clear_run_objects()
	game.player.reset_player()
	game.state = game.GameState.RUNNING
	game._trigger_hit(game.player, "wall")
	for i in range(32):
		await process_frame
	_save_frame("trip.png")
	game._clear_run_objects()
	game.player.reset_player()
	game.state = game.GameState.RUNNING
	game._spawn_obstacle("bar", 1, -1.0)
	game._trigger_hit(game.obstacles[-1].node, "bar")
	for i in range(48):
		await process_frame
	_save_frame("bar_flip.png")
	game.state = game.GameState.PAUSED
	game.player.active = false
	game._show_shop()
	game.toast_label.visible = false
	for i in range(8):
		await process_frame
	_save_frame("shop.png")
	game.queue_free()
	for i in range(6):
		await process_frame
	quit()

func _save_frame(filename: String) -> void:
	RenderingServer.force_draw(false, 0.0)
	var image := root.get_texture().get_image()
	var path := "%s/%s" % [OUTPUT_DIR, filename]
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save %s: %s" % [path, error_string(error)])
	else:
		print("ART_CAPTURE %s" % ProjectSettings.globalize_path(path))
