extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var error := change_scene_to_file("res://scenes/main.tscn")
	if error != OK:
		push_error("Could not open main scene: %s" % error_string(error))
		quit(1)
		return
	await process_frame
	await process_frame
	var game := current_scene
	if game == null:
		push_error("Main scene did not instantiate")
		quit(1)
		return
	game.audio_enabled = false
	root.get_node("GameManager").save_enabled = false
	var ad_bar_service: Node = root.get_node_or_null("AdBarService")
	if not is_instance_valid(ad_bar_service):
		push_error("AdBarService autoload is missing")
		quit(1)
		return
	if ad_bar_service.banner_unit_id_for("ostrich_dash", "Android").is_empty():
		push_error("Ostrich Dash is missing its Android test banner unit")
		quit(1)
		return
	if game.PRIVACY_POLICY_URL != "https://patguettler.github.io/privacy-policy.html":
		push_error("Ostrich Dash is not using the shared Grapegames privacy policy")
		quit(1)
		return
	if game.DATA_DELETION_URL != "https://patguettler.github.io/privacy-policy.html#data-deletion":
		push_error("Ostrich Dash data-deletion URL is incorrect")
		quit(1)
		return
	if not is_instance_valid(game.privacy_button) or not game.privacy_button.visible:
		push_error("The menu is missing its Privacy & Data button")
		quit(1)
		return
	if game._ad_bottom_reserve() != 0.0:
		push_error("Desktop/headless play unexpectedly reserves an ad bar")
		quit(1)
		return
	var required_art: Array[String] = []
	required_art.append_array(game.RUNNER_ART_PATHS)
	required_art.append_array([
		game.RIVAL_ART_PATH,
		game.OBSTACLE_ATLAS_PATH,
		game.REWARD_POWER_ATLAS_PATH,
		game.BIOME_PROP_ATLAS_PATH,
		game.EFFECTS_MEDALS_ATLAS_PATH,
		game.SURFACE_ATLAS_PATH,
	])
	required_art.append_array(game.SURFACE_PATHS)
	for art_path in required_art:
		if not FileAccess.file_exists(art_path):
			push_error("Missing generated gameplay art: %s" % art_path)
			quit(1)
			return
	if not is_instance_valid(game.player.character_sprite) or game.player.character_sprite.texture == null:
		push_error("Generated runner art is not active")
		quit(1)
		return
	for mesh in game.player.visual.find_children("*", "MeshInstance3D", true, false):
		if (mesh as MeshInstance3D).visible:
			push_error("Procedural player geometry is still visible")
			quit(1)
			return
	game.validation_ad_reserve = 74.0
	game.refresh_ad_layout()
	await process_frame
	var expected_content_height: float = game.get_viewport().get_visible_rect().size.y - 74.0
	if (
		absf(game.game_viewport_container.offset_bottom + 74.0) > 0.1
		or absf(game.ui_content_root.offset_bottom + 74.0) > 0.1
		or not game.ad_reserve_rect.visible
		or absf(game.game_viewport_container.size.y - expected_content_height) > 1.0
		or absf(game.ui_content_root.size.y - expected_content_height) > 1.0
	):
		push_error(
			"Reserved ad bar layout failed: viewport=%s content=%s offsets=%.1f/%.1f" % [
				game.game_viewport_container.size,
				game.ui_content_root.size,
				game.game_viewport_container.offset_bottom,
				game.ui_content_root.offset_bottom,
			]
		)
		quit(1)
		return
	game.validation_ad_reserve = 0.0
	game.refresh_ad_layout()
	await process_frame
	game._apply_biome(1, true)
	if game.stadium_art_root.visible:
		push_error("Classic stadium artwork remained visible in another biome")
		quit(1)
		return
	if game.biome_art_roots.size() != game.BIOMES.size():
		push_error("Not every biome has a unique background root")
		quit(1)
		return
	for biome_index in range(game.BIOMES.size()):
		game._apply_biome(biome_index, true)
		for art_index in range(game.biome_art_roots.size()):
			if game.biome_art_roots[art_index].visible != (art_index == biome_index):
				push_error("Biome background visibility mismatch")
				quit(1)
				return
	game._apply_biome(0, true)
	if not game.stadium_art_root.visible:
		push_error("Classic stadium artwork did not restore")
		quit(1)
		return
	game._shuffle_biome_sequence()
	var unique_biomes: Dictionary = {}
	for biome_index in game.biome_sequence:
		unique_biomes[biome_index] = true
	if unique_biomes.size() != game.BIOMES.size():
		push_error("Shuffled biome tour contains duplicate backgrounds")
		quit(1)
		return
	game.mobile_mode = true
	game._start_run()
	if game.touch_controls.visible:
		push_error("Mobile mode displayed keyboard-style arrow controls")
		quit(1)
		return
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(600, 420)
	game._unhandled_input(touch)
	touch = InputEventScreenTouch.new()
	touch.pressed = false
	touch.position = Vector2(470, 420)
	game._unhandled_input(touch)
	if game.player.lane != 0:
		push_error("Mobile left swipe did not switch lanes")
		quit(1)
		return
	touch = InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(600, 500)
	game._unhandled_input(touch)
	touch = InputEventScreenTouch.new()
	touch.pressed = false
	touch.position = Vector2(600, 360)
	game._unhandled_input(touch)
	if not game.player.jumping:
		push_error("Mobile upward swipe did not jump")
		quit(1)
		return
	game.player.jumping = false
	game.player.position.y = 0.0
	touch = InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(470, 420)
	game._unhandled_input(touch)
	touch = InputEventScreenTouch.new()
	touch.pressed = false
	touch.position = Vector2(610, 420)
	game._unhandled_input(touch)
	if game.player.lane != 1:
		push_error("Mobile right swipe did not switch lanes")
		quit(1)
		return
	touch = InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(600, 360)
	game._unhandled_input(touch)
	touch = InputEventScreenTouch.new()
	touch.pressed = false
	touch.position = Vector2(600, 500)
	game._unhandled_input(touch)
	if not game.player.ducking:
		push_error("Mobile downward swipe did not duck")
		quit(1)
		return
	game.mobile_mode = false
	game._start_run()
	game._clear_run_objects()
	for kind in ["wall", "bar", "cone", "drone", "slip", "rival"]:
		game._spawn_obstacle(kind, 1, -20.0)
		var spawned: Node3D = game.obstacles[-1].node
		if not _has_sprite_descendant(spawned):
			push_error("Generated obstacle art missing for %s" % kind)
			quit(1)
			return
	game._spawn_feather(1, -18.0)
	if not _has_sprite_descendant(game.feathers[-1].node):
		push_error("Generated feather pickup art is missing")
		quit(1)
		return
	game._show_shop()
	await process_frame
	if game.shop_medal_row.get_child_count() != game.BIOMES.size():
		push_error("Generated medal gallery is incomplete")
		quit(1)
		return
	for card in game.shop_cards.get_children():
		if card.find_children("*", "TextureRect", true, false).is_empty():
			push_error("A shop skin card is missing generated runner art")
			quit(1)
			return
	game._start_run()
	var arrow := InputEventKey.new()
	arrow.pressed = true
	arrow.keycode = KEY_LEFT
	game._input(arrow)
	if game.player.lane != 0:
		push_error("Left arrow did not move the player left")
		quit(1)
		return
	arrow = InputEventKey.new()
	arrow.pressed = true
	arrow.keycode = KEY_RIGHT
	game._input(arrow)
	if game.player.lane != 1:
		push_error("Right arrow did not move the player right")
		quit(1)
		return
	arrow = InputEventKey.new()
	arrow.pressed = true
	arrow.keycode = KEY_UP
	game._input(arrow)
	if not game.player.jumping:
		push_error("Up arrow did not make the player jump")
		quit(1)
		return
	game.player.jumping = false
	game.player.position.y = 0.0
	arrow = InputEventKey.new()
	arrow.pressed = true
	arrow.keycode = KEY_DOWN
	game._input(arrow)
	if not game.player.ducking:
		push_error("Down arrow did not make the player duck")
		quit(1)
		return
	game.player.ducking = false
	for frame in range(720):
		if frame % 95 == 0:
			game.player.jump()
		if frame % 140 == 0:
			game._move_player(1 if int(frame / 140.0) % 2 == 0 else -1)
		if frame % 175 == 0:
			game.player.duck()
		await process_frame
	game._start_run()
	game._trigger_hit(game.player, "wall")
	for frame in range(120):
		await process_frame
	if game.state != game.GameState.RESULTS or game.last_crash != "trip":
		push_error("Foot-level collision did not produce trip results")
		quit(1)
		return
	game._start_run()
	game._trigger_hit(game.player, "bar")
	for frame in range(120):
		await process_frame
	if game.state != game.GameState.RESULTS or game.last_crash != "spin":
		push_error("Elevated bar collision did not produce spin results")
		quit(1)
		return
	print("SMOKE_OK state=%s distance=%.1f obstacles=%d feathers=%d" % [game.state, game.distance, game.obstacles.size(), game.run_feathers])
	game.sfx_player.stop()
	game.sfx_player.stream = null
	game.pickup_sound = null
	game.honk_sound = null
	game.trip_sound = null
	game.success_sound = null
	game.queue_free()
	for i in range(12):
		await process_frame
	quit(0)

func _has_sprite_descendant(node: Node) -> bool:
	return not node.find_children("*", "Sprite3D", true, false).is_empty()
