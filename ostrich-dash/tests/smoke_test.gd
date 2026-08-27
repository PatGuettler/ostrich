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
	var game_manager: Node = root.get_node("GameManager")
	game_manager.save_enabled = false
	var wardrobe_cost := 0
	for skin_cost in game_manager.SKIN_COSTS:
		wardrobe_cost += int(skin_cost)
	if (
		game_manager.SKINS.size() < 12
		or game_manager.SKIN_COSTS.size() != game_manager.SKINS.size()
		or game_manager.SKIN_COSTS[1] < 25000
		or game_manager.SKIN_COSTS[-1] < 5000000
		or wardrobe_cost < 15050000
	):
		push_error("The prestige wardrobe economy is missing or too inexpensive")
		quit(1)
		return
	for skin_index in range(1, game_manager.SKIN_COSTS.size()):
		if game_manager.SKIN_COSTS[skin_index] <= game_manager.SKIN_COSTS[skin_index - 1]:
			push_error("Skin prices must increase with each rarer color")
			quit(1)
			return
	var ad_bar_service: Node = root.get_node_or_null("AdBarService")
	if not is_instance_valid(ad_bar_service):
		push_error("AdBarService autoload is missing")
		quit(1)
		return
	var leaderboard_service: Node = root.get_node_or_null("LeaderboardService")
	if (
		not is_instance_valid(leaderboard_service)
		or leaderboard_service.available
		or not leaderboard_service.leaderboard_id.is_empty()
		or leaderboard_service.begin_global_scores() != "setup"
	):
		push_error("The optional Play Games leaderboard service is missing or unsafe without release IDs")
		quit(1)
		return
	game._show_global_scores()
	await process_frame
	if not is_instance_valid(game.scores_layer) or not game.scores_layer.visible:
		push_error("GLOBAL SCORES should open the in-app scores panel")
		quit(1)
		return
	if game.toast_label.visible and "PLAY GAMES SETUP" not in game.toast_label.text:
		push_error("GLOBAL SCORES should show the Play Games setup toast when release IDs are blank")
		quit(1)
		return
	game._hide_global_scores()
	if bool(ProjectSettings.get_setting("application/config/quit_on_go_back", true)):
		push_error("Android native back is still configured to quit the app")
		quit(1)
		return
	if game.BIOMES.size() < 12 or game_manager.biome_bests.size() != game.BIOMES.size():
		push_error("The expanded twelve-biome tour is incomplete")
		quit(1)
		return
	if (
		game.BIOME_BACKDROP_PATHS.size() != game.BIOMES.size()
		or game.SURFACE_PATHS.size() != game.BIOMES.size()
		or game.OBSTACLE_ATLAS_PATHS.size() != game.BIOMES.size()
	):
		push_error("Every biome needs its own vista, track surface, and obstacle style")
		quit(1)
		return
	var unique_obstacle_atlases := {}
	for obstacle_atlas_path in game.OBSTACLE_ATLAS_PATHS:
		unique_obstacle_atlases[obstacle_atlas_path] = true
	if unique_obstacle_atlases.size() != game.BIOMES.size():
		push_error("Biome obstacle art is being reused instead of matching each environment")
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
	if (
		not is_instance_valid(game.music_toggle_button)
		or not is_instance_valid(game.music_player)
		or game.background_music == null
		or game.background_music.loop_mode != AudioStreamWAV.LOOP_FORWARD
		or "MUSIC" not in game.music_toggle_button.text
		or not game.menu_panel.is_ancestor_of(game.music_toggle_button)
	):
		push_error("The original looping background music or its in-menu toggle is missing")
		quit(1)
		return
	var initial_music_enabled: bool = game_manager.music_enabled
	game._toggle_music()
	if game_manager.music_enabled == initial_music_enabled or ("OFF" in game.music_toggle_button.text) == game_manager.music_enabled:
		push_error("Music toggle did not immediately update its saved setting and playback")
		quit(1)
		return
	game._toggle_music()
	if game_manager.music_enabled != initial_music_enabled or ("ON" in game.music_toggle_button.text) != initial_music_enabled:
		push_error("Music toggle did not restore its original playback state")
		quit(1)
		return
	if game._ad_bottom_reserve() != 0.0:
		push_error("Desktop/headless play unexpectedly reserves an ad bar")
		quit(1)
		return
	var required_art: Array[String] = []
	required_art.append_array(game.RUNNER_ART_PATHS)
	required_art.append_array(game.player.SKIN_TEXTURE_PATHS)
	required_art.append_array(game.player.BODY_TEXTURE_PATHS)
	required_art.append_array(game.player.DUCK_TEXTURE_PATHS)
	required_art.append_array(game.player.JUMP_TEXTURE_PATHS)
	required_art.append_array([
		game.RIVAL_ART_PATH,
		game.OBSTACLE_ATLAS_PATH,
		game.REWARD_POWER_ATLAS_PATH,
		game.BIOME_PROP_ATLAS_PATH,
		game.EFFECTS_MEDALS_ATLAS_PATH,
		game.MENU_LOGO_PATH,
		game.UI_FONT_PATH,
		game.UI_FONT_BOLD_PATH,
		game.player.RUN_LEG_SHEET_PATH,
	])
	required_art.append_array(game.SURFACE_PATHS)
	required_art.append_array(game.BIOME_BACKDROP_PATHS)
	required_art.append_array(game.OBSTACLE_ATLAS_PATHS)
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
	for obstacle_atlas_path in game.OBSTACLE_ATLAS_PATHS:
		var obstacle_texture := load(obstacle_atlas_path) as Texture2D
		var obstacle_image := obstacle_texture.get_image() if obstacle_texture != null else null
		if obstacle_texture == null or obstacle_texture.get_width() < 1500 or obstacle_image == null or obstacle_image.detect_alpha() == Image.ALPHA_NONE:
			push_error("Biome obstacle atlas is missing production detail or transparency: %s" % obstacle_atlas_path)
			quit(1)
			return
	var logo_texture := load(game.MENU_LOGO_PATH) as Texture2D
	var logo_image := logo_texture.get_image() if logo_texture != null else null
	if logo_image == null or logo_image.is_empty() or logo_image.detect_alpha() == Image.ALPHA_NONE:
		push_error("The startup-menu logo is missing its transparent background")
		quit(1)
		return
	var leg_sheet_texture := load(game.player.RUN_LEG_SHEET_PATH) as Texture2D
	var leg_sheet_image := leg_sheet_texture.get_image() if leg_sheet_texture != null else null
	if (
		leg_sheet_texture == null
		or leg_sheet_texture.get_width() != 1536
		or leg_sheet_texture.get_height() != 1024
		or leg_sheet_image == null
		or leg_sheet_image.detect_alpha() == Image.ALPHA_NONE
	):
		push_error("The six-pose runner leg sheet is missing, malformed, or not transparent")
		quit(1)
		return
	for pose_path in game.player.DUCK_TEXTURE_PATHS + game.player.JUMP_TEXTURE_PATHS:
		var pose_texture := load(pose_path) as Texture2D
		var pose_image := pose_texture.get_image() if pose_texture != null else null
		if pose_texture == null or pose_image == null or pose_image.detect_alpha() == Image.ALPHA_NONE:
			push_error("Authored jump/duck pose is missing transparent production art: %s" % pose_path)
			quit(1)
			return
	if (
		not is_instance_valid(game.player.duck_sprite)
		or not is_instance_valid(game.player.jump_sprite)
		or not game.player.ground_shadow.top_level
	):
		push_error("The player is missing its authored avoidance poses or grounded jump shadow")
		quit(1)
		return
	game.player.reset_player()
	game.player.duck()
	for pose_step in range(5):
		game.player._animate_run(0.1)
	if (
		not game.player.duck_sprite.visible
		or game.player.duck_pose_blend < 0.99
		or game.player.run_leg_sprite.visible
		or game.player.run_leg_sprite.frame != 2
		or game.player.duck_sprite.scale.y > 0.65
		or game.player.duck_sprite.position.y > 1.05
		or game.player.character_sprite.modulate.a > 0.01
		or game.player.neck.rotation.x > -0.7
		or game.player.collision_height() > 2.0
	):
		push_error("Duck input does not produce the low, neck-folded authored crouch")
		quit(1)
		return
	game.player.reset_player()
	game.player.jump()
	game.player.step(0.1)
	game.player._animate_run(0.1)
	if (
		not game.player.jump_sprite.visible
		or game.player.jump_pose_blend < 0.99
		or game.player.run_leg_sprite.visible
		or game.player.run_leg_sprite.frame != 2
		or game.player.position.y < 0.7
		or absf(game.player.ground_shadow.global_position.y - 0.055) > 0.02
		or game.player.ground_shadow.scale.x > 0.9
	):
		push_error("Jump input does not show the tucked airborne pose with a planted shrinking shadow")
		quit(1)
		return
	game.player.reset_player()
	if not game.player.run_leg_sprite.visible:
		push_error("Run legs did not resume after the avoidance pose ended")
		quit(1)
		return
	game._clear_run_objects()
	game.current_biome = 0
	game._spawn_obstacle("drone", 1, -2.0)
	var drone_art := game.obstacles[-1].node.get_node_or_null("GeneratedDroneArt") as Sprite3D
	if drone_art == null or drone_art.position.y < 3.4:
		push_error("Flying hazards are not visibly raised above the folded duck pose")
		quit(1)
		return
	game._clear_run_objects()
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
		or not is_instance_valid(game.player.run_leg_sprite)
		or game.player.run_leg_sprite.texture.resource_path != game.player.RUN_LEG_SHEET_PATH
		or game.player.run_leg_sprite.hframes != 3
		or game.player.run_leg_sprite.vframes != 2
	):
		push_error("Gameplay runner is missing its generated six-pose leg cycle")
		quit(1)
		return
	if (
		not is_instance_valid(game.power_effect_root)
		or game.power_effect_root.get_parent() != game.player
		or not is_instance_valid(game.power_effect_shell)
		or game.power_effect_rings.size() < 2
		or game.power_effect_icons.size() < 3
	):
		push_error("The runner is missing its attached full-duration power aura rig")
		quit(1)
		return
	var original_skin: int = game_manager.selected_skin
	var seen_power_icons := {}
	var seen_power_colors := {}
	var seen_ability_kinds := {}
	if game_manager.RUNNER_ABILITIES.size() != game_manager.SKINS.size():
		push_error("Every unlockable runner must have exactly one built-in gift")
		quit(1)
		return
	for ability_index in range(1, game_manager.RUNNER_ABILITIES.size()):
		var previous: Dictionary = game_manager.RUNNER_ABILITIES[ability_index - 1]
		var current: Dictionary = game_manager.RUNNER_ABILITIES[ability_index]
		if (
			float(current.duration) <= float(previous.duration)
			or float(current.start_charge) <= float(previous.start_charge)
			or float(current.charge_rate) <= float(previous.charge_rate)
		):
			push_error("Runner gifts must become progressively easier to charge and longer-lasting")
			quit(1)
			return
	for ability in game_manager.RUNNER_ABILITIES:
		seen_ability_kinds[int(ability.kind)] = true
		if int(ability.get("icon_cell", -1)) < 0 or int(ability.get("icon_cell", -1)) >= 6 or str(ability.get("description", "")).is_empty():
			push_error("Every runner gift needs valid buddy art and a readable explanation")
			quit(1)
			return
	if seen_ability_kinds.size() < 8 or not seen_ability_kinds.has(game_manager.ABILITY_DOUBLE_JUMP):
		push_error("The runner collection does not offer enough distinct gifts, including double jump")
		quit(1)
		return
	game.state = game.GameState.RUNNING
	game.player.visible = true
	for power_index in range(4):
		game_manager.selected_skin = power_index
		game.player.apply_skin(power_index)
		game.power_charge = 100.0
		game.power_timer = 0.0
		game.elapsed = 0.75 + float(power_index)
		game._activate_power()
		game._update_power_effect(0.016)
		var power_icon_texture := game.power_effect_icons[0].texture as AtlasTexture
		var power_material := game.power_effect_shell.material_override as StandardMaterial3D
		if (
			not game.power_effect_root.visible
			or game.power_timer <= 0.0
			or power_icon_texture == null
			or power_material == null
		):
			push_error("Power %d did not create a visible runner-following effect" % power_index)
			quit(1)
			return
		seen_power_icons[str(power_icon_texture.region)] = true
		seen_power_colors[power_material.emission.to_html()] = true
		game.power_timer = 0.01
		game._update_power(0.02)
		if game.power_effect_root.visible:
			push_error("Power %d effect remained after its gameplay timer expired" % power_index)
			quit(1)
			return
	if seen_power_icons.size() != 4 or seen_power_colors.size() != 4:
		push_error("Power effects do not have four distinct generated icons and aura colors")
		quit(1)
		return

	# Bubblegum and Celestial must change the real jump rules, not merely display
	# double-jump text in the shop.
	game_manager.selected_skin = 3
	game.player.reset_player()
	game.power_charge = 100.0
	game.power_timer = 0.0
	game._activate_power()
	var first_jump: bool = game._try_jump()
	game.player.step(0.08)
	var second_jump: bool = game._try_jump()
	var third_jump: bool = game._try_jump()
	if not first_jump or not second_jump or third_jump or game.player.jumps_used != 2 or game.player.jump_velocity < 10.0:
		push_error("Bubble Double did not provide exactly one responsive midair jump")
		quit(1)
		return

	# Golden Flock is a mechanical reward multiplier.
	game_manager.selected_skin = 2
	game.player.apply_skin(2)
	game.power_timer = 2.0
	game.run_feathers = 0
	game.combo = 2
	game._spawn_feather(1, -8.0)
	var frenzy_feather: Dictionary = game.feathers[-1]
	game._collect_feather(frenzy_feather)
	if game.run_feathers != 4:
		push_error("Golden Flock did not double collected feather rewards")
		quit(1)
		return

	# Aurora Glide must reduce airborne gravity for a visibly longer jump.
	game_manager.selected_skin = 4
	game.player.reset_player()
	game.power_timer = 2.0
	game.player.jump()
	game.player.step(0.1, game._player_gravity_scale())
	if game.player.jump_velocity < 9.6:
		push_error("Aurora Glide did not create a slower, floatier fall")
		quit(1)
		return
	game_manager.selected_skin = game_manager.RUNNER_ABILITIES.size() - 1
	game.power_charge = 0.0
	game._clean_dodge(false)
	var prestige_charge: float = game.power_charge
	game_manager.selected_skin = 0
	game.power_charge = 0.0
	game._clean_dodge(false)
	if prestige_charge <= game.power_charge:
		push_error("Prestige runners do not recharge their built-in gifts faster")
		quit(1)
		return
	game_manager.selected_skin = original_skin
	game.player.apply_skin(original_skin)
	game._show_menu()
	for skin_index in range(game.player.BODY_TEXTURE_PATHS.size()):
		game.player.apply_skin(skin_index)
		var expected_body: String = game.player.BODY_TEXTURE_PATHS[skin_index]
		var leg_sheet: Texture2D = (game.player.run_leg_sprite.material_override as ShaderMaterial).get_shader_parameter("texture_albedo")
		if (
			game.player.character_sprite.texture.resource_path != expected_body
			or leg_sheet.resource_path != game.player.RUN_LEG_SHEET_PATH
		):
			push_error("Runner skin did not retain its body and generated run-cycle legs")
			quit(1)
			return
	game.player.apply_skin(original_skin)
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
		or game.shop_medal_row.columns != 5
		or not is_instance_valid(game.shop_scroll)
		or game.shop_scroll.horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED
		or game.shop_scroll.vertical_scroll_mode != ScrollContainer.SCROLL_MODE_AUTO
		or game.menu_panel.position.x < 0.0
		or game.menu_panel.position.y < 0.0
		or game.menu_panel.position.x + game.menu_panel.size.x > portrait_viewport_size.x
		or game.menu_panel.size.x < portrait_viewport_size.x * 0.8
		or game.loadout_ability_panel.get_class() == "Button"
		or str(game_manager.selected_ability().name).to_upper() not in game.loadout_ability_label.text
		or game.start_button.custom_minimum_size.y < 120.0
		or game.start_button.get_theme_stylebox("normal").corner_radius_top_left < 24
		or game.shop_panel.position.x < 0.0
		or game.shop_panel.position.y < 0.0
		or game.shop_panel.position.x + game.shop_panel.size.x > portrait_viewport_size.x
		or game.shop_panel.position.y + game.shop_panel.size.y > expected_content_height
		or game.result_panel.position.x < 0.0
		or game.result_panel.position.y < 0.0
		or game.result_panel.position.x + game.result_panel.size.x > portrait_viewport_size.x
		or game.result_panel.position.y + game.result_panel.size.y > expected_content_height
		or game.result_stats_grid.columns != 2
		or not is_instance_valid(game.leaderboard_button)
		or not is_instance_valid(game.result_leaderboard_button)
		or not game.menu_panel.is_ancestor_of(game.leaderboard_button)
		or not game.result_panel.is_ancestor_of(game.result_leaderboard_button)
		or game.result_stats_grid.get_child_count() != 4
		or game.result_runner_portrait.custom_minimum_size.x < 350.0
		or game.result_retry_button.custom_minimum_size.y < 100.0
		or not game.result_panel.is_ancestor_of(game.result_medal_icon)
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
		or portrait_cards.size() != game_manager.SKINS.size()
		or portrait_medals.size() != game.BIOMES.size()
		or portrait_cards.is_empty()
		or portrait_medals.is_empty()
		or not (portrait_medals[0] is PanelContainer)
		or (portrait_cards[0] as Control).custom_minimum_size.x < 390.0
		or (portrait_cards[0].get_node("CardMargin/CardBox/PortraitBubble/RunnerPortrait") as TextureRect) == null
		or (portrait_cards[0].get_node("CardMargin/CardBox/RunnerAbility") as Label).text.is_empty()
		or (portrait_cards[0].get_node("CardMargin/CardBox/RunnerAction") as Button).get_theme_font_size("font_size") < 22
		or game.shop_cards.size.y <= game.shop_scroll.size.y
		or game.shop_panel.position.y < 0.0
		or game.shop_panel.position.y + game.shop_panel.size.y > expected_content_height
	):
		push_error("Portrait shop is not using its large, bubbly, ad-safe presentation")
		quit(1)
		return
	if (
		not is_instance_valid(game.shop_previous_button)
		or not is_instance_valid(game.shop_next_button)
		or game.shop_scroll.get_v_scroll_bar().max_value <= game.shop_scroll.get_v_scroll_bar().page
		or "PAGE 1 OF 6" not in game.shop_page_label.text
	):
		push_error("Runner gallery does not expose navigation to all twelve runners")
		quit(1)
		return
	game.shop_scroll.scroll_vertical = 0
	var shop_drag_start: Vector2 = game.shop_scroll.get_global_rect().get_center()
	var shop_touch := InputEventScreenTouch.new()
	shop_touch.index = 17
	shop_touch.pressed = true
	shop_touch.position = shop_drag_start
	game._input(shop_touch)
	var shop_drag := InputEventScreenDrag.new()
	shop_drag.index = 17
	shop_drag.position = shop_drag_start - Vector2(0.0, 260.0)
	shop_drag.relative = Vector2(0.0, -260.0)
	game._input(shop_drag)
	shop_touch = InputEventScreenTouch.new()
	shop_touch.index = 17
	shop_touch.pressed = false
	shop_touch.position = shop_drag.position
	game._input(shop_touch)
	if game.shop_scroll.scroll_vertical <= 0:
		push_error("Android-style vertical drag did not scroll the runner gallery")
		quit(1)
		return
	game.shop_scroll.scroll_vertical = 0
	game._scroll_shop_page(1)
	if game.shop_scroll.scroll_vertical <= 0:
		push_error("More Runners button did not advance the runner gallery")
		quit(1)
		return
	for page_advance in range(6):
		game._scroll_shop_page(1)
	var shop_bar: VScrollBar = game.shop_scroll.get_v_scroll_bar()
	var shop_max_scroll := int(ceil(shop_bar.max_value - shop_bar.page))
	if game.shop_scroll.scroll_vertical < shop_max_scroll - 1 or not game.shop_next_button.disabled:
		push_error("Runner gallery navigation cannot reach its final runners")
		quit(1)
		return
	game.shop_scroll.scroll_vertical = 0
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
		or game.result_stats_grid.columns != 4
		or game.result_actions.columns != 3
		or game.shop_cards.columns != 4
		or game.shop_medal_row.columns != 9
	):
		push_error("Landscape layout did not restore its wide-screen camera and grids")
		quit(1)
		return
	game._show_shop()
	game._handle_back_request()
	if game.state != game.GameState.MENU:
		push_error("Native back did not return from the shop to home")
		quit(1)
		return
	game._start_run()
	if not is_equal_approx(game.power_charge, float(game_manager.selected_ability().start_charge)):
		push_error("A run did not inherit its starting gift charge from the equipped runner")
		quit(1)
		return
	game._handle_back_request()
	if game.state != game.GameState.PAUSED:
		push_error("Native back did not pause a running game")
		quit(1)
		return
	game._handle_back_request()
	if game.state != game.GameState.RUNNING:
		push_error("Native back did not resume a paused game")
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
	game.player.run_clock = PI / 24.0
	game.player._animate_run()
	var first_stride_frame: int = game.player.run_leg_sprite.frame
	game.player.run_clock += PI / 12.0
	game.player._animate_run()
	if (
		first_stride_frame == game.player.run_leg_sprite.frame
		or absi(first_stride_frame - game.player.run_leg_sprite.frame) < 2
		or game.player.run_leg_sprite.frame < 0
		or game.player.run_leg_sprite.frame > 5
	):
		push_error("Runner did not advance between opposite generated run-cycle poses")
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
	game._clear_run_objects()
	for biome_index in range(game.BIOMES.size()):
		game.current_biome = biome_index
		game._spawn_obstacle("wall", 1, -20.0)
		var biome_wall: Node3D = game.obstacles[-1].node
		var biome_wall_art := biome_wall.get_node("GeneratedWallArt") as Sprite3D
		var biome_atlas := biome_wall_art.texture as AtlasTexture
		if biome_atlas == null or biome_atlas.atlas.resource_path != game.OBSTACLE_ATLAS_PATHS[biome_index]:
			push_error("%s spawned an obstacle from the wrong biome art set" % game.BIOMES[biome_index].name)
			quit(1)
			return
		game._clear_run_objects()
	game.current_biome = 0
	game._spawn_feather(1, -18.0)
	if not _has_sprite_descendant(game.feathers[-1].node):
		push_error("Generated feather pickup art is missing")
		quit(1)
		return
	game._spawn_feather(1, -21.0, "jump")
	var jump_feather: Dictionary = game.feathers[-1]
	game.player.position.y = 0.0
	if float(jump_feather.base_height) < 2.4 or game._can_collect_feather(jump_feather):
		push_error("High skill-route feathers do not require a jump")
		quit(1)
		return
	game.player.position.y = 1.25
	if not game._can_collect_feather(jump_feather):
		push_error("Jumping cannot collect a high skill-route feather")
		quit(1)
		return
	game._spawn_feather(1, -24.0, "duck")
	var duck_feather: Dictionary = game.feathers[-1]
	game.player.position.y = 0.0
	game.player.ducking = false
	if float(duck_feather.base_height) > 0.9 or game._can_collect_feather(duck_feather):
		push_error("Low skill-route feathers do not require a duck")
		quit(1)
		return
	game.player.ducking = true
	if not game._can_collect_feather(duck_feather):
		push_error("Ducking cannot collect a low skill-route feather")
		quit(1)
		return
	game.player.ducking = false
	game.player.position.y = 0.0
	game._clear_run_objects()
	seed(20260825)
	game.distance = 300.0
	var found_skill_route := false
	for pattern_index in range(60):
		game._spawn_pattern()
		for feather_item in game.feathers:
			if str(feather_item.height_mode) in ["jump", "duck"]:
				found_skill_route = true
				break
		if found_skill_route:
			break
		game._clear_run_objects()
	if not found_skill_route:
		push_error("Obstacle patterns never place feather trails through jump or duck routes")
		quit(1)
		return
	game._clear_run_objects()
	game._spawn_all_lane_skill_row()
	var blocked_lanes := {}
	var row_kind := ""
	for obstacle_item in game.obstacles:
		blocked_lanes[int(obstacle_item.lane)] = true
		if row_kind.is_empty():
			row_kind = str(obstacle_item.kind)
		elif str(obstacle_item.kind) != row_kind:
			push_error("All-lane skill row mixes conflicting obstacle instructions")
			quit(1)
			return
	var expected_route_mode := "jump" if row_kind in ["wall", "cone"] else "duck"
	game.distance = game.ALL_LANES_SKILL_DISTANCE
	var first_row_chance: float = game._all_lanes_skill_chance()
	game.distance = game.ALL_LANES_SKILL_DISTANCE + game.ALL_LANES_SKILL_RAMP_DISTANCE
	var late_row_chance: float = game._all_lanes_skill_chance()
	if (
		game.ALL_LANES_SKILL_DISTANCE < 600.0
		or game.ALL_LANES_SKILL_CHANCE <= 0.0
		or late_row_chance <= first_row_chance
		or blocked_lanes.size() != 3
		or game.obstacles.size() != 3
		or game.feathers.size() < 4
		or str(game.feathers[0].height_mode) != expected_route_mode
	):
		push_error("Late-run all-lane rows do not force one readable jump or duck skill")
		quit(1)
		return
	game._clear_run_objects()
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
	if (
		game.neck_squawk_sound == null
		or game.trip_yelp_sound == null
		or game.neck_squawk_sound == game.trip_yelp_sound
		or game.neck_squawk_sound.data == game.trip_yelp_sound.data
		or game.neck_squawk_sound.get_meta("reaction", "") != "neck_flip"
		or game.trip_yelp_sound.get_meta("reaction", "") != "trip"
		or game.neck_squawk_sound.data.size() < 50000
		or game.trip_yelp_sound.data.size() < 38000
		or game._crash_sound_for("bar_flip") != game.neck_squawk_sound
		or game._crash_sound_for("trip") != game.trip_yelp_sound
	):
		push_error("Trip and neck-flip collisions are missing their distinct dramatic bird calls")
		quit(1)
		return
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
	game.music_player.stop()
	game.sfx_player.stream = null
	game.music_player.stream = null
	game.background_music = null
	game.music_player.queue_free()
	game.music_player = null
	for i in range(4):
		await process_frame
	game.pickup_sound = null
	game.neck_squawk_sound = null
	game.trip_yelp_sound = null
	game.spin_sound = null
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
