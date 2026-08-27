extends Node3D

const TRACK_LENGTH := 3000.0
const TRACK_STEP := 3.0
const PLAYER_CLEARANCE := 0.16
const SAVE_PATH := "user://penguin_dash_3d_save.json"
const PENGUIN_SCENE: PackedScene = preload("res://assets/models/penguin_joy_biped.glb")
# Mesh vertices are already in meters; do not compensate for the 0.01 armature node.
const PENGUIN_MODEL_SCALE := 0.85
# Meshy biped is Y-up and faces +Z. Rotate onto its belly, head down the chute.
const PENGUIN_MODEL_ROTATION := Vector3(90.0, 180.0, 0.0)
const PENGUIN_MODEL_OFFSET := Vector3(0.0, 0.02, 0.0)

const NAVY := Color("#0E1F2E")
const GLACIER := Color("#1B4B6B")
const CYAN := Color("#6FD8E8")
const ORANGE := Color("#F4692A")
const CREAM := Color("#F7F2E7")
const GOLD := Color("#E8B23D")

enum GameState { MENU, RUNNING, GAME_OVER }

@onready var ui: Control = $UI/Overlay

var state := GameState.MENU
var distance := 0.0
var speed := 12.0
var fish_count := 0
var best_distance := 0
var jump_height := 0.0
var jump_velocity := 0.0
var run_time := 0.0
var world_time := 0.0
var game_over_age := 0.0
var new_best := false

var rng := RandomNumberGenerator.new()
var player: Node3D
var player_visual: Node3D
var penguin_anim: AnimationPlayer
var camera: Camera3D
var obstacle_root: Node3D
var next_obstacle_at := 55.0
var obstacles: Array[Dictionary] = []

var mat_navy: StandardMaterial3D
var mat_glacier: StandardMaterial3D
var mat_cyan: StandardMaterial3D
var mat_orange: StandardMaterial3D
var mat_cream: StandardMaterial3D
var mat_gold: StandardMaterial3D
var mat_dark_ice: StandardMaterial3D


func _ready() -> void:
	rng.randomize()
	_load_save()
	_build_materials()
	_build_world()
	_build_path_resource()
	_build_track_mesh()
	_build_edge_ribbons()
	_build_connected_mountain_terrain()
	obstacle_root = Node3D.new()
	obstacle_root.name = "Obstacles"
	add_child(obstacle_root)
	player = _build_penguin()
	add_child(player)
	_build_camera()
	_place_player(true)
	_update_ui()


func _process(delta: float) -> void:
	world_time += delta
	match state:
		GameState.MENU:
			distance = fmod(world_time * 2.0, 18.0)
			_place_player(false)
			_update_camera(delta, true)
		GameState.RUNNING:
			_update_run(delta)
		GameState.GAME_OVER:
			game_over_age += delta
			_update_camera(delta, false)
	_update_character_animation()
	_update_ui()


func _build_materials() -> void:
	mat_navy = _make_material(NAVY, 0.72)
	mat_glacier = _make_material(GLACIER, 0.64)
	mat_cyan = _make_material(CYAN, 0.27)
	mat_orange = _make_material(ORANGE, 0.48)
	mat_cream = _make_material(CREAM, 0.78)
	mat_gold = _make_material(GOLD, 0.36)
	mat_dark_ice = _make_material(Color("#07141F"), 0.42)
	mat_gold.metallic = 0.16
	mat_cyan.metallic = 0.08


func _make_material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = 0.0
	return material


