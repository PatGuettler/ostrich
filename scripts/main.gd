extends Node

enum GameState { MENU, RUNNING, HIT, RESULTS, SHOP, PAUSED }

const DashPlayer = preload("res://scripts/dash_player.gd")
const BIOMES := [
	{"name": "Classic Stadium", "sky": Color("#52b7e8"), "track": Color("#c8423a"), "ground": Color("#3d8b58"), "accent": Color("#ffd166")},
	{"name": "Beach Track", "sky": Color("#60d5ee"), "track": Color("#e4ad64"), "ground": Color("#f4d68d"), "accent": Color("#13c7c4")},
	{"name": "Night Games", "sky": Color("#07132e"), "track": Color("#28395e"), "ground": Color("#131a38"), "accent": Color("#7c5cff")},
	{"name": "Desert Circuit", "sky": Color("#ef9d61"), "track": Color("#a94c39"), "ground": Color("#d98b4e"), "accent": Color("#ffe066")},
	{"name": "Snow Games", "sky": Color("#9dd7ea"), "track": Color("#74a4bb"), "ground": Color("#e9f5f6"), "accent": Color("#f25f5c")},
	{"name": "Jungle Track", "sky": Color("#163a34"), "track": Color("#74523b"), "ground": Color("#1f6b4e"), "accent": Color("#f6bd60")}
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
const BIOME_FOG_DENSITIES := [0.0018, 0.0022, 0.0032, 0.0022, 0.0028, 0.0034]
const BIOME_EXPOSURES := [0.84, 0.82, 1.0, 0.84, 0.86, 0.94]
const PRIVACY_POLICY_URL := "https://patguettler.github.io/privacy-policy.html"
const DATA_DELETION_URL := "https://patguettler.github.io/privacy-policy.html#data-deletion"
const BIOME_BACKDROP_PATHS := [
	"res://assets/generated/classic_stadium_vista.png",
	"res://assets/generated/beach_track_vista.png",
	"res://assets/generated/night_games_vista.png",
	"res://assets/generated/desert_circuit_vista.png",
	"res://assets/generated/snow_games_vista.png",
	"res://assets/generated/jungle_track_vista.png"
]
const RUNNER_ART_PATHS := [
	"res://assets/generated/gameplay/runner_classic.png",
	"res://assets/generated/gameplay/runner_midnight.png",
	"res://assets/generated/gameplay/runner_golden.png",
	"res://assets/generated/gameplay/runner_bubblegum.png"
]
const RUNNER_GAMEPLAY_ART_PATHS := [
	"res://assets/generated/gameplay/runner_classic_back.png",
	"res://assets/generated/gameplay/runner_midnight_back.png",
	"res://assets/generated/gameplay/runner_golden_back.png",
	"res://assets/generated/gameplay/runner_bubblegum_back.png"
]
const RIVAL_ART_PATH := "res://assets/generated/gameplay/rival_runner_back.png"
const OBSTACLE_ATLAS_PATH := "res://assets/generated/gameplay/obstacle_atlas.png"
const REWARD_POWER_ATLAS_PATH := "res://assets/generated/gameplay/reward_power_atlas.png"
const BIOME_PROP_ATLAS_PATH := "res://assets/generated/gameplay/biome_prop_atlas.png"
const EFFECTS_MEDALS_ATLAS_PATH := "res://assets/generated/gameplay/effects_medals_atlas.png"
const SURFACE_ATLAS_PATH := "res://assets/generated/gameplay/surface_atlas.png"
const MENU_LOGO_PATH := "res://assets/generated/ui/ostrich_dash_menu_logo.png"
const UI_FONT_PATH := "res://assets/fonts/NotoSansDisplay-Regular.ttf"
const UI_FONT_BOLD_PATH := "res://assets/fonts/NotoSansDisplay-Bold.ttf"
const SURFACE_PATHS := [
	"res://assets/generated/gameplay/surfaces/hd/classic_rubber_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/beach_sand_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/night_track_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/desert_clay_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/snow_pack_hd.png",
	"res://assets/generated/gameplay/surfaces/hd/jungle_earth_hd.png"
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
var score := 0
var speed := 16.0
var spawn_meter := 18.0
var current_biome := 0
var last_biome := -1
var biome_sequence: Array[int] = [0, 1, 2, 3, 4, 5]
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
var controls_reversed := false
var slip_timer := 0.0
var shake_time := 0.0
var elapsed := 0.0
var touch_start := Vector2.ZERO
var touch_tracking := false
var touch_finger := -1
var touch_action_committed := false
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
var control_help_label: Label
var menu_wallet: Label
var loadout_skin_label: Label
var loadout_power_button: Button
var daily_label: Label
var start_button: Button
var shop_button: Button
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
var touch_controls: Control
var result_layer: Control
var result_panel: PanelContainer
var result_title: Label
var result_subtitle: Label
var result_medal_icon: TextureRect
var result_stats: Label
var result_bonus: Label
var shop_layer: Control
var shop_panel: PanelContainer
var shop_margin: MarginContainer
var shop_box: VBoxContainer
var shop_heading: Label
var shop_wallet: Label
var shop_cards: GridContainer
var shop_medal_row: HBoxContainer
var shop_medals: Label
var shop_back: Button
var pause_layer: Control
var pause_panel: PanelContainer
var toast_label: Label
var toast_time := 0.0

var sfx_player: AudioStreamPlayer
var pickup_sound: AudioStreamWAV
var honk_sound: AudioStreamWAV
var trip_sound: AudioStreamWAV
var success_sound: AudioStreamWAV
var audio_enabled := true

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
	_build_world()
	_build_ui()
	_build_audio()
	_show_menu()
	refresh_ad_layout()
	get_viewport().size_changed.connect(refresh_ad_layout)
	call_deferred("_sync_ad_bar")

func _process(delta: float) -> void:
	var ad_reserve := _ad_bottom_reserve()
	if absf(ad_reserve - applied_ad_reserve) > 0.5:
		refresh_ad_layout()
	elapsed += delta
	player.step(delta)
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
	_update_particles(delta)

func _input(event: InputEvent) -> void:
	# Android GUI controls receive events before _unhandled_input(), so gestures
	# must be observed here. Keep tracking through release after a committed swipe
	# to prevent the same finger from also clicking the power button.
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if state == GameState.RUNNING:
			_process_touch_gesture(event)
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
			player.jump()
		KEY_DOWN:
			player.duck()
		_:
			return
	get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
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
		player.jump()
	elif event.is_action_pressed("duck"):
		player.duck()
	elif event.is_action_pressed("power_up"):
		_activate_power()

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
		player.jump()
	else:
		player.duck()
	return true

func _swipe_min_distance() -> float:
	var viewport_size := get_viewport().get_visible_rect().size
	return clampf(minf(viewport_size.x, viewport_size.y) * 0.055, 30.0, 64.0)

func _reset_touch_gesture() -> void:
	touch_start = Vector2.ZERO
	touch_tracking = false
	touch_finger = -1
	touch_action_committed = false

func _move_player(direction: int) -> void:
	player.move_lane(-direction if controls_reversed else direction)

func _start_run() -> void:
	_reset_touch_gesture()
	_clear_run_objects()
	distance = 0.0
	run_feathers = 0
	near_misses = 0
	combo = 1
	score = 0
	speed = 16.0
	spawn_meter = 24.0
	current_biome = 0
	last_biome = -1
	biome_tour = 0
	checkpoint_stage = 0
	_shuffle_biome_sequence()
	last_crash = "spin"
	power_charge = 0.0
	power_timer = 0.0
	shield_active = false
	controls_reversed = false
	slip_timer = 0.0
	player.reset_player()
	state = GameState.RUNNING
	menu_layer.visible = false
	result_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	hud.visible = true
	touch_controls.visible = false
	_apply_biome(0, true)
	_update_hud()
	if mobile_mode:
		_show_toast("SWIPE SIDEWAYS • SWIPE UP TO JUMP • SWIPE DOWN TO DUCK")

func _update_run(delta: float) -> void:
	var time_scale := 0.62 if power_timer > 0.0 and GameManager.selected_power == 2 else 1.0
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
	power_charge = minf(100.0, power_charge + 18.0)
	if completed_tour:
		_show_toast("TOUR COMPLETE!  +%d FEATHERS" % reward)
	else:
		_show_toast("CHECKPOINT!  +%d FEATHERS" % reward)

func _update_power(delta: float) -> void:
	if power_timer > 0.0:
		power_timer -= delta
		if power_timer <= 0.0:
			shield_active = false
	if slip_timer > 0.0:
		slip_timer -= delta
		if slip_timer <= 0.0:
			controls_reversed = false
	if GameManager.selected_power == 1 and power_timer > 0.0:
		for item in feathers:
			var node: Node3D = item.node
			if is_instance_valid(node) and node.position.z > -18.0:
				node.position.x = move_toward(node.position.x, player.position.x, delta * 10.0)

func _activate_power() -> void:
	if power_charge < 100.0 or power_timer > 0.0:
		_show_toast("Power charges from clean dodges")
		return
	power_charge = 0.0
	power_timer = 6.0
	match GameManager.selected_power:
		0:
			shield_active = true
			_show_toast("SHIELD READY — one hit blocked!")
		1:
			_show_toast("FEATHER MAGNET!")
		2:
			_show_toast("SLOW-MO REFLEX!")
		3:
			_show_toast("SCORE RUSH — 2× combo charge!")

func _spawn_pattern() -> void:
	var blocked: Array[int] = []
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
		_spawn_obstacle(kind, lane, -72.0 - i * 1.5)
	var open_lanes: Array[int] = []
	for lane in range(3):
		if lane not in blocked:
			open_lanes.append(lane)
	if not open_lanes.is_empty():
		var feather_lane: int = open_lanes.pick_random()
		for i in range(4):
			_spawn_feather(feather_lane, -64.0 - i * 2.5)

func _next_spawn_gap() -> float:
	var difficulty_reduction := minf(SPAWN_GAP_RAMP_REDUCTION, distance / 600.0)
	return randf_range(SPAWN_GAP_MIN, SPAWN_GAP_MAX) - difficulty_reduction

func _spawn_obstacle(kind: String, lane: int, z: float) -> void:
	var node := Node3D.new()
	node.name = "Cute%sObstacle" % kind.capitalize()
	node.position = Vector3(LANES[lane], 0.0, z)
	obstacle_root.add_child(node)
	var rival_parts: Dictionary = {}
	if kind == "rival":
		rival_parts = _build_rival_runner(node)
	else:
		var cell: int = [0, 5].pick_random() if kind == "wall" else OBSTACLE_CELLS.get(kind, 5)
		var sprite_height: float = {"wall": 1.42, "bar": 2.82, "cone": 1.08, "drone": 2.55, "slip": 0.62}.get(kind, 1.0)
		var pixel_size: float = {"wall": 0.0074, "bar": 0.0088, "cone": 0.0062, "drone": 0.0074, "slip": 0.0063}.get(kind, 0.0065)
		var art := _sprite_3d(node, _atlas_texture(OBSTACLE_ATLAS_PATH, 3, 2, cell), Vector3(0.0, sprite_height, 0.0), pixel_size, "Generated%sArt" % kind.capitalize())
		if kind == "bar":
			# Keep the feet planted while lifting the crossbar well above the other
			# hazards. A little extra width reinforces that this spans the lane.
			art.scale = Vector3(1.08, 1.28, 1.0)
		elif kind == "slip":
			art.scale.y = 0.46
	var item := {"node": node, "kind": kind, "lane": lane, "passed": false, "phase": randf() * TAU}
	item.merge(rival_parts)
	obstacles.append(item)

func _build_rival_runner(parent: Node3D) -> Dictionary:
	var texture: Texture2D = load(RIVAL_ART_PATH)
	var visual := Node3D.new()
	visual.name = "RivalRunningVisual"
	parent.add_child(visual)
	var body := _rival_sprite(visual, texture, Vector3(0.0, 2.35, 0.0), "GeneratedRivalBody", 4)
	body.material_override = _rival_body_material(texture)
	var left_pivot := _make_rival_stride_layer(visual, texture, "RivalLeftStride", true, Vector3(-0.25, 1.99, -0.02))
	var right_pivot := _make_rival_stride_layer(visual, texture, "RivalRightStride", false, Vector3(0.23, 1.99, -0.02))
	var shadow_mesh := QuadMesh.new()
	shadow_mesh.size = Vector2(1.9, 0.9)
	var shadow_material := StandardMaterial3D.new()
	shadow_material.albedo_color = Color(0.015, 0.025, 0.05, 0.25)
	shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var shadow := MeshInstance3D.new()
	shadow.name = "RivalGroundShadow"
	shadow.mesh = shadow_mesh
	shadow.material_override = shadow_material
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
	leg.material_override = _rival_leg_material(texture, keep_left)
	return pivot

func _rival_body_material(texture: Texture2D) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
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
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("runner_texture", texture)
	return material

func _rival_leg_material(texture: Texture2D, keep_left: bool) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
uniform sampler2D runner_texture : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform float keep_left = 1.0;
void fragment() {
	vec2 sample_uv = UV;
	if (keep_left < 0.5) {
		sample_uv.x = 1.0 - UV.x;
	}
	vec4 art = texture(runner_texture, sample_uv);
	float below_hip = step(0.55, UV.y);
	float left_half = 1.0 - step(0.505, UV.x);
	float right_half = step(0.495, UV.x);
	float selected_half = mix(right_half, left_half, keep_left);
	ALBEDO = art.rgb;
	ALPHA = art.a * below_hip * selected_half;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("runner_texture", texture)
	material.set_shader_parameter("keep_left", 1.0 if keep_left else 0.0)
	return material

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

func _spawn_feather(lane: int, z: float) -> void:
	var node := Node3D.new()
	node.name = "GoldenFeatherPickup"
	node.position = Vector3(LANES[lane], 1.55, z)
	obstacle_root.add_child(node)
	_sprite_3d(node, _atlas_texture(REWARD_POWER_ATLAS_PATH, 3, 2, 0), Vector3.ZERO, 0.00235, "GeneratedFeatherArt")
	feathers.append({"node": node, "lane": lane, "phase": randf() * TAU})

func _move_objects(delta: float, move_speed: float) -> void:
	for item in obstacles.duplicate():
		var node: Node3D = item.node
		if not is_instance_valid(node):
			obstacles.erase(item)
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
			obstacles.erase(item)
			node.queue_free()
	for item in feathers.duplicate():
		var node: Node3D = item.node
		if not is_instance_valid(node):
			feathers.erase(item)
			continue
		node.position.z += move_speed * delta
		node.rotation.y += delta * 4.5
		node.position.y = 1.55 + sin(elapsed * 4.0 + item.phase) * 0.18
		if node.position.z > -1.0 and node.position.z < 1.8 and absf(node.position.x - player.position.x) < 0.95:
			_collect_feather(item)
		elif node.position.z > 10.0:
			feathers.erase(item)
			node.queue_free()

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
	if near:
		near_misses += 1
	var charge_gain := 22.0
	if GameManager.selected_power == 3 and power_timer > 0.0:
		charge_gain = 44.0
	power_charge = minf(100.0, power_charge + charge_gain)
	if combo >= 4:
		_show_toast("%d× CLEAN COMBO" % combo)

func _collect_feather(item: Dictionary) -> void:
	var node: Node3D = item.node
	run_feathers += combo
	power_charge = minf(100.0, power_charge + 5.0)
	_play_sound(pickup_sound, -8.0)
	feathers.erase(item)
	node.queue_free()

func _trigger_slip() -> void:
	controls_reversed = true
	slip_timer = 3.2
	combo = 1
	_show_toast("SLIPPERY! Controls reversed")

func _trigger_hit(obstacle: Node3D, obstacle_kind := "bar") -> void:
	if state != GameState.RUNNING:
		return
	if shield_active:
		shield_active = false
		power_timer = 0.0
		combo = 1
		_spawn_puff(player.global_position + Vector3(0, 2.4, 0), Color("#9be7ff"), 12)
		_show_toast("SHIELD SAVE!")
		return
	state = GameState.HIT
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
	_play_sound(trip_sound if last_crash == "trip" else honk_sound, 0.0)
	hud.visible = false
	touch_controls.visible = false

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
	last_result = GameManager.finish_run(distance, run_feathers, current_biome)
	if last_result.new_best:
		result_title.text = "NEW PERSONAL BEST!"
	elif last_crash == "trip":
		result_title.text = "WHAT A TRIP!"
	elif last_crash == "bar_flip":
		result_title.text = "OVER THE BAR!"
	else:
		result_title.text = "WHAT A SPIN!"
	result_subtitle.text = {
		"trip": "TOE CLIP → FORWARD TUMBLE",
		"bar_flip": "NECK CATCH → FEET UP → FLIP DOWN",
	}.get(last_crash, "THE NECK-WRAP PINWHEEL")
	result_stats.text = "%dm  •  %d pts\n%d feathers  •  %d near-misses\nBest: %dm  •  %s medal here" % [int(distance), score, run_feathers, near_misses, int(GameManager.best_distance), GameManager.medal_for_biome(current_biome)]
	result_bonus.text = "+25 DAILY CHALLENGE BONUS" if last_result.daily_bonus > 0 else "Clean-dodge combo peaked at %d×" % combo
	var earned_medal := GameManager.medal_for_biome(current_biome)
	result_medal_icon.visible = earned_medal != "—"
	result_medal_icon.texture = _atlas_texture(EFFECTS_MEDALS_ATLAS_PATH, 3, 2, _medal_cell(earned_medal))
	result_medal_icon.tooltip_text = "%s — %s" % [BIOMES[current_biome].name, earned_medal]
	result_layer.visible = true
	_play_sound(success_sound, -4.0)

func _clear_run_objects() -> void:
	for child in obstacle_root.get_children():
		child.queue_free()
	for child in particle_root.get_children():
		child.queue_free()
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
	env.ambient_light_energy = 0.56 if index != 2 else 0.34
	sun.light_color = Color("#fff1cf") if index != 2 else Color("#8fb8ff")
	sun.light_energy = 1.02 if index != 2 else 0.68
	fill_light.light_color = biome.accent
	fill_light.light_energy = 2.2 if index == 2 else 0.7

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
	return 0.34 if index == 2 else 0.56

func _sun_color(index: int) -> Color:
	return Color("#8fb8ff") if index == 2 else Color("#fff1cf")

func _sun_energy(index: int) -> float:
	return 0.68 if index == 2 else 1.02

func _fill_energy(index: int) -> float:
	return 2.2 if index == 2 else 0.7

func _road_tint(index: int) -> Color:
	return Color("#b8d8e8") if index == 4 else Color.WHITE

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
	if index == 0:
		return
	var prop_number := 0
	for z in range(-82, 20, 26):
		# Stagger one cluster at a time instead of mirroring identical plates on
		# both sides. This keeps parallax without creating a doubled-image look.
		var side := -1.0 if posmod(prop_number + index, 2) == 0 else 1.0
		var x: float = side * randf_range(8.6, 10.2)
		var prop := _sprite_3d(prop_root, _atlas_texture(BIOME_PROP_ATLAS_PATH, 3, 2, index), Vector3(x, 2.55, float(z)), randf_range(0.0102, 0.0115), "%sPropCluster" % BIOMES[index].name.replace(" ", ""))
		prop.flip_h = side > 0.0
		prop.modulate = Color(1.0, 1.0, 1.0, randf_range(0.94, 1.0))
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
		_set_font_size(loadout_power_button, 30)
		_set_font_size(daily_label, 26)
		_set_font_size(start_button, 40)
		_set_font_size(shop_button, 32)
		_set_font_size(control_help_label, 23)
		_set_font_size(privacy_button, 20)
		loadout_power_button.custom_minimum_size.y = 72.0
		daily_label.custom_minimum_size.y = 60.0
		start_button.custom_minimum_size.y = 126.0
		shop_button.custom_minimum_size.y = 92.0
		control_help_label.custom_minimum_size.y = 48.0
		privacy_button.custom_minimum_size.y = 48.0
		_position_center_panel(result_panel, Vector2(minf(540.0, content_size.x - 24.0), minf(560.0, content_size.y - 32.0)))
		_position_center_panel(shop_panel, Vector2(minf(1120.0, content_size.x - 64.0), minf(1640.0, content_size.y - 96.0)))
		_position_center_panel(pause_panel, Vector2(minf(440.0, content_size.x - 32.0), 340.0))
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
		_set_font_size(loadout_power_button, 17)
		_set_font_size(daily_label, 15)
		_set_font_size(start_button, 25)
		_set_font_size(shop_button, 17)
		_set_font_size(control_help_label, 14)
		_set_font_size(privacy_button, 14)
		loadout_power_button.custom_minimum_size.y = 54.0
		daily_label.custom_minimum_size.y = 46.0
		start_button.custom_minimum_size.y = 66.0
		shop_button.custom_minimum_size.y = 50.0
		control_help_label.custom_minimum_size.y = 34.0
		privacy_button.custom_minimum_size.y = 32.0
		_position_center_panel(result_panel, Vector2(520.0, 500.0))
		_position_center_panel(shop_panel, Vector2(minf(980.0, content_size.x - 32.0), minf(620.0, content_size.y - 24.0)))
		_position_center_panel(pause_panel, Vector2(420.0, 320.0))
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

	if mobile_mode:
		control_help_label.text = "SWIPE TO MOVE  •  SWIPE UP TO JUMP  •  SWIPE DOWN TO DUCK"
	else:
		control_help_label.text = "ARROW KEYS TO MOVE  •  SPACE TO JUMP  •  E FOR POWER"

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
		shop_cards.custom_minimum_size.y = 1010.0
		shop_medal_row.add_theme_constant_override("separation", 16)
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
		shop_cards.custom_minimum_size.y = 284.0
		shop_medal_row.add_theme_constant_override("separation", 12)
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
	var remaining: Array[int] = [1, 2, 3, 4, 5]
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
	for item in puff_particles.duplicate():
		var node: Node3D = item.node
		if not is_instance_valid(node):
			puff_particles.erase(item)
			continue
		item.life -= delta
		item.velocity.y -= 9.0 * delta
		node.position += item.velocity * delta
		node.rotation.z += delta * 8.0
		node.scale *= 0.985
		if item.life <= 0.0:
			puff_particles.erase(item)
			node.queue_free()

func _build_audio() -> void:
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	pickup_sound = _synth_sound(0.18, 720.0, 1120.0, "sine")
	honk_sound = _synth_sound(0.72, 130.0, 72.0, "honk")
	trip_sound = _synth_sound(0.42, 105.0, 54.0, "thud")
	success_sound = _synth_sound(0.55, 420.0, 880.0, "sparkle")

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

func _play_sound(stream: AudioStream, volume_db: float) -> void:
	if not audio_enabled:
		return
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.play()

func _atlas_texture(path: String, columns: int, rows: int, index: int) -> AtlasTexture:
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
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(SURFACE_PATHS[clampi(index, 0, SURFACE_PATHS.size() - 1)])
	mat.albedo_color = tint
	mat.roughness = roughness
	# Repeat the higher-density swatch across each 24 m track tile instead of
	# enlarging one image over the entire tile. This keeps rubber crumbs, sand
	# grains, ice crystals, and soil detail at a believable gameplay scale.
	mat.uv1_scale = Vector3(4.0, 4.0, 4.0)
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
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
	return _mesh(parent, shape, pos, Vector3.ONE, color)

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
	loadout_power_button = _button("", Color("#173c5d"), Color("#51ded1"), 17)
	loadout_power_button.expand_icon = true
	loadout_power_button.add_theme_constant_override("icon_max_width", 46)
	loadout_power_button.custom_minimum_size.y = 54
	loadout_power_button.pressed.connect(_cycle_power)
	menu_box.add_child(loadout_power_button)
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
	shop_button = _button("CUSTOMIZE", Color("#17385d"), Color("#5ecfda"), 17)
	shop_button.pressed.connect(_show_shop)
	menu_box.add_child(shop_button)
	control_help_label = _label("ARROW KEYS TO MOVE  •  SPACE TO JUMP  •  E FOR POWER", 14, Color("#c8d9e9"))
	control_help_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	control_help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	control_help_label.custom_minimum_size.y = 34
	menu_box.add_child(control_help_label)
	privacy_button = _button("PRIVACY & DATA", Color(0.025, 0.11, 0.18, 0.72), Color(0.45, 0.9, 0.87, 0.48), 14)
	privacy_button.name = "PrivacyAndDataButton"
	privacy_button.tooltip_text = "Privacy policy and data-deletion instructions"
	privacy_button.pressed.connect(_open_privacy_policy)
	menu_box.add_child(privacy_button)

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
	goal_label = _label("TOUR 1  •  STAGE 1 OF 6", 16, Color("#ffe7a3"))
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

	touch_controls = Control.new()
	touch_controls.name = "InputGestureLayer"
	touch_controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	touch_controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_controls.visible = false
	ui_content_root.add_child(touch_controls)

	result_layer = _modal_layer(ui_content_root)
	result_panel = _center_panel(result_layer, Vector2(520, 500))
	var result_box := _modal_box(result_panel)
	result_title = _label("WHAT A SPIN!", 34, Color("#ffd166"))
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_box.add_child(result_title)
	result_subtitle = _label("THE NECK-WRAP PINWHEEL", 13, Color("#79f2e8"))
	result_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_box.add_child(result_subtitle)
	result_medal_icon = TextureRect.new()
	result_medal_icon.name = "EarnedMedalArt"
	result_medal_icon.custom_minimum_size = Vector2(94, 82)
	result_medal_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result_medal_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result_medal_icon.texture = _atlas_texture(EFFECTS_MEDALS_ATLAS_PATH, 3, 2, 3)
	result_medal_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	result_box.add_child(result_medal_icon)
	result_stats = _label("", 21, Color.WHITE)
	result_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_stats.custom_minimum_size.y = 122
	result_box.add_child(result_stats)
	result_bonus = _label("", 15, Color("#ffe89a"))
	result_bonus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_box.add_child(result_bonus)
	var retry := _button("RUN AGAIN", Color("#ff654f"), Color("#ffb34b"), 21)
	retry.custom_minimum_size.y = 58
	retry.pressed.connect(_start_run)
	result_box.add_child(retry)
	var home := _button("BACK TO HOME", Color("#263f68"), Color("#5c7cbd"), 16)
	home.pressed.connect(_show_menu)
	result_box.add_child(home)

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
	shop_cards = GridContainer.new()
	shop_cards.columns = 4
	shop_cards.add_theme_constant_override("h_separation", 12)
	shop_cards.add_theme_constant_override("v_separation", 12)
	shop_cards.custom_minimum_size.y = 284
	shop_box.add_child(shop_cards)
	shop_medal_row = HBoxContainer.new()
	shop_medal_row.name = "GeneratedMedalGallery"
	shop_medal_row.alignment = BoxContainer.ALIGNMENT_CENTER
	shop_medal_row.add_theme_constant_override("separation", 20)
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
	state = GameState.MENU
	menu_layer.visible = true
	result_layer.visible = false
	shop_layer.visible = false
	pause_layer.visible = false
	hud.visible = false
	touch_controls.visible = false
	player.active = false
	player.stunned = false
	player.visible = false
	camera.position = camera_home_position
	camera.look_at_from_position(camera.position, camera_look_target)
	_refresh_menu()

func _refresh_menu() -> void:
	menu_wallet.text = "◆  %d FEATHERS     BEST  %dm" % [GameManager.total_feathers, int(GameManager.best_distance)]
	loadout_skin_label.text = "RUNNER  •  %s" % GameManager.SKINS[GameManager.selected_skin].to_upper()
	loadout_power_button.text = "POWER  •  %s     TAP TO CHANGE" % GameManager.POWERS[GameManager.selected_power].to_upper()
	loadout_power_button.icon = _atlas_texture(REWARD_POWER_ATLAS_PATH, 3, 2, GameManager.selected_power + 1)
	daily_label.text = "✓  DAILY CHALLENGE COMPLETE" if GameManager.daily_complete else "DAILY CHALLENGE  •  COLLECT 15 FEATHERS  •  REWARD ◆25"

func _cycle_power() -> void:
	GameManager.set_power(GameManager.selected_power + 1)
	_refresh_menu()

func _open_privacy_policy() -> void:
	var error := OS.shell_open(PRIVACY_POLICY_URL)
	if error != OK:
		DisplayServer.clipboard_set(PRIVACY_POLICY_URL)
		_show_toast("Could not open the browser — privacy link copied")

func _show_shop() -> void:
	state = GameState.SHOP
	menu_layer.visible = false
	shop_layer.visible = true
	_rebuild_shop_cards()

func _rebuild_shop_cards() -> void:
	for child in shop_cards.get_children():
		child.queue_free()
	for child in shop_medal_row.get_children():
		child.queue_free()
	shop_wallet.text = "◆  %d FEATHERS" % GameManager.total_feathers
	var earned_medals := 0
	var medal_colors := [Color("#20c7bc"), Color("#54c7f2"), Color("#8f75f5"), Color("#ff9c63"), Color("#82c86d"), Color("#ff6f9f")]
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
	var skin_colors := [Color("#13c7c4"), Color("#7c5cff"), Color("#f7c948"), Color("#ff5da2")]
	for index in range(GameManager.SKINS.size()):
		var card := PanelContainer.new()
		card.name = "RunnerCard%d" % index
		card.set_meta("accent_color", skin_colors[index])
		card.set_meta("selected", GameManager.selected_skin == index)
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
		portrait_bubble.add_theme_stylebox_override("panel", _panel_style(Color(1, 1, 1, 0.72), skin_colors[index].lerp(Color.WHITE, 0.35), 2, 28))
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
		var detail_text := "READY TO WEAR" if index in GameManager.owned_skins else "◆ %d FEATHERS" % GameManager.SKIN_COSTS[index]
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
	var detail := card.get_node("CardMargin/CardBox/RunnerPrice") as Label
	var action := card.get_node("CardMargin/CardBox/RunnerAction") as Button
	if portrait_layout:
		card.custom_minimum_size = Vector2(400, 492)
		for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
			margin.add_theme_constant_override(side, 24)
		box.add_theme_constant_override("separation", 14)
		portrait_bubble.custom_minimum_size = Vector2(280, 270)
		portrait.custom_minimum_size = Vector2(260, 250)
		_set_font_size(name_label, 29)
		_set_font_size(detail, 20)
		_set_font_size(action, 22)
		action.custom_minimum_size.y = 68
	else:
		card.custom_minimum_size = Vector2(205, 276)
		for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
			margin.add_theme_constant_override(side, 12)
		box.add_theme_constant_override("separation", 7)
		portrait_bubble.custom_minimum_size = Vector2(126, 122)
		portrait.custom_minimum_size = Vector2(118, 114)
		_set_font_size(name_label, 18)
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
	pause_layer.visible = true
	hud.visible = false
	touch_controls.visible = false

func _resume_game() -> void:
	if state != GameState.PAUSED:
		return
	state = GameState.RUNNING
	pause_layer.visible = false
	hud.visible = true
	touch_controls.visible = false

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
	var power_name: String = GameManager.POWERS[GameManager.selected_power]
	power_button.icon = _atlas_texture(REWARD_POWER_ATLAS_PATH, 3, 2, GameManager.selected_power + 1)
	if power_charge >= 100.0:
		power_button.text = "%s READY!\n%s" % [power_name.to_upper(), "TAP TO USE" if mobile_mode else "PRESS E"]
	else:
		power_button.text = "%s  %d%%\nDODGE TO CHARGE" % [power_name.to_upper(), int(power_charge)]
	if power_timer > 0.0:
		power_button.text = "%s ACTIVE\n%.1f SECONDS" % [power_name.to_upper(), power_timer]
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
