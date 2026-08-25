extends Node3D

signal crash_finished

const LANES := [-2.8, 0.0, 2.8]
const SKIN_TEXTURE_PATHS := [
	"res://assets/generated/gameplay/runner_classic_back.png",
	"res://assets/generated/gameplay/runner_midnight_back.png",
	"res://assets/generated/gameplay/runner_golden_back.png",
	"res://assets/generated/gameplay/runner_bubblegum_back.png",
	"res://assets/generated/gameplay/runner_midnight_back.png",
	"res://assets/generated/gameplay/runner_classic_back.png",
	"res://assets/generated/gameplay/runner_bubblegum_back.png",
	"res://assets/generated/gameplay/runner_classic_back.png",
	"res://assets/generated/gameplay/runner_midnight_back.png",
	"res://assets/generated/gameplay/runner_bubblegum_back.png",
	"res://assets/generated/gameplay/runner_classic_back.png",
	"res://assets/generated/gameplay/runner_midnight_back.png",
]
const BODY_TEXTURE_PATHS := [
	"res://assets/generated/gameplay/runner_classic_body_back.png",
	"res://assets/generated/gameplay/runner_midnight_body_back.png",
	"res://assets/generated/gameplay/runner_golden_body_back.png",
	"res://assets/generated/gameplay/runner_bubblegum_body_back.png",
	"res://assets/generated/gameplay/runner_midnight_body_back.png",
	"res://assets/generated/gameplay/runner_classic_body_back.png",
	"res://assets/generated/gameplay/runner_bubblegum_body_back.png",
	"res://assets/generated/gameplay/runner_classic_body_back.png",
	"res://assets/generated/gameplay/runner_midnight_body_back.png",
	"res://assets/generated/gameplay/runner_bubblegum_body_back.png",
	"res://assets/generated/gameplay/runner_classic_body_back.png",
	"res://assets/generated/gameplay/runner_midnight_body_back.png",
]
const RUN_LEG_SHEET_PATH := "res://assets/generated/gameplay/runner_classic_legs_run_sheet.png"

var lane := 1
var jump_velocity := 0.0
var jumping := false
var ducking := false
var duck_timer := 0.0
var stunned := false
var spin_time := 0.0
var crash_mode := "spin"
var run_clock := 0.0
var active := false

var visual: Node3D
var body: Node3D
var neck: Node3D
var head: Node3D
var left_leg: Node3D
var right_leg: Node3D
var left_wing: Node3D
var right_wing: Node3D
var character_sprite: Sprite3D
var run_leg_sprite: Sprite3D
var ground_shadow: MeshInstance3D
var current_skin_index := 0
var visor_parts: Array[MeshInstance3D] = []
var dark_parts: Array[MeshInstance3D] = []
var accent_parts: Array[MeshInstance3D] = []

func _ready() -> void:
	_build_ostrich()
	apply_skin(GameManager.selected_skin)

func reset_player() -> void:
	lane = 1
	position = Vector3(0.0, 0.0, 0.0)
	jump_velocity = 0.0
	jumping = false
	ducking = false
	duck_timer = 0.0
	stunned = false
	spin_time = 0.0
	active = true
	visual.rotation = Vector3.ZERO
	visual.position = Vector3.ZERO
	visual.scale = Vector3.ONE
	character_sprite.position = Vector3(0.0, 2.53, -0.08)
	character_sprite.rotation = Vector3.ZERO
	character_sprite.scale = Vector3.ONE
	_set_layered_runner_visible(true)
	_reset_run_cycle()
	visible = true
	apply_skin(GameManager.selected_skin)

func step(delta: float) -> void:
	if not active:
		_idle_animation(delta)
		return
	run_clock += delta
	position.x = move_toward(position.x, LANES[lane], delta * 12.5)
	if stunned:
		match crash_mode:
			"trip":
				_trip_animation(delta)
			"bar_flip":
				_bar_flip_animation(delta)
			_:
				_spin_animation(delta)
		return
	if jumping:
		jump_velocity -= 24.0 * delta
		position.y += jump_velocity * delta
		if position.y <= 0.0:
			position.y = 0.0
			jumping = false
			jump_velocity = 0.0
	if ducking:
		duck_timer -= delta
		if duck_timer <= 0.0:
			ducking = false
	_animate_run()