func _build_world() -> void:
	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	var environment := Environment.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#03101F")
	sky_material.sky_horizon_color = Color("#205B70")
	sky_material.ground_bottom_color = Color("#071523")
	sky_material.ground_horizon_color = Color("#5F98A5")
	sky_material.sky_curve = 0.16
	sky_material.ground_curve = 0.08
	var night_sky := Sky.new()
	night_sky.sky_material = sky_material
	environment.sky = night_sky
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#78B9C8")
	environment.ambient_light_energy = 0.34
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.fog_enabled = true
	environment.fog_light_color = Color("#376D7D")
	environment.fog_light_energy = 0.20
	environment.fog_density = 0.0021
	environment.fog_sky_affect = 0.18
	world_environment.environment = environment
	add_child(world_environment)

	var key_light := DirectionalLight3D.new()
	key_light.name = "MoonKey"
	key_light.light_color = Color("#D9F7FF")
	key_light.light_energy = 0.78
	key_light.rotation_degrees = Vector3(-54.0, -28.0, 0.0)
	key_light.shadow_enabled = true
	key_light.directional_shadow_max_distance = 90.0
	add_child(key_light)

	var warm_light := DirectionalLight3D.new()
	warm_light.name = "WarmRim"
	warm_light.light_color = GOLD
	warm_light.light_energy = 0.24
	warm_light.rotation_degrees = Vector3(-25.0, 142.0, 18.0)
	add_child(warm_light)


func _course_point(at: float) -> Vector3:
	var x := sin(at * 0.024) * 8.5 + sin(at * 0.0085 + 0.7) * 5.0
	var y := -at * 0.014 + sin(at * 0.035) * 0.75
	return Vector3(x, y, -at)


func _course_bank(at: float) -> float:
	return clampf(sin(at * 0.024) * 0.34 + sin(at * 0.0085 + 0.7) * 0.14, -0.48, 0.48)


func _course_frame(at: float) -> Transform3D:
	var before := _course_point(maxf(0.0, at - 0.6))
	var after := _course_point(minf(TRACK_LENGTH, at + 0.6))
	var tangent := (after - before).normalized()
	var right := tangent.cross(Vector3.UP).normalized()
	var up := right.cross(tangent).normalized()
	var bank_angle := _course_bank(at)
	right = right.rotated(tangent, bank_angle)
	up = up.rotated(tangent, bank_angle)
	var basis := Basis(right, up, -tangent).orthonormalized()
	return Transform3D(basis, _course_point(at))


func _build_path_resource() -> void:
	var path := Path3D.new()
	path.name = "BobsledSpline"
	var curve := Curve3D.new()
	curve.bake_interval = 1.0
	var at := 0.0
	while at <= TRACK_LENGTH:
		var point := _course_point(at)
		var tangent := (_course_point(minf(TRACK_LENGTH, at + 1.0)) - _course_point(maxf(0.0, at - 1.0))) * 0.42
		curve.add_point(point, -tangent, tangent)
		at += 10.0
	path.curve = curve
	add_child(path)


func _build_track_mesh() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var track_material := StandardMaterial3D.new()
	track_material.albedo_color = Color("#5897A4")
	track_material.albedo_texture = load("res://assets/art/track_ice.png")
	track_material.roughness = 0.46
	track_material.metallic = 0.03
	track_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	track_material.texture_repeat = true
	surface.set_material(track_material)

	var lateral: Array[float] = [-5.2, -4.7, -3.8, -2.3, 0.0, 2.3, 3.8, 4.7, 5.2]
	var heights: Array[float] = [2.7, 1.25, 0.38, 0.06, 0.0, 0.06, 0.38, 1.25, 2.7]
	var at := 0.0
	while at < TRACK_LENGTH:
		var next_at := minf(TRACK_LENGTH, at + TRACK_STEP)
		var frame_a := _course_frame(at)
		var frame_b := _course_frame(next_at)
		for cross in range(lateral.size() - 1):
			var a0 := frame_a.origin + frame_a.basis.x * lateral[cross] + frame_a.basis.y * heights[cross]
			var a1 := frame_a.origin + frame_a.basis.x * lateral[cross + 1] + frame_a.basis.y * heights[cross + 1]
			var b0 := frame_b.origin + frame_b.basis.x * lateral[cross] + frame_b.basis.y * heights[cross]
			var b1 := frame_b.origin + frame_b.basis.x * lateral[cross + 1] + frame_b.basis.y * heights[cross + 1]
			var u0 := float(cross) / float(lateral.size() - 1)
			var u1 := float(cross + 1) / float(lateral.size() - 1)
			var v0 := at / 14.0
			var v1 := next_at / 14.0
			_add_track_vertex(surface, a0, Vector2(u0, v0))
			_add_track_vertex(surface, b0, Vector2(u0, v1))
			_add_track_vertex(surface, b1, Vector2(u1, v1))
			_add_track_vertex(surface, a0, Vector2(u0, v0))
			_add_track_vertex(surface, b1, Vector2(u1, v1))
			_add_track_vertex(surface, a1, Vector2(u1, v0))
		at = next_at
	surface.generate_normals()
	var track_mesh := surface.commit()
	var track_instance := MeshInstance3D.new()
	track_instance.name = "PaintedIceChute"
	track_instance.mesh = track_mesh
	track_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	add_child(track_instance)


