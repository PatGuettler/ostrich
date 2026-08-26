extends Node

enum GameState { MENU, RUNNING, HIT, RESULTS, SHOP, PAUSED }

const DashPlayer = preload("res://scripts/dash_player.gd")
const BIOMES := [
	{"name": "Classic Stadium", "sky": Color("#52b7e8"), "track": Color("#c8423a"), "ground": Color("#3d8b58"), "accent": Color("#ffd166")},
	{"name": "Beach Track", "sky": Color("#60d5ee"), "track": Color("#e4ad64"), "ground": Color("#f4d68d"), "accent": Color("#13c7c4")},
	{"name": "Night Games", "sky": Color("#07132e"), "track": Color("#28395e"), "ground": Color("#131a38"), "accent": Color("#7c5cff")},
	{"name": "Desert Circuit", "sky": Color("#ef9d61"), "track": Color("#a94c39"), "ground": Color("#d98b4e"), "accent": Color("#ffe066")},
	{"name": "Snow Games", "sky": Color("#9dd7ea"), "track": Color("#74a4bb"), "ground": Color("#e9f5f6"), "accent": Color("#f25f5c")},
	{"name": "Jungle Track", "sky": Color("#163a34"), "track": Color("#74523b"), "ground": Color("#1f6b4e"), "accent": Color("#f6bd60")},
	{"name": "Candy Carnival", "sky": Color("#77cff5"), "track": Color("#f45b91"), "ground": Color("#f7c6dc"), "accent": Color("#ffe66d")},
	{"name": "Volcano Valley", "sky": Color("#d85d55"), "track": Color("#211d27"), "ground": Color("#3a2533"), "accent": Color("#ff7b3d")},
	{"name": "Cloud Kingdom", "sky": Color("#a8dcff"), "track": Color("#7fc8ef"), "ground": Color("#e8f5ff"), "accent": Color("#ffd875")},
	{"name": "Savanna Sunrise", "sky": Color("#efb45e"), "track": Color("#b85d2d"), "ground": Color("#c89a43"), "accent": Color("#21b5a8")},
	{"name": "Crystal Caverns", "sky": Color("#2b174d"), "track": Color("#4b2d72"), "ground": Color("#24183f"), "accent": Color("#55e8e1")},
	{"name": "Moonbase Marathon", "sky": Color("#071735"), "track": Color("#8ea9bd"), "ground": Color("#4c596b"), "accent": Color("#41d7ef")},
]
const LANES := [-2.8, 0.0, 2.8]
const BIOME_DISTANCE := 225.0
const BIOME_TRANSITION_DURATION := 4.5
const CHECKPOINT_REWARD := 5
const TOUR_REWARD := 25
const AD_PREVIEW_HEIGHT := 74.0
const VISTA_OVERSCAN := 1.38
const SPAWN_GAP_MIN := 30.0
const SPAWN_GAP_MAX := 38.0
const SPAWN_GAP_RAMP_REDUCTION := 4.0
const DOUBLE_OBSTACLE_DISTANCE := 240.0
const DOUBLE_OBSTACLE_CHANCE := 0.26
const SKILL_FEATHER_TRAIL_CHANCE := 0.40
const ALL_LANES_SKILL_DISTANCE := 650.0
const ALL_LANES_SKILL_CHANCE := 0.10
const ALL_LANES_SKILL_MAX_CHANCE := 0.28
const ALL_LANES_SKILL_RAMP_DISTANCE := 2200.0
const BIOME_FOG_DENSITIES := [0.0018, 0.0022, 0.0032, 0.0022, 0.0028, 0.0034, 0.0018, 0.0024, 0.0016, 0.0020, 0.0030, 0.0017]
const BIOME_EXPOSURES := [0.84, 0.82, 1.0, 0.84, 0.86, 0.94, 0.86, 0.9, 0.82, 0.86, 0.96, 0.92]
const PRIVACY_POLICY_URL := "https://patguettler.github.io/privacy-policy.html"
const DATA_DELETION_URL := "https://patguettler.github.io/privacy-policy.html#data-deletion"
const BIOME_BACKDROP_PATHS := [
	"res://assets/generated/classic_stadium_vista.png",
	"res://assets/generated/beach_track_vista.png",
	"res://assets/generated/night_games_vista.png",
	"res://assets/generated/desert_circuit_vista.png",
	"res://assets/generated/snow_games_vista.png",
	"res://assets/generated/jungle_track_vista.png",
	"res://assets/generated/candy_carnival_vista.png",
	"res://assets/generated/volcano_valley_vista.png",
	"res://assets/generated/cloud_kingdom_vista.png",
	"res://assets/generated/savanna_sunrise_vista.png",
	"res://assets/generated/crystal_caverns_vista.png",
	"res://assets/generated/moonbase_marathon_vista.png",
]
const RUNNER_ART_PATHS := [
	"res://assets/generated/gameplay/runner_classic.png",
	"res://assets/generated/gameplay/runner_midnight.png",
	"res://assets/generated/gameplay/runner_golden.png",
	"res://assets/generated/gameplay/runner_bubblegum.png",
	"res://assets/generated/gameplay/runner_aurora.png",
	"res://assets/generated/gameplay/runner_emerald.png",
	"res://assets/generated/gameplay/runner_sunset.png",
	"res://assets/generated/gameplay/runner_frost.png",
	"res://assets/generated/gameplay/runner_celestial.png",
	"res://assets/generated/gameplay/runner_rose_gold.png",
	"res://assets/generated/gameplay/runner_electric_lime.png",
	"res://assets/generated/gameplay/runner_royal_peacock.png",
]
const RIVAL_ART_PATH := "res://assets/generated/gameplay/rival_runner_back.png"
const OBSTACLE_ATLAS_PATH := "res://assets/generated/gameplay/obstacle_atlas.png"
const OBSTACLE_ATLAS_PATHS := [
	OBSTACLE_ATLAS_PATH,
	"res://assets/generated/gameplay/obstacles/beach_track_obstacles.png",
	"res://assets/generated/gameplay/obstacles/night_games_obstacles.png",
	"res://assets/generated/gameplay/obstacles/desert_circuit_obstacles.png",
	"res://assets/generated/gameplay/obstacles/snow_games_obstacles.png",
	"res://assets/generated/gameplay/obstacles/jungle_track_obstacles.png",
	"res://assets/generated/gameplay/obstacles/candy_carnival_obstacles.png",
	"res://assets/generated/gameplay/obstacles/volcano_valley_obstacles.png",
	"res://assets/generated/gameplay/obstacles/cloud_kingdom_obstacles.png",
	"res://assets/generated/gameplay/obstacles/savanna_sunrise_obstacles.png",
	"res://assets/generated/gameplay/obstacles/crystal_caverns_obstacles.png",
	"res://assets/generated/gameplay/obstacles/moonbase_marathon_obstacles.png",
]
const REWARD_POWER_ATLAS_PATH := "res://assets/generated/gameplay/reward_power_atlas.png"
const BIOME_PROP_ATLAS_PATH := "res://assets/generated/gameplay/biome_prop_atlas.png"
const EFFECTS_MEDALS_ATLAS_PATH := "res://assets/generated/gameplay/effects_medals_atlas.png"
const MENU_LOGO_PATH := "res://assets/generated/ui/ostrich_dash_menu_logo.png"
const UI_FONT_PATH := "res://assets/fonts/NotoSansDisplay-Regular.ttf"
const UI_FONT_BOLD_PATH := "res://assets/fonts/NotoSansDisplay-Bold.ttf"
const SURFACE_PATHS := [
	"res://assets/generated/gameplay/surfaces/hd/classic_rubber_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/beach_sand_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/night_track_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/desert_clay_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/snow_pack_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/jungle_earth_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/candy_rubber_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/volcano_rubber_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/cloud_rubber_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/savanna_earth_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/crystal_floor_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/moon_dust_hd.png",
]
const OBSTACLE_CELLS := {"wall": 0, "bar": 1, "cone": 2, "drone": 3, "slip": 4}

var state := GameState.MENU
var game_viewport_container: SubViewportContainer
var game_viewport: SubViewport
var world: Node3D
var camera: Camera3D
var world_environment: WorldEnvironment
var sun: DirectionalLight3D
var fill_light: OmniLight3D
var player: Node3D
var track_root: Node3D
var prop_root: Node3D
var stadium_art_root: Node3D
var biome_art_roots: Array[Node3D] = []
var obstacle_root: Node3D
var particle_root: Node3D
var track_tiles: Array[Node3D] = []
var obstacles: Array[Dictionary] = []
var feathers: Array[Dictionary] = []
var puff_particles: Array[Dictionary] = []

var distance := 0.0
var run_feathers := 0
var near_misses := 0
var combo := 1
var best_combo := 1
var score := 0
var speed := 16.0
var spawn_meter := 18.0
var current_biome := 0
var last_biome := -1
var biome_sequence: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
var biome_tour := 0
var checkpoint_stage := 0
var biome_transition_active := false
var biome_transition_elapsed := 0.0
var biome_transition_from := 0
var biome_transition_to := 0
var biome_transition_props_swapped := false
var surface_blend_shader: Shader
var vista_transition_shader: Shader
var transition_vista_material: ShaderMaterial
var transition_road_material: ShaderMaterial
var transition_ground_material: ShaderMaterial
var power_charge := 0.0
var power_timer := 0.0
var shield_active := false
var power_effect_root: Node3D
var power_effect_shell: MeshInstance3D
var power_effect_rings: Array[MeshInstance3D] = []
var power_effect_icons: Array[Sprite3D] = []
var controls_reversed := false
var slip_timer := 0.0
var shake_time := 0.0
var elapsed := 0.0
var touch_start := Vector2.ZERO
var touch_tracking := false
var touch_finger := -1
var touch_action_committed := false
var shop_touch_tracking := false
var shop_touch_finger := -1
var shop_touch_start_y := 0.0
var shop_touch_last_y := 0.0
var shop_touch_dragging := false
var last_result: Dictionary = {}
var last_crash := "spin"
var mobile_mode := false
var validation_ad_reserve := 0.0
var applied_ad_reserve := -1.0
var ad_preview_mode := false
var portrait_layout := false
var camera_home_position := Vector3(0, 5.6, 11.5)
var camera_look_target := Vector3(0, 2.1, -16.0)

var menu_layer: Control
var ui_content_root: Control
var ad_reserve_rect: ColorRect
var ad_preview_label: Label
var menu_background: TextureRect
var menu_panel: PanelContainer
var menu_margin: MarginContainer
var menu_box: VBoxContainer
var menu_logo: TextureRect
var menu_tagline: Label
var privacy_button: Button
var music_toggle_button: Button
var control_help_label: Label
var menu_wallet: Label
var loadout_skin_label: Label
var loadout_ability_panel: PanelContainer
var loadout_ability_icon: TextureRect
var loadout_ability_label: Label
var daily_label: Label
var start_button: Button
var shop_button: Button
var leaderboard_button: Button
var hud: Control
var hud_top_panel: PanelContainer
var hud_margin: MarginContainer
var hud_box: VBoxContainer
var hud_stats: GridContainer
var distance_label: Label
var feather_label: Label
var combo_label: Label
var biome_label: Label
var goal_label: Label
var goal_detail_label: Label
var goal_progress: ProgressBar
var power_button: Button
var power_bar: ProgressBar
var result_layer: Control
var result_panel: PanelContainer
var result_margin: MarginContainer
var result_box: VBoxContainer
var result_title: Label
var result_subtitle: Label
var result_runner_portrait: TextureRect
var result_medal_icon: TextureRect
var result_medal_name: Label
var result_stats_grid: GridContainer
var result_distance_value: Label
var result_score_value: Label
var result_feather_value: Label
var result_best_value: Label
var result_stats: Label
var result_bonus: Label
var result_actions: GridContainer
var result_retry_button: Button
var result_home_button: Button
var result_leaderboard_button: Button
var scores_layer: Control
var scores_panel: PanelContainer
var scores_title: Label
var scores_status: Label
var scores_list: VBoxContainer
var scores_native_button: Button
var scores_back_button: Button
var shop_layer: Control
var shop_panel: PanelContainer
var shop_margin: MarginContainer
var shop_box: VBoxContainer
var shop_heading: Label
var shop_wallet: Label
var shop_scroll: ScrollContainer
var shop_cards: GridContainer
var shop_navigation: HBoxContainer
var shop_previous_button: Button
var shop_page_label: Label
var shop_next_button: Button
var shop_medal_row: GridContainer
var shop_medals: Label
var shop_back: Button
var pause_layer: Control
var pause_panel: PanelContainer
var toast_label: Label
var toast_time := 0.0

var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var background_music: AudioStreamWAV
var pickup_sound: AudioStreamWAV
var neck_squawk_sound: AudioStreamWAV
var trip_yelp_sound: AudioStreamWAV
var spin_sound: AudioStreamWAV
var success_sound: AudioStreamWAV
var audio_enabled := true

var _atlas_cache: Dictionary = {}
var _surface_material_cache: Dictionary = {}
var _rival_body_shader: Shader
var _rival_leg_shader: Shader
var _rival_body_material: ShaderMaterial
var _rival_leg_material_left: ShaderMaterial
var _rival_leg_material_right: ShaderMaterial
var _rival_shadow_material: StandardMaterial3D
var _power_shell_material: StandardMaterial3D
var _power_ring_material: StandardMaterial3D
var _cached_hud_power_icon_cell := -1
var _feather_pool: Array[Node3D] = []
var _obstacle_pool: Array[Node3D] = []
const FEATHER_POOL_MAX := 24
const OBSTACLE_POOL_MAX := 16

func _ready() -> void:
	if "--store-listing" in OS.get_cmdline_user_args():
		seed(20260823)
	else:
		randomize()
	mobile_mode = OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
	if mobile_mode and DisplayServer.has_feature(DisplayServer.FEATURE_ORIENTATION):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR)
	ad_preview_mode = "--preview-ad-bar" in OS.get_cmdline_user_args()
	_build_game_viewport()
	_init_runtime_caches()
	_build_world()
	_apply_mobile_render_tier()
	_build_ui()
	_build_audio()
	_show_menu()
	_sync_viewport_render_mode()
	refresh_ad_layout()
	get_viewport().size_changed.connect(refresh_ad_layout)
	call_deferred("_sync_ad_bar")

func _init_runtime_caches() -> void:
	var rival_texture: Texture2D = load(RIVAL_ART_PATH)
	_rival_body_shader = Shader.new()
	_rival_body_shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
uniform sampler2D runner_texture : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
void fragment() {
	vec4 art = texture(runner_texture, UV);
	float upper_body = 1.0 - step(0.615, UV.y);
	ALBEDO = art.rgb;
	ALPHA = art.a * upper_body;
}
"""
	_rival_leg_shader = Shader.new()
	_rival_leg_shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
uniform sampler2D runner_texture : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform float keep_left = 1.0;
void fragment() {
	vec2 sample_uv = UV;
	float leg_mask = step(0.615, UV.y);
	float side_mask = step(0.5, UV.x);
	if (keep_left > 0.5) {
		side_mask = 1.0 - side_mask;
	}
	vec4 art = texture(runner_texture, sample_uv);
	ALBEDO = art.rgb;
	ALPHA = art.a * leg_mask * side_mask;
}
"""
	_rival_body_material = ShaderMaterial.new()
	_rival_body_material.shader = _rival_body_shader
	_rival_body_material.set_shader_parameter("runner_texture", rival_texture)
	_rival_leg_material_left = ShaderMaterial.new()
	_rival_leg_material_left.shader = _rival_leg_shader
	_rival_leg_material_left.set_shader_parameter("runner_texture", rival_texture)
	_rival_leg_material_left.set_shader_parameter("keep_left", 1.0)
	_rival_leg_material_right = ShaderMaterial.new()
	_rival_leg_material_right.shader = _rival_leg_shader
	_rival_leg_material_right.set_shader_parameter("runner_texture", rival_texture)
	_rival_leg_material_right.set_shader_parameter("keep_left", 0.0)
	_rival_shadow_material = StandardMaterial3D.new()
	_rival_shadow_material.albedo_color = Color(0.015, 0.025, 0.05, 0.25)
	_rival_shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_rival_shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_rival_shadow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_power_shell_material = _make_power_aura_material()
	_power_ring_material = _make_power_aura_material()

func _make_power_aura_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.emission_enabled = true
	material.emission_energy_multiplier = 1.5
	material.no_depth_test = true
	material.render_priority = 4
	return material

func _configure_power_aura(material: StandardMaterial3D, color: Color, alpha: float) -> void:
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.emission = color

func _apply_mobile_render_tier() -> void:
	if not mobile_mode or not is_instance_valid(world_environment):
		return
	var environment := world_environment.environment
	environment.glow_enabled = false
	environment.fog_density = minf(environment.fog_density, 0.0025)
	if is_instance_valid(sun):
		sun.shadow_enabled = false
	if is_instance_valid(fill_light):
		fill_light.light_energy = 0.45
	if is_instance_valid(game_viewport):
		game_viewport.msaa_3d = Viewport.MSAA_DISABLED

func _sync_viewport_render_mode() -> void:
	if not is_instance_valid(game_viewport):
		return
	match state:
		GameState.RUNNING, GameState.HIT, GameState.MENU:
			game_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_:
			game_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func _process(delta: float) -> void:
	var ad_reserve := _ad_bottom_reserve()
	if absf(ad_reserve - applied_ad_reserve) > 0.5:
		refresh_ad_layout()
	elapsed += delta
	player.step(delta, _player_gravity_scale())
	if toast_time > 0.0:
		toast_time -= delta
		toast_label.modulate.a = minf(1.0, toast_time * 2.0)
		if toast_time <= 0.0:
			toast_label.visible = false
	if state == GameState.RUNNING:
		_update_run(delta)
	elif state == GameState.HIT:
		_update_hit(delta)
	elif state == GameState.MENU:
		_move_track(delta, 4.0)
	if is_instance_valid(power_button) and hud.visible:
		power_button.pivot_offset = power_button.size * 0.5
		var ready_pulse := 0.045 if power_charge >= 100.0 else 0.015
		var pulse := 1.0 + sin(elapsed * 3.2) * ready_pulse
		power_button.scale = Vector2(pulse, pulse)
		power_button.rotation = sin(elapsed * 2.1) * 0.018
	if puff_particles.size() > 0:
		_update_particles(delta)

func _input(event: InputEvent) -> void:
	# Android GUI controls receive events before _unhandled_input(), so gestures
	# must be observed here. Keep tracking through release after a committed swipe
	# to prevent the same finger from also clicking the power button.
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if state == GameState.RUNNING:
			_process_touch_gesture(event)
		elif state == GameState.SHOP:
			_process_shop_scroll_gesture(event)
		elif touch_tracking:
			_reset_touch_gesture()
		return
	# Capture laptop arrow keys before focused UI controls can consume them.
	if state != GameState.RUNNING or not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var pressed_key := key_event.keycode if key_event.keycode != 0 else key_event.physical_keycode
	match pressed_key:
		KEY_LEFT:
			_move_player(-1)
		KEY_RIGHT:
			_move_player(1)
		KEY_UP:
			_try_jump()
		KEY_DOWN:
			player.duck()
		_:
			return
	get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_handle_back_request()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause"):
		if state == GameState.RUNNING:
			_pause_game()
		elif state == GameState.PAUSED:
			_resume_game()
	if state != GameState.RUNNING:
		return
	if event.is_action_pressed("move_left"):
		_move_player(-1)
	elif event.is_action_pressed("move_right"):
		_move_player(1)
	elif event.is_action_pressed("jump"):
		_try_jump()
	elif event.is_action_pressed("duck"):
		player.duck()
	elif event.is_action_pressed("power_up"):
		_activate_power()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_back_request()