func move_lane(direction: int) -> void:
	if active and not stunned:
		lane = clampi(lane + direction, 0, 2)

func jump() -> void:
	if active and not stunned and not jumping:
		ducking = false
		jumping = true
		jump_velocity = 10.8

func duck() -> void:
	if active and not stunned and not jumping:
		ducking = true
		duck_timer = 0.72

func trigger_spin() -> void:
	if stunned:
		return
	stunned = true
	crash_mode = "spin"
	spin_time = 0.0
	ducking = false
	jumping = false
	jump_velocity = 0.0
	_prepare_crash_plate()

func trigger_trip() -> void:
	if stunned:
		return
	stunned = true
	crash_mode = "trip"
	spin_time = 0.0
	ducking = false
	jumping = false
	jump_velocity = 0.0
	_prepare_crash_plate()

func trigger_bar_flip() -> void:
	if stunned:
		return
	stunned = true
	crash_mode = "bar_flip"
	spin_time = 0.0
	ducking = false
	jumping = false
	jump_velocity = 0.0
	_prepare_crash_plate()

func collision_height() -> float:
	if ducking:
		return 1.75
	return 4.6

func _spin_animation(delta: float) -> void:
	spin_time += delta
	var t := minf(spin_time / 1.55, 1.0)
	var spin_ease := sin(t * PI * 0.5)
	visual.rotation.z = spin_ease * TAU * 2.75
	visual.rotation.y = sin(t * PI * 5.0) * 0.28
	visual.scale = Vector3(1.0 + sin(t * PI) * 0.18, 1.0 - sin(t * PI) * 0.14, 1.0)
	position.y = sin(t * PI) * 1.0
	character_sprite.scale = Vector3(1.0 + sin(t * PI) * 0.16, 1.0 - sin(t * PI) * 0.12, 1.0)
	if spin_time >= 1.55:
		active = false
		visual.rotation.z = 0.0
		visual.rotation.x = -0.9
		visual.rotation.y = 0.35
		position.y = 0.0
		crash_finished.emit()

func _trip_animation(delta: float) -> void:
	spin_time += delta
	var t := minf(spin_time / 1.25, 1.0)
	var stumble := sin(minf(t * 2.4, 1.0) * PI)
	visual.rotation.x = -pow(t, 1.35) * 1.42
	visual.rotation.z = sin(t * PI * 4.0) * (1.0 - t) * 0.18
	visual.rotation.y = sin(t * PI) * 0.18
	visual.position.z = -t * 1.3
	visual.position.y = stumble * 0.38 - pow(t, 2.0) * 0.62
	# The generated character plate stays camera-readable while visibly pitching
	# into a forward stumble instead of spinning around its center.
	character_sprite.rotation.z = -pow(t, 1.2) * 1.28 + sin(t * PI * 4.0) * (1.0 - t) * 0.12
	character_sprite.position.y = 2.53 - pow(t, 1.5) * 1.02
	character_sprite.position.x = sin(t * PI) * 0.34
	character_sprite.scale = Vector3(1.0 + t * 0.08, 1.0 - t * 0.16, 1.0)
	left_leg.rotation.x = lerpf(left_leg.rotation.x, 1.15, delta * 9.0)
	right_leg.rotation.x = lerpf(right_leg.rotation.x, -0.65, delta * 9.0)
	if spin_time >= 1.25:
		active = false
		visual.rotation.x = -1.42
		visual.rotation.z = 0.08
		crash_finished.emit()

