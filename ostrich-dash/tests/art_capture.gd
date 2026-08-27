extends SceneTree

const DEFAULT_OUTPUT_DIR := "user://art_audit"
const STORE_OUTPUT_DIR := "res://store/google-play/source-captures"

var output_dir := DEFAULT_OUTPUT_DIR

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if "--store-listing" in OS.get_cmdline_user_args():
		output_dir = STORE_OUTPUT_DIR
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	seed(20260823)
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
	var game_manager = root.get_node("GameManager")
	game_manager.save_enabled = false
	if "--powers-only" in OS.get_cmdline_user_args():
		root.size = Vector2i(720, 1280)
		DisplayServer.window_set_size(Vector2i(720, 1280))
		for i in range(10):
			await process_frame
		game.mobile_mode = true
		game.refresh_ad_layout()
		game._start_run()
		game._clear_run_objects()
		var original_skin: int = game_manager.selected_skin
		var power_filenames := ["feather_guard", "moon_magnet", "golden_flock", "bubble_double"]
		for power_index in range(4):
			game_manager.selected_skin = power_index
			game.player.apply_skin(power_index)
			game.power_timer = 0.0
			game.power_charge = 100.0
			game._activate_power()
			game.toast_label.visible = false
			for i in range(8):
				await process_frame
			_save_frame("portrait_power_%s.png" % power_filenames[power_index])
			game.power_timer = 0.0
			game._stop_power_effect()
		game_manager.selected_skin = original_skin
		game.player.apply_skin(original_skin)
		game.queue_free()
		for i in range(6):
			await process_frame
		quit()
		return
	if "--shop-only" in OS.get_cmdline_user_args():
		root.size = Vector2i(720, 1280)
		DisplayServer.window_set_size(Vector2i(720, 1280))
		for i in range(10):
			await process_frame
		game.refresh_ad_layout()
		game._show_shop()
		for i in range(6):
			await process_frame
		_save_frame("portrait_shop.png")
		game.shop_scroll.scroll_vertical = 100000
		for i in range(6):
			await process_frame
		_save_frame("portrait_shop_premium_colors.png")
		root.size = Vector2i(1280, 720)
		DisplayServer.window_set_size(Vector2i(1280, 720))
		for i in range(10):
			await process_frame
		game.refresh_ad_layout()
		game._show_shop()
		for i in range(6):
			await process_frame
		_save_frame("shop.png")
		game.queue_free()
		for i in range(6):
			await process_frame
		quit()
		return
	_save_frame("menu_landscape.png")
	game.mobile_mode = false
	game._start_run()
	game.state = game.GameState.PAUSED
	game.pause_layer.visible = false
	game.hud.visible = true
	for biome_index in range(game.BIOMES.size()):
		game.current_biome = biome_index
		game._apply_biome(biome_index, true)
		game._clear_run_objects()
		game._spawn_obstacle("wall", 0, -8.5)
		game._spawn_obstacle("bar", 1, -15.5)
		game._spawn_obstacle("drone", 2, -22.0)
		for i in range(5):
			game._spawn_feather(1, -6.0 - i * 3.0)
		game.toast_label.visible = false
		for i in range(8):
			await process_frame
		_save_frame("biome_%d_%s.png" % [biome_index, game.BIOMES[biome_index].name.to_lower().replace(" ", "_")])
	if output_dir == STORE_OUTPUT_DIR:
		game.queue_free()
		for i in range(6):
			await process_frame
		quit()
		return
	game.player.run_clock = PI / 24.0
	game.player._animate_run()
	for i in range(4):
		await process_frame
	_save_frame("run_stride_left.png")
	game.player.run_clock += PI / 12.0
	game.player._animate_run()
	for i in range(4):
		await process_frame
	_save_frame("run_stride_right.png")
	# Assign the root Window as well as the native window. The desktop override in
	# project.godot otherwise keeps the capture render target at 1280x720 even
	# though Android correctly supplies its current surface dimensions.
	root.size = Vector2i(720, 1280)
	DisplayServer.window_set_size(Vector2i(720, 1280))
	for i in range(10):
		await process_frame
	game.refresh_ad_layout()
	game.current_biome = 0
	game._apply_biome(0, true)
	game._update_hud()
	_save_frame("portrait_gameplay.png")
	game.mobile_mode = true
	game.power_charge = 100.0
	game._update_hud()
	game._show_toast("CHECKPOINT!  +5 FEATHERS")
	for i in range(4):
		await process_frame
	_save_frame("portrait_goal_and_power_ready.png")
	game.power_charge = 0.0
	game.toast_label.visible = false
	game.mobile_mode = true
	game._show_menu()
	game.refresh_ad_layout()
	for i in range(4):
		await process_frame
	_save_frame("portrait_menu.png")
	game.mobile_mode = false
	game._show_shop()
	for i in range(4):
		await process_frame
	_save_frame("portrait_shop.png")
	game.shop_scroll.scroll_vertical = 100000
	for i in range(6):
		await process_frame
	_save_frame("portrait_shop_premium_colors.png")
	game.shop_layer.visible = false
	game.distance = 1085.0
	game.score = 18740
	game.run_feathers = 22
	game.near_misses = 5
	game.best_combo = 8
	game.last_crash = "trip"
	game._show_results()
	for i in range(6):
		await process_frame
	_save_frame("portrait_results.png")
	game.result_layer.visible = false
	game.menu_layer.visible = false
	game.player.visible = true
	game.hud.visible = true
	game.state = game.GameState.PAUSED
	root.size = Vector2i(1280, 720)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	for i in range(10):
		await process_frame
	game.refresh_ad_layout()
	game.result_layer.visible = true
	for i in range(4):
		await process_frame
	_save_frame("results_landscape.png")
	game.result_layer.visible = false
	# Results intentionally freezes the gameplay SubViewport. Restart the run
	# before the world-space audit frames, then pause gameplay without disabling
	# rendering so obstacle/avoidance captures contain the actual 3D scene.
	game._start_run()
	game.state = game.GameState.PAUSED
	game.pause_layer.visible = false
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
	game._clear_run_objects()
	game.player.visible = true
	game.player.reset_player()
	game._spawn_obstacle("wall", 1, -1.0)
	game.player.jump()
	game.player.position.y = 1.65
	game.player._animate_run(1.0)
	for i in range(4):
		await process_frame
	_save_frame("jump_avoids_hurdle.png")
	game._clear_run_objects()
	game.player.reset_player()
	game._spawn_obstacle("bar", 1, -1.0)
	game.player.duck()
	game.player._animate_run(1.0)
	for i in range(4):
		await process_frame
	_save_frame("duck_neck_fold_under_bar.png")
	game._clear_run_objects()
	game.player.reset_player()
	game._spawn_obstacle("drone", 1, -1.0)
	game.player.duck()
	game.player._animate_run(1.0)
	for i in range(4):
		await process_frame
	_save_frame("duck_clears_flying_hazard.png")
	game._clear_run_objects()
	game.player.reset_player()
	game.player.visible = false
	game._clear_run_objects()
	game._spawn_all_lane_skill_row("jump", -8.0)
	for i in range(8):
		await process_frame
	_save_frame("all_lanes_jump_route.png")
	game._clear_run_objects()
	game._spawn_all_lane_skill_row("duck", -8.0)
	for i in range(8):
		await process_frame
	_save_frame("all_lanes_duck_route.png")
	game._clear_run_objects()
	game._spawn_obstacle("rival", 1, -2.4)
	var rival_item: Dictionary = game.obstacles[-1]
	game.elapsed = 0.0
	rival_item.phase = PI * 0.5
	game._animate_rival_runner(rival_item, 18.0)
	for i in range(4):
		await process_frame
	_save_frame("rival_stride_forward.png")
	rival_item.phase = PI * 1.5
	game._animate_rival_runner(rival_item, 18.0)
	for i in range(4):
		await process_frame
	_save_frame("rival_stride_recovery.png")
	game._clear_run_objects()
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
	var path := "%s/%s" % [output_dir, filename]
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save %s: %s" % [path, error_string(error)])
	else:
		print("ART_CAPTURE %s" % ProjectSettings.globalize_path(path))