func _handle_back_request() -> void:
	if is_instance_valid(scores_layer) and scores_layer.visible:
		_hide_global_scores()
		return
	match state:
		GameState.RUNNING:
			_pause_game()
		GameState.PAUSED:
			_resume_game()
		GameState.SHOP, GameState.RESULTS, GameState.HIT:
			_show_menu()
		GameState.MENU:
			# Keep the player in the app instead of accidentally closing it.
			pass

func _process_touch_gesture(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if not touch_tracking:
				touch_start = touch.position
				touch_tracking = true
				touch_finger = touch.index
				touch_action_committed = false
			return
		if not touch_tracking or touch.index != touch_finger:
			return
		if not touch_action_committed:
			touch_action_committed = _handle_swipe(touch.position - touch_start)
		if touch_action_committed:
			get_viewport().set_input_as_handled()
		_reset_touch_gesture()
		return
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if not touch_tracking or drag.index != touch_finger:
			return
		if not touch_action_committed:
			touch_action_committed = _handle_swipe(drag.position - touch_start)
		if touch_action_committed:
			get_viewport().set_input_as_handled()

func _handle_swipe(delta: Vector2) -> bool:
	if state != GameState.RUNNING or delta.length() < _swipe_min_distance():
		return false
	if absf(delta.x) > absf(delta.y):
		_move_player(-1 if delta.x < 0.0 else 1)
	elif delta.y < 0.0:
		_try_jump()
	else:
		player.duck()
	return true

func _swipe_min_distance() -> float:
	var viewport_size := get_viewport().get_visible_rect().size
	return clampf(minf(viewport_size.x, viewport_size.y) * 0.055, 30.0, 64.0)

func _power_is_active(ability_kind: int) -> bool:
	return power_timer > 0.0 and GameManager.selected_ability_kind() == ability_kind

func _try_jump() -> bool:
	var ability_kind := GameManager.selected_ability_kind()
	var can_double_jump := power_timer > 0.0 and ability_kind in [GameManager.ABILITY_DOUBLE_JUMP, GameManager.ABILITY_MIRACLE]
	var jumped: bool = player.jump(2 if can_double_jump else 1)
	if jumped and player.jumps_used == 2:
		_spawn_puff(player.global_position + Vector3(0, 1.2, 0), Color("#fff0a8"), 10)
		_show_toast("DOUBLE JUMP!")
	return jumped

func _player_gravity_scale() -> float:
	return 0.48 if _power_is_active(GameManager.ABILITY_GLIDE) else 1.0

func _reset_touch_gesture() -> void:
	touch_start = Vector2.ZERO
	touch_tracking = false
	touch_finger = -1
	touch_action_committed = false

func _reset_shop_touch_gesture() -> void:
	shop_touch_tracking = false
	shop_touch_finger = -1
	shop_touch_start_y = 0.0
	shop_touch_last_y = 0.0
	shop_touch_dragging = false

func _process_shop_scroll_gesture(event: InputEvent) -> void:
	if not is_instance_valid(shop_scroll):
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			if shop_scroll.get_global_rect().has_point(touch.position):
				shop_touch_tracking = true
				shop_touch_finger = touch.index
				shop_touch_start_y = touch.position.y
				shop_touch_last_y = touch.position.y
				shop_touch_dragging = false
			return
		if not shop_touch_tracking or touch.index != shop_touch_finger:
			return
		if shop_touch_dragging:
			get_viewport().set_input_as_handled()
		_reset_shop_touch_gesture()
		_refresh_shop_navigation()
		return
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if not shop_touch_tracking or drag.index != shop_touch_finger:
			return
		if absf(drag.position.y - shop_touch_start_y) >= 12.0:
			shop_touch_dragging = true
		if shop_touch_dragging:
			shop_scroll.scroll_vertical += int(round(shop_touch_last_y - drag.position.y))
			get_viewport().set_input_as_handled()
		shop_touch_last_y = drag.position.y

func _move_player(direction: int) -> void:
	player.move_lane(-direction if controls_reversed else direction)

func _start_run() -> void:
	_reset_touch_gesture()
	_clear_run_objects()
	distance = 0.0
	run_feathers = 0
	near_misses = 0
	combo = 1
	best_combo = 1
	score = 0
	speed = 16.0
	spawn_meter = 24.0
	current_biome = 0
	last_biome = -1
	biome_tour = 0
	checkpoint_stage = 0
	_shuffle_biome_sequence()
	last_crash = "spin"
	power_charge = float(GameManager.selected_ability().start_charge)
	power_timer = 0.0
	shield_active = false
	_stop_power_effect()
	controls_reversed = false
	slip_timer = 0.0
	player.reset_player()
	state = GameState.RUNNING
	_sync_viewport_render_mode()
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	hud.visible = true
	_apply_biome(0, true)
	_update_hud()
	if mobile_mode:
		_show_toast("SWIPE SIDEWAYS • SWIPE UP TO JUMP • SWIPE DOWN TO DUCK")

func _update_run(delta: float) -> void:
	var ability_kind := GameManager.selected_ability_kind()
	var slow_strength := clampf(0.68 - float(GameManager.selected_skin) * 0.012, 0.52, 0.68)
	var time_scale := slow_strength if power_timer > 0.0 and ability_kind == GameManager.ABILITY_SLOW_MO else 1.0
	var move_speed := speed * time_scale
	speed = minf(31.0, speed + delta * 0.19)
	distance += move_speed * delta * 0.72
	score = int(distance * 10.0 * (1.0 + float(combo - 1) * 0.15)) + run_feathers * 25
	spawn_meter -= move_speed * delta
	if spawn_meter <= 0.0:
		_spawn_pattern()
		spawn_meter = _next_spawn_gap()
	_move_track(delta, move_speed)
	_move_objects(delta, move_speed)
	_update_power(delta)
	var biome_stage := int(distance / BIOME_DISTANCE)
	var next_tour := int(biome_stage / biome_sequence.size())
	if next_tour != biome_tour:
		biome_tour = next_tour
		_shuffle_biome_sequence()
	var next_biome: int = biome_sequence[biome_stage % biome_sequence.size()]
	if next_biome != current_biome:
		current_biome = next_biome
		_apply_biome(current_biome)
	while checkpoint_stage < biome_stage:
		checkpoint_stage += 1
		_award_checkpoint(checkpoint_stage % biome_sequence.size() == 0)
	_update_biome_transition(delta)
	_update_hud()

func _award_checkpoint(completed_tour: bool) -> void:
	var reward := TOUR_REWARD if completed_tour else CHECKPOINT_REWARD
	run_feathers += reward
	power_charge = minf(100.0, power_charge + 18.0 * float(GameManager.selected_ability().charge_rate))
	if completed_tour:
		_show_toast("TOUR COMPLETE!  +%d FEATHERS" % reward)
	else:
		_show_toast("CHECKPOINT!  +%d FEATHERS" % reward)

func _build_power_effects() -> void:
	power_effect_root = Node3D.new()
	power_effect_root.name = "ActivePowerAura"
	power_effect_root.visible = false
	player.add_child(power_effect_root)

	var shell_mesh := SphereMesh.new()
	shell_mesh.radius = 0.5
	shell_mesh.height = 1.0
	shell_mesh.radial_segments = 32
	shell_mesh.rings = 18
	power_effect_shell = MeshInstance3D.new()
	power_effect_shell.name = "ProtectivePowerBubble"
	power_effect_shell.mesh = shell_mesh
	power_effect_shell.position = Vector3(0.0, 2.55, 0.2)
	power_effect_shell.scale = Vector3(3.55, 5.2, 2.15)
	power_effect_shell.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	power_effect_shell.material_override = _power_shell_material
	power_effect_root.add_child(power_effect_shell)

	for ring_index in range(2):
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = 0.465
		ring_mesh.outer_radius = 0.5
		ring_mesh.rings = 36
		ring_mesh.ring_segments = 10
		var ring := MeshInstance3D.new()
		ring.name = "PowerOrbitRing%d" % (ring_index + 1)
		ring.mesh = ring_mesh
		ring.position = Vector3(0.0, 2.55, 0.34 + ring_index * 0.04)
		ring.rotation_degrees.x = 90.0
		ring.scale = Vector3(3.45 - ring_index * 0.38, 1.0, 4.75 - ring_index * 0.42)
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ring.material_override = _power_ring_material
		power_effect_root.add_child(ring)
		power_effect_rings.append(ring)

	for icon_index in range(3):
		var icon := _sprite_3d(
			power_effect_root,
			_atlas_texture(REWARD_POWER_ATLAS_PATH, 3, 2, 1),
			Vector3.ZERO,
			0.00225,
			"OrbitingPowerBuddy%d" % (icon_index + 1)
		)
		icon.render_priority = 6
		power_effect_icons.append(icon)

func _start_power_effect() -> void:
	var ability := GameManager.selected_ability()
	var ability_kind := GameManager.selected_ability_kind()
	var effect_color := Color(str(ability.get("aura_color", "#4de9ff")))
	var icon_texture := _atlas_texture(REWARD_POWER_ATLAS_PATH, 3, 2, int(ability.get("icon_cell", 1)))
	var protective := ability_kind in [GameManager.ABILITY_SHIELD, GameManager.ABILITY_RESCUE, GameManager.ABILITY_MIRACLE]
	_configure_power_aura(_power_shell_material, effect_color, 0.11 if protective else 0.065)
	_configure_power_aura(_power_ring_material, effect_color, 0.82)
	for ring in power_effect_rings:
		ring.material_override = _power_ring_material
	for icon in power_effect_icons:
		icon.texture = icon_texture
		icon.modulate = Color.WHITE
	power_effect_root.visible = true
	_update_power_effect(0.0)

func _stop_power_effect() -> void:
	if is_instance_valid(power_effect_root):
		power_effect_root.visible = false

func _update_power_effect(_delta: float) -> void:
	if power_timer <= 0.0 or state != GameState.RUNNING:
		_stop_power_effect()
		return
	if not power_effect_root.visible:
		_start_power_effect()
	var pulse := 1.0 + sin(elapsed * 5.2) * 0.035
	power_effect_shell.scale = Vector3(3.55, 5.2, 2.15) * pulse
	power_effect_shell.rotation.y = elapsed * 0.42
	for ring_index in range(power_effect_rings.size()):
		var ring := power_effect_rings[ring_index]
		ring.rotation.z = elapsed * (0.72 if ring_index == 0 else -0.94)
		var ring_pulse := 1.0 + sin(elapsed * 4.4 + float(ring_index) * PI) * 0.045
		ring.scale = Vector3(3.45 - ring_index * 0.38, 1.0, 4.75 - ring_index * 0.42) * ring_pulse
	var fade := clampf(power_timer * 2.5, 0.0, 1.0)
	for icon_index in range(power_effect_icons.size()):
		var phase := elapsed * (1.55 + float(icon_index) * 0.08) + float(icon_index) * TAU / float(power_effect_icons.size())
		var icon := power_effect_icons[icon_index]
		icon.position = Vector3(cos(phase) * 2.0, 2.65 + sin(phase) * 1.72, 0.62 + sin(phase * 2.0) * 0.12)
		var icon_scale := 0.9 + sin(elapsed * 5.0 + float(icon_index)) * 0.09
		icon.scale = Vector3.ONE * icon_scale
		icon.modulate.a = fade

func _update_power(delta: float) -> void:
	if power_timer > 0.0:
		power_timer -= delta
		if power_timer <= 0.0:
			power_timer = 0.0
			shield_active = false
	if slip_timer > 0.0:
		slip_timer -= delta
		if slip_timer <= 0.0:
			controls_reversed = false
	if power_timer > 0.0 and GameManager.selected_ability_kind() in [GameManager.ABILITY_MAGNET, GameManager.ABILITY_MIRACLE]:
		for item in feathers:
			var node: Node3D = item.node
			if is_instance_valid(node) and node.position.z > -18.0:
				var pull_speed := 9.0 + float(GameManager.selected_skin) * 0.75
				node.position.x = move_toward(node.position.x, player.position.x, delta * pull_speed)
	_update_power_effect(delta)

func _activate_power() -> void:
	if power_charge < 100.0 or power_timer > 0.0:
		_show_toast("%s charges from clean dodges" % str(GameManager.selected_ability().name).to_upper())
		return
	var ability := GameManager.selected_ability()
	var ability_kind := int(ability.kind)
	power_charge = 0.0
	power_timer = float(ability.duration)
	_start_power_effect()
	match ability_kind:
		GameManager.ABILITY_SHIELD:
			shield_active = true
			_show_toast("%s — one crash blocked!" % str(ability.name).to_upper())
		GameManager.ABILITY_MAGNET:
			_show_toast("%s — feathers fly to you!" % str(ability.name).to_upper())
		GameManager.ABILITY_SLOW_MO:
			_show_toast("%s — obstacles slowed!" % str(ability.name).to_upper())
		GameManager.ABILITY_RESCUE:
			shield_active = true
			_show_toast("%s — phase through obstacles!" % str(ability.name).to_upper())
		GameManager.ABILITY_DOUBLE_JUMP:
			_show_toast("%s — jump again in midair!" % str(ability.name).to_upper())
		GameManager.ABILITY_FEATHER_FRENZY:
			_show_toast("%s — every feather is worth more!" % str(ability.name).to_upper())
		GameManager.ABILITY_GLIDE:
			_show_toast("%s — long, floaty jumps!" % str(ability.name).to_upper())
		GameManager.ABILITY_MIRACLE:
			shield_active = true
			_show_toast("%s — all gifts at once!" % str(ability.name).to_upper())

func _spawn_pattern() -> void:
	if distance >= ALL_LANES_SKILL_DISTANCE and randf() < _all_lanes_skill_chance():
		_spawn_all_lane_skill_row()
		return
	var blocked: Array[int] = []
	var skill_routes: Array[Dictionary] = []
	var obstacle_count := 2 if distance >= DOUBLE_OBSTACLE_DISTANCE and randf() < DOUBLE_OBSTACLE_CHANCE else 1
	for i in obstacle_count:
		var lane := randi_range(0, 2)
		while lane in blocked:
			lane = randi_range(0, 2)
		blocked.append(lane)
		var types := ["wall", "bar", "cone", "drone", "slip", "rival"]
		if distance < 55.0:
			types = ["wall", "bar", "cone"]
		var kind: String = types[randi_range(0, types.size() - 1)]
		var obstacle_z := -72.0 - i * 1.5
		_spawn_obstacle(kind, lane, obstacle_z)
		if kind in ["wall", "cone"]:
			skill_routes.append({"lane": lane, "z": obstacle_z, "height_mode": "jump"})
		elif kind in ["bar", "drone"]:
			skill_routes.append({"lane": lane, "z": obstacle_z, "height_mode": "duck"})
	if not skill_routes.is_empty() and randf() < SKILL_FEATHER_TRAIL_CHANCE:
		var route: Dictionary = skill_routes.pick_random()
		for i in range(4):
			# The trail crosses the obstacle itself. Collecting the full line means
			# committing to the same jump or duck that safely clears the hazard.
			_spawn_feather(int(route.lane), float(route.z) + 5.4 - float(i) * 3.6, str(route.height_mode))
		return
	var open_lanes: Array[int] = []
	for lane in range(3):
		if lane not in blocked:
			open_lanes.append(lane)
	if not open_lanes.is_empty():
		var feather_lane: int = open_lanes.pick_random()
		for i in range(4):
			_spawn_feather(feather_lane, -64.0 - i * 2.5)

func _all_lanes_skill_chance() -> float:
	var ramp_progress := clampf((distance - ALL_LANES_SKILL_DISTANCE) / ALL_LANES_SKILL_RAMP_DISTANCE, 0.0, 1.0)
	return lerpf(ALL_LANES_SKILL_CHANCE, ALL_LANES_SKILL_MAX_CHANCE, ramp_progress)

func _spawn_all_lane_skill_row(forced_mode := "", row_z := -72.0) -> void:
	# A full row always asks for one consistent action. Mixing a wall in one lane
	# with a duck gate in another would turn a readable skill check into a guess.
	var height_mode: String = forced_mode if forced_mode in ["jump", "duck"] else ("jump" if randf() < 0.5 else "duck")
	var kind: String = (["wall", "cone"] if height_mode == "jump" else ["bar", "drone"]).pick_random()
	for lane in range(3):
		_spawn_obstacle(kind, lane, row_z)
	# The centered trail advertises both the safe timing and the required move.
	for feather_index in range(4):
		_spawn_feather(1, row_z + 5.4 - float(feather_index) * 3.6, height_mode)

func _next_spawn_gap() -> float:
	var difficulty_reduction := minf(SPAWN_GAP_RAMP_REDUCTION, distance / 600.0)
	return randf_range(SPAWN_GAP_MIN, SPAWN_GAP_MAX) - difficulty_reduction

func _spawn_obstacle(kind: String, lane: int, z: float) -> void:
	var node := _acquire_obstacle_node()
	node.name = "Cute%sObstacle" % kind.capitalize()
	node.position = Vector3(LANES[lane], 0.0, z)
	node.visible = true
	var rival_parts: Dictionary = {}
	if kind == "rival":
		rival_parts = _build_rival_runner(node)
	else:
		var cell: int = [0, 5].pick_random() if kind == "wall" else OBSTACLE_CELLS.get(kind, 5)
		var sprite_height: float = {"wall": 1.42, "bar": 2.82, "cone": 1.08, "drone": 2.55, "slip": 0.62}.get(kind, 1.0)
		var pixel_size: float = {"wall": 0.0074, "bar": 0.0088, "cone": 0.0062, "drone": 0.0074, "slip": 0.0063}.get(kind, 0.0065)
		var atlas_path: String = OBSTACLE_ATLAS_PATHS[clampi(current_biome, 0, OBSTACLE_ATLAS_PATHS.size() - 1)]
		var art := _sprite_3d(node, _atlas_texture(atlas_path, 3, 2, cell), Vector3(0.0, sprite_height, 0.0), pixel_size, "Generated%sArt" % kind.capitalize())
		if kind == "bar":
			art.scale = Vector3(1.08, 1.28, 1.0)
		elif kind == "slip":
			art.scale.y = 0.46
	var item := {"node": node, "kind": kind, "lane": lane, "passed": false, "phase": randf() * TAU}
	item.merge(rival_parts)
	obstacles.append(item)

func _acquire_obstacle_node() -> Node3D:
	while not _obstacle_pool.is_empty():
		var pooled: Node3D = _obstacle_pool.pop_back()
		if is_instance_valid(pooled):
			if pooled.get_parent() != obstacle_root:
				obstacle_root.add_child(pooled)
			_reset_obstacle_node(pooled)
			return pooled
	var node := Node3D.new()
	obstacle_root.add_child(node)
	return node

func _reset_obstacle_node(node: Node3D) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.free()

func _release_obstacle_node(node: Node3D) -> void:
	if not is_instance_valid(node):
		return
	node.visible = false
	if _obstacle_pool.size() < OBSTACLE_POOL_MAX:
		_obstacle_pool.append(node)
	else:
		node.queue_free()

func _build_rival_runner(parent: Node3D) -> Dictionary:
	_reset_obstacle_node(parent)
	var texture: Texture2D = load(RIVAL_ART_PATH)
	var visual := Node3D.new()
	visual.name = "RivalRunningVisual"
	parent.add_child(visual)
	var body := _rival_sprite(visual, texture, Vector3(0.0, 2.35, 0.0), "GeneratedRivalBody", 4)
	body.material_override = _rival_body_material
	var left_pivot := _make_rival_stride_layer(visual, texture, "RivalLeftStride", true, Vector3(-0.25, 1.99, -0.02))
	var right_pivot := _make_rival_stride_layer(visual, texture, "RivalRightStride", false, Vector3(0.23, 1.99, -0.02))
	var shadow_mesh := QuadMesh.new()
	shadow_mesh.size = Vector2(1.9, 0.9)
	var shadow := MeshInstance3D.new()
	shadow.name = "RivalGroundShadow"
	shadow.mesh = shadow_mesh
	shadow.material_override = _rival_shadow_material
	shadow.position = Vector3(0.0, 0.055, 0.12)
	shadow.rotation_degrees.x = -90.0
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(shadow)
	return {
		"rival_visual": visual,
		"rival_body": body,
		"rival_left_pivot": left_pivot,
		"rival_right_pivot": right_pivot,
		"rival_left_leg": left_pivot.get_node("LegArt"),
		"rival_right_leg": right_pivot.get_node("LegArt"),
		"rival_shadow": shadow,
	}

func _rival_sprite(parent: Node3D, texture: Texture2D, pos: Vector3, node_name: String, priority: int) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.name = node_name
	sprite.texture = texture
	sprite.position = pos
	sprite.pixel_size = 0.00335
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	sprite.shaded = false
	sprite.double_sided = true
	sprite.render_priority = priority
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(sprite)
	return sprite

func _make_rival_stride_layer(visual: Node3D, texture: Texture2D, node_name: String, keep_left: bool, hip_position: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = node_name
	pivot.position = hip_position
	visual.add_child(pivot)
	var leg := _rival_sprite(pivot, texture, Vector3(-hip_position.x, 2.35 - hip_position.y, -0.01), "LegArt", 2)
	leg.material_override = _rival_leg_material_left if keep_left else _rival_leg_material_right
	return pivot

func _spawn_feather(lane: int, z: float, height_mode := "normal") -> void:
	var base_height: float = {"jump": 2.55, "duck": 0.72}.get(height_mode, 1.55)
	var node := _acquire_feather_node()
	node.name = "%sGoldenFeatherPickup" % str(height_mode).capitalize()
	node.position = Vector3(LANES[lane], base_height, z)
	node.visible = true
	feathers.append({"node": node, "lane": lane, "phase": randf() * TAU, "base_height": base_height, "height_mode": height_mode})

func _acquire_feather_node() -> Node3D:
	while not _feather_pool.is_empty():
		var pooled: Node3D = _feather_pool.pop_back()
		if is_instance_valid(pooled):
			if pooled.get_parent() != obstacle_root:
				obstacle_root.add_child(pooled)
			return pooled
	var node := Node3D.new()
	obstacle_root.add_child(node)
	_sprite_3d(node, _atlas_texture(REWARD_POWER_ATLAS_PATH, 3, 2, 0), Vector3.ZERO, 0.00235, "GeneratedFeatherArt")
	return node

func _release_feather_node(node: Node3D) -> void:
	if not is_instance_valid(node):
		return
	node.visible = false
	if _feather_pool.size() < FEATHER_POOL_MAX:
		_feather_pool.append(node)
	else:
		node.queue_free()

func _animate_rival_runner(item: Dictionary, move_speed: float) -> void:
	var visual: Node3D = item.rival_visual
	var body: Sprite3D = item.rival_body
	var left_pivot: Node3D = item.rival_left_pivot
	var right_pivot: Node3D = item.rival_right_pivot
	var left_leg: Sprite3D = item.rival_left_leg
	var right_leg: Sprite3D = item.rival_right_leg
	var pace: float = elapsed * lerpf(9.5, 13.0, clampf(move_speed / 31.0, 0.0, 1.0)) + float(item.phase)
	var drive := sin(pace) * 0.7
	var bounce := absf(sin(pace)) * 0.11
	visual.position.y = bounce
	visual.rotation.z = sin(pace) * 0.018
	body.scale = Vector3(1.0 + bounce * 0.08, 1.0 - bounce * 0.05, 1.0)
	_animate_rival_stride(left_pivot, left_leg, drive, true)
	_animate_rival_stride(right_pivot, right_leg, -drive, false)
	var shadow: MeshInstance3D = item.rival_shadow
	shadow.scale = Vector3(1.0 - bounce * 0.5, 1.0 - bounce * 0.5, 1.0)

func _animate_rival_stride(pivot: Node3D, leg: Sprite3D, drive: float, is_left: bool) -> void:
	var recovery := maxf(drive, 0.0)
	var extension := maxf(-drive, 0.0)
	pivot.rotation.x = drive * 0.92
	pivot.rotation.z = drive * (0.05 if is_left else -0.05)
	pivot.scale.y = 0.86 + extension * 0.25 - recovery * 0.12
	pivot.scale.x = 1.0 + extension * 0.05
	pivot.position.y = 1.99 + recovery * 0.15
	pivot.position.z = -0.02 + drive * 0.22
	leg.render_priority = 3 if drive > 0.0 else 2

func _move_objects(delta: float, move_speed: float) -> void:
	for index in range(obstacles.size() - 1, -1, -1):
		var item: Dictionary = obstacles[index]
		var node: Node3D = item.node
		if not is_instance_valid(node):
			obstacles.remove_at(index)
			continue
		var approach_speed := move_speed * (0.84 if item.kind == "rival" else 1.0)
		node.position.z += approach_speed * delta
		if item.kind == "rival":
			node.position.x = LANES[item.lane] + sin(elapsed * 2.35 + item.phase) * 0.38
			_animate_rival_runner(item, move_speed)
		if node.position.z > -1.15 and not item.passed:
			item.passed = true
			if absf(node.position.x - player.position.x) < 1.05:
				if _obstacle_hits(item.kind):
					if item.kind == "slip":
						_trigger_slip()
					else:
						_trigger_hit(node, item.kind)
				else:
					_clean_dodge(true)
			elif absf(node.position.x - player.position.x) < 3.7:
				_clean_dodge(false)
		if node.position.z > 14.0:
			obstacles.remove_at(index)
			_release_obstacle_node(node)
	for index in range(feathers.size() - 1, -1, -1):
		var item: Dictionary = feathers[index]
		var node: Node3D = item.node
		if not is_instance_valid(node):
			feathers.remove_at(index)
			continue
		node.position.z += move_speed * delta
		node.rotation.y += delta * 4.5
		node.position.y = float(item.base_height) + sin(elapsed * 4.0 + item.phase) * 0.18
		if node.position.z > -1.0 and node.position.z < 1.8 and absf(node.position.x - player.position.x) < 0.95 and _can_collect_feather(item):
			_collect_feather(item)
		elif node.position.z > 10.0:
			feathers.remove_at(index)
			_release_feather_node(node)

func _can_collect_feather(item: Dictionary) -> bool:
	if power_timer > 0.0 and GameManager.selected_ability_kind() in [GameManager.ABILITY_MAGNET, GameManager.ABILITY_MIRACLE]:
		return true
	match str(item.get("height_mode", "normal")):
		"jump":
			return player.position.y >= 0.75
		"duck":
			return player.ducking
	return true

func _obstacle_hits(kind: String) -> bool:
	match kind:
		"wall", "cone":
			return player.position.y < 1.2
		"bar", "drone":
			return not player.ducking
		"slip":
			return player.position.y < 0.35
		"rival":
			return true
	return true

func _clean_dodge(near: bool) -> void:
	combo = mini(combo + 1, 9)
	best_combo = maxi(best_combo, combo)
	if near:
		near_misses += 1
	var charge_gain := 22.0
	charge_gain *= float(GameManager.selected_ability().charge_rate)
	power_charge = minf(100.0, power_charge + charge_gain)
	if combo >= 4:
		_show_toast("%d× CLEAN COMBO" % combo)

func _collect_feather(item: Dictionary) -> void:
	var node: Node3D = item.node
	var pickup_multiplier := 1
	if power_timer > 0.0 and GameManager.selected_ability_kind() in [GameManager.ABILITY_FEATHER_FRENZY, GameManager.ABILITY_MIRACLE]:
		pickup_multiplier = int(GameManager.selected_ability().get("pickup_multiplier", 2))
	run_feathers += combo * pickup_multiplier
	power_charge = minf(100.0, power_charge + 5.0 * float(GameManager.selected_ability().charge_rate))
	_play_sound(pickup_sound, -8.0)
	feathers.erase(item)
	_release_feather_node(node)

func _trigger_slip() -> void:
	controls_reversed = true
	slip_timer = 3.2
	combo = 1
	_show_toast("SLIPPERY! Controls reversed")

func _trigger_hit(obstacle: Node3D, obstacle_kind := "bar") -> void:
	if state != GameState.RUNNING:
		return
	if shield_active:
		var continuous_rescue := power_timer > 0.0 and GameManager.selected_ability_kind() in [GameManager.ABILITY_RESCUE, GameManager.ABILITY_MIRACLE]
		if not continuous_rescue:
			shield_active = false
			power_timer = 0.0
			_stop_power_effect()
		combo = 1
		_spawn_puff(player.global_position + Vector3(0, 2.4, 0), Color("#9be7ff"), 12)
		_show_toast("%s SAVE!" % str(GameManager.selected_ability().name).to_upper())
		return
	state = GameState.HIT
	power_timer = 0.0
	shield_active = false
	_stop_power_effect()
	shake_time = 0.75
	if obstacle_kind in ["wall", "cone", "rival"]:
		last_crash = "trip"
		player.trigger_trip()
	elif obstacle_kind == "bar":
		last_crash = "bar_flip"
		player.trigger_bar_flip()
	else:
		last_crash = "spin"
		player.trigger_spin()
	var puff_height := 0.65 if last_crash == "trip" else (4.0 if last_crash == "bar_flip" else 2.6)
	_spawn_puff(player.global_position + Vector3(0, puff_height, 0), Color("#fff0cf"), 24)
	_play_sound(_crash_sound_for(last_crash), 3.0 if last_crash == "bar_flip" else (2.0 if last_crash == "trip" else 0.0))
	hud.visible = false

func _update_hit(delta: float) -> void:
	_move_track(delta, speed * maxf(0.0, 1.0 - player.spin_time / 1.2))
	if shake_time > 0.0:
		shake_time -= delta
		camera.position.x = camera_home_position.x + randf_range(-0.22, 0.22) * (shake_time / 0.75)
		camera.position.y = camera_home_position.y + randf_range(-0.16, 0.16)
	else:
		camera.position = camera.position.lerp(camera_home_position, delta * 8.0)

func _on_crash_finished() -> void:
	if state != GameState.HIT:
		return
	_show_results()

func _show_results() -> void:
	state = GameState.RESULTS
	_sync_viewport_render_mode()
	power_timer = 0.0
	shield_active = false
	_stop_power_effect()
	last_result = GameManager.finish_run(distance, run_feathers, current_biome)
	_ensure_leaderboard_feedback_connected()
	LeaderboardService.submit_longest_dash(int(distance))
	if last_result.new_best:
		result_title.text = "NEW PERSONAL BEST!"
	elif last_crash == "trip":
		result_title.text = "WHAT A TRIP!"
	elif last_crash == "bar_flip":
		result_title.text = "OVER THE BAR!"
	else:
		result_title.text = "WHAT A DASH!"
	result_subtitle.text = {
		"trip": "THOSE SPEEDY FEET GOT TANGLED!",
		"bar_flip": "FEET UP, FEATHERS FLYING!",
	}.get(last_crash, "A WILD AND WOBBLY FINISH!")
	result_runner_portrait.texture = load(RUNNER_ART_PATHS[GameManager.selected_skin])
	result_distance_value.text = "%d m" % int(distance)
	result_score_value.text = "%d" % score
	result_feather_value.text = "+%d" % run_feathers
	result_best_value.text = "%d m" % int(GameManager.best_distance)
	result_bonus.text = "DAILY CHALLENGE COMPLETE!  +25 FEATHERS" if last_result.daily_bonus > 0 else "BEST DODGE STREAK  •  %d×     NEAR MISSES  •  %d" % [best_combo, near_misses]
	var earned_medal := GameManager.medal_for_biome(current_biome)
	result_medal_icon.visible = true
	result_medal_icon.texture = _atlas_texture(EFFECTS_MEDALS_ATLAS_PATH, 3, 2, _medal_cell(earned_medal))
	result_medal_icon.modulate.a = 0.32 if earned_medal == "—" else 1.0
	result_medal_name.text = "BRONZE AT 300m" if earned_medal == "—" else "%s • %s" % [BIOMES[current_biome].name.to_upper(), earned_medal]
	result_medal_icon.tooltip_text = "%s — %s" % [BIOMES[current_biome].name, earned_medal]
	result_layer.visible = true
	_play_sound(success_sound, -4.0)

func _clear_run_objects() -> void:
	for item in obstacles:
		var node: Node3D = item.get("node")
		if is_instance_valid(node):
			_release_obstacle_node(node)
	for item in feathers:
		var node: Node3D = item.get("node")
		if is_instance_valid(node):
			_release_feather_node(node)
	for item in puff_particles:
		var node: Node3D = item.get("node")
		if is_instance_valid(node):
			node.queue_free()
	obstacles.clear()
	feathers.clear()
	puff_particles.clear()

func _move_track(delta: float, move_speed: float) -> void:
	var wrap_length := float(track_tiles.size()) * 24.0
	for tile in track_tiles:
		tile.position.z += move_speed * delta
		if tile.position.z > 24.0:
			tile.position.z -= wrap_length

func _apply_biome(index: int, immediate := false) -> void:
	if index == last_biome and not immediate:
		return
	var from_index := last_biome
	last_biome = index
	if immediate or from_index < 0:
		biome_transition_active = false
		transition_vista_material = null
		transition_road_material = null
		transition_ground_material = null
		_set_biome_art_immediate(index)
		_apply_biome_environment(index)
		_set_biome_surfaces(index)
		_rebuild_props(index)
		biome_label.text = BIOMES[index].name.to_upper()
		return
	_start_biome_transition(from_index, index)
	biome_label.text = BIOMES[index].name.to_upper()
	if state == GameState.RUNNING:
		_show_toast("ENTERING — %s" % BIOMES[index].name.to_upper())

func _start_biome_transition(from_index: int, to_index: int) -> void:
	biome_transition_active = true
	biome_transition_elapsed = 0.0
	biome_transition_from = from_index
	biome_transition_to = to_index
	biome_transition_props_swapped = false
	for art_index in range(biome_art_roots.size()):
		var art_root := biome_art_roots[art_index]
		art_root.visible = art_index == from_index or art_index == to_index
		var vista := art_root.get_child(0) as Sprite3D
		vista.position.z = -126.0
		vista.render_priority = -2
		vista.modulate = Color.WHITE
		vista.material_override = null
	var incoming_vista := biome_art_roots[to_index].get_child(0) as Sprite3D
	incoming_vista.position.z = -125.8
	incoming_vista.render_priority = -1
	transition_vista_material = _vista_reveal_material(incoming_vista.texture)
	incoming_vista.material_override = transition_vista_material
	transition_road_material = _surface_blend_material(
		from_index,
		to_index,
		_road_tint(from_index),
		_road_tint(to_index),
		0.93
	)
	transition_ground_material = _surface_blend_material(
		from_index,
		to_index,
		_ground_tint(from_index),
		_ground_tint(to_index),
		0.97
	)
	for tile in track_tiles:
		(tile.get_node("Road") as MeshInstance3D).material_override = transition_road_material
		(tile.get_node("Ground") as MeshInstance3D).material_override = transition_ground_material

func _update_biome_transition(delta: float) -> void:
	if not biome_transition_active:
		return
	biome_transition_elapsed += delta
	var t := clampf(biome_transition_elapsed / BIOME_TRANSITION_DURATION, 0.0, 1.0)
	var eased := t * t * (3.0 - 2.0 * t)
	transition_vista_material.set_shader_parameter("transition_progress", lerpf(-0.12, 0.96, eased))
	_blend_biome_environment(biome_transition_from, biome_transition_to, eased)
	transition_road_material.set_shader_parameter("blend_amount", eased)
	transition_ground_material.set_shader_parameter("blend_amount", eased)
	if not biome_transition_props_swapped:
		_set_prop_alpha(1.0 - smoothstep(0.12, 0.48, t))
		if t >= 0.5:
			_rebuild_props(biome_transition_to)
			_set_prop_alpha(0.0)
			biome_transition_props_swapped = true
	else:
		_set_prop_alpha(smoothstep(0.52, 0.9, t))
	if t >= 1.0:
		biome_transition_active = false
		_set_biome_art_immediate(biome_transition_to)
		_apply_biome_environment(biome_transition_to)
		_set_biome_surfaces(biome_transition_to)
		_set_prop_alpha(1.0)
		transition_vista_material = null
		transition_road_material = null
		transition_ground_material = null

func _set_biome_art_immediate(index: int) -> void:
	for art_index in range(biome_art_roots.size()):
		var art_root := biome_art_roots[art_index]
		art_root.visible = art_index == index
		var vista := art_root.get_child(0) as Sprite3D
		vista.position.z = -126.0
		vista.render_priority = -2
		vista.modulate = Color.WHITE
		vista.material_override = null

func _apply_biome_environment(index: int) -> void:
	var biome: Dictionary = BIOMES[index]
	var env := world_environment.environment
	env.background_color = biome.sky
	env.fog_light_color = biome.sky
	# Generated vistas carry their own atmospheric perspective. Heavy engine fog
	# was bleaching the distant art into a flat cyan wash.
	env.fog_density = BIOME_FOG_DENSITIES[index]
	env.fog_sky_affect = 0.18
	env.ambient_light_color = biome.sky.lightened(0.35)
	env.tonemap_exposure = BIOME_EXPOSURES[index]
	env.ambient_light_energy = _ambient_energy(index)
	sun.light_color = _sun_color(index)
	sun.light_energy = _sun_energy(index)
	fill_light.light_color = biome.accent
	fill_light.light_energy = _fill_energy(index)

func _blend_biome_environment(from_index: int, to_index: int, amount: float) -> void:
	var from_biome: Dictionary = BIOMES[from_index]
	var to_biome: Dictionary = BIOMES[to_index]
	var from_sky: Color = from_biome.sky
	var to_sky: Color = to_biome.sky
	var env := world_environment.environment
	env.background_color = from_sky.lerp(to_sky, amount)
	env.fog_light_color = from_sky.lerp(to_sky, amount)
	env.fog_density = lerpf(BIOME_FOG_DENSITIES[from_index], BIOME_FOG_DENSITIES[to_index], amount)
	env.fog_sky_affect = 0.18
	env.ambient_light_color = from_sky.lightened(0.35).lerp(to_sky.lightened(0.35), amount)
	env.tonemap_exposure = lerpf(BIOME_EXPOSURES[from_index], BIOME_EXPOSURES[to_index], amount)
	env.ambient_light_energy = lerpf(_ambient_energy(from_index), _ambient_energy(to_index), amount)
	sun.light_color = _sun_color(from_index).lerp(_sun_color(to_index), amount)
	sun.light_energy = lerpf(_sun_energy(from_index), _sun_energy(to_index), amount)
	var from_accent: Color = from_biome.accent
	var to_accent: Color = to_biome.accent
	fill_light.light_color = from_accent.lerp(to_accent, amount)
	fill_light.light_energy = lerpf(_fill_energy(from_index), _fill_energy(to_index), amount)

func _ambient_energy(index: int) -> float:
	return {2: 0.34, 10: 0.40, 11: 0.36}.get(index, 0.56)

func _sun_color(index: int) -> Color:
	return Color("#8fb8ff") if index in [2, 10, 11] else Color("#fff1cf")

func _sun_energy(index: int) -> float:
	return {2: 0.68, 10: 0.78, 11: 0.72}.get(index, 1.02)

func _fill_energy(index: int) -> float:
	return {2: 2.2, 10: 2.0, 11: 1.3}.get(index, 0.7)

func _road_tint(index: int) -> Color:
	return {4: Color("#b8d8e8"), 10: Color("#d9ccff"), 11: Color("#d7e5f0")}.get(index, Color.WHITE)

func _ground_tint(index: int) -> Color:
	return Color("#a9cbd9") if index == 4 else BIOMES[index].ground.lightened(0.14)

func _set_biome_surfaces(index: int) -> void:
	var road_material := _surface_material(index, _road_tint(index), 0.93)
	var ground_material := _surface_material(index, _ground_tint(index), 0.97)
	for tile in track_tiles:
		var road: MeshInstance3D = tile.get_node("Road")
		road.material_override = road_material
		var sides: MeshInstance3D = tile.get_node("Ground")
		sides.material_override = ground_material

func _surface_blend_material(from_index: int, to_index: int, from_tint: Color, to_tint: Color, roughness: float) -> ShaderMaterial:
	if surface_blend_shader == null:
		surface_blend_shader = Shader.new()
		surface_blend_shader.code = """
shader_type spatial;
render_mode depth_draw_opaque, cull_back;

uniform sampler2D from_texture : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D to_texture : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform vec4 from_tint : source_color = vec4(1.0);
uniform vec4 to_tint : source_color = vec4(1.0);
uniform float blend_amount : hint_range(0.0, 1.0) = 0.0;
uniform float material_roughness : hint_range(0.0, 1.0) = 0.95;

void fragment() {
	vec2 tiled_uv = UV * 4.0;
	vec3 from_color = texture(from_texture, tiled_uv).rgb * from_tint.rgb;
	vec3 to_color = texture(to_texture, tiled_uv).rgb * to_tint.rgb;
	ALBEDO = mix(from_color, to_color, blend_amount);
	ROUGHNESS = material_roughness;
}
"""
	var material := ShaderMaterial.new()
	material.shader = surface_blend_shader
	material.set_shader_parameter("from_texture", load(SURFACE_PATHS[from_index]))
	material.set_shader_parameter("to_texture", load(SURFACE_PATHS[to_index]))
	material.set_shader_parameter("from_tint", from_tint)
	material.set_shader_parameter("to_tint", to_tint)
	material.set_shader_parameter("blend_amount", 0.0)
	material.set_shader_parameter("material_roughness", roughness)
	return material

func _vista_reveal_material(texture: Texture2D) -> ShaderMaterial:
	if vista_transition_shader == null:
		vista_transition_shader = Shader.new()
		vista_transition_shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform sampler2D vista_texture : source_color, repeat_disable, filter_linear_mipmap_anisotropic;
uniform float transition_progress : hint_range(-0.2, 1.0) = -0.12;

void fragment() {
	vec4 color = texture(vista_texture, UV);
	vec2 from_horizon = (UV - vec2(0.5, 0.55)) * vec2(1.35, 0.9);
	float horizon_distance = length(from_horizon);
	float reveal = 1.0 - smoothstep(transition_progress - 0.10, transition_progress + 0.10, horizon_distance);
	ALBEDO = color.rgb;
	ALPHA = color.a * reveal;
}
"""
	var material := ShaderMaterial.new()
	material.shader = vista_transition_shader
	material.set_shader_parameter("vista_texture", texture)
	material.set_shader_parameter("transition_progress", -0.12)
	return material

func _set_prop_alpha(alpha: float) -> void:
	for child in prop_root.get_children():
		if child is Sprite3D:
			(child as Sprite3D).modulate.a = alpha

func _rebuild_props(index: int) -> void:
	for child in prop_root.get_children():
		child.free()
	# The stadium vista already includes its own flags, flowers, lamps, and crowd
	# dressing. Extra foreground plates made those details appear twice.
	if index == 0 or index >= 9:
		return
	var prop_cells := [0, 1, 2, 3, 4, 5, 1, 3, 0, 5, 2, 4]
	var prop_tints := [
		Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE,
		Color("#ffd8ef"), Color("#ffad72"), Color("#dff5ff"),
		Color("#ffe0a3"), Color("#bda9ff"), Color("#bfeaff"),
	]
	var prop_number := 0
	for z in range(-82, 20, 26):
		# Stagger one cluster at a time instead of mirroring identical plates on
		# both sides. This keeps parallax without creating a doubled-image look.
		var side := -1.0 if posmod(prop_number + index, 2) == 0 else 1.0
		var x: float = side * randf_range(8.6, 10.2)
		var prop := _sprite_3d(prop_root, _atlas_texture(BIOME_PROP_ATLAS_PATH, 3, 2, prop_cells[index]), Vector3(x, 2.55, float(z)), randf_range(0.0102, 0.0115), "%sPropCluster" % BIOMES[index].name.replace(" ", ""))
		prop.flip_h = side > 0.0
		prop.modulate = prop_tints[index]
		prop.modulate.a = randf_range(0.94, 1.0)
		prop_number += 1

func _build_game_viewport() -> void:
	game_viewport_container = SubViewportContainer.new()
	game_viewport_container.name = "GameplayViewportContainer"
	game_viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game_viewport_container.stretch = true
	game_viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(game_viewport_container)
	game_viewport = SubViewport.new()
	game_viewport.name = "GameplayViewport"
	game_viewport.size = Vector2i.ONE
	game_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	game_viewport.handle_input_locally = false
	game_viewport_container.add_child(game_viewport)

func _sync_ad_bar() -> void:
	AdBarService.attach_to(self)

func _ad_bottom_reserve() -> float:
	if validation_ad_reserve > 0.0:
		return validation_ad_reserve
	if ad_preview_mode:
		return AD_PREVIEW_HEIGHT
	return maxf(0.0, AdBarService.banner_height())

func refresh_ad_layout() -> void:
	var reserve := clampf(_ad_bottom_reserve(), 0.0, 180.0)
	applied_ad_reserve = reserve
	if is_instance_valid(game_viewport_container):
		game_viewport_container.offset_bottom = -reserve
	if is_instance_valid(ui_content_root):
		ui_content_root.offset_bottom = -reserve
	if is_instance_valid(ad_reserve_rect):
		ad_reserve_rect.visible = reserve > 0.0
		ad_reserve_rect.offset_top = -reserve
	if is_instance_valid(ad_preview_label):
		ad_preview_label.visible = reserve > 0.0 and (ad_preview_mode or validation_ad_reserve > 0.0)
		ad_preview_label.offset_top = -reserve
	var viewport_size := get_viewport().get_visible_rect().size
	_apply_orientation_layout(Vector2(viewport_size.x, maxf(1.0, viewport_size.y - reserve)))

func _apply_orientation_layout(content_size: Vector2) -> void:
	if content_size.x <= 1.0 or content_size.y <= 1.0:
		return
	portrait_layout = content_size.y > content_size.x
	if portrait_layout:
		camera_home_position = Vector3(0.0, 5.8, 12.8)
		camera_look_target = Vector3(0.0, 2.15, -15.0)
	else:
		camera_home_position = Vector3(0.0, 5.6, 11.5)
		camera_look_target = Vector3(0.0, 2.1, -16.0)
	if is_instance_valid(camera):
		camera.position = camera_home_position
		camera.fov = 82.0 if portrait_layout else 63.0
		camera.look_at_from_position(camera.position, camera_look_target)
	if not is_instance_valid(ui_content_root):
		return

	if portrait_layout:
		_position_center_panel(menu_panel, Vector2(minf(1080.0, content_size.x - 64.0), minf(1240.0, content_size.y - 80.0)))
		menu_margin.add_theme_constant_override("margin_left", 58)
		menu_margin.add_theme_constant_override("margin_right", 58)
		menu_margin.add_theme_constant_override("margin_top", 44)
		menu_margin.add_theme_constant_override("margin_bottom", 42)
		menu_box.add_theme_constant_override("separation", 16)
		menu_logo.custom_minimum_size.y = 360.0
		_set_font_size(menu_tagline, 31)
		_set_font_size(menu_wallet, 30)
		_set_font_size(loadout_skin_label, 27)
		_set_font_size(loadout_ability_label, 27)
		_set_font_size(daily_label, 26)
		_set_font_size(start_button, 40)
		_set_font_size(shop_button, 32)
		_set_font_size(leaderboard_button, 32)
		_set_font_size(control_help_label, 23)
		_set_font_size(privacy_button, 20)
		_set_font_size(music_toggle_button, 20)
		loadout_ability_panel.custom_minimum_size.y = 82.0
		daily_label.custom_minimum_size.y = 60.0
		start_button.custom_minimum_size.y = 126.0
		shop_button.custom_minimum_size.y = 92.0
		leaderboard_button.custom_minimum_size.y = 92.0
		control_help_label.custom_minimum_size.y = 48.0
		privacy_button.custom_minimum_size.y = 48.0
		music_toggle_button.custom_minimum_size.y = 48.0
		_position_center_panel(result_panel, Vector2(minf(1080.0, content_size.x - 64.0), minf(1320.0, content_size.y - 96.0)))
		_position_center_panel(shop_panel, Vector2(minf(1120.0, content_size.x - 64.0), minf(1640.0, content_size.y - 96.0)))
		_position_center_panel(pause_panel, Vector2(minf(440.0, content_size.x - 32.0), 340.0))
		_position_center_panel(scores_panel, Vector2(minf(1080.0, content_size.x - 64.0), minf(1320.0, content_size.y - 96.0)))
		if is_instance_valid(scores_title):
			_set_font_size(scores_title, 40)
			_set_font_size(scores_status, 22)
			_set_font_size(scores_native_button, 22)
			_set_font_size(scores_back_button, 26)
			scores_native_button.custom_minimum_size.y = 72.0
			scores_back_button.custom_minimum_size.y = 84.0
		hud_top_panel.offset_left = 18.0
		hud_top_panel.offset_top = 16.0
		hud_top_panel.offset_right = -18.0
		hud_top_panel.offset_bottom = 286.0
		hud_margin.add_theme_constant_override("margin_left", 20)
		hud_margin.add_theme_constant_override("margin_right", 20)
		hud_margin.add_theme_constant_override("margin_top", 18)
		hud_margin.add_theme_constant_override("margin_bottom", 18)
		hud_box.add_theme_constant_override("separation", 12)
		hud_stats.columns = 3
		hud_stats.add_theme_constant_override("h_separation", 12)
		hud_stats.add_theme_constant_override("v_separation", 0)
		_style_hud_cards(true)
		_set_font_size(goal_label, 25)
		_set_font_size(biome_label, 24)
		_set_font_size(goal_detail_label, 22)
		goal_progress.custom_minimum_size.y = 28.0
		power_button.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		power_button.offset_left = 90.0
		power_button.offset_top = -820.0
		power_button.offset_right = 430.0
		power_button.offset_bottom = -640.0
		power_button.add_theme_constant_override("icon_max_width", 92)
		_set_font_size(power_button, 27)
		_set_font_size(toast_label, 28)
		_position_top_center(toast_label, minf(700.0, content_size.x - 48.0), 310.0, 90.0)
	else:
		menu_panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
		menu_panel.offset_left = 42.0
		menu_panel.offset_top = 18.0
		menu_panel.offset_right = 532.0
		menu_panel.offset_bottom = -18.0
		menu_margin.add_theme_constant_override("margin_left", 34)
		menu_margin.add_theme_constant_override("margin_right", 34)
		menu_margin.add_theme_constant_override("margin_top", 24)
		menu_margin.add_theme_constant_override("margin_bottom", 24)
		menu_box.add_theme_constant_override("separation", 10)
		menu_logo.custom_minimum_size.y = 172.0
		_set_font_size(menu_tagline, 16)
		_set_font_size(menu_wallet, 18)
		_set_font_size(loadout_skin_label, 16)
		_set_font_size(loadout_ability_label, 16)
		_set_font_size(daily_label, 15)
		_set_font_size(start_button, 25)
		_set_font_size(shop_button, 17)
		_set_font_size(leaderboard_button, 17)
		_set_font_size(control_help_label, 14)
		_set_font_size(privacy_button, 14)
		_set_font_size(music_toggle_button, 14)
		loadout_ability_panel.custom_minimum_size.y = 58.0
		daily_label.custom_minimum_size.y = 46.0
		start_button.custom_minimum_size.y = 66.0
		shop_button.custom_minimum_size.y = 50.0
		leaderboard_button.custom_minimum_size.y = 50.0
		control_help_label.custom_minimum_size.y = 34.0
		privacy_button.custom_minimum_size.y = 32.0
		music_toggle_button.custom_minimum_size.y = 32.0
		_position_center_panel(result_panel, Vector2(minf(1040.0, content_size.x - 36.0), minf(600.0, content_size.y - 28.0)))
		_position_center_panel(shop_panel, Vector2(minf(980.0, content_size.x - 32.0), minf(620.0, content_size.y - 24.0)))
		_position_center_panel(pause_panel, Vector2(420.0, 320.0))
		_position_center_panel(scores_panel, Vector2(minf(980.0, content_size.x - 36.0), minf(620.0, content_size.y - 28.0)))
		if is_instance_valid(scores_title):
			_set_font_size(scores_title, 28)
			_set_font_size(scores_status, 15)
			_set_font_size(scores_native_button, 13)
			_set_font_size(scores_back_button, 16)
			scores_native_button.custom_minimum_size.y = 46.0
			scores_back_button.custom_minimum_size.y = 50.0
		hud_top_panel.offset_left = 26.0
		hud_top_panel.offset_top = 20.0
		hud_top_panel.offset_right = -26.0
		hud_top_panel.offset_bottom = 180.0
		hud_margin.add_theme_constant_override("margin_left", 18)
		hud_margin.add_theme_constant_override("margin_right", 18)
		hud_margin.add_theme_constant_override("margin_top", 12)
		hud_margin.add_theme_constant_override("margin_bottom", 12)
		hud_box.add_theme_constant_override("separation", 8)
		hud_stats.columns = 3
		hud_stats.add_theme_constant_override("h_separation", 14)
		hud_stats.add_theme_constant_override("v_separation", 0)
		_style_hud_cards(false)
		_set_font_size(goal_label, 16)
		_set_font_size(biome_label, 16)
		_set_font_size(goal_detail_label, 14)
		goal_progress.custom_minimum_size.y = 16.0
		power_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		power_button.offset_left = -300.0
		power_button.offset_top = -190.0
		power_button.offset_right = -34.0
		power_button.offset_bottom = -54.0
		power_button.add_theme_constant_override("icon_max_width", 70)
		_set_font_size(power_button, 20)
		_set_font_size(toast_label, 20)
		_position_top_center(toast_label, 560.0, 196.0, 58.0)
	_apply_shop_layout()
	_apply_result_layout()

	if mobile_mode:
		control_help_label.text = "SWIPE TO MOVE  •  SWIPE UP TO JUMP  •  SWIPE DOWN TO DUCK"
	else:
		control_help_label.text = "ARROW KEYS TO MOVE  •  SPACE TO JUMP  •  E FOR RUNNER GIFT"

func _set_font_size(control: Control, font_size: int) -> void:
	if is_instance_valid(control):
		control.add_theme_font_size_override("font_size", font_size)

func _apply_shop_layout() -> void:
	if not is_instance_valid(shop_panel):
		return
	if portrait_layout:
		shop_margin.add_theme_constant_override("margin_left", 40)
		shop_margin.add_theme_constant_override("margin_right", 40)
		shop_margin.add_theme_constant_override("margin_top", 38)
		shop_margin.add_theme_constant_override("margin_bottom", 38)
		shop_box.add_theme_constant_override("separation", 20)
		shop_cards.columns = 2
		shop_cards.add_theme_constant_override("h_separation", 24)
		shop_cards.add_theme_constant_override("v_separation", 24)
		shop_scroll.custom_minimum_size.y = 1010.0
		shop_cards.custom_minimum_size.y = 0.0
		shop_navigation.custom_minimum_size.y = 76.0
		_set_font_size(shop_previous_button, 21)
		_set_font_size(shop_page_label, 20)
		_set_font_size(shop_next_button, 21)
		shop_medal_row.columns = 5
		shop_medal_row.add_theme_constant_override("h_separation", 14)
		shop_medal_row.add_theme_constant_override("v_separation", 8)
		shop_medal_row.custom_minimum_size.y = 116.0
		_set_font_size(shop_heading, 42)
		_set_font_size(shop_wallet, 28)
		_set_font_size(shop_medals, 23)
		_set_font_size(shop_back, 28)
		shop_heading.custom_minimum_size.y = 106.0
		shop_wallet.custom_minimum_size.y = 62.0
		shop_back.custom_minimum_size.y = 88.0
	else:
		shop_margin.add_theme_constant_override("margin_left", 30)
		shop_margin.add_theme_constant_override("margin_right", 30)
		shop_margin.add_theme_constant_override("margin_top", 24)
		shop_margin.add_theme_constant_override("margin_bottom", 24)
		shop_box.add_theme_constant_override("separation", 8)
		shop_cards.columns = 4
		shop_cards.add_theme_constant_override("h_separation", 12)
		shop_cards.add_theme_constant_override("v_separation", 12)
		shop_scroll.custom_minimum_size.y = 284.0
		shop_cards.custom_minimum_size.y = 0.0
		shop_navigation.custom_minimum_size.y = 42.0
		_set_font_size(shop_previous_button, 14)
		_set_font_size(shop_page_label, 13)
		_set_font_size(shop_next_button, 14)
		shop_medal_row.columns = 9
		shop_medal_row.add_theme_constant_override("h_separation", 8)
		shop_medal_row.add_theme_constant_override("v_separation", 0)
		shop_medal_row.custom_minimum_size.y = 52.0
		_set_font_size(shop_heading, 28)
		_set_font_size(shop_wallet, 16)
		_set_font_size(shop_medals, 14)
		_set_font_size(shop_back, 16)
		shop_heading.custom_minimum_size.y = 52.0
		shop_wallet.custom_minimum_size.y = 28.0
		shop_back.custom_minimum_size.y = 46.0
	for card in shop_cards.get_children():
		_style_shop_card(card)
	for medal_bubble in shop_medal_row.get_children():
		medal_bubble.custom_minimum_size = Vector2(112, 104) if portrait_layout else Vector2(62, 48)
	call_deferred("_refresh_shop_navigation")

func _apply_result_layout() -> void:
	if not is_instance_valid(result_panel):
		return
	if portrait_layout:
		result_margin.add_theme_constant_override("margin_left", 44)
		result_margin.add_theme_constant_override("margin_right", 44)
		result_margin.add_theme_constant_override("margin_top", 40)
		result_margin.add_theme_constant_override("margin_bottom", 40)
		result_box.add_theme_constant_override("separation", 18)
		result_title.custom_minimum_size.y = 112.0
		result_subtitle.custom_minimum_size.y = 58.0
		_set_font_size(result_title, 44)
		_set_font_size(result_subtitle, 25)
		result_runner_portrait.custom_minimum_size = Vector2(360, 330)
		result_medal_icon.custom_minimum_size = Vector2(250, 220)
		_set_font_size(result_medal_name, 25)
		result_stats_grid.columns = 2
		result_stats_grid.add_theme_constant_override("h_separation", 20)
		result_stats_grid.add_theme_constant_override("v_separation", 20)
		_style_result_stat_cards(true)
		result_bonus.custom_minimum_size.y = 78.0
		_set_font_size(result_bonus, 25)
		result_actions.columns = 1
		result_actions.add_theme_constant_override("v_separation", 16)
		result_retry_button.custom_minimum_size.y = 108.0
		result_home_button.custom_minimum_size.y = 78.0
		result_leaderboard_button.custom_minimum_size.y = 78.0
		_set_font_size(result_retry_button, 34)
		_set_font_size(result_home_button, 25)
		_set_font_size(result_leaderboard_button, 25)
	else:
		result_margin.add_theme_constant_override("margin_left", 34)
		result_margin.add_theme_constant_override("margin_right", 34)
		result_margin.add_theme_constant_override("margin_top", 24)
		result_margin.add_theme_constant_override("margin_bottom", 24)
		result_box.add_theme_constant_override("separation", 8)
		result_title.custom_minimum_size.y = 62.0
		result_subtitle.custom_minimum_size.y = 30.0
		_set_font_size(result_title, 31)
		_set_font_size(result_subtitle, 17)
		result_runner_portrait.custom_minimum_size = Vector2(250, 176)
		result_medal_icon.custom_minimum_size = Vector2(150, 134)
		_set_font_size(result_medal_name, 16)
		result_stats_grid.columns = 4
		result_stats_grid.add_theme_constant_override("h_separation", 12)
		result_stats_grid.add_theme_constant_override("v_separation", 8)
		_style_result_stat_cards(false)
		result_bonus.custom_minimum_size.y = 42.0
		_set_font_size(result_bonus, 16)
		result_actions.columns = 3
		result_actions.add_theme_constant_override("h_separation", 14)
		result_retry_button.custom_minimum_size.y = 62.0
		result_home_button.custom_minimum_size.y = 62.0
		result_leaderboard_button.custom_minimum_size.y = 62.0
		_set_font_size(result_retry_button, 24)
		_set_font_size(result_home_button, 18)
		_set_font_size(result_leaderboard_button, 18)

func _position_center_panel(panel: Control, panel_size: Vector2) -> void:
	if not is_instance_valid(panel):
		return
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -panel_size.x * 0.5
	panel.offset_top = -panel_size.y * 0.5
	panel.offset_right = panel_size.x * 0.5
	panel.offset_bottom = panel_size.y * 0.5

func _build_world() -> void:
	world = Node3D.new()
	world.name = "World3D"
	game_viewport.add_child(world)
	world_environment = WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = BIOMES[0].sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#b9ddf3")
	environment.ambient_light_energy = 0.7
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.glow_enabled = true
	environment.glow_intensity = 0.55
	environment.fog_enabled = true
	environment.fog_light_color = BIOMES[0].sky
	environment.fog_density = 0.008
	environment.fog_sky_affect = 0.45
	world_environment.environment = environment
	world.add_child(world_environment)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	world.add_child(sun)
	fill_light = OmniLight3D.new()
	fill_light.position = Vector3(0, 4, 2)
	fill_light.omni_range = 16.0
	fill_light.light_energy = 0.7
	world.add_child(fill_light)
	camera = Camera3D.new()
	camera.position = camera_home_position
	camera.fov = 63.0
	camera.look_at_from_position(camera.position, camera_look_target)
	world.add_child(camera)
	track_root = Node3D.new()
	world.add_child(track_root)
	for i in range(7):
		var tile := Node3D.new()
		tile.position.z = -120.0 + i * 24.0
		track_root.add_child(tile)
		var ground := _box(tile, Vector3(0, -0.25, 0), Vector3(30.0, 0.5, 24.2), BIOMES[0].ground)
		ground.name = "Ground"
		var road := _box(tile, Vector3(0, 0, 0), Vector3(9.4, 0.18, 24.2), BIOMES[0].track)
		road.name = "Road"
		for lane_x in [-1.4, 1.4]:
			_box(tile, Vector3(lane_x, 0.11, 0), Vector3(0.07, 0.025, 24.0), Color(1, 1, 1, 0.72))
		for edge_x in [-4.55, 4.55]:
			_box(tile, Vector3(edge_x, 0.12, 0), Vector3(0.12, 0.035, 24.0), Color.WHITE)
		track_tiles.append(tile)
	prop_root = Node3D.new()
	world.add_child(prop_root)
	_build_stadium_art()
	_build_biome_backdrops()
	obstacle_root = Node3D.new()
	world.add_child(obstacle_root)
	particle_root = Node3D.new()
	world.add_child(particle_root)
	player = DashPlayer.new()
	world.add_child(player)
	player.crash_finished.connect(_on_crash_finished)
	_build_power_effects()
	_rebuild_props(0)

func _build_stadium_art() -> void:
	stadium_art_root = Node3D.new()
	stadium_art_root.name = "ClassicStadiumArt"
	world.add_child(stadium_art_root)
	biome_art_roots.append(stadium_art_root)

	# A distant full vista locks the horizon, canopy, sky, and end-zone crowd together.
	var vista := Sprite3D.new()
	vista.name = "StadiumVista"
	vista.texture = load("res://assets/generated/classic_stadium_vista.png")
	vista.position = Vector3(0.0, 15.0, -126.0)
	vista.pixel_size = 0.15
	# Treat the 16:9 vista like a cover image. Overscan keeps the environment
	# color from appearing at the trapezoidal edges on wide screens or shake.
	vista.scale = Vector3.ONE * VISTA_OVERSCAN
	vista.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	vista.shaded = false
	vista.double_sided = true
	vista.render_priority = -2
	stadium_art_root.add_child(vista)

func _build_biome_backdrops() -> void:
	# Classic uses the single complete stadium vista above. Every other biome gets
	# its own original generated vista plus sparse procedural foreground props.
	for biome_index in range(1, BIOME_BACKDROP_PATHS.size()):
		var art_root := Node3D.new()
		art_root.name = "%sArt" % BIOMES[biome_index].name.replace(" ", "")
		art_root.visible = false
		world.add_child(art_root)
		var vista := Sprite3D.new()
		vista.name = "Vista"
		vista.texture = load(BIOME_BACKDROP_PATHS[biome_index])
		vista.position = Vector3(0.0, 15.0, -126.0)
		vista.pixel_size = 0.15
		vista.scale = Vector3.ONE * VISTA_OVERSCAN
		vista.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		vista.shaded = false
		vista.double_sided = true
		vista.render_priority = -2
		art_root.add_child(vista)
		biome_art_roots.append(art_root)

func _shuffle_biome_sequence() -> void:
	# Always open in the signature stadium, then tour every other unique biome
	# exactly once in a fresh order before the sequence repeats.
	var remaining: Array[int] = []
	for biome_index in range(1, BIOMES.size()):
		remaining.append(biome_index)
	remaining.shuffle()
	biome_sequence = [0]
	biome_sequence.append_array(remaining)

func _spawn_puff(origin: Vector3, color: Color, count: int) -> void:
	var sprite_count := clampi(int(ceil(float(count) / 4.0)), 3, 7)
	for i in sprite_count:
		var effect_cell: int = [0, 1, 2][i % 3]
		var node := _sprite_3d(particle_root, _atlas_texture(EFFECTS_MEDALS_ATLAS_PATH, 3, 2, effect_cell), origin + Vector3(randf_range(-0.45, 0.45), randf_range(-0.15, 0.45), 0.0), randf_range(0.0028, 0.0039), "CuteImpactEffect")
		node.modulate = color.lerp(Color.WHITE, 0.62)
		node.rotation.z = randf_range(-0.45, 0.45)
		var velocity := Vector3(randf_range(-5, 5), randf_range(2.5, 7.5), randf_range(-2, 4))
		puff_particles.append({"node": node, "velocity": velocity, "life": randf_range(0.7, 1.35)})

func _update_particles(delta: float) -> void:
	for index in range(puff_particles.size() - 1, -1, -1):
		var item: Dictionary = puff_particles[index]
		var node: Node3D = item.node
		if not is_instance_valid(node):
			puff_particles.remove_at(index)
			continue
		item.life -= delta
		item.velocity.y -= 9.0 * delta
		node.position += item.velocity * delta
		node.rotation.z += delta * 8.0
		node.scale *= 0.985
		if item.life <= 0.0:
			puff_particles.remove_at(index)
			node.queue_free()

func _build_audio() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SoundEffectsPlayer"
	add_child(sfx_player)
	pickup_sound = _synth_sound(0.18, 720.0, 1120.0, "sine")
	neck_squawk_sound = _synth_bird_reaction("neck_flip")
	trip_yelp_sound = _synth_bird_reaction("trip")
	spin_sound = _synth_sound(0.72, 130.0, 72.0, "honk")
	success_sound = _synth_sound(0.55, 420.0, 880.0, "sparkle")
	music_player = AudioStreamPlayer.new()
	music_player.name = "BackgroundMusicPlayer"
	music_player.volume_db = -15.0
	add_child(music_player)
	background_music = _synth_background_music()
	music_player.stream = background_music
	_update_music_button()
	if GameManager.music_enabled and DisplayServer.get_name() != "headless":
		music_player.play()

func _synth_background_music() -> AudioStreamWAV:
	# An original, compact four-chord marimba loop generated at startup keeps the
	# APK self-contained and avoids licensing a third-party recording.
	var sample_rate := 22050
	var bpm := 132.0
	var total_beats := 16.0
	var duration := total_beats * 60.0 / bpm
	var count := int(duration * sample_rate)
	var melody: Array[int] = [
		72, 76, 79, 76, 74, 77, 81, 77,
		72, 76, 79, 83, 81, 79, 76, 74,
		72, 77, 81, 77, 74, 79, 83, 79,
		71, 74, 79, 74, 72, 76, 79, 83,
	]
	var chord_roots: Array[int] = [48, 45, 53, 55]
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	for i in count:
		var seconds := float(i) / float(sample_rate)
		var beat := seconds * bpm / 60.0
		var melody_step := int(floor(beat * 2.0)) % melody.size()
		var step_time := fmod(beat * 2.0, 1.0)
		var melody_hz := 440.0 * pow(2.0, (float(melody[melody_step]) - 69.0) / 12.0)
		var pluck_envelope := exp(-5.4 * step_time)
		var pluck := (sin(TAU * melody_hz * seconds) * 0.72 + sin(TAU * melody_hz * 2.01 * seconds) * 0.28) * pluck_envelope
		var chord_index := int(floor(beat / 4.0)) % chord_roots.size()
		var root_note := chord_roots[chord_index]
		var root_hz := 440.0 * pow(2.0, (float(root_note) - 69.0) / 12.0)
		var bass_time := fmod(beat, 1.0)
		var bass := sin(TAU * root_hz * seconds) * exp(-3.4 * bass_time)
		var third_hz := root_hz * pow(2.0, 4.0 / 12.0)
		var fifth_hz := root_hz * pow(2.0, 7.0 / 12.0)
		var pad := (sin(TAU * root_hz * 2.0 * seconds) + sin(TAU * third_hz * 2.0 * seconds) + sin(TAU * fifth_hz * 2.0 * seconds)) / 3.0
		var kick_time := fmod(beat, 1.0)
		var kick := sin(TAU * (72.0 - kick_time * 24.0) * seconds) * exp(-10.0 * kick_time)
		var half_beat := fmod(beat * 2.0, 1.0)
		var sparkle_noise := sin(float(i) * 12.9898) * sin(float(i) * 0.071)
		var sparkle := sparkle_noise * exp(-14.0 * half_beat) * (0.45 if melody_step % 2 == 1 else 0.16)
		var mix := pluck * 0.38 + bass * 0.2 + pad * 0.12 + kick * 0.17 + sparkle * 0.08
		var edge_fade := clampf(minf(seconds, duration - seconds) / 0.035, 0.0, 1.0)
		var sample := clampi(int(mix * edge_fade * 24500.0), -32768, 32767)
		bytes[i * 2] = sample & 0xff
		bytes[i * 2 + 1] = (sample >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = count
	stream.data = bytes
	return stream

func _toggle_music() -> void:
	GameManager.set_music_enabled(not GameManager.music_enabled)
	if GameManager.music_enabled:
		if DisplayServer.get_name() != "headless" and not music_player.playing:
			music_player.play()
	else:
		music_player.stop()
	_update_music_button()

func _update_music_button() -> void:
	if not is_instance_valid(music_toggle_button):
		return
	music_toggle_button.text = "♫  MUSIC ON" if GameManager.music_enabled else "♫  MUSIC OFF"
	music_toggle_button.modulate = Color.WHITE if GameManager.music_enabled else Color(0.65, 0.72, 0.78, 1.0)

func _synth_sound(duration: float, start_hz: float, end_hz: float, style: String) -> AudioStreamWAV:
	var sample_rate := 22050
	var count := int(duration * sample_rate)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var phase := 0.0
	for i in count:
		var t := float(i) / float(count)
		var frequency := lerpf(start_hz, end_hz, t)
		phase += TAU * frequency / sample_rate
		var wave := sin(phase)
		if style == "honk":
			wave = sin(phase) * 0.55 + sin(phase * 2.03) * 0.28 + sin(phase * 0.49) * 0.17
		elif style == "thud":
			wave = sin(phase) * 0.72 + sin(phase * 0.37) * 0.28
		elif style == "sparkle":
			wave = sin(phase) * 0.65 + sin(phase * 1.5) * 0.35
		var envelope := sin(PI * t) * (1.0 - t * 0.32)
		var sample := clampi(int(wave * envelope * 24500.0), -32768, 32767)
		bytes[i * 2] = sample & 0xff
		bytes[i * 2 + 1] = (sample >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream

func _synth_bird_reaction(reaction: String) -> AudioStreamWAV:
	# Original layered vocal effects: a fast frequency sweep supplies the bird
	# call, noisy harmonics add the raspy chicken quality, and a low impact layer
	# makes each collision feel substantial on phone speakers.
	var sample_rate := 22050
	var duration := 1.18 if reaction == "neck_flip" else 0.92
	var count := int(duration * sample_rate)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var phase := 0.0
	for i in count:
		var seconds := float(i) / float(sample_rate)
		var t := float(i) / float(count)
		var frequency: float
		var voice_envelope: float
		var voice: float
		var impact: float
		var deterministic_noise := sin(float(i) * 12.9898 + 0.31) * sin(float(i) * 0.071 + 1.7)
		if reaction == "neck_flip":
			# "BA-KAW-WAAAH!": a sharp startled rise followed by a long falling cry.
			var first_call_t := clampf(t / 0.28, 0.0, 1.0)
			var long_call_t := clampf((t - 0.24) / 0.76, 0.0, 1.0)
			frequency = lerpf(510.0, 1040.0, first_call_t)
			if t >= 0.24:
				frequency = lerpf(930.0, 185.0, pow(long_call_t, 0.72))
			frequency += sin(TAU * 24.0 * seconds) * (70.0 * (1.0 - t))
			var first_burst := sin(PI * first_call_t) if t < 0.28 else 0.0
			var long_burst := sin(PI * long_call_t) if t >= 0.24 else 0.0
			voice_envelope = maxf(first_burst, long_burst * 0.92) * (1.0 - t * 0.12)
			phase += TAU * frequency / float(sample_rate)
			voice = (
				sin(phase) * 0.46
				+ sin(phase * 2.03) * 0.28
				+ sin(phase * 3.97) * 0.14
				+ deterministic_noise * 0.18
			) * voice_envelope
			impact = sin(TAU * lerpf(118.0, 54.0, t) * seconds) * exp(-19.0 * t) * 0.55
		else:
			# "BWAAK-uk-uk!": a falling alarm call with two short stumbling chirps.
			frequency = lerpf(780.0, 165.0, pow(t, 0.58))
			frequency += sin(TAU * 18.0 * seconds) * 58.0
			var main_cry := sin(PI * clampf(t / 0.62, 0.0, 1.0)) if t < 0.62 else 0.0
			var chirp_one := sin(PI * clampf((t - 0.58) / 0.18, 0.0, 1.0)) if t >= 0.58 and t < 0.76 else 0.0
			var chirp_two := sin(PI * clampf((t - 0.75) / 0.2, 0.0, 1.0)) if t >= 0.75 else 0.0
			voice_envelope = maxf(main_cry, maxf(chirp_one * 0.72, chirp_two * 0.56))
			phase += TAU * frequency / float(sample_rate)
			voice = (
				sin(phase) * 0.5
				+ sin(phase * 1.91) * 0.23
				+ sin(phase * 3.08) * 0.12
				+ deterministic_noise * 0.15
			) * voice_envelope
			var thud_time := clampf(t / 0.24, 0.0, 1.0)
			impact = sin(TAU * lerpf(96.0, 42.0, thud_time) * seconds) * exp(-15.0 * t) * 0.72
		var edge_fade := clampf(minf(seconds, duration - seconds) / 0.012, 0.0, 1.0)
		var sample := clampi(int((voice * 0.82 + impact) * edge_fade * 24500.0), -32768, 32767)
		bytes[i * 2] = sample & 0xff
		bytes[i * 2 + 1] = (sample >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	stream.set_meta("reaction", reaction)
	return stream

func _crash_sound_for(crash_kind: String) -> AudioStreamWAV:
	match crash_kind:
		"trip":
			return trip_yelp_sound
		"bar_flip":
			return neck_squawk_sound
		_:
			return spin_sound

func _play_sound(stream: AudioStream, volume_db: float) -> void:
	if not audio_enabled:
		return
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.play()

func _atlas_texture(path: String, columns: int, rows: int, index: int) -> AtlasTexture:
	var cache_key := "%s:%d:%d:%d" % [path, columns, rows, index]
	if _atlas_cache.has(cache_key):
		return _atlas_cache[cache_key]
	var source: Texture2D = load(path)
	var cell_width := float(source.get_width()) / float(columns)
	var cell_height := float(source.get_height()) / float(rows)
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = Rect2(
		float(index % columns) * cell_width,
		float(floori(float(index) / float(columns))) * cell_height,
		cell_width,
		cell_height
	)
	_atlas_cache[cache_key] = atlas
	return atlas

func _sprite_3d(parent: Node3D, texture: Texture2D, pos: Vector3, pixel_size: float, node_name: String) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.name = node_name
	sprite.texture = texture
	sprite.position = pos
	sprite.pixel_size = pixel_size
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	sprite.shaded = false
	sprite.double_sided = true
	sprite.render_priority = 2
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(sprite)
	return sprite

func _surface_material(index: int, tint: Color, roughness: float) -> StandardMaterial3D:
	var cache_key := "%d:%s:%s" % [index, tint, roughness]
	if _surface_material_cache.has(cache_key):
		return _surface_material_cache[cache_key]
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(SURFACE_PATHS[clampi(index, 0, SURFACE_PATHS.size() - 1)])
	mat.albedo_color = tint
	mat.roughness = roughness
	mat.uv1_scale = Vector3(4.0, 4.0, 4.0)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_surface_material_cache[cache_key] = mat
	return mat

func _material(color: Color, roughness := 0.7) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat

func _mesh(parent: Node3D, primitive: PrimitiveMesh, pos: Vector3, scale_value: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = primitive
	node.position = pos
	node.scale = scale_value
	node.material_override = _material(color)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(node)
	return node

func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	var node := _mesh(parent, shape, pos, Vector3.ONE, color)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node

func _sphere(parent: Node3D, pos: Vector3, scale_value: Vector3, color: Color) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 16
	shape.rings = 10
	return _mesh(parent, shape, pos, scale_value * 2.0, color)

func _capsule(parent: Node3D, pos: Vector3, scale_value: Vector3, color: Color) -> MeshInstance3D:
	var shape := CapsuleMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 12
	shape.rings = 5
	return _mesh(parent, shape, pos, scale_value, color)

func _cone(parent: Node3D, pos: Vector3, scale_value: Vector3, color: Color) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = 0.05
	shape.bottom_radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 12
	return _mesh(parent, shape, pos, scale_value, color)

func _torus(parent: Node3D, pos: Vector3, scale_value: Vector3, color: Color) -> MeshInstance3D:
	var shape := TorusMesh.new()
	shape.inner_radius = 0.3
	shape.outer_radius = 0.5
	shape.rings = 16
	shape.ring_segments = 8
	return _mesh(parent, shape, pos, scale_value, color)

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)
	ui_content_root = Control.new()
	ui_content_root.name = "GameContentRoot"
	ui_content_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_content_root.clip_contents = true
	var app_theme := Theme.new()
	app_theme.default_font = load(UI_FONT_PATH)
	app_theme.default_font_size = 18
	ui_content_root.theme = app_theme
	canvas.add_child(ui_content_root)
	menu_layer = Control.new()
	menu_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_content_root.add_child(menu_layer)
	menu_background = TextureRect.new()
	menu_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_background.texture = load("res://assets/generated/ostrich_dash_key_art.png")
	menu_background.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	menu_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	menu_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	menu_layer.add_child(menu_background)
	var menu_shade := ColorRect.new()
	menu_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_shade.color = Color(0.01, 0.035, 0.085, 0.26)
	menu_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_layer.add_child(menu_shade)

	menu_panel = PanelContainer.new()
	menu_panel.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	menu_panel.offset_left = 42
	menu_panel.offset_top = 18
	menu_panel.offset_right = 532
	menu_panel.offset_bottom = -18
	var menu_panel_style := _panel_style(Color(0.018, 0.065, 0.13, 0.92), Color("#54eadb"), 4, 52)
	menu_panel_style.shadow_color = Color(0.0, 0.015, 0.06, 0.66)
	menu_panel_style.shadow_size = 28
	menu_panel_style.shadow_offset = Vector2(0, 8)
	menu_panel.add_theme_stylebox_override("panel", menu_panel_style)
	menu_layer.add_child(menu_panel)
	menu_margin = MarginContainer.new()
	menu_margin.add_theme_constant_override("margin_left", 30)
	menu_margin.add_theme_constant_override("margin_right", 30)
	menu_margin.add_theme_constant_override("margin_top", 24)
	menu_margin.add_theme_constant_override("margin_bottom", 24)
	menu_panel.add_child(menu_margin)
	menu_box = VBoxContainer.new()
	menu_box.add_theme_constant_override("separation", 10)
	menu_margin.add_child(menu_box)
	menu_logo = TextureRect.new()
	menu_logo.name = "OstrichDashTitleLogo"
	menu_logo.texture = load(MENU_LOGO_PATH)
	menu_logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	menu_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	menu_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	menu_logo.custom_minimum_size.y = 172
	menu_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_box.add_child(menu_logo)
	menu_tagline = _label("RUN WILD  •  DODGE FAST  •  COLLECT FEATHERS", 16, Color("#fff0c2"))
	menu_tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_set_bold(menu_tagline)
	menu_box.add_child(menu_tagline)
	var stats_panel := PanelContainer.new()
	stats_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.12, 0.2, 0.88), Color("#7ceee3"), 2, 24))
	stats_panel.custom_minimum_size.y = 42
	menu_box.add_child(stats_panel)
	menu_wallet = _label("", 18, Color.WHITE)
	menu_wallet.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_wallet.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_set_bold(menu_wallet)
	stats_panel.add_child(menu_wallet)
	loadout_skin_label = _label("", 16, Color("#d9f5ff"))
	loadout_skin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_box.add_child(loadout_skin_label)
	loadout_ability_panel = PanelContainer.new()
	loadout_ability_panel.name = "RunnerAbilityCard"
	loadout_ability_panel.custom_minimum_size.y = 58
	loadout_ability_panel.add_theme_stylebox_override("panel", _panel_style(Color("#173c5d"), Color("#51ded1"), 3, 26))
	menu_box.add_child(loadout_ability_panel)
	var ability_margin := MarginContainer.new()
	ability_margin.add_theme_constant_override("margin_left", 16)
	ability_margin.add_theme_constant_override("margin_right", 16)
	ability_margin.add_theme_constant_override("margin_top", 6)
	ability_margin.add_theme_constant_override("margin_bottom", 6)
	loadout_ability_panel.add_child(ability_margin)
	var ability_row := HBoxContainer.new()
	ability_row.add_theme_constant_override("separation", 12)
	ability_margin.add_child(ability_row)
	loadout_ability_icon = TextureRect.new()
	loadout_ability_icon.name = "RunnerAbilityIcon"
	loadout_ability_icon.custom_minimum_size = Vector2(46, 46)
	loadout_ability_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	loadout_ability_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	loadout_ability_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	loadout_ability_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ability_row.add_child(loadout_ability_icon)
	loadout_ability_label = _label("", 16, Color.WHITE)
	loadout_ability_label.name = "RunnerAbilityDescription"
	loadout_ability_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loadout_ability_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	loadout_ability_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_set_bold(loadout_ability_label)
	ability_row.add_child(loadout_ability_label)
	daily_label = _label("", 15, Color("#ffe9a6"))
	daily_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	daily_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	daily_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	daily_label.custom_minimum_size.y = 46
	daily_label.add_theme_stylebox_override("normal", _panel_style(Color(0.36, 0.21, 0.035, 0.58), Color("#ffd166"), 2, 24))
	menu_box.add_child(daily_label)
	start_button = _button("PLAY NOW", Color("#f5534d"), Color("#ffd05a"), 25)
	start_button.custom_minimum_size.y = 66
	start_button.pressed.connect(_start_run)
	menu_box.add_child(start_button)
	var discovery_row := HBoxContainer.new()
	discovery_row.name = "DiscoveryButtons"
	discovery_row.add_theme_constant_override("separation", 12)
	menu_box.add_child(discovery_row)
	shop_button = _button("CUSTOMIZE", Color("#17385d"), Color("#5ecfda"), 17)
	shop_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_button.pressed.connect(_show_shop)
	discovery_row.add_child(shop_button)
	leaderboard_button = _button("GLOBAL SCORES", Color("#55378a"), Color("#c69aff"), 17)
	leaderboard_button.name = "GlobalScoresButton"
	leaderboard_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	leaderboard_button.pressed.connect(_show_global_scores)
	discovery_row.add_child(leaderboard_button)
	control_help_label = _label("ARROW KEYS TO MOVE  •  SPACE TO JUMP  •  E FOR RUNNER GIFT", 14, Color("#c8d9e9"))
	control_help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	control_help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	control_help_label.custom_minimum_size.y = 34
	menu_box.add_child(control_help_label)
	var settings_row := HBoxContainer.new()
	settings_row.name = "MenuSettingsRow"
	settings_row.add_theme_constant_override("separation", 12)
	menu_box.add_child(settings_row)
	music_toggle_button = _button("♫  MUSIC ON", Color("#16586b"), Color("#62e9db"), 14)
	music_toggle_button.name = "MusicToggleButton"
	music_toggle_button.tooltip_text = "Turn background music on or off"
	music_toggle_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	music_toggle_button.pressed.connect(_toggle_music)
	settings_row.add_child(music_toggle_button)
	privacy_button = _button("PRIVACY & DATA", Color(0.025, 0.11, 0.18, 0.72), Color(0.45, 0.9, 0.87, 0.48), 14)
	privacy_button.name = "PrivacyAndDataButton"
	privacy_button.tooltip_text = "Privacy policy and data-deletion instructions"
	privacy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	privacy_button.pressed.connect(_open_privacy_policy)
	settings_row.add_child(privacy_button)

	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_content_root.add_child(hud)
	hud_top_panel = PanelContainer.new()
	hud_top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_top_panel.offset_left = 26
	hud_top_panel.offset_top = 20
	hud_top_panel.offset_right = -26
	hud_top_panel.offset_bottom = 164
	var hud_panel_style := _panel_style(Color(0.018, 0.06, 0.12, 0.92), Color("#72eee1"), 3, 30)
	hud_panel_style.shadow_color = Color(0.0, 0.02, 0.08, 0.5)
	hud_panel_style.shadow_size = 14
	hud_panel_style.shadow_offset = Vector2(0, 6)
	hud_top_panel.add_theme_stylebox_override("panel", hud_panel_style)
	hud.add_child(hud_top_panel)
	hud_margin = MarginContainer.new()
	hud_margin.name = "RaceDashboardMargin"
	hud_margin.add_theme_constant_override("margin_left", 18)
	hud_margin.add_theme_constant_override("margin_right", 18)
	hud_margin.add_theme_constant_override("margin_top", 12)
	hud_margin.add_theme_constant_override("margin_bottom", 12)
	hud_top_panel.add_child(hud_margin)
	hud_box = VBoxContainer.new()
	hud_box.name = "RaceDashboard"
	hud_box.add_theme_constant_override("separation", 8)
	hud_margin.add_child(hud_box)
	hud_stats = GridContainer.new()
	hud_stats.columns = 3
	hud_stats.add_theme_constant_override("h_separation", 14)
	hud_box.add_child(hud_stats)
	distance_label = _hud_stat_card(hud_stats, "DISTANCE", "0m", Color("#55d9ff"))
	feather_label = _hud_stat_card(hud_stats, "FEATHERS", "0", Color("#ffd166"))
	combo_label = _hud_stat_card(hud_stats, "DODGE STREAK", "1×", Color("#ff83b6"))
	var goal_panel := PanelContainer.new()
	goal_panel.name = "NextWorldGoal"
	goal_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.12, 0.18, 0.94), Color("#ffd166"), 2, 22))
	hud_box.add_child(goal_panel)
	var goal_margin := MarginContainer.new()
	goal_margin.add_theme_constant_override("margin_left", 18)
	goal_margin.add_theme_constant_override("margin_right", 18)
	goal_margin.add_theme_constant_override("margin_top", 8)
	goal_margin.add_theme_constant_override("margin_bottom", 8)
	goal_panel.add_child(goal_margin)
	var goal_box := VBoxContainer.new()
	goal_box.add_theme_constant_override("separation", 5)
	goal_margin.add_child(goal_box)
	var goal_header := HBoxContainer.new()
	goal_box.add_child(goal_header)
	goal_label = _label("TOUR 1  •  STAGE 1 OF 9", 16, Color("#ffe7a3"))
	goal_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_set_bold(goal_label)
	goal_header.add_child(goal_label)
	biome_label = _label("CLASSIC STADIUM", 16, Color.WHITE)
	biome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	biome_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_set_bold(biome_label)
	goal_header.add_child(biome_label)
	goal_progress = ProgressBar.new()
	goal_progress.name = "NextWorldProgress"
	goal_progress.max_value = BIOME_DISTANCE
	goal_progress.show_percentage = false
	goal_progress.custom_minimum_size.y = 16
	goal_progress.add_theme_stylebox_override("background", _panel_style(Color("#102941"), Color(1, 1, 1, 0.16), 1, 10))
	goal_progress.add_theme_stylebox_override("fill", _panel_style(Color("#ffb84d"), Color("#fff0a6"), 1, 10))
	goal_box.add_child(goal_progress)
	goal_detail_label = _label("NEXT: BEACH TRACK  •  225m  •  REWARD +5", 14, Color("#d9fbf6"))
	goal_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_set_bold(goal_detail_label)
	goal_box.add_child(goal_detail_label)
	power_button = _button("SHIELD\nDODGE TO CHARGE", Color("#18bdb4"), Color("#b8fff5"), 20)
	power_button.name = "FloatingPowerBuddy"
	power_button.expand_icon = true
	power_button.add_theme_constant_override("icon_max_width", 70)
	power_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	power_button.offset_left = -300
	power_button.offset_top = -190
	power_button.offset_right = -34
	power_button.offset_bottom = -54
	power_button.mouse_filter = Control.MOUSE_FILTER_STOP
	for state_name in ["normal", "hover", "pressed", "focus"]:
		var bubble_color := Color("#18bdb4") if state_name != "pressed" else Color("#109a96")
		var bubble_style := _panel_style(bubble_color, Color("#d7fff8"), 4, 72)
		bubble_style.shadow_color = Color(0.02, 0.08, 0.13, 0.56)
		bubble_style.shadow_size = 13
		bubble_style.shadow_offset = Vector2(0, 7)
		power_button.add_theme_stylebox_override(state_name, bubble_style)
	power_button.pressed.connect(_activate_power)
	hud.add_child(power_button)
	power_bar = ProgressBar.new()
	power_bar.name = "PowerCharge"
	power_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	power_bar.offset_left = 24
	power_bar.offset_top = -30
	power_bar.offset_right = -24
	power_bar.offset_bottom = -14
	power_bar.max_value = 100.0
	power_bar.show_percentage = false
	power_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	power_bar.add_theme_stylebox_override("background", _panel_style(Color("#0b5360"), Color(1, 1, 1, 0.32), 1, 9))
	power_bar.add_theme_stylebox_override("fill", _panel_style(Color("#ffe066"), Color("#fff6be"), 1, 9))
	power_button.add_child(power_bar)

	result_layer = _modal_layer(ui_content_root)
	result_panel = _center_panel(result_layer, Vector2(1040, 680))
	var result_panel_style := _panel_style(Color("#fff3d8"), Color("#35d5c5"), 5, 46)
	result_panel_style.shadow_color = Color(0.02, 0.02, 0.12, 0.68)
	result_panel_style.shadow_size = 28
	result_panel_style.shadow_offset = Vector2(0, 10)
	result_panel.add_theme_stylebox_override("panel", result_panel_style)
	result_box = _modal_box(result_panel)
	result_box.name = "CelebrationResults"
	result_margin = result_box.get_parent() as MarginContainer
	result_title = _label("WHAT A DASH!", 31, Color.WHITE)
	result_title.name = "ResultTitleBubble"
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_title.add_theme_stylebox_override("normal", _panel_style(Color("#ff5c70"), Color("#ffbc53"), 4, 30))
	_set_bold(result_title)
	result_box.add_child(result_title)
	result_subtitle = _label("FEATHERS FLEW—WHAT A FINISH!", 17, Color("#244766"))
	result_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_subtitle.add_theme_constant_override("outline_size", 0)
	_set_bold(result_subtitle)
	result_box.add_child(result_subtitle)
	var result_hero := HBoxContainer.new()
	result_hero.name = "RunnerAndMedalCelebration"
	result_hero.alignment = BoxContainer.ALIGNMENT_CENTER
	result_hero.add_theme_constant_override("separation", 20)
	result_box.add_child(result_hero)
	var runner_bubble := PanelContainer.new()
	runner_bubble.name = "ResultRunnerBubble"
	runner_bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var runner_style := _panel_style(Color("#d9fbf6"), Color("#25c7bd"), 4, 36)
	runner_style.shadow_color = Color(0.12, 0.08, 0.2, 0.22)
	runner_style.shadow_size = 10
	runner_style.shadow_offset = Vector2(0, 6)
	runner_bubble.add_theme_stylebox_override("panel", runner_style)
	result_hero.add_child(runner_bubble)
	result_runner_portrait = TextureRect.new()
	result_runner_portrait.name = "ResultRunnerPortrait"
	result_runner_portrait.texture = load(RUNNER_ART_PATHS[0])
	result_runner_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	result_runner_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result_runner_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	runner_bubble.add_child(result_runner_portrait)
	var medal_bubble := PanelContainer.new()
	medal_bubble.name = "ResultMedalBubble"
	medal_bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var medal_style := _panel_style(Color("#fff0bd"), Color("#ffb84d"), 4, 36)
	medal_style.shadow_color = Color(0.12, 0.08, 0.2, 0.22)
	medal_style.shadow_size = 10
	medal_style.shadow_offset = Vector2(0, 6)
	medal_bubble.add_theme_stylebox_override("panel", medal_style)
	result_hero.add_child(medal_bubble)
	var medal_box := VBoxContainer.new()
	medal_box.alignment = BoxContainer.ALIGNMENT_CENTER
	medal_bubble.add_child(medal_box)
	var prize_label := _label("BIOME BADGE", 15, Color("#9a5a24"))
	prize_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prize_label.add_theme_constant_override("outline_size", 0)
	_set_bold(prize_label)
	medal_box.add_child(prize_label)
	result_medal_icon = TextureRect.new()
	result_medal_icon.name = "EarnedMedalArt"
	result_medal_icon.custom_minimum_size = Vector2(150, 134)
	result_medal_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result_medal_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result_medal_icon.texture = _atlas_texture(EFFECTS_MEDALS_ATLAS_PATH, 3, 2, 3)
	result_medal_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	medal_box.add_child(result_medal_icon)
	result_medal_name = _label("KEEP DASHING!", 16, Color("#6d3b22"))
	result_medal_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_medal_name.add_theme_constant_override("outline_size", 0)
	_set_bold(result_medal_name)
	medal_box.add_child(result_medal_name)
	result_stats_grid = GridContainer.new()
	result_stats_grid.name = "ResultStatCards"
	result_stats_grid.columns = 4
	result_stats_grid.add_theme_constant_override("h_separation", 12)
	result_box.add_child(result_stats_grid)
	result_distance_value = _result_stat_card(result_stats_grid, "DISTANCE", "0 m", Color("#55cbed"))
	result_score_value = _result_stat_card(result_stats_grid, "SCORE", "0", Color("#8e75ef"))
	result_feather_value = _result_stat_card(result_stats_grid, "FEATHERS", "0", Color("#e2ae35"))
	result_best_value = _result_stat_card(result_stats_grid, "PERSONAL BEST", "0 m", Color("#ff6f9f"))
	result_stats = _label("", 1, Color.TRANSPARENT)
	result_stats.visible = false
	result_box.add_child(result_stats)
	result_bonus = _label("BEST DODGE STREAK  •  1×", 16, Color("#28506a"))
	result_bonus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_bonus.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_bonus.add_theme_constant_override("outline_size", 0)
	result_bonus.add_theme_stylebox_override("normal", _panel_style(Color("#d9fbf6"), Color("#32cabb"), 3, 24))
	_set_bold(result_bonus)
	result_box.add_child(result_bonus)
	result_actions = GridContainer.new()
	result_actions.name = "ResultActions"
	result_actions.columns = 2
	result_actions.add_theme_constant_override("h_separation", 14)
	result_box.add_child(result_actions)
	result_retry_button = _button("RUN AGAIN", Color("#ff5c5c"), Color("#ffd166"), 24)
	result_retry_button.name = "RunAgainButton"
	result_retry_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_retry_button.custom_minimum_size.y = 62
	result_retry_button.pressed.connect(_start_run)
	result_actions.add_child(result_retry_button)
	result_home_button = _button("BACK TO HOME", Color("#1baeb1"), Color("#78eee0"), 18)
	result_home_button.name = "ResultHomeButton"
	result_home_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_home_button.pressed.connect(_show_menu)
	result_actions.add_child(result_home_button)
	result_leaderboard_button = _button("GLOBAL SCORES", Color("#55378a"), Color("#c69aff"), 18)
	result_leaderboard_button.name = "ResultGlobalScoresButton"
	result_leaderboard_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_leaderboard_button.pressed.connect(_show_global_scores)
	result_actions.add_child(result_leaderboard_button)

	shop_layer = _modal_layer(ui_content_root)
	shop_panel = _center_panel(shop_layer, Vector2(980, 620))
	var shop_panel_style := _panel_style(Color("#fff3d8"), Color("#31d1c4"), 4, 38)
	shop_panel_style.shadow_color = Color(0.02, 0.02, 0.12, 0.64)
	shop_panel_style.shadow_size = 24
	shop_panel.add_theme_stylebox_override("panel", shop_panel_style)
	shop_box = _modal_box(shop_panel)
	shop_margin = shop_box.get_parent() as MarginContainer
	shop_heading = _label("CHOOSE YOUR RUNNER", 28, Color.WHITE)
	shop_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shop_heading.custom_minimum_size.y = 52
	shop_heading.add_theme_constant_override("outline_size", 0)
	shop_heading.add_theme_stylebox_override("normal", _panel_style(Color("#ff5c70"), Color("#ffb04f"), 3, 24))
	_set_bold(shop_heading)
	shop_box.add_child(shop_heading)
	shop_wallet = _label("", 16, Color("#173454"))
	shop_wallet.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_wallet.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shop_wallet.add_theme_constant_override("outline_size", 0)
	shop_wallet.add_theme_stylebox_override("normal", _panel_style(Color("#d8fbf4"), Color("#66dccd"), 2, 18))
	_set_bold(shop_wallet)
	shop_box.add_child(shop_wallet)
	shop_scroll = ScrollContainer.new()
	shop_scroll.name = "RunnerGalleryScroll"
	shop_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	shop_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	shop_scroll.follow_focus = true
	shop_scroll.custom_minimum_size.y = 284
	shop_box.add_child(shop_scroll)
	shop_cards = GridContainer.new()
	shop_cards.name = "RunnerGallery"
	shop_cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_cards.columns = 4
	shop_cards.add_theme_constant_override("h_separation", 12)
	shop_cards.add_theme_constant_override("v_separation", 12)
	shop_scroll.add_child(shop_cards)
	shop_navigation = HBoxContainer.new()
	shop_navigation.name = "RunnerGalleryNavigation"
	shop_navigation.add_theme_constant_override("separation", 12)
	shop_box.add_child(shop_navigation)
	shop_previous_button = _button("▲  PREVIOUS", Color("#385f8f"), Color("#8cc9ef"), 14)
	shop_previous_button.name = "PreviousRunnersButton"
	shop_previous_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_previous_button.pressed.connect(_scroll_shop_page.bind(-1))
	shop_navigation.add_child(shop_previous_button)
	shop_page_label = _label("SWIPE TO SEE ALL 12", 14, Color("#34516c"))
	shop_page_label.name = "RunnerGalleryPageLabel"
	shop_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_page_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shop_page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_page_label.add_theme_constant_override("outline_size", 0)
	_set_bold(shop_page_label)
	shop_navigation.add_child(shop_page_label)
	shop_next_button = _button("MORE  ▼", Color("#e45875"), Color("#ffb6c7"), 14)
	shop_next_button.name = "MoreRunnersButton"
	shop_next_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_next_button.pressed.connect(_scroll_shop_page.bind(1))
	shop_navigation.add_child(shop_next_button)
	shop_scroll.get_v_scroll_bar().value_changed.connect(func(_value: float) -> void: _refresh_shop_navigation())
	shop_medal_row = GridContainer.new()
	shop_medal_row.name = "GeneratedMedalGallery"
	shop_medal_row.columns = 9
	shop_medal_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	shop_medal_row.add_theme_constant_override("h_separation", 8)
	shop_medal_row.custom_minimum_size.y = 52
	shop_box.add_child(shop_medal_row)
	shop_medals = _label("", 14, Color("#34516c"))
	shop_medals.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_medals.add_theme_constant_override("outline_size", 0)
	_set_bold(shop_medals)
	shop_box.add_child(shop_medals)
	shop_back = _button("BACK TO HOME", Color("#20aeb0"), Color("#7af0df"), 16)
	shop_back.pressed.connect(_show_menu)
	shop_box.add_child(shop_back)

	pause_layer = _modal_layer(ui_content_root)
	pause_panel = _center_panel(pause_layer, Vector2(420, 320))
	var pause_box := _modal_box(pause_panel)
	var paused_title := _label("PAUSED", 38, Color.WHITE)
	paused_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_box.add_child(paused_title)
	var resume := _button("RESUME", Color("#1c8c82"), Color("#6ee7d8"), 21)
	resume.pressed.connect(_resume_game)
	pause_box.add_child(resume)
	var quit := _button("END RUN", Color("#8f3a48"), Color("#e96b78"), 17)
	quit.pressed.connect(_quit_run)
	pause_box.add_child(quit)

	scores_layer = _modal_layer(ui_content_root)
	scores_layer.visible = false
	scores_panel = _center_panel(scores_layer, Vector2(980, 720))
	scores_panel.add_theme_stylebox_override("panel", _panel_style(Color("#fff3d8"), Color("#35d5c5"), 4, 28))
	var scores_box := _modal_box(scores_panel)
	scores_title = _label("LONGEST DASH", 34, Color("#17385d"))
	scores_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_set_bold(scores_title)
	scores_box.add_child(scores_title)
	scores_status = _label("ALL-TIME PUBLIC RANKS", 16, Color("#385f8f"))
	scores_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scores_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scores_box.add_child(scores_status)
	var scores_scroll := ScrollContainer.new()
	scores_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scores_scroll.custom_minimum_size.y = 320.0
	scores_box.add_child(scores_scroll)
	scores_list = VBoxContainer.new()
	scores_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scores_list.add_theme_constant_override("separation", 8)
	scores_scroll.add_child(scores_list)
	var scores_actions := HBoxContainer.new()
	scores_actions.add_theme_constant_override("separation", 10)
	scores_box.add_child(scores_actions)
	scores_native_button = _button("OPEN IN PLAY GAMES", Color("#16586b"), Color("#62e9db"), 14)
	scores_native_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scores_native_button.pressed.connect(_open_native_global_scores)
	scores_actions.add_child(scores_native_button)
	scores_back_button = _button("CLOSE", Color("#20aeb0"), Color("#7af0df"), 16)
	scores_back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scores_back_button.pressed.connect(_hide_global_scores)
	scores_actions.add_child(scores_back_button)

	toast_label = _label("", 19, Color.WHITE)
	toast_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	toast_label.position = Vector2(-240, 150)
	toast_label.size = Vector2(480, 52)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_stylebox_override("normal", _panel_style(Color(0.02, 0.07, 0.15, 0.9), Color("#ffd166"), 2, 16))
	toast_label.visible = false
	ui_content_root.add_child(toast_label)

	# The native banner overlays this dedicated band. The game viewport and every
	# UI screen above are physically shorter, so ads never cover gameplay.
	ad_reserve_rect = ColorRect.new()
	ad_reserve_rect.name = "AdBarReserve"
	ad_reserve_rect.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	ad_reserve_rect.offset_top = -AD_PREVIEW_HEIGHT
	ad_reserve_rect.offset_bottom = 0
	ad_reserve_rect.color = Color(0.008, 0.018, 0.04, 1.0)
	ad_reserve_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ad_reserve_rect.visible = false
	canvas.add_child(ad_reserve_rect)
	ad_preview_label = _label("ADVERTISEMENT SPACE — GAME ENDS ABOVE THIS BAR", 11, Color(1, 1, 1, 0.55))
	ad_preview_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	ad_preview_label.offset_top = -AD_PREVIEW_HEIGHT
	ad_preview_label.offset_bottom = 0
	ad_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ad_preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ad_preview_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ad_preview_label.visible = false
	canvas.add_child(ad_preview_label)

func _show_menu() -> void:
	_reset_shop_touch_gesture()
	state = GameState.MENU
	_sync_viewport_render_mode()
	power_timer = 0.0
	shield_active = false
	_stop_power_effect()
	menu_layer.visible = true
	result_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	if is_instance_valid(scores_layer):
		scores_layer.visible = false
	hud.visible = false
	player.active = false
	player.stunned = false
	player.visible = false
	camera.position = camera_home_position
	camera.look_at_from_position(camera.position, camera_look_target)
	_refresh_menu()

func _refresh_menu() -> void:
	menu_wallet.text = "◆  %s FEATHERS     BEST  %dm" % [_format_number(GameManager.total_feathers), int(GameManager.best_distance)]
	loadout_skin_label.text = "RUNNER  •  %s" % GameManager.SKINS[GameManager.selected_skin].to_upper()
	var ability := GameManager.selected_ability()
	loadout_ability_label.text = "%s\n%s  •  %.1fs  •  starts %d%% charged" % [
		str(ability.name).to_upper(), str(ability.description), float(ability.duration), int(ability.start_charge),
	]
	loadout_ability_icon.texture = _atlas_texture(REWARD_POWER_ATLAS_PATH, 3, 2, int(ability.get("icon_cell", 1)))
	daily_label.text = "✓  DAILY CHALLENGE COMPLETE" if GameManager.daily_complete else "DAILY CHALLENGE  •  COLLECT 15 FEATHERS  •  REWARD ◆25"
	_update_music_button()

func _open_privacy_policy() -> void:
	var error := OS.shell_open(PRIVACY_POLICY_URL)
	if error != OK:
		DisplayServer.clipboard_set(PRIVACY_POLICY_URL)
		_show_toast("Could not open the browser — privacy link copied")

func _show_shop() -> void:
	state = GameState.SHOP
	_sync_viewport_render_mode()
	_reset_shop_touch_gesture()
	menu_layer.visible = false
	shop_layer.visible = true
	_rebuild_shop_cards()
	# A fresh visit always begins with the starter colors. Without this reset,
	# reopening after inspecting premium colors can strand landscape players
	# halfway between the two card rows.
	shop_scroll.scroll_vertical = 0
	call_deferred("_refresh_shop_navigation")

func _shop_page_count() -> int:
	return maxi(1, int(ceil(float(GameManager.SKINS.size()) / float(maxi(1, shop_cards.columns)))))

func _scroll_shop_page(direction: int) -> void:
	if not is_instance_valid(shop_scroll):
		return
	var bar := shop_scroll.get_v_scroll_bar()
	var max_scroll := maxi(0, int(ceil(bar.max_value - bar.page)))
	var page_count := _shop_page_count()
	var current_page := 1
	if max_scroll > 0 and page_count > 1:
		current_page = clampi(int(round(float(shop_scroll.scroll_vertical) / float(max_scroll) * float(page_count - 1))) + 1, 1, page_count)
	var target_page := clampi(current_page + direction, 1, page_count)
	shop_scroll.scroll_vertical = int(round(float(max_scroll) * float(target_page - 1) / float(maxi(1, page_count - 1))))
	_refresh_shop_navigation()

func _refresh_shop_navigation() -> void:
	if not is_instance_valid(shop_scroll) or not is_instance_valid(shop_page_label):
		return
	var bar := shop_scroll.get_v_scroll_bar()
	var max_scroll := maxi(0, int(ceil(bar.max_value - bar.page)))
	var page_count := _shop_page_count()
	var current_page := 1
	if max_scroll > 0 and page_count > 1:
		current_page = clampi(int(round(float(shop_scroll.scroll_vertical) / float(max_scroll) * float(page_count - 1))) + 1, 1, page_count)
	shop_previous_button.disabled = shop_scroll.scroll_vertical <= 0
	shop_next_button.disabled = shop_scroll.scroll_vertical >= max_scroll
	shop_page_label.text = "PAGE %d OF %d  •  SWIPE" % [current_page, page_count]

func _show_global_scores() -> void:
	_ensure_leaderboard_feedback_connected()
	LeaderboardService.submit_longest_dash(int(GameManager.best_distance))
	_open_scores_panel("Loading global ranks...")
	match LeaderboardService.begin_global_scores():
		"":
			_refresh_scores_board()
		"signing_in":
			scores_status.text = "SIGNING IN TO GOOGLE PLAY GAMES..."
			_show_toast("SIGN IN TO GOOGLE PLAY GAMES TO VIEW GLOBAL SCORES")
		"unavailable":
			_fill_local_scores_fallback("GLOBAL SCORES NEED THE PLAY GAMES ANDROID BUILD")
			_show_toast("GLOBAL SCORES NEED THE PLAY GAMES ANDROID BUILD")
		_:
			_fill_local_scores_fallback("GLOBAL SCORES WILL OPEN AFTER PLAY GAMES SETUP")
			_show_toast("GLOBAL SCORES WILL OPEN AFTER PLAY GAMES SETUP")

func _open_scores_panel(status_text: String) -> void:
	if not is_instance_valid(scores_layer):
		return
	scores_layer.visible = true
	scores_status.text = status_text
	for child in scores_list.get_children():
		child.queue_free()

func _hide_global_scores() -> void:
	if is_instance_valid(scores_layer):
		scores_layer.visible = false

func _refresh_scores_board() -> void:
	scores_status.text = "LOADING ALL-TIME PUBLIC RANKS..."
	for child in scores_list.get_children():
		child.queue_free()
	LeaderboardService.fetch_scores()

func _fill_local_scores_fallback(status_text: String) -> void:
	scores_status.text = status_text
	for child in scores_list.get_children():
		child.queue_free()
	var local_rows: Array = []
	if GameManager.best_distance > 0.0:
		local_rows.append({
			"rank": 1,
			"display_rank": "1",
			"name": "YOU (LOCAL BEST)",
			"score": int(GameManager.best_distance),
			"display_score": "%d m" % int(GameManager.best_distance),
		})
	_populate_scores_list(local_rows)

func _populate_scores_list(rows: Array) -> void:
	for child in scores_list.get_children():
		child.queue_free()
	if rows.is_empty():
		var empty := _label("NO PUBLIC SCORES YET — TURN ON GAME ACTIVITY IN PLAY GAMES PRIVACY", 15, Color("#385f8f"))
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		scores_list.add_child(empty)
		return
	for row in rows:
		var row_panel := PanelContainer.new()
		row_panel.add_theme_stylebox_override("panel", _panel_style(Color("#fffaf0"), Color("#35d5c5"), 2, 16))
		scores_list.add_child(row_panel)
		var row_box := HBoxContainer.new()
		row_box.add_theme_constant_override("separation", 12)
		row_panel.add_child(row_box)
		var rank_label := _label(str(row.get("display_rank", row.get("rank", ""))), 18, Color("#55378a"))
		rank_label.custom_minimum_size.x = 56.0
		_set_bold(rank_label)
		row_box.add_child(rank_label)
		var name_label := _label(str(row.get("name", "PLAYER")), 17, Color("#17385d"))
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.clip_text = true
		row_box.add_child(name_label)
		var score_text := str(row.get("display_score", ""))
		if score_text.is_empty():
			score_text = "%d m" % int(row.get("score", 0))
		var score_label := _label(score_text, 18, Color("#e45875"))
		_set_bold(score_label)
		row_box.add_child(score_label)

func _open_native_global_scores() -> void:
	if not LeaderboardService.available or not LeaderboardService.authenticated:
		_show_toast("SIGN IN TO OPEN PLAY GAMES")
		return
	LeaderboardService.show_native_leaderboard()

func _ensure_leaderboard_feedback_connected() -> void:
	if not LeaderboardService.sign_in_failed.is_connected(_on_play_games_sign_in_failed):
		LeaderboardService.sign_in_failed.connect(_on_play_games_sign_in_failed)
	if not LeaderboardService.score_queued.is_connected(_on_leaderboard_score_queued):
		LeaderboardService.score_queued.connect(_on_leaderboard_score_queued)
	if not LeaderboardService.score_submit_finished.is_connected(_on_leaderboard_score_submit_finished):
		LeaderboardService.score_submit_finished.connect(_on_leaderboard_score_submit_finished)
	if not LeaderboardService.ready_to_show.is_connected(_on_leaderboard_ready_to_show):
		LeaderboardService.ready_to_show.connect(_on_leaderboard_ready_to_show)
	if not LeaderboardService.scores_loaded.is_connected(_on_leaderboard_scores_loaded):
		LeaderboardService.scores_loaded.connect(_on_leaderboard_scores_loaded)
	if not LeaderboardService.scores_load_failed.is_connected(_on_leaderboard_scores_load_failed):
		LeaderboardService.scores_load_failed.connect(_on_leaderboard_scores_load_failed)

func _on_play_games_sign_in_failed() -> void:
	scores_status.text = "PLAY GAMES SIGN-IN FAILED"
	_show_toast("PLAY GAMES SIGN-IN FAILED — CHECK SHA-1 AND TESTERS")

func _on_leaderboard_ready_to_show() -> void:
	if is_instance_valid(scores_layer) and scores_layer.visible:
		_refresh_scores_board()

func _on_leaderboard_scores_loaded(rows: Array) -> void:
	scores_status.text = "LONGEST DASH  •  ALL TIME  •  PUBLIC"
	_populate_scores_list(rows)

func _on_leaderboard_scores_load_failed(message: String) -> void:
	match message:
		"signed_out":
			scores_status.text = "SIGN IN TO LOAD GLOBAL RANKS"
		_:
			scores_status.text = "COULD NOT LOAD GLOBAL RANKS"
	_fill_local_scores_fallback(scores_status.text)

func _on_leaderboard_score_queued(meters: int) -> void:
	_show_toast("SIGNED OUT — TAP GLOBAL SCORES TO POST %d m" % meters)

func _on_leaderboard_score_submit_finished(success: bool, meters: int) -> void:
	if success:
		_show_toast("POSTED %d m TO GLOBAL SCORES" % meters)
	else:
		_show_toast("COULD NOT POST %d m — CHECK PLAY GAMES PRIVACY / TESTERS" % meters)

func _rebuild_shop_cards() -> void:
	for child in shop_cards.get_children():
		child.queue_free()
	for child in shop_medal_row.get_children():
		child.queue_free()
	shop_wallet.text = "◆  %s FEATHERS     •     %d OF %d RUNNERS UNLOCKED" % [_format_number(GameManager.total_feathers), GameManager.owned_skins.size(), GameManager.SKINS.size()]
	var earned_medals := 0
	var medal_colors := [
		Color("#20c7bc"), Color("#54c7f2"), Color("#8f75f5"), Color("#ff9c63"),
		Color("#82c86d"), Color("#ff6f9f"), Color("#f45b91"), Color("#ff7b3d"),
		Color("#7fc8ef"), Color("#d9a245"), Color("#8f6bdf"), Color("#638eaa"),
	]
	for biome_index in range(BIOMES.size()):
		var medal_name := GameManager.medal_for_biome(biome_index)
		if medal_name != "—":
			earned_medals += 1
		var medal_bubble := PanelContainer.new()
		medal_bubble.name = "%sMedalBubble" % BIOMES[biome_index].name.replace(" ", "")
		medal_bubble.custom_minimum_size = Vector2(112, 104) if portrait_layout else Vector2(62, 48)
		var medal_style := _panel_style(medal_colors[biome_index].lerp(Color.WHITE, 0.78), medal_colors[biome_index], 3, 28)
		medal_style.shadow_color = Color(0.12, 0.08, 0.2, 0.24)
		medal_style.shadow_size = 7
		medal_style.shadow_offset = Vector2(0, 4)
		medal_bubble.add_theme_stylebox_override("panel", medal_style)
		shop_medal_row.add_child(medal_bubble)
		var medal_icon := TextureRect.new()
		medal_icon.name = "%sMedal" % BIOMES[biome_index].name.replace(" ", "")
		medal_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		medal_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		medal_icon.texture = _atlas_texture(EFFECTS_MEDALS_ATLAS_PATH, 3, 2, _medal_cell(medal_name))
		medal_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		medal_icon.modulate.a = 0.3 if medal_name == "—" else 1.0
		medal_icon.tooltip_text = "%s — %s medal" % [BIOMES[biome_index].name, medal_name]
		medal_bubble.add_child(medal_icon)
	shop_medals.text = "BIOME MEDALS  •  %d OF %d EARNED" % [earned_medals, BIOMES.size()]
	var skin_colors := [
		Color("#13c7c4"), Color("#7c5cff"), Color("#f7c948"), Color("#ff5da2"),
		Color("#655dff"), Color("#5fbe3f"), Color("#ff7048"), Color("#7cccf1"),
		Color("#5268dd"), Color("#d58d88"), Color("#98dd24"), Color("#138f9c"),
	]
	for index in range(GameManager.SKINS.size()):
		var card := PanelContainer.new()
		card.name = "RunnerCard%d" % index
		card.set_meta("accent_color", skin_colors[index])
		card.set_meta("selected", GameManager.selected_skin == index)
		card.set_meta("premium_portrait", index >= 4)
		shop_cards.add_child(card)
		var margin := MarginContainer.new()
		margin.name = "CardMargin"
		card.add_child(margin)
		var box := VBoxContainer.new()
		box.name = "CardBox"
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		margin.add_child(box)
		var portrait_bubble := PanelContainer.new()
		portrait_bubble.name = "PortraitBubble"
		var portrait_fill := Color("#111b38") if index >= 4 else Color(1, 1, 1, 0.72)
		portrait_bubble.add_theme_stylebox_override("panel", _panel_style(portrait_fill, skin_colors[index].lerp(Color.WHITE, 0.35), 3, 28))
		box.add_child(portrait_bubble)
		var portrait := TextureRect.new()
		portrait.name = "RunnerPortrait"
		portrait.texture = load(RUNNER_ART_PATHS[index])
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.tooltip_text = "%s runner" % GameManager.SKINS[index]
		portrait_bubble.add_child(portrait)
		var name_label := _label(GameManager.SKINS[index].to_upper(), 20, Color("#173454"))
		name_label.name = "RunnerName"
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_constant_override("outline_size", 0)
		_set_bold(name_label)
		box.add_child(name_label)
		var ability: Dictionary = GameManager.RUNNER_ABILITIES[index]
		var ability_detail := _label("%s\n%s  •  %.1fs  •  starts %d%%" % [
			str(ability.name).to_upper(),
			str(ability.description),
			float(ability.duration),
			int(ability.start_charge),
		], 13, skin_colors[index].darkened(0.38))
		ability_detail.name = "RunnerAbility"
		ability_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ability_detail.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ability_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ability_detail.add_theme_constant_override("outline_size", 0)
		_set_bold(ability_detail)
		box.add_child(ability_detail)
		var detail_text := "READY TO WEAR" if index in GameManager.owned_skins else "◆ %s FEATHERS" % _format_number(GameManager.SKIN_COSTS[index])
		var detail := _label(detail_text, 14, Color("#6d4963"))
		detail.name = "RunnerPrice"
		detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		detail.add_theme_constant_override("outline_size", 0)
		box.add_child(detail)
		var action_text := "WEARING" if GameManager.selected_skin == index else ("WEAR IT" if index in GameManager.owned_skins else "UNLOCK")
		var action := _button(action_text, skin_colors[index].darkened(0.16), skin_colors[index].lightened(0.18), 15)
		action.name = "RunnerAction"
		action.disabled = GameManager.selected_skin == index
		if action.disabled:
			action.add_theme_color_override("font_disabled_color", Color.WHITE)
			action.add_theme_stylebox_override("disabled", _panel_style(skin_colors[index].darkened(0.1), Color.WHITE, 3, 22))
		action.pressed.connect(_select_skin.bind(index))
		box.add_child(action)
		_style_shop_card(card)
	_apply_shop_layout()
	call_deferred("_refresh_shop_navigation")

func _style_shop_card(card: Control) -> void:
	if not is_instance_valid(card) or not card.has_meta("accent_color"):
		return
	var accent: Color = card.get_meta("accent_color")
	var selected: bool = card.get_meta("selected")
	var card_style := _panel_style(accent.lerp(Color("#fffaf0"), 0.8), accent, 5 if selected else 3, 34)
	card_style.shadow_color = Color(0.14, 0.08, 0.2, 0.28)
	card_style.shadow_size = 10
	card_style.shadow_offset = Vector2(0, 6)
	card.add_theme_stylebox_override("panel", card_style)
	var margin := card.get_node("CardMargin") as MarginContainer
	var box := card.get_node("CardMargin/CardBox") as VBoxContainer
	var portrait_bubble := card.get_node("CardMargin/CardBox/PortraitBubble") as PanelContainer
	var portrait := card.get_node("CardMargin/CardBox/PortraitBubble/RunnerPortrait") as TextureRect
	var name_label := card.get_node("CardMargin/CardBox/RunnerName") as Label
	var ability_detail := card.get_node("CardMargin/CardBox/RunnerAbility") as Label
	var detail := card.get_node("CardMargin/CardBox/RunnerPrice") as Label
	var action := card.get_node("CardMargin/CardBox/RunnerAction") as Button
	if portrait_layout:
		card.custom_minimum_size = Vector2(400, 570)
		for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
			margin.add_theme_constant_override(side, 24)
		box.add_theme_constant_override("separation", 14)
		portrait_bubble.custom_minimum_size = Vector2(280, 270)
		portrait.custom_minimum_size = Vector2(260, 250)
		_set_font_size(name_label, 29)
		_set_font_size(ability_detail, 19)
		ability_detail.custom_minimum_size.y = 58
		_set_font_size(detail, 20)
		_set_font_size(action, 22)
		action.custom_minimum_size.y = 68
	else:
		card.custom_minimum_size = Vector2(225, 332)
		for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
			margin.add_theme_constant_override(side, 12)
		box.add_theme_constant_override("separation", 7)
		portrait_bubble.custom_minimum_size = Vector2(126, 122)
		portrait.custom_minimum_size = Vector2(118, 114)
		_set_font_size(name_label, 18)
		_set_font_size(ability_detail, 12)
		ability_detail.custom_minimum_size.y = 43
		_set_font_size(detail, 13)
		_set_font_size(action, 14)
		action.custom_minimum_size.y = 42

func _select_skin(index: int) -> void:
	if GameManager.buy_or_equip_skin(index):
		player.apply_skin(index)
		_show_toast("%s equipped" % GameManager.SKINS[index])
	else:
		_show_toast("Not enough feathers yet")
	_rebuild_shop_cards()

func _pause_game() -> void:
	state = GameState.PAUSED
	_sync_viewport_render_mode()
	pause_layer.visible = true
	hud.visible = false

func _resume_game() -> void:
	if state != GameState.PAUSED:
		return
	state = GameState.RUNNING
	_sync_viewport_render_mode()
	pause_layer.visible = false
	hud.visible = true

func _quit_run() -> void:
	state = GameState.RESULTS
	pause_layer.visible = false
	_show_results()

func _update_hud() -> void:
	distance_label.text = "%d m" % int(distance)
	feather_label.text = "%d" % run_feathers
	combo_label.text = "%d×" % combo
	var stage := int(distance / BIOME_DISTANCE)
	var stage_in_tour := stage % biome_sequence.size()
	var stage_progress := fmod(distance, BIOME_DISTANCE)
	var next_biome_index: int = biome_sequence[(stage_in_tour + 1) % biome_sequence.size()]
	var meters_remaining := maxi(0, int(ceil(BIOME_DISTANCE - stage_progress)))
	goal_progress.value = stage_progress
	goal_label.text = "TOUR %d  •  STAGE %d OF %d" % [int(stage / biome_sequence.size()) + 1, stage_in_tour + 1, biome_sequence.size()]
	biome_label.text = BIOMES[current_biome].name.to_upper()
	var reward := TOUR_REWARD if stage_in_tour == biome_sequence.size() - 1 else CHECKPOINT_REWARD
	goal_detail_label.text = "NEXT: %s  •  %dm  •  +%d FEATHERS" % [BIOMES[next_biome_index].name.to_upper(), meters_remaining, reward]
	power_bar.value = power_charge
	var ability := GameManager.selected_ability()
	var ability_name := str(ability.name)
	var icon_cell := int(ability.get("icon_cell", 1))
	if icon_cell != _cached_hud_power_icon_cell:
		_cached_hud_power_icon_cell = icon_cell
		power_button.icon = _atlas_texture(REWARD_POWER_ATLAS_PATH, 3, 2, icon_cell)
	if power_charge >= 100.0:
		power_button.text = "%s READY!\n%s" % [ability_name.to_upper(), "TAP TO USE" if mobile_mode else "PRESS E"]
	else:
		power_button.text = "%s  %d%%\nDODGE TO CHARGE" % [ability_name.to_upper(), int(power_charge)]
	if power_timer > 0.0:
		var active_hint := "POWER ACTIVE"
		match int(ability.kind):
			GameManager.ABILITY_DOUBLE_JUMP:
				active_hint = "JUMP AGAIN IN AIR"
			GameManager.ABILITY_GLIDE:
				active_hint = "SWIPE UP TO FLOAT"
			GameManager.ABILITY_FEATHER_FRENZY:
				active_hint = "%d× FEATHERS" % int(ability.get("pickup_multiplier", 2))
			GameManager.ABILITY_MIRACLE:
				active_hint = "ALL GIFTS ACTIVE"
		power_button.text = "%s  %.1fs\n%s" % [ability_name.to_upper(), power_timer, active_hint]
	power_button.modulate = Color.WHITE if power_charge >= 100.0 or power_timer > 0.0 else Color(0.84, 0.92, 0.95, 1.0)

func _medal_cell(medal_name: String) -> int:
	var normalized := medal_name.to_lower()
	if "gold" in normalized:
		return 5
	if "silver" in normalized:
		return 4
	return 3

func _show_toast(message: String) -> void:
	toast_label.text = message
	toast_label.visible = true
	toast_label.modulate.a = 1.0
	toast_time = 2.4

func _label(text_value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_override("font", load(UI_FONT_PATH))
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.008, 0.025, 0.055, 0.82))
	label.add_theme_constant_override("outline_size", 3)
	return label

func _format_number(value: int) -> String:
	var digits := str(maxi(0, value))
	var comma_index := digits.length() - 3
	while comma_index > 0:
		digits = digits.left(comma_index) + "," + digits.substr(comma_index)
		comma_index -= 3
	return digits

func _set_bold(control: Control) -> void:
	control.add_theme_font_override("font", load(UI_FONT_BOLD_PATH))

func _button(text_value: String, base: Color, border: Color, font_size: int) -> Button:
	var button := Button.new()
	button.text = text_value
	button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	button.custom_minimum_size.y = 48
	button.add_theme_font_override("font", load(UI_FONT_BOLD_PATH))
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_shadow_color", Color(0.0, 0.02, 0.07, 0.72))
	button.add_theme_constant_override("shadow_offset_y", 2)
	var normal_style := _panel_style(base, border, 3, 26)
	var hover_style := _panel_style(base.lightened(0.1), border.lightened(0.12), 4, 26)
	var pressed_style := _panel_style(base.darkened(0.1), Color("#fff1bd"), 3, 26)
	var focus_style := _panel_style(base.lightened(0.04), Color("#fff1bd"), 4, 26)
	for style in [normal_style, hover_style, pressed_style, focus_style]:
		style.content_margin_left = 18.0
		style.content_margin_right = 18.0
		style.shadow_color = Color(0.0, 0.015, 0.055, 0.42)
		style.shadow_size = 7
		style.shadow_offset = Vector2(0, 4)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", focus_style)
	button.add_theme_stylebox_override("disabled", _panel_style(base.darkened(0.28), Color(1, 1, 1, 0.18), 2, 26))
	return button

func _panel_style(color: Color, border_color: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.anti_aliasing = true
	style.anti_aliasing_size = 1.5
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 10
	return style

func _hud_stat_card(parent: Container, title: String, value: String, accent: Color) -> Label:
	var card := PanelContainer.new()
	card.name = title.to_pascal_case() + "Card"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _panel_style(accent.darkened(0.72), accent, 2, 20))
	parent.add_child(card)
	var margin := MarginContainer.new()
	margin.name = "StatMargin"
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	card.add_child(margin)
	var box := VBoxContainer.new()
	box.name = "StatBox"
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	margin.add_child(box)
	var title_label := _label(title, 12, accent.lightened(0.28))
	title_label.name = "StatTitle"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_set_bold(title_label)
	box.add_child(title_label)
	var value_label := _label(value, 22, Color.WHITE)
	value_label.name = "StatValue"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_set_bold(value_label)
	box.add_child(value_label)
	return value_label

func _style_hud_cards(is_portrait: bool) -> void:
	for card_node in hud_stats.get_children():
		var card := card_node as PanelContainer
		if card == null:
			continue
		card.custom_minimum_size.y = 94.0 if is_portrait else 50.0
		var title := card.get_node("StatMargin/StatBox/StatTitle") as Label
		var value := card.get_node("StatMargin/StatBox/StatValue") as Label
		_set_font_size(title, 19 if is_portrait else 11)
		_set_font_size(value, 35 if is_portrait else 20)

func _result_stat_card(parent: Container, title: String, value: String, accent: Color) -> Label:
	var card := PanelContainer.new()
	card.name = title.to_pascal_case().replace(" ", "") + "ResultCard"
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.set_meta("accent", accent)
	var card_style := _panel_style(accent.lerp(Color.WHITE, 0.78), accent, 3, 26)
	card_style.shadow_color = Color(0.12, 0.08, 0.2, 0.2)
	card_style.shadow_size = 8
	card_style.shadow_offset = Vector2(0, 5)
	card.add_theme_stylebox_override("panel", card_style)
	parent.add_child(card)
	var margin := MarginContainer.new()
	margin.name = "ResultStatMargin"
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	var box := VBoxContainer.new()
	box.name = "ResultStatBox"
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(box)
	var title_label := _label(title, 13, accent.darkened(0.48))
	title_label.name = "ResultStatTitle"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_constant_override("outline_size", 0)
	_set_bold(title_label)
	box.add_child(title_label)
	var value_label := _label(value, 24, Color("#173454"))
	value_label.name = "ResultStatValue"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_constant_override("outline_size", 0)
	_set_bold(value_label)
	box.add_child(value_label)
	return value_label

func _style_result_stat_cards(is_portrait: bool) -> void:
	for card_node in result_stats_grid.get_children():
		var card := card_node as PanelContainer
		if card == null:
			continue
		card.custom_minimum_size.y = 145.0 if is_portrait else 92.0
		var title := card.get_node("ResultStatMargin/ResultStatBox/ResultStatTitle") as Label
		var value := card.get_node("ResultStatMargin/ResultStatBox/ResultStatValue") as Label
		_set_font_size(title, 21 if is_portrait else 13)
		_set_font_size(value, 34 if is_portrait else 24)

func _position_top_center(control: Control, width: float, top: float, height: float) -> void:
	control.anchor_left = 0.5
	control.anchor_right = 0.5
	control.anchor_top = 0.0
	control.anchor_bottom = 0.0
	control.offset_left = -width * 0.5
	control.offset_right = width * 0.5
	control.offset_top = top
	control.offset_bottom = top + height

func _modal_layer(parent: Node) -> Control:
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(layer)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.025, 0.07, 0.82)
	layer.add_child(shade)
	return layer

func _center_panel(layer: Control, size_value: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = -size_value * 0.5
	panel.size = size_value
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#0c1f3d"), Color("#32d8cc"), 3, 24))
	layer.add_child(panel)
	return panel

func _modal_box(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)
	return box