func _bar_flip_animation(delta: float) -> void:
	spin_time += delta
	var duration := 1.65
	var t := minf(spin_time / duration, 1.0)
	var eased := t * t * (3.0 - 2.0 * t)
	var forward_angle := TAU * eased
	var depth_projection := cos(forward_angle)

	# Project a rotation around the track's left/right axis into the rear camera.
	# The sprite foreshortens vertically as the feet swing forward in depth, then
	# appears inverted overhead before opening back out on the far side. Keeping x
	# centered prevents this from reading as a screen-plane cartwheel.
	var neck_pivot := Vector2(0.0, 4.05)
	var upright_center := Vector2(0.0, 2.53)
	var projected_center := neck_pivot + (upright_center - neck_pivot) * depth_projection
	var landing := smoothstep(0.82, 1.0, t)
	character_sprite.position.x = 0.0
	character_sprite.position.y = projected_center.y - landing * 0.38
	character_sprite.rotation.z = landing * 0.08
	character_sprite.scale = Vector3(
		1.0 + landing * 0.12,
		depth_projection * (1.0 - landing * 0.16),
		1.0
	)
	visual.position.z = -eased * 1.25
	visual.position.y = sin(t * PI) * 0.16
	left_leg.rotation.x = lerpf(left_leg.rotation.x, 1.2, delta * 8.0)
	right_leg.rotation.x = lerpf(right_leg.rotation.x, -1.0, delta * 8.0)

	if spin_time >= duration:
		active = false
		visual.position.y = 0.0
		character_sprite.position = Vector3(0.0, 2.15, -0.08)
		character_sprite.rotation = Vector3(0.0, 0.0, 0.08)
		character_sprite.scale = Vector3(1.12, 0.84, 1.0)
		crash_finished.emit()

func _animate_run() -> void:
	var pace := run_clock * 12.0
	var swing := sin(pace) * 0.58
	var bounce := absf(sin(pace)) * 0.10
	left_leg.rotation.x = swing
	right_leg.rotation.x = -swing
	# Six authored poses replace the old rigid cutout rotation. Advancing the
	# 3x2 sheet changes knee bend, recovery height, planted foot, and visible sole
	# while the body plate continues to bob smoothly above it.
	if is_instance_valid(run_leg_sprite) and run_leg_sprite.visible:
		var stride_phase := fposmod(pace, TAU) / TAU
		run_leg_sprite.frame = mini(int(floor(stride_phase * 6.0)), 5)
		run_leg_sprite.position.y = 1.15 + bounce
		run_leg_sprite.rotation.z = sin(pace) * 0.018
		run_leg_sprite.scale = Vector3(1.0 + bounce * 0.08, 1.0 - bounce * 0.04, 1.0)
	left_wing.rotation.z = -0.35 + sin(pace) * 0.12
	right_wing.rotation.z = 0.35 - sin(pace) * 0.12
	body.position.y = 2.55 + bounce
	character_sprite.position.y = 2.53 + bounce
	character_sprite.rotation.z = sin(pace) * 0.018
	character_sprite.scale = Vector3(1.0 + absf(sin(pace)) * 0.018, 1.0 - absf(sin(pace)) * 0.012, 1.0)
	visual.rotation.z = lerpf(visual.rotation.z, (LANES[lane] - position.x) * -0.075, 0.2)
	if ducking:
		neck.scale.y = lerpf(neck.scale.y, 0.34, 0.35)
		neck.rotation.x = lerpf(neck.rotation.x, -0.92, 0.3)
		head.rotation.x = lerpf(head.rotation.x, 0.7, 0.3)
		body.scale.y = lerpf(body.scale.y, 0.78, 0.3)
		character_sprite.scale.y = lerpf(character_sprite.scale.y, 0.72, 0.3)
		character_sprite.position.y = lerpf(character_sprite.position.y, 1.95, 0.3)
		if is_instance_valid(run_leg_sprite):
			run_leg_sprite.position.y = lerpf(run_leg_sprite.position.y, 0.82 + bounce * 0.35, 0.3)
	else:
		neck.scale.y = lerpf(neck.scale.y, 1.0, 0.28)
		neck.rotation.x = lerpf(neck.rotation.x, sin(pace * 0.5) * 0.025, 0.25)
		head.rotation.x = lerpf(head.rotation.x, sin(pace * 0.5) * -0.045, 0.2)
		body.scale.y = lerpf(body.scale.y, 1.0, 0.3)

