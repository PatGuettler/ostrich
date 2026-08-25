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
	if not game.menu_panel.is_ancestor_of(game.privacy_button):
		push_error("Privacy & Data must be a quiet footer inside the menu, not a top-corner overlay")
		quit(1)
		return
	if game._ad_bottom_reserve() != 0.0:
		push_error("Desktop/headless play unexpectedly reserves an ad bar")
		quit(1)
		return
	var required_art: Array[String] = []
	required_art.append_array(game.RUNNER_ART_PATHS)
	required_art.append_array(game.RUNNER_GAMEPLAY_ART_PATHS)
	required_art.append_array(game.player.BODY_TEXTURE_PATHS)
	required_art.append_array([
		game.RIVAL_ART_PATH,
		game.OBSTACLE_ATLAS_PATH,
		game.REWARD_POWER_ATLAS_PATH,
		game.BIOME_PROP_ATLAS_PATH,
		game.EFFECTS_MEDALS_ATLAS_PATH,
		game.SURFACE_ATLAS_PATH,
		game.MENU_LOGO_PATH,
		game.UI_FONT_PATH,
		game.UI_FONT_BOLD_PATH,
	])
	required_art.append_array(game.SURFACE_PATHS)
	for art_path in required_art:
		if not FileAccess.file_exists(art_path):
			push_error("Missing generated gameplay art: %s" % art_path)
			quit(1)
			return
	for surface_path in game.SURFACE_PATHS:
		var surface_texture := load(surface_path) as Texture2D
		if surface_texture == null or surface_texture.get_width() < 1200 or surface_texture.get_height() < 1200:
			push_error("Gameplay surface is not using the high-detail production asset: %s" % surface_path)
			quit(1)
			return
	var logo_texture := load(game.MENU_LOGO_PATH) as Texture2D
	var logo_image := logo_texture.get_image() if logo_texture != null else null
	if logo_image == null or logo_image.is_empty() or logo_image.detect_alpha() == Image.ALPHA_NONE:
		push_error("The startup-menu logo is missing its transparent background")
		quit(1)
		return
	if (
		not is_instance_valid(game.menu_logo)
		or game.menu_logo.texture == null
		or game.menu_logo.texture.resource_path != game.MENU_LOGO_PATH
		or game.start_button.text != "PLAY NOW"
		or game.start_button.get_theme_font("font") == null
	):
		push_error("The modern startup-menu logo, CTA, or bundled display font is not active")
		quit(1)
		return
	if not is_instance_valid(game.player.character_sprite) or game.player.character_sprite.texture == null:
		push_error("Generated runner art is not active")
		quit(1)
		return
	if not game.player.character_sprite.texture.resource_path.ends_with("_back.png"):
		push_error("Gameplay runner is not using a rear-facing follow-camera plate")
		quit(1)
		return
	if (
		not game.player.character_sprite.texture.resource_path.ends_with("_body_back.png")
		or not is_instance_valid(game.player.left_leg_sprite)
		or not is_instance_valid(game.player.right_leg_sprite)
	):
		push_error("Gameplay runner is missing its independently animated leg layers")
		quit(1)
		return
	for skin_index in range(game.player.BODY_TEXTURE_PATHS.size()):
		game.player.apply_skin(skin_index)
		var expected_body: String = game.player.BODY_TEXTURE_PATHS[skin_index]
		var expected_legs: String = game.player.SKIN_TEXTURE_PATHS[skin_index]
		var left_leg_texture: Texture2D = (game.player.left_leg_sprite.material_override as ShaderMaterial).get_shader_parameter("leg_texture")
		if (
			game.player.character_sprite.texture.resource_path != expected_body
			or left_leg_texture.resource_path != expected_legs
		):
			push_error("Runner skin did not update both its body and animated leg layers")
			quit(1)
			return
	game.player.apply_skin(0)
	for mesh in game.player.visual.find_children("*", "MeshInstance3D", true, false):
		if (mesh as MeshInstance3D).visible:
			push_error("Procedural player geometry is still visible")
			quit(1)
			return
	if int(ProjectSettings.get_setting("display/window/handheld/orientation", -1)) != DisplayServer.SCREEN_SENSOR:
		push_error("Android orientation is not set to unrestricted sensor rotation")
		quit(1)
		return
	# Exercise a real root-window resize instead of only calling the layout helper.
	# This catches incorrect anchor offsets that can look valid by size but render
	# partly off-screen on a portrait Android surface.
	root.size = Vector2i(720, 1280)
	await process_frame
	await process_frame
	game.validation_ad_reserve = 74.0
	game.refresh_ad_layout()
	await process_frame
	var portrait_viewport_size := game.get_viewport().get_visible_rect().size
	var expected_content_height: float = portrait_viewport_size.y - 74.0
	if (
		absf(game.game_viewport_container.offset_bottom + 74.0) > 0.1
		or absf(game.ui_content_root.offset_bottom + 74.0) > 0.1
		or not game.ad_reserve_rect.visible
		or absf(game.game_viewport_container.size.y - expected_content_height) > 1.0
		or absf(game.ui_content_root.size.y - expected_content_height) > 1.0
		or not game.portrait_layout
		or game.camera.fov < 80.0
		or game.hud_stats.columns != 3
		or game.goal_label.text.is_empty()
		or game.goal_progress.max_value != game.BIOME_DISTANCE
		or game.power_bar.get_parent() != game.power_button
		or game.power_button.position.x + game.power_button.size.x > portrait_viewport_size.x
		or game.power_button.position.y + game.power_button.size.y > expected_content_height
		or game.shop_cards.columns != 2
		or game.menu_panel.position.x < 0.0
		or game.menu_panel.position.y < 0.0
		or game.menu_panel.position.x + game.menu_panel.size.x > portrait_viewport_size.x
		or game.menu_panel.size.x < portrait_viewport_size.x * 0.8
		or game.start_button.custom_minimum_size.y < 120.0
		or game.start_button.get_theme_stylebox("normal").corner_radius_top_left < 24
		or game.shop_panel.position.x < 0.0
		or game.shop_panel.position.y < 0.0
		or game.shop_panel.position.x + game.shop_panel.size.x > portrait_viewport_size.x
		or game.shop_panel.position.y + game.shop_panel.size.y > expected_content_height
	):
		push_error(
			"Portrait/ad-safe layout failed: viewport=%s content=%s offsets=%.1f/%.1f" % [
				game.game_viewport_container.size,
				game.ui_content_root.size,
				game.game_viewport_container.offset_bottom,
				game.ui_content_root.offset_bottom,
			]
		)
		quit(1)
		return
	game._show_toast("CHECKPOINT!  +5 FEATHERS")
	await process_frame
	if (
		game.toast_label.position.x < 0.0
		or game.toast_label.position.x + game.toast_label.size.x > portrait_viewport_size.x
		or game.toast_label.position.y < game.hud_top_panel.position.y + game.hud_top_panel.size.y
		or game.toast_label.position.y + game.toast_label.size.y > expected_content_height
	):
		push_error("Portrait checkpoint popup leaves the visible ad-safe play area")
		quit(1)
		return
	game.toast_label.visible = false
	game._show_shop()
	await process_frame
	await process_frame
	var portrait_cards: Array[Node] = game.shop_cards.get_children()
	var portrait_medals: Array[Node] = game.shop_medal_row.get_children()
	if (
		game.shop_heading.text != "CHOOSE YOUR RUNNER"
		or portrait_cards.size() != GameManager.SKINS.size()
		or portrait_medals.size() != game.BIOMES.size()
		or portrait_cards.is_empty()
		or portrait_medals.is_empty()
		or not (portrait_medals[0] is PanelContainer)
		or (portrait_cards[0] as Control).custom_minimum_size.x < 390.0
		or (portrait_cards[0].get_node("CardMargin/CardBox/PortraitBubble/RunnerPortrait") as TextureRect) == null
		or (portrait_cards[0].get_node("CardMargin/CardBox/RunnerAction") as Button).get_theme_font_size("font_size") < 22
		or game.shop_panel.position.y < 0.0
		or game.shop_panel.position.y + game.shop_panel.size.y > expected_content_height
	):
		push_error("Portrait shop is not using its large, bubbly, ad-safe presentation")
		quit(1)
		return
	root.size = Vector2i(1280, 720)
	await process_frame
	await process_frame
	game.validation_ad_reserve = 0.0
	game.refresh_ad_layout()
	await process_frame
	if (
		game.portrait_layout
		or absf(game.camera.fov - 63.0) > 0.1
		or game.hud_stats.columns != 3
		or game.shop_cards.columns != 4
	):
		push_error("Landscape layout did not restore its wide-screen camera and grids")
		quit(1)
		return
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
		var vista := game.biome_art_roots[biome_index].get_child(0) as Sprite3D
		if vista == null or vista.scale.x + 0.001 < game.VISTA_OVERSCAN or vista.scale.y + 0.001 < game.VISTA_OVERSCAN:
			push_error("Biome vista does not overscan the camera frame")
			quit(1)
			return
	game._apply_biome(0, true)
	if not game.stadium_art_root.visible:
		push_error("Classic stadium artwork did not restore")
		quit(1)
		return
	if game.stadium_art_root.get_child_count() != 1 or game.stadium_art_root.get_child(0).name != "StadiumVista":
		push_error("Classic stadium contains duplicate layered artwork")
		quit(1)
		return
	if game.prop_root.get_child_count() != 0:
		push_error("Classic stadium contains duplicate foreground prop plates")
		quit(1)
		return
	game._apply_biome(1)
	if (
		not game.biome_transition_active
		or not game.biome_art_roots[0].visible
		or not game.biome_art_roots[1].visible
	):
		push_error("Biome change did not begin as a two-vista gradual transition")
		quit(1)
		return
	game._update_biome_transition(game.BIOME_TRANSITION_DURATION * 0.5)
	var transition_vista := game.biome_art_roots[1].get_child(0) as Sprite3D
	var vista_progress: float = game.transition_vista_material.get_shader_parameter("transition_progress")
	var surface_blend: float = game.transition_road_material.get_shader_parameter("blend_amount")
	if transition_vista.material_override == null or vista_progress < 0.4 or vista_progress > 0.44 or surface_blend < 0.45 or surface_blend > 0.55:
		push_error("Biome vista and track did not blend together at transition midpoint")
		quit(1)
		return
	game._update_biome_transition(game.BIOME_TRANSITION_DURATION * 0.5 + 0.01)
	if game.biome_transition_active or game.biome_art_roots[0].visible or not game.biome_art_roots[1].visible:
		push_error("Biome transition did not settle cleanly on the incoming vista")
		quit(1)
		return
	game._apply_biome(0, true)
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
	_dispatch_swipe(game, Vector2(600, 420), Vector2(470, 420), 7, true)
	if game.player.lane != 0:
		push_error("Mobile left swipe did not switch lanes")
		quit(1)
		return
	_dispatch_swipe(game, Vector2(600, 500), Vector2(600, 360), 7, true)
	if not game.player.jumping:
		push_error("Mobile upward swipe did not jump")
		quit(1)
		return
	game.player.jumping = false
	game.player.position.y = 0.0
	_dispatch_swipe(game, Vector2(470, 420), Vector2(610, 420), 12, true)
	if game.player.lane != 1:
		push_error("Mobile right swipe did not switch lanes")
		quit(1)
		return
	_dispatch_swipe(game, Vector2(600, 360), Vector2(600, 500), 12, true)
	if not game.player.ducking:
		push_error("Mobile downward swipe did not duck")
		quit(1)
		return
	game.player.ducking = false
	_dispatch_swipe(game, Vector2(620, 420), Vector2(500, 420), 4, false)
	if game.player.lane != 0:
		push_error("Mobile release-only swipe did not switch lanes")
		quit(1)
		return
	_dispatch_swipe(game, Vector2(500, 420), Vector2(620, 420), 4, false)
	if game.player.lane != 1:
		push_error("Mobile release-only swipe did not restore the lane")
		quit(1)
		return
	# Reproduce Android's real dispatch order: a full-screen GUI control consumes
	# the event after _input(), so a swipe implemented only in _unhandled_input()
	# would fail this integration check.
	var gui_blocker := Control.new()
	gui_blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gui_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	game.add_child(gui_blocker)
	var pipeline_touch := InputEventScreenTouch.new()
	pipeline_touch.index = 9
	pipeline_touch.pressed = true
	pipeline_touch.position = Vector2(640, 430)
	game.get_viewport().push_input(pipeline_touch, true)
	var pipeline_drag := InputEventScreenDrag.new()
	pipeline_drag.index = 9
	pipeline_drag.position = Vector2(500, 430)
	pipeline_drag.relative = Vector2(-140, 0)
	game.get_viewport().push_input(pipeline_drag, true)
	pipeline_touch = InputEventScreenTouch.new()
	pipeline_touch.index = 9
	pipeline_touch.pressed = false
	pipeline_touch.position = Vector2(500, 430)
	game.get_viewport().push_input(pipeline_touch, true)
	await process_frame
	gui_blocker.queue_free()
	if game.player.lane != 0:
		push_error("Android-style swipe was swallowed by the GUI input layer")
		quit(1)
		return
	game.mobile_mode = false
	game._start_run()
	if game.touch_controls.visible or game.touch_controls.get_child_count() != 0:
		push_error("Desktop mode displayed on-screen arrow controls")
		quit(1)
		return
	game.player.run_clock = PI / 24.0
	game.player._animate_run()
	var left_stride_a: float = game.player.left_stride_pivot.rotation.x
	var right_stride_a: float = game.player.right_stride_pivot.rotation.x
	game.player.run_clock += PI / 12.0
	game.player._animate_run()
	if (
		left_stride_a * game.player.left_stride_pivot.rotation.x >= 0.0
		or right_stride_a * game.player.right_stride_pivot.rotation.x >= 0.0
		or left_stride_a * right_stride_a >= 0.0
		or absf(left_stride_a) < 0.45
		or absf(right_stride_a) < 0.45
	):
		push_error("Runner leg layers did not alternate through a readable stride")
		quit(1)
		return
	game._clear_run_objects()
	for kind in ["wall", "bar", "cone", "drone", "slip", "rival"]:
		game._spawn_obstacle(kind, 1, -20.0)
		var spawned: Node3D = game.obstacles[-1].node
		if not _has_sprite_descendant(spawned):
			push_error("Generated obstacle art missing for %s" % kind)
			quit(1)
			return
		if kind == "bar":
			var gate_art := spawned.get_node("GeneratedBarArt") as Sprite3D
			if gate_art.position.y < 2.8 or gate_art.scale.y < 1.25:
				push_error("Duck-under gate is not visually tall enough")
				quit(1)
				return
		elif kind == "rival":
			var rival_item: Dictionary = game.obstacles[-1]
			var left_pivot := spawned.get_node_or_null("RivalRunningVisual/RivalLeftStride") as Node3D
			var right_pivot := spawned.get_node_or_null("RivalRunningVisual/RivalRightStride") as Node3D
			var rival_shadow := spawned.get_node_or_null("RivalGroundShadow") as MeshInstance3D
			if left_pivot == null or right_pivot == null or rival_shadow == null:
				push_error("Rival ostrich is missing its running rig or planted shadow")
				quit(1)
				return
			game.elapsed = 0.0
			rival_item.phase = PI * 0.5
			game._animate_rival_runner(rival_item, 18.0)
			var rival_left_stride_a: float = left_pivot.rotation.x
			var rival_right_stride_a: float = right_pivot.rotation.x
			rival_item.phase = PI * 1.5
			game._animate_rival_runner(rival_item, 18.0)
			if (
				rival_left_stride_a * left_pivot.rotation.x >= 0.0
				or rival_right_stride_a * right_pivot.rotation.x >= 0.0
				or rival_left_stride_a * rival_right_stride_a >= 0.0
				or absf(rival_left_stride_a) < 0.55
			):
				push_error("Rival ostrich leg layers did not alternate through a running stride")
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
	if game.spawn_meter < 20.0:
		push_error("A new run does not provide enough space before its first obstacle")
		quit(1)
		return
	game.distance = game.BIOME_DISTANCE + 1.0
	game._update_run(0.0)
	if (
		game.checkpoint_stage != 1
		or game.run_feathers != game.CHECKPOINT_REWARD
		or game.goal_progress.value <= 0.0
		or "NEXT:" not in game.goal_detail_label.text
	):
		push_error("Biome checkpoint did not award progress or update the visible run goal")
		quit(1)
		return
	game.run_feathers = 0
	game.checkpoint_stage = 0
	game.distance = 0.0
	for i in range(12):
		var early_gap: float = game._next_spawn_gap()
		if early_gap < game.SPAWN_GAP_MIN or early_gap > game.SPAWN_GAP_MAX:
			push_error("Early obstacle spacing fell outside the relaxed range")
			quit(1)
			return
	game.distance = 3000.0
	for i in range(12):
		var late_gap: float = game._next_spawn_gap()
		if late_gap < game.SPAWN_GAP_MIN - game.SPAWN_GAP_RAMP_REDUCTION or late_gap > game.SPAWN_GAP_MAX - game.SPAWN_GAP_RAMP_REDUCTION:
			push_error("Late obstacle spacing became too dense")
			quit(1)
			return
	game.distance = 0.0
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
	for frame in range(50):
		await process_frame
	if (
		game.player.character_sprite.position.y < 5.25
		or game.player.character_sprite.scale.y > -0.85
		or absf(game.player.character_sprite.position.x) > 0.05
		or absf(game.player.character_sprite.rotation.z) > 0.05
	):
		push_error("Tall-gate collision did not project the feet forward and overhead")
		quit(1)
		return
	for frame in range(80):
		await process_frame
	if game.state != game.GameState.RESULTS or game.last_crash != "bar_flip":
		push_error("Elevated bar collision did not complete the neck-pivot flip")
		quit(1)
		return
	if absf(game.player.character_sprite.position.y - 2.15) > 0.05 or absf(game.player.character_sprite.rotation.z) > 0.12:
		push_error("Tall-gate flip did not return the runner's feet to the ground")
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

func _dispatch_swipe(game: Node, start: Vector2, finish: Vector2, finger: int, include_drag: bool) -> void:
	var touch := InputEventScreenTouch.new()
	touch.index = finger
	touch.pressed = true
	touch.position = start
	game._input(touch)
	if include_drag:
		var drag := InputEventScreenDrag.new()
		drag.index = finger
		drag.position = finish
		drag.relative = finish - start
		game._input(drag)
		# Android can send several drag samples after the threshold. A gesture must
		# still perform exactly one action before the finger is released.
		drag = InputEventScreenDrag.new()
		drag.index = finger
		drag.position = finish + (finish - start).normalized() * 30.0
		drag.relative = (finish - start).normalized() * 30.0
		game._input(drag)
	touch = InputEventScreenTouch.new()
	touch.index = finger
	touch.pressed = false
	touch.position = finish
	game._input(touch)