func _add_track_vertex(surface: SurfaceTool, point: Vector3, uv: Vector2) -> void:
	surface.set_uv(uv)
	surface.add_vertex(point)


func _build_edge_ribbons() -> void:
	var snow_material := _make_material(Color("#EAF8F4"), 0.74)
	snow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	for side: float in [-1.0, 1.0]:
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface.set_material(snow_material)
		var at := 0.0
		while at < TRACK_LENGTH:
			var next_at := minf(TRACK_LENGTH, at + TRACK_STEP)
			var frame_a := _course_frame(at)
			var frame_b := _course_frame(next_at)
			var inner_a := frame_a.origin + frame_a.basis.x * side * 4.54 + frame_a.basis.y * 1.30
			var outer_a := frame_a.origin + frame_a.basis.x * side * 4.88 + frame_a.basis.y * 1.43
			var inner_b := frame_b.origin + frame_b.basis.x * side * 4.54 + frame_b.basis.y * 1.30
			var outer_b := frame_b.origin + frame_b.basis.x * side * 4.88 + frame_b.basis.y * 1.43
			surface.add_vertex(inner_a)
			surface.add_vertex(inner_b)
			surface.add_vertex(outer_b)
			surface.add_vertex(inner_a)
			surface.add_vertex(outer_b)
			surface.add_vertex(outer_a)
			at = next_at
		surface.generate_normals()
		var ribbon := MeshInstance3D.new()
		ribbon.name = "SnowbankLeft" if side < 0.0 else "SnowbankRight"
		ribbon.mesh = surface.commit()
		ribbon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		add_child(ribbon)


func _shoulder_point(at: float, side: float, lateral: float, height: float) -> Vector3:
	var frame := _course_frame(at)
	var horizontal_right := Vector3(frame.basis.x.x, 0.0, frame.basis.x.z).normalized()
	var banked := frame.origin + frame.basis.x * side * lateral + frame.basis.y * height
	var level := frame.origin + horizontal_right * side * lateral + Vector3.UP * height
	var level_blend := smoothstep(5.2, 15.0, lateral)
	return banked.lerp(level, level_blend)


func _terrain_height(at: float, lateral_index: int, side: float) -> float:
	var near_wave := pow(0.5 + 0.5 * sin(at * 0.054 + side * 1.12), 2.35)
	var far_wave := pow(0.5 + 0.5 * sin(at * 0.036 + side * 1.12 + 2.0), 2.15)
	var base_heights: Array[float] = [2.62, 2.44, 1.92, 0.92, 0.58, 0.35, 0.08, -1.20]
	var height := base_heights[lateral_index]
	match lateral_index:
		4: height += near_wave * 3.2
		5: height += near_wave * 6.8 + far_wave * 1.0
		6: height += near_wave * 2.0 + far_wave * 8.0
	return height