func _idle_animation(delta: float) -> void:
	run_clock += delta
	if visual == null or stunned:
		return
	body.position.y = 2.55 + sin(run_clock * 2.0) * 0.04
	character_sprite.position.y = 2.53 + sin(run_clock * 2.0) * 0.04
	character_sprite.rotation.z = sin(run_clock * 1.4) * 0.012
	head.rotation.y = sin(run_clock * 0.8) * 0.1
	if is_instance_valid(run_leg_sprite) and run_leg_sprite.visible:
		run_leg_sprite.frame = 2
		run_leg_sprite.position.y = lerpf(run_leg_sprite.position.y, 1.15, delta * 7.0)
		run_leg_sprite.rotation.z = lerpf(run_leg_sprite.rotation.z, 0.0, delta * 7.0)
		run_leg_sprite.scale = run_leg_sprite.scale.lerp(Vector3.ONE, delta * 7.0)

func apply_skin(index: int) -> void:
	var palettes := [
		[Color("#171821"), Color("#13c7c4"), Color("#fff0cf")],
		[Color("#1b1c45"), Color("#7c5cff"), Color("#d9d5ff")],
		[Color("#5b3514"), Color("#f7c948"), Color("#fff1ad")],
		[Color("#58243f"), Color("#ff5da2"), Color("#ffe0ee")],
		[Color("#161744"), Color("#5d62ff"), Color("#d9f4ff")],
		[Color("#063f32"), Color("#8bd329"), Color("#f8efc8")],
		[Color("#76273a"), Color("#ff713f"), Color("#ffe0d5")],
		[Color("#44647f"), Color("#82d9ff"), Color("#f0efff")],
		[Color("#11194e"), Color("#55dcff"), Color("#ffe4a6")],
		[Color("#74434b"), Color("#e9a192"), Color("#fff2dc")],
		[Color("#063b2e"), Color("#b7ff24"), Color("#f9ffc7")],
		[Color("#082f54"), Color("#17b9a8"), Color("#c8a4ff")],
	]
	var art_tints := [
		Color.WHITE,
		Color.WHITE,
		Color.WHITE,
		Color.WHITE,
		Color(0.92, 0.84, 1.15, 1.0),
		Color(0.64, 1.05, 0.72, 1.0),
		Color(1.12, 0.78, 0.62, 1.0),
		Color(0.72, 0.92, 1.16, 1.0),
		Color(0.78, 0.82, 1.18, 1.0),
		Color(1.15, 0.82, 0.86, 1.0),
		Color(0.72, 1.18, 0.62, 1.0),
		Color(0.68, 0.96, 1.16, 1.0),
	]
	current_skin_index = clampi(index, 0, palettes.size() - 1)
	var p: Array = palettes[current_skin_index]
	var art_tint: Color = art_tints[current_skin_index]
	if is_instance_valid(character_sprite):
		character_sprite.texture = load(SKIN_TEXTURE_PATHS[current_skin_index] if stunned else BODY_TEXTURE_PATHS[current_skin_index])
		character_sprite.modulate = art_tint
	if is_instance_valid(run_leg_sprite):
		run_leg_sprite.modulate = Color.WHITE
		var leg_material := run_leg_sprite.material_override as ShaderMaterial
		leg_material.set_shader_parameter("shoe_color", p[1])
	for mesh in dark_parts:
		mesh.material_override = _material(p[0], 0.7, 0.05)
	for mesh in accent_parts:
		mesh.material_override = _material(p[1], 0.45, 0.25)
	for mesh in visor_parts:
		mesh.material_override = _material(p[1], 0.32, 0.35)

func _build_ostrich() -> void:
	visual = Node3D.new()
	visual.name = "OstrichVisual"
	add_child(visual)
	body = Node3D.new()
	body.name = "Body"
	body.position = Vector3(0, 2.55, 0)
	visual.add_child(body)

	var torso := _sphere(body, Vector3(0, 0, 0), Vector3(1.05, 1.25, 0.92), Color("#171821"))
	dark_parts.append(torso)
	var chest := _sphere(body, Vector3(0, 0.13, -0.72), Vector3(0.63, 0.72, 0.22), Color("#fff0cf"))
	var tail_a := _capsule(body, Vector3(-0.62, 0.35, 0.62), Vector3(0.25, 0.75, 0.25), Color("#fff0cf"))
	tail_a.rotation.z = -0.75
	tail_a.rotation.x = 0.45
	var tail_b := _capsule(body, Vector3(0.0, 0.55, 0.72), Vector3(0.28, 0.85, 0.28), Color("#171821"))
	tail_b.rotation.x = 0.6
	var tail_c := _capsule(body, Vector3(0.62, 0.35, 0.62), Vector3(0.25, 0.75, 0.25), Color("#fff0cf"))
	tail_c.rotation.z = 0.75
	tail_c.rotation.x = 0.45

	left_wing = Node3D.new()
	left_wing.position = Vector3(-0.95, 0.1, 0)
	body.add_child(left_wing)
	var wing_l := _capsule(left_wing, Vector3(-0.25, -0.1, 0), Vector3(0.38, 1.0, 0.26), Color("#171821"))
	wing_l.rotation.z = -0.35
	dark_parts.append(wing_l)
	right_wing = Node3D.new()
	right_wing.position = Vector3(0.95, 0.1, 0)
	body.add_child(right_wing)
	var wing_r := _capsule(right_wing, Vector3(0.25, -0.1, 0), Vector3(0.38, 1.0, 0.26), Color("#171821"))
	wing_r.rotation.z = 0.35
	dark_parts.append(wing_r)

	neck = Node3D.new()
	neck.name = "Neck"
	neck.position = Vector3(0, 0.82, -0.18)
	body.add_child(neck)
	_capsule(neck, Vector3(0, 1.15, 0), Vector3(0.34, 2.25, 0.34), Color("#f2cda8"))
	head = Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 2.42, -0.03)
	neck.add_child(head)
	_sphere(head, Vector3(0, 0.05, -0.03), Vector3(0.66, 0.65, 0.58), Color("#fff0cf"))
	var hair := _sphere(head, Vector3(0, 0.37, 0.09), Vector3(0.54, 0.28, 0.48), Color("#171821"))
	dark_parts.append(hair)
	for side in [-1.0, 1.0]:
		_sphere(head, Vector3(side * 0.25, 0.13, -0.5), Vector3(0.25, 0.29, 0.14), Color.WHITE)
		_sphere(head, Vector3(side * 0.25, 0.12, -0.63), Vector3(0.105, 0.14, 0.06), Color("#102a43"))
	var beak := _sphere(head, Vector3(0, -0.16, -0.62), Vector3(0.45, 0.2, 0.38), Color("#ff836f"))
	var visor_band := _torus(head, Vector3(0, 0.35, -0.03), Vector3(0.7, 0.19, 0.7), Color("#13c7c4"))
	visor_parts.append(visor_band)
	var brim := _box(head, Vector3(0, 0.34, -0.54), Vector3(0.82, 0.09, 0.42), Color("#13c7c4"))
	brim.rotation.x = -0.12
	visor_parts.append(brim)

	left_leg = _make_leg(body, -0.43)
	right_leg = _make_leg(body, 0.43)

	# The generated runner is the production visual. The procedural rig remains
	# hidden as an animation/collision skeleton, keeping gameplay behavior intact.
	for child in visual.find_children("*", "MeshInstance3D", true, false):
		(child as MeshInstance3D).visible = false
	character_sprite = Sprite3D.new()
	character_sprite.name = "GeneratedRunnerArt"
	character_sprite.texture = load(SKIN_TEXTURE_PATHS[0])
	character_sprite.position = Vector3(0.0, 2.53, -0.08)
	character_sprite.pixel_size = 0.00335
	character_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	# The gameplay camera is fixed, so the runner plate can stay in the track
	# plane. Avoiding billboarding lets trip/spin rotations remain fully visible.
	character_sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	character_sprite.shaded = false
	character_sprite.double_sided = true
	character_sprite.render_priority = 3
	visual.add_child(character_sprite)

	# The production runner uses a legless body plate over a six-pose run-cycle
	# sheet. Every frame has the same hip anchor, so contact, push-off, passing,
	# and recovery poses remain stable beneath the feather body.
	run_leg_sprite = Sprite3D.new()
	run_leg_sprite.name = "GeneratedSixPoseRunLegs"
	run_leg_sprite.texture = load(RUN_LEG_SHEET_PATH)
	run_leg_sprite.hframes = 3
	run_leg_sprite.vframes = 2
	run_leg_sprite.frame = 2
	run_leg_sprite.position = Vector3(0.0, 1.15, -0.07)
	run_leg_sprite.pixel_size = 0.0043
	run_leg_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	run_leg_sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	run_leg_sprite.shaded = false
	run_leg_sprite.double_sided = true
	run_leg_sprite.render_priority = 3
	run_leg_sprite.material_override = _run_leg_palette_material()
	visual.add_child(run_leg_sprite)
	character_sprite.texture = load(BODY_TEXTURE_PATHS[0])
	character_sprite.render_priority = 4

	var shadow_mesh := QuadMesh.new()
	shadow_mesh.size = Vector2(2.25, 1.18)
	var shadow_material := StandardMaterial3D.new()
	shadow_material.albedo_color = Color(0.015, 0.025, 0.045, 0.32)
	shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ground_shadow = MeshInstance3D.new()
	ground_shadow.name = "SoftGroundShadow"
	ground_shadow.mesh = shadow_mesh
	ground_shadow.material_override = shadow_material
	ground_shadow.position = Vector3(0.0, 0.055, 0.15)
	ground_shadow.rotation_degrees.x = -90.0
	ground_shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(ground_shadow)