func _build_connected_mountain_terrain() -> void:
	var terrain_material := _make_material(Color("#91A7A8"), 0.88)
	terrain_material.vertex_color_use_as_albedo = true
	terrain_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var lateral: Array[float] = [5.15, 7.2, 10.5, 16.0, 23.0, 32.0, 44.0, 60.0]
	var colors: Array[Color] = [
		Color("#B9D9D7"), Color("#A3C8C9"), Color("#7FAAB0"), Color("#527C89"),
		Color("#356779"), Color("#27576C"), Color("#193E55"), Color("#102C41")
	]
	var terrain_step := 9.0
	var row_count := int(ceil(TRACK_LENGTH / terrain_step)) + 1
	var column_count := lateral.size()
	for side: float in [-1.0, 1.0]:
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface.set_material(terrain_material)
		for row in range(row_count):
			var at := minf(TRACK_LENGTH, float(row) * terrain_step)
			for cross in range(column_count):
				var height := _terrain_height(at, cross, side)
				surface.set_uv(Vector2(float(cross) / float(column_count - 1), at / 36.0))
				surface.set_color(colors[cross])
				surface.add_vertex(_shoulder_point(at, side, lateral[cross], height))
		for row in range(row_count - 1):
			for cross in range(column_count - 1):
				var a0 := row * column_count + cross
				var a1 := a0 + 1
				var b0 := (row + 1) * column_count + cross
				var b1 := b0 + 1
				if side > 0.0:
					surface.add_index(a0)
					surface.add_index(b1)
					surface.add_index(b0)
					surface.add_index(a0)
					surface.add_index(a1)
					surface.add_index(b1)
				else:
					surface.add_index(a0)
					surface.add_index(b0)
					surface.add_index(b1)
					surface.add_index(a0)
					surface.add_index(b1)
					surface.add_index(a1)
		surface.generate_normals()
		var terrain := MeshInstance3D.new()
		terrain.name = "ConnectedMountainTerrainLeft" if side < 0.0 else "ConnectedMountainTerrainRight"
		terrain.mesh = surface.commit()
		terrain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		add_child(terrain)


func _build_penguin() -> Node3D:
	var root := Node3D.new()
	root.name = "HeadFirstPenguin"
	player_visual = Node3D.new()
	player_visual.name = "Model"
	root.add_child(player_visual)

	var model := PENGUIN_SCENE.instantiate() as Node3D
	model.name = "MeshyPenguin"
	model.rotation_degrees = PENGUIN_MODEL_ROTATION
	model.scale = Vector3.ONE * PENGUIN_MODEL_SCALE
	model.position = PENGUIN_MODEL_OFFSET
	player_visual.add_child(model)
	_tune_penguin_materials(model)
	penguin_anim = _find_animation_player(model)
	if penguin_anim:
		penguin_anim.active = true
		_play_penguin_clip("Walking", 0.85)
	return root


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found:
			return found
	return null


func _penguin_clip_name(want: String) -> String:
	if penguin_anim == null:
		return ""
	if penguin_anim.has_animation(want):
		return want
	for clip in penguin_anim.get_animation_list():
		if clip.ends_with("/" + want) or clip.ends_with("|" + want) or clip == want:
			return clip
	for clip in penguin_anim.get_animation_list():
		if want.to_lower() in clip.to_lower():
			return clip
	return ""


func _play_penguin_clip(want: String, speed_scale: float) -> void:
	if penguin_anim == null:
		return
	var clip := _penguin_clip_name(want)
	if clip.is_empty():
		return
	if penguin_anim.current_animation != clip:
		penguin_anim.play(clip)
	penguin_anim.speed_scale = speed_scale


func _tune_penguin_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.material_override is BaseMaterial3D:
			mesh_instance.material_override = _dim_meshy_material(mesh_instance.material_override)
		var surface_count := 0
		if mesh_instance.mesh:
			surface_count = mesh_instance.mesh.get_surface_count()
		for surface in range(surface_count):
			var material := mesh_instance.get_active_material(surface)
			if material == null and mesh_instance.mesh:
				material = mesh_instance.mesh.surface_get_material(surface)
			if material:
				mesh_instance.set_surface_override_material(surface, _dim_meshy_material(material))
	for child in node.get_children():
		_tune_penguin_materials(child)