func _make_leg(parent: Node3D, x: float) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = Vector3(x, -0.8, 0)
	parent.add_child(pivot)
	_capsule(pivot, Vector3(0, -0.75, 0), Vector3(0.18, 1.45, 0.18), Color("#ef8d72"))
	var shoe := _box(pivot, Vector3(0, -1.45, -0.20), Vector3(0.58, 0.28, 0.9), Color("#13c7c4"))
	accent_parts.append(shoe)
	return pivot

func _run_leg_palette_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform vec4 shoe_color : source_color = vec4(0.075, 0.78, 0.77, 1.0);
void fragment() {
	vec4 art = texture(texture_albedo, UV);
	float cyan = smoothstep(0.025, 0.18, min(art.g - art.r, art.b - art.r));
	float brightness = max(art.r, max(art.g, art.b));
	vec3 recolored_shoe = shoe_color.rgb * mix(0.42, 1.42, brightness);
	ALBEDO = mix(art.rgb, recolored_shoe, cyan * 0.92);
	ALPHA = art.a;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("texture_albedo", load(RUN_LEG_SHEET_PATH))
	return material

func _reset_run_cycle() -> void:
	if not is_instance_valid(run_leg_sprite):
		return
	run_leg_sprite.frame = 2
	run_leg_sprite.position = Vector3(0.0, 1.15, -0.07)
	run_leg_sprite.rotation = Vector3.ZERO
	run_leg_sprite.scale = Vector3.ONE

func _set_layered_runner_visible(enabled: bool) -> void:
	if not is_instance_valid(run_leg_sprite):
		return
	run_leg_sprite.visible = enabled
	if enabled:
		character_sprite.texture = load(BODY_TEXTURE_PATHS[current_skin_index])

func _prepare_crash_plate() -> void:
	_set_layered_runner_visible(false)
	character_sprite.texture = load(SKIN_TEXTURE_PATHS[current_skin_index])

func _material(color: Color, roughness := 0.65, metallic := 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
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

func _sphere(parent: Node3D, pos: Vector3, scale_value: Vector3, color: Color) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 20
	shape.rings = 12
	return _mesh(parent, shape, pos, scale_value * 2.0, color)

func _capsule(parent: Node3D, pos: Vector3, scale_value: Vector3, color: Color) -> MeshInstance3D:
	var shape := CapsuleMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 16
	shape.rings = 6
	return _mesh(parent, shape, pos, scale_value, color)

func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	return _mesh(parent, shape, pos, Vector3.ONE, color)

func _torus(parent: Node3D, pos: Vector3, scale_value: Vector3, color: Color) -> MeshInstance3D:
	var shape := TorusMesh.new()
	shape.inner_radius = 0.38
	shape.outer_radius = 0.52
	shape.rings = 20
	shape.ring_segments = 8
	return _mesh(parent, shape, pos, scale_value, color)