func _dim_meshy_material(material: Material) -> Material:
	var tuned := material.duplicate()
	if tuned is BaseMaterial3D:
		var base := tuned as BaseMaterial3D
		base.emission_enabled = false
		base.emission_energy_multiplier = 0.0
		base.emission = Color.BLACK
		base.metallic = minf(base.metallic, 0.04)
		base.roughness = maxf(base.roughness, 0.55)
		base.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		base.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return tuned


func _sphere_mesh() -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 20
	mesh.rings = 12
	return mesh


func _add_sphere(parent: Node3D, part_name: String, position: Vector3, scale_value: Vector3, material: Material) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = _sphere_mesh()
	part.material_override = material
	part.position = position
	part.scale = scale_value
	parent.add_child(part)
	return part


func _add_box(parent: Node3D, part_name: String, position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.material_override = material
	part.position = position
	parent.add_child(part)
	return part


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "FollowCamera"
	camera.fov = 58.0
	camera.near = 0.08
	camera.far = 420.0
	add_child(camera)
	camera.current = true
	_update_camera(1.0, true)


func _place_player(immediate: bool) -> void:
	var frame := _course_frame(distance)
	frame.origin += frame.basis.y * (PLAYER_CLEARANCE + jump_height)
	if immediate:
		player.global_transform = frame
	else:
		player.global_transform = player.global_transform.interpolate_with(frame, 0.28)


func _update_camera(delta: float, immediate: bool) -> void:
	var frame := _course_frame(distance)
	var forward := -frame.basis.z
	var desired_position := frame.origin - forward * 5.6 + frame.basis.y * 2.8
	var target := _course_point(minf(TRACK_LENGTH, distance + 9.0)) + frame.basis.y * 0.42
	if immediate:
		camera.global_position = desired_position
	else:
		camera.global_position = camera.global_position.lerp(desired_position, 1.0 - exp(-delta * 5.4))
	camera.look_at(target, frame.basis.y)


func _update_run(delta: float) -> void:
	run_time += delta
	speed = minf(28.0, 12.0 + distance * 0.012)
	distance += speed * delta
	if distance > TRACK_LENGTH - 90.0:
		_end_run()
		return

	if jump_height > 0.0 or jump_velocity > 0.0:
		jump_height += jump_velocity * delta
		jump_velocity -= 14.5 * delta
		if jump_height <= 0.0:
			jump_height = 0.0
			jump_velocity = 0.0

	while next_obstacle_at < distance + 105.0:
		_spawn_obstacle(next_obstacle_at)
		next_obstacle_at += rng.randf_range(25.0, 34.0)

	_update_obstacles()
	_place_player(true)
	_update_camera(delta, false)


func _spawn_obstacle(at: float) -> void:
	var roll := rng.randf()
	var kind := "ice"
	if at > 110.0 and roll < 0.36:
		kind = "sea_lion"
	elif at > 220.0 and roll > 0.78:
		kind = "gate"
	elif at > 430.0 and roll > 0.64:
		kind = "gap"
	var node := _create_obstacle_model(kind)
	obstacle_root.add_child(node)
	_place_track_node(node, at, 0.03)
	obstacles.append({"node": node, "at": at, "kind": kind, "checked": false})

	if rng.randf() < 0.52:
		var fish_at := at + rng.randf_range(11.0, 17.0)
		var fish := _create_obstacle_model("fish")
		obstacle_root.add_child(fish)
		_place_track_node(fish, fish_at, 1.15)
		obstacles.append({"node": fish, "at": fish_at, "kind": "fish", "checked": false})


func _create_obstacle_model(kind: String) -> Node3D:
	var root := Node3D.new()
	root.name = kind.capitalize()
	match kind:
		"ice":
			_add_crystal(root, "CrystalCenter", Vector3(0, 0.83, 0), Vector3(0.72, 1.65, 0.72), mat_cyan, Vector3(0, 22, 7))
			_add_crystal(root, "CrystalLeft", Vector3(-0.72, 0.53, 0.08), Vector3(0.54, 1.02, 0.54), mat_cream, Vector3(-8, -25, -13))
			_add_crystal(root, "CrystalRight", Vector3(0.72, 0.49, -0.05), Vector3(0.50, 0.94, 0.50), mat_glacier, Vector3(10, 32, 15))
			_add_sphere(root, "CrystalGleam", Vector3(0.17, 1.50, -0.26), Vector3(0.10, 0.10, 0.10), mat_cream)
		"sea_lion":
			_add_sphere(root, "Body", Vector3(0, 0.47, 0), Vector3(0.82, 0.44, 1.02), mat_glacier)
			_add_sphere(root, "Belly", Vector3(0, 0.63, 0.18), Vector3(0.58, 0.18, 0.68), mat_cream)
			_add_sphere(root, "Head", Vector3(0, 0.72, 0.68), Vector3(0.58, 0.56, 0.60), mat_glacier)
			_add_sphere(root, "Muzzle", Vector3(0, 0.72, 1.08), Vector3(0.36, 0.24, 0.20), mat_cream)
			_add_sphere(root, "EyeLeft", Vector3(-0.20, 0.94, 1.10), Vector3(0.10, 0.13, 0.07), mat_navy)
			_add_sphere(root, "EyeRight", Vector3(0.20, 0.94, 1.10), Vector3(0.10, 0.13, 0.07), mat_navy)
			_add_sphere(root, "Nose", Vector3(0, 0.76, 1.30), Vector3(0.15, 0.10, 0.10), mat_orange)
			var fin_l := _add_sphere(root, "FinLeft", Vector3(-0.60, 0.39, 0.18), Vector3(0.46, 0.11, 0.24), mat_glacier)
			var fin_r := _add_sphere(root, "FinRight", Vector3(0.60, 0.39, 0.18), Vector3(0.46, 0.11, 0.24), mat_glacier)
			fin_l.rotation_degrees.z = -18
			fin_r.rotation_degrees.z = 18
		"gate":
			_add_box(root, "LeftPost", Vector3(-2.55, 1.1, 0), Vector3(0.34, 2.2, 0.34), mat_cyan)
			_add_box(root, "RightPost", Vector3(2.55, 1.1, 0), Vector3(0.34, 2.2, 0.34), mat_cyan)
			_add_box(root, "Bar", Vector3(0, 2.08, 0), Vector3(5.4, 0.48, 0.42), mat_orange)
			for stripe in range(5):
				_add_box(root, "Stripe%d" % stripe, Vector3(-2.0 + stripe, 2.10, 0.24), Vector3(0.40, 0.50, 0.05), mat_gold if stripe % 2 == 0 else mat_cream)
		"gap":
			_add_box(root, "DarkGap", Vector3(0, 0.015, 0), Vector3(7.0, 0.05, 2.2), mat_dark_ice)
			_add_box(root, "SnowLip", Vector3(0, 0.08, -1.0), Vector3(7.2, 0.10, 0.18), mat_cream)
		"fish":
			_add_sphere(root, "FishBody", Vector3.ZERO, Vector3(0.46, 0.30, 0.66), mat_gold)
			_add_sphere(root, "FishEyeLeft", Vector3(-0.22, 0.18, -0.43), Vector3(0.08, 0.09, 0.06), mat_navy)
			_add_sphere(root, "FishEyeRight", Vector3(0.22, 0.18, -0.43), Vector3(0.08, 0.09, 0.06), mat_navy)
			var tail_l := _add_box(root, "TailLeft", Vector3(-0.18, 0, 0.50), Vector3(0.40, 0.12, 0.46), mat_gold)
			var tail_r := _add_box(root, "TailRight", Vector3(0.18, 0, 0.50), Vector3(0.40, 0.12, 0.46), mat_gold)
			tail_l.rotation_degrees.y = -28
			tail_r.rotation_degrees.y = 28
	return root


func _add_crystal(parent: Node3D, part_name: String, position: Vector3, scale_value: Vector3, material: Material, angles: Vector3) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.04
	mesh.bottom_radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 5
	mesh.rings = 1
	var crystal := MeshInstance3D.new()
	crystal.name = part_name
	crystal.mesh = mesh
	crystal.material_override = material
	crystal.position = position
	crystal.scale = scale_value
	crystal.rotation_degrees = angles
	parent.add_child(crystal)
	return crystal


func _place_track_node(node: Node3D, at: float, lift: float) -> void:
	var frame := _course_frame(at)
	frame.origin += frame.basis.y * lift
	node.global_transform = frame


func _update_obstacles() -> void:
	var survivors: Array[Dictionary] = []
	var crashed := false
	for obstacle in obstacles:
		var node = obstacle.get("node")
		if not is_instance_valid(node):
			continue
		var relative := float(obstacle.at) - distance
		if str(obstacle.kind) == "fish":
			node.rotation.y = world_time * 2.6
			node.position.y += sin(world_time * 5.0 + float(obstacle.at)) * 0.002
		elif str(obstacle.kind) == "sea_lion" and relative < 18.0:
			node.scale.y = 1.0 + sin(world_time * 8.0) * 0.06

		if not bool(obstacle.checked) and relative <= 1.2:
			obstacle.checked = true
			var kind := str(obstacle.kind)
			if kind == "fish":
				fish_count += 1
				node.queue_free()
				continue
			var required_height := 0.72
			match kind:
				"sea_lion": required_height = 0.78
				"gate": required_height = 1.00
				"gap": required_height = 0.48
			if jump_height < required_height:
				crashed = true

		if relative < -14.0:
			node.queue_free()
			continue
		survivors.append(obstacle)
	obstacles = survivors
	if crashed:
		_end_run()


func _update_character_animation() -> void:
	if not is_instance_valid(player_visual):
		return
	var hopping := jump_height > 0.04
	match state:
		GameState.RUNNING:
			_play_penguin_clip("Running", (1.15 + speed / 22.0) if not hopping else 1.7)
		GameState.GAME_OVER:
			_play_penguin_clip("Walking", 0.35)
		_:
			_play_penguin_clip("Walking", 0.85)
	player_visual.rotation.z = sin(world_time * 4.6) * 0.04
	player_visual.rotation.x = (-0.18 if hopping else 0.0) + sin(world_time * 6.1) * 0.02


func _start_run() -> void:
	state = GameState.RUNNING
	distance = 0.0
	speed = 12.0
	fish_count = 0
	jump_height = 0.0
	jump_velocity = 0.0
	run_time = 0.0
	game_over_age = 0.0
	new_best = false
	next_obstacle_at = 55.0
	for obstacle in obstacles:
		var node = obstacle.get("node")
		if is_instance_valid(node):
			node.queue_free()
	obstacles.clear()
	while next_obstacle_at < 112.0:
		_spawn_obstacle(next_obstacle_at)
		next_obstacle_at += rng.randf_range(25.0, 34.0)
	_place_player(true)
	_update_camera(1.0, true)


func _hop() -> void:
	if jump_height <= 0.01:
		jump_velocity = 6.8
		jump_height = 0.02


func _end_run() -> void:
	if state != GameState.RUNNING:
		return
	state = GameState.GAME_OVER
	game_over_age = 0.0
	new_best = int(distance) > best_distance
	if new_best:
		best_distance = int(distance)
	_save_game()


func _unhandled_input(event: InputEvent) -> void:
	var pressed := false
	if event is InputEventScreenTouch:
		pressed = event.pressed
	elif event is InputEventMouseButton:
		pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventKey:
		pressed = event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_UP]
	if not pressed:
		return
	match state:
		GameState.MENU:
			_start_run()
		GameState.RUNNING:
			_hop()
		GameState.GAME_OVER:
			if game_over_age > 0.45:
				_start_run()
	get_viewport().set_input_as_handled()


func _update_ui() -> void:
	ui.call("set_game_view", state, distance, best_distance, fish_count, new_best, game_over_age)


func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		best_distance = int(parsed.get("best", 0))


func _save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"best": best_distance}))
