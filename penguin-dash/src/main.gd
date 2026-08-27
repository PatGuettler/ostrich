extends Node2D

# Penguin Dash is deliberately asset-light: every visual is drawn as bold,
# screen-printed poster geometry so the game has one coherent visual language.

const VIEW := Vector2(540.0, 960.0)
const SLIDE_ENTRY_Y := 432.0
const GROUND_Y := 748.0
const PLAYER_X := 270.0

const NAVY := Color("#0E1F2E")
const GLACIER := Color("#1B4B6B")
const CYAN := Color("#6FD8E8")
const ORANGE := Color("#F4692A")
const CREAM := Color("#F7F2E7")
const GOLD := Color("#E8B23D")
const CYAN_SHADOW := Color("#3A91A8")

const SAVE_PATH := "user://penguin_dash_save.json"
const POSTER_FONT: Font = preload("res://assets/UbuntuSansCondensed.ttf")
const BACKGROUND_ART: Texture2D = preload("res://assets/art/alpine_background.png")
const PENGUIN_ART: Texture2D = preload("res://assets/art/penguin_headfirst.png")
const SEA_LION_ART: Texture2D = preload("res://assets/art/sea_lion_lunge.png")
const FISH_ART: Texture2D = preload("res://assets/art/golden_fish.png")
const ICE_BLOCK_ART: Texture2D = preload("res://assets/art/ice_block.png")
const GATE_ART: Texture2D = preload("res://assets/art/race_gate.png")
const TITLE_CREST_ART: Texture2D = preload("res://assets/art/title_crest.png")

enum GameState { MENU, RUNNING, GAME_OVER }

var state := GameState.MENU
var run_time := 0.0
var world_time := 0.0
var distance := 0.0
var best_distance := 0
var fish_count := 0
var speed := 38.0
var next_spawn_at := 48.0
var jump_height := 0.0
var jump_velocity := 0.0
var bank := 0.0
var bank_target := 0.0
var bank_phase := 0.0
var was_airborne := false
var game_over_age := 0.0
var crash_flash := 0.0
var shake := 0.0
var new_best := false
var tutorial_seen := false
var tutorial_age := 0.0

var obstacles: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var snow: Array[Dictionary] = []
var grain: Array[Vector2] = []
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_load_save()
	_build_ambient_layers()
	queue_redraw()


func _build_ambient_layers() -> void:
	var seeded := RandomNumberGenerator.new()
	seeded.seed = 73421
	for i in range(60):
		snow.append({
			"p": Vector2(seeded.randf_range(0.0, VIEW.x), seeded.randf_range(0.0, VIEW.y)),
			"s": seeded.randf_range(8.0, 22.0),
			"r": seeded.randf_range(1.0, 2.8),
			"a": seeded.randf_range(0.12, 0.48),
		})
	for i in range(310):
		grain.append(Vector2(seeded.randf_range(0.0, VIEW.x), seeded.randf_range(0.0, VIEW.y)))


func _load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		best_distance = int(parsed.get("best", 0))
		tutorial_seen = bool(parsed.get("tutorial_seen", false))


func _save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"best": best_distance, "tutorial_seen": tutorial_seen}))


func _process(delta: float) -> void:
	world_time += delta
	_update_snow(delta)
	_update_particles(delta)
	crash_flash = maxf(0.0, crash_flash - delta * 2.8)
	shake = maxf(0.0, shake - delta * 12.0)

	match state:
		GameState.MENU:
			bank_target = sin(world_time * 0.42) * 0.38
			bank = lerpf(bank, bank_target, delta * 1.2)
		GameState.RUNNING:
			_update_run(delta)
		GameState.GAME_OVER:
			game_over_age += delta
			bank = lerpf(bank, 0.0, delta * 1.8)

	queue_redraw()


func _update_run(delta: float) -> void:
	run_time += delta
	tutorial_age += delta
	speed = minf(82.0, 38.0 + distance * 0.032)
	distance += speed * delta

	# Two overlapping waves prevent the bank from feeling mechanically periodic.
	bank_phase += delta * (0.50 + speed * 0.003)
	bank_target = sin(bank_phase) * 0.78 + sin(bank_phase * 0.43 + 1.7) * 0.22
	bank = lerpf(bank, clampf(bank_target, -1.0, 1.0), delta * 2.4)

	if jump_height > 0.0 or jump_velocity > 0.0:
		jump_height += jump_velocity * delta
		jump_velocity -= 1850.0 * delta
		was_airborne = true
		if jump_height <= 0.0:
			jump_height = 0.0
			jump_velocity = 0.0
			if was_airborne:
				was_airborne = false
				_spawn_ice_spray(_player_position() + Vector2(-20, 18))
				_play_tone(115.0, 0.06, 0.14, 0.55)

	while distance >= next_spawn_at:
		_spawn_obstacle()
		var difficulty := clampf(distance / 900.0, 0.0, 1.0)
		next_spawn_at += rng.randf_range(88.0 - difficulty * 8.0, 116.0 - difficulty * 10.0)

	for obstacle in obstacles:
		obstacle.progress = (distance - float(obstacle.spawn_distance)) / float(obstacle.travel_distance)
	obstacles = obstacles.filter(func(o: Dictionary) -> bool: return float(o.progress) < 1.20)

	_check_collisions()


func _spawn_obstacle() -> void:
	var roll := rng.randf()
	var kind := "ice"
	if distance > 120.0 and roll < 0.38:
		kind = "sea_lion"
	elif distance > 310.0 and roll > 0.82:
		kind = "gate"
	elif distance > 520.0 and roll > 0.68:
		kind = "gap"

	obstacles.append({
		"kind": kind,
		"spawn_distance": distance,
		"travel_distance": 105.0,
		"progress": 0.0,
		"checked": false,
		"seed": rng.randf_range(-1.0, 1.0),
	})

	# Fish are deliberately offset in time, so collecting one never masks danger.
	if rng.randf() < 0.48:
		obstacles.append({
			"kind": "fish",
			"spawn_distance": distance + rng.randf_range(35.0, 52.0),
			"travel_distance": 105.0,
			"progress": -0.4,
			"checked": false,
			"seed": rng.randf_range(-1.0, 1.0),
		})


func _check_collisions() -> void:
	for obstacle in obstacles:
		if bool(obstacle.checked):
			continue
		var p := float(obstacle.progress)
		if p < 0.90:
			continue
		obstacle.checked = true
		var kind := str(obstacle.kind)
		if kind == "fish":
			fish_count += 1
			_spawn_gold_burst(_obstacle_position(obstacle))
			_play_tone(620.0, 0.08, 0.12, 1.35)
			obstacle.progress = 2.0
			continue

		var required_height := 38.0
		match kind:
			"ice": required_height = 45.0
			"sea_lion": required_height = 50.0
			"gate": required_height = 58.0
			"gap": required_height = 27.0
		if jump_height < required_height:
			_end_run(kind)
			return


func _start_run() -> void:
	state = GameState.RUNNING
	run_time = 0.0
	distance = 0.0
	fish_count = 0
	speed = 38.0
	next_spawn_at = 48.0
	jump_height = 0.0
	jump_velocity = 0.0
	bank_phase = -0.6
	bank = 0.0
	obstacles.clear()
	particles.clear()
	new_best = false
	tutorial_age = 0.0
	game_over_age = 0.0
	_play_tone(330.0, 0.09, 0.11, 1.50)


func _end_run(_cause: String) -> void:
	state = GameState.GAME_OVER
	game_over_age = 0.0
	crash_flash = 0.75
	shake = 8.0
	var final_score := int(distance)
	new_best = final_score > best_distance
	if new_best:
		best_distance = final_score
		_spawn_confetti()
	_play_tone(150.0, 0.18, 0.18, 0.65)
	_save_game()


func _hop() -> void:
	if jump_height <= 0.01:
		jump_velocity = 660.0
		jump_height = 0.1
		shake = maxf(shake, 1.8)
		for i in range(5):
			particles.append({
				"p": _player_position() + Vector2(rng.randf_range(-28.0, 18.0), 17.0),
				"v": Vector2(rng.randf_range(-80.0, -25.0), rng.randf_range(-70.0, -20.0)),
				"life": rng.randf_range(0.25, 0.45), "max": 0.45, "c": CREAM, "size": rng.randf_range(2.0, 5.0)
			})
		_play_tone(240.0, 0.07, 0.12, 1.38)


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
			if not tutorial_seen:
				tutorial_seen = true
				_save_game()
		GameState.GAME_OVER:
			if game_over_age > 0.45:
				_start_run()
	get_viewport().set_input_as_handled()


func _update_snow(delta: float) -> void:
	for flake in snow:
		flake.p += Vector2(float(flake.s) * 0.34, float(flake.s)) * delta
		if flake.p.y > VIEW.y + 5.0:
			flake.p = Vector2(rng.randf_range(-80.0, VIEW.x), -8.0)
		if flake.p.x > VIEW.x + 8.0:
			flake.p.x = -8.0


func _update_particles(delta: float) -> void:
	for particle in particles:
		particle.p += particle.v * delta
		particle.v.y += 250.0 * delta
		particle.life = float(particle.life) - delta
	particles = particles.filter(func(p: Dictionary) -> bool: return float(p.life) > 0.0)


func _spawn_ice_spray(at: Vector2) -> void:
	shake = maxf(shake, 2.5)
	for i in range(13):
		particles.append({
			"p": at + Vector2(rng.randf_range(-12.0, 30.0), 0.0),
			"v": Vector2(rng.randf_range(-120.0, 100.0), rng.randf_range(-145.0, -35.0)),
			"life": rng.randf_range(0.25, 0.58), "max": 0.58, "c": CYAN, "size": rng.randf_range(2.0, 6.0)
		})


func _spawn_gold_burst(at: Vector2) -> void:
	for i in range(16):
		var a := TAU * float(i) / 16.0
		particles.append({
			"p": at, "v": Vector2(cos(a), sin(a)) * rng.randf_range(55.0, 145.0),
			"life": 0.65, "max": 0.65, "c": GOLD, "size": rng.randf_range(3.5, 7.0),
			"shape": "heart" if i % 3 == 0 else "square"
		})


func _spawn_confetti() -> void:
	for i in range(55):
		particles.append({
			"p": Vector2(rng.randf_range(60.0, 480.0), rng.randf_range(270.0, 430.0)),
			"v": Vector2(rng.randf_range(-80.0, 80.0), rng.randf_range(-240.0, -80.0)),
			"life": rng.randf_range(1.2, 2.3), "max": 2.3,
			"c": [GOLD, ORANGE, CYAN, CREAM][i % 4], "size": rng.randf_range(3.0, 7.0),
			"shape": "heart" if i % 5 == 0 else "square"
		})


func _play_tone(frequency: float, duration: float, volume: float, end_ratio: float) -> void:
	# Tiny procedural cues keep the project self-contained and make actions tactile.
	var sample_rate := 22050
	var frame_count := int(duration * sample_rate)
	var bytes := PackedByteArray()
	bytes.resize(frame_count * 2)
	var phase := 0.0
	for i in range(frame_count):
		var t := float(i) / float(frame_count)
		var freq := frequency * lerpf(1.0, end_ratio, t)
		phase += TAU * freq / sample_rate
		var envelope := sin(PI * t) * (1.0 - t * 0.35)
		var sample := int(sin(phase) * envelope * volume * 32767.0)
		bytes.encode_s16(i * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.finished.connect(player.queue_free)
	player.play()


func _draw() -> void:
	var shake_offset := Vector2.ZERO
	if shake > 0.0:
		shake_offset = Vector2(sin(world_time * 77.0), cos(world_time * 91.0)) * shake
	draw_set_transform(shake_offset)
	_draw_sky()
	_draw_mountains()

	if state == GameState.MENU:
		_draw_menu()
	else:
		_draw_obstacles()
		if state != GameState.GAME_OVER:
			_draw_player(_player_position(), jump_height)
		_draw_hud()
		if state == GameState.GAME_OVER:
			_draw_game_over()
		elif not tutorial_seen and tutorial_age < 5.5:
			_draw_tutorial()

	_draw_particles()
	_draw_snow()
	_draw_grain()
	if crash_flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, VIEW), Color(0.956, 0.412, 0.165, crash_flash * 0.22))
	draw_set_transform(Vector2.ZERO)


func _draw_sky() -> void:
	# The painting is the mountain run itself. Camera drift supplies the bank;
	# there is deliberately no synthetic track rendered over it.
	var ambient_drift := sin(world_time * 0.12) * 2.0
	var bank_drift := bank * -10.0 if state != GameState.GAME_OVER else 0.0
	var downhill_breathe := sin(distance * 0.012) * 2.0 if state == GameState.RUNNING else 0.0
	draw_texture_rect(BACKGROUND_ART, Rect2(Vector2(-8.0 + ambient_drift + bank_drift, -12.0 + downhill_breathe), VIEW + Vector2(16.0, 24.0)), false)
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(NAVY, 0.05 if state == GameState.MENU else 0.10))


func _draw_mountains() -> void:
	# Mountains are now part of the hand-painted environment art.
	pass


func _track_center(y: float) -> float:
	# Perspective begins where the painted valley opens into the snow run,
	# not at the skyline behind the mountains.
	var depth := clampf((y - SLIDE_ENTRY_Y) / (GROUND_Y + 160.0 - SLIDE_ENTRY_Y), 0.0, 1.0)
	var curve := bank * 118.0 * pow(depth, 1.42)
	var secondary := sin(world_time * 0.7 + depth * 3.0) * 7.0 * depth
	return VIEW.x * 0.5 + curve + secondary


func _obstacle_position(obstacle: Dictionary) -> Vector2:
	var p := clampf(float(obstacle.progress), 0.0, 1.0)
	var y := lerpf(SLIDE_ENTRY_Y, GROUND_Y + 72.0, pow(p, 1.42))
	return Vector2(_track_center(y), y)


func _draw_obstacles() -> void:
	var ordered := obstacles.duplicate()
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.progress) < float(b.progress))
	for obstacle in ordered:
		var p := float(obstacle.progress)
		if p < 0.0 or p > 1.08:
			continue
		var pos := _obstacle_position(obstacle)
		var scale_amount := lerpf(0.12, 1.18, pow(clampf(p, 0.0, 1.0), 1.25))
		match str(obstacle.kind):
			"ice": _draw_ice_block(pos, scale_amount)
			"sea_lion": _draw_sea_lion(pos, scale_amount, p)
			"gate": _draw_gate(pos, scale_amount)
			"gap": _draw_gap(pos, scale_amount)
			"fish": _draw_fish(pos + Vector2(0, sin(world_time * 6.0 + float(obstacle.seed)) * 8.0 * scale_amount), scale_amount)


func _draw_ice_block(pos: Vector2, s: float) -> void:
	draw_set_transform(pos, sin(world_time * 2.2) * 0.012, Vector2.ONE * s)
	draw_texture_rect(ICE_BLOCK_ART, Rect2(Vector2(-60,-40), Vector2(120,80)), false)
	draw_set_transform(Vector2.ZERO)


func _draw_sea_lion(pos: Vector2, s: float, progress: float) -> void:
	var tell := clampf((progress - 0.46) / 0.24, 0.0, 1.0)
	var lunge_x := lerpf(66.0, 0.0, tell)
	var rear := sin(tell * PI) * 18.0
	draw_set_transform(pos + Vector2(lunge_x * s, -rear * s), -0.16 * (1.0 - tell), Vector2.ONE * s)
	draw_texture_rect(SEA_LION_ART, Rect2(Vector2(-66,-44), Vector2(132,88)), false)
	if progress > 0.40 and progress < 0.68:
		draw_arc(Vector2(-63,-14), 18.0, -1.1, 1.1, 10, ORANGE, 3.0)
	draw_set_transform(Vector2.ZERO)


func _draw_gate(pos: Vector2, s: float) -> void:
	draw_set_transform(pos, 0.0, Vector2.ONE * s)
	draw_texture_rect(GATE_ART, Rect2(Vector2(-76,-51), Vector2(152,101)), false)
	draw_set_transform(Vector2.ZERO)


func _draw_gap(pos: Vector2, s: float) -> void:
	draw_set_transform(pos + Vector2(0, 8*s), 0.0, Vector2.ONE * s)
	var opening := PackedVector2Array([Vector2(-72,-18), Vector2(72,-18), Vector2(88,24), Vector2(-88,24)])
	draw_colored_polygon(opening, NAVY)
	draw_polyline(PackedVector2Array([Vector2(-72,-18),Vector2(72,-18)]), CREAM, 4.0)
	for x in [-48.0, -16.0, 16.0, 48.0]:
		draw_line(Vector2(x,-15), Vector2(x+8,5), CYAN_SHADOW, 3.0)
	draw_set_transform(Vector2.ZERO)


func _draw_fish(pos: Vector2, s: float) -> void:
	draw_set_transform(pos, sin(world_time * 5.0) * 0.10, Vector2.ONE * s)
	draw_texture_rect(FISH_ART, Rect2(Vector2(-39,-26), Vector2(78,52)), false)
	draw_set_transform(Vector2.ZERO)


func _player_position() -> Vector2:
	return Vector2(PLAYER_X + bank * 33.0, GROUND_Y - absf(bank) * 14.0 - jump_height)


func _draw_player(pos: Vector2, height: float = 0.0, menu_scale: float = 1.0) -> void:
	var air_factor := clampf(height / 100.0, 0.0, 1.0)
	var tilt := -bank * 0.12 + sin(world_time * 8.0) * 0.018 * (1.0 - air_factor)
	var squash := 1.0 + sin(world_time * 7.0) * 0.025 * (1.0 - air_factor)

	# A soft grounding mark is the only procedural character element left.
	if height < 6.0:
		# Snow streaks trail behind the feet, making the head-first direction unmistakable.
		for i in range(3):
			var streak_x := (-1.0 + i) * 22.0 * menu_scale
			var streak_wobble := sin(world_time * (7.0 + i) + i) * 4.0
			draw_line(pos + Vector2(streak_x + streak_wobble, 62.0 * menu_scale), pos + Vector2(streak_x - 6.0, 102.0 * menu_scale), Color(CREAM, 0.30), maxf(1.5, 2.4 * menu_scale), true)
		draw_set_transform(pos + Vector2(0, 48 * menu_scale), tilt, Vector2(0.72, 0.32) * menu_scale)
		draw_circle(Vector2.ZERO, 58.0, Color(NAVY, 0.30))
	draw_set_transform(pos, tilt, Vector2(squash, 1.0 / squash))
	var art_size := Vector2(112.0, 168.0) * menu_scale
	draw_texture_rect(PENGUIN_ART, Rect2(-art_size * 0.5, art_size), false)
	draw_set_transform(Vector2.ZERO)


func _draw_limb(origin: Vector2, angle: float, length: float, color: Color, width: float) -> void:
	var endpoint := origin + Vector2(cos(angle), sin(angle)) * length
	draw_line(origin, endpoint, color, width, true)
	draw_circle(endpoint, width * 0.52, color)


func _draw_hud() -> void:
	# One race-pennant ribbon: score and fish, no jump button anywhere.
	var ribbon := PackedVector2Array([Vector2(22,22),Vector2(518,22),Vector2(506,48),Vector2(518,76),Vector2(22,76),Vector2(34,48)])
	draw_colored_polygon(ribbon, NAVY)
	var inner := PackedVector2Array([Vector2(29,28),Vector2(511,28),Vector2(499,48),Vector2(511,70),Vector2(29,70),Vector2(41,48)])
	draw_colored_polygon(inner, CREAM)

	# Odometer tile.
	draw_rect(Rect2(51,34,170,31), GOLD)
	draw_rect(Rect2(56,38,160,23), NAVY)
	_draw_centered_text("%05d M" % int(distance), Rect2(56,37,160,27), CREAM, 23)
	_draw_fish(Vector2(364,50), 0.36)
	_draw_text("%02d" % fish_count, Vector2(390,62), NAVY, 27)
	_draw_text("BEST %05d" % best_distance, Vector2(233,59), GLACIER, 16)


func _draw_tutorial() -> void:
	var alpha := 1.0
	if tutorial_age > 3.8:
		alpha = clampf((5.5 - tutorial_age) / 1.7, 0.0, 1.0)
	var y := 492.0 + sin(world_time * 3.0) * 5.0
	draw_colored_polygon(PackedVector2Array([Vector2(111,y-31),Vector2(429,y-31),Vector2(411,y+31),Vector2(129,y+31)]), Color(NAVY, alpha * 0.86))
	_draw_centered_text("BOOP!  TAP TO HOP", Rect2(116,y-22,308,44), Color(CREAM, alpha), 25)
	draw_line(Vector2(205,y+45), Vector2(335,y+45), Color(GOLD, alpha), 5.0)


func _draw_menu() -> void:
	# A hand-painted carved-ice crest replaces the original geometric badge.
	draw_texture_rect(TITLE_CREST_ART, Rect2(25,72,490,327), false)

	_draw_centered_text("PENGUIN", Rect2(45,145,450,82), CREAM, 70)
	_draw_centered_text("DASH", Rect2(45,210,450,94), GOLD, 92)
	_draw_centered_text("TINY TUMMY  •  BIG DREAMS", Rect2(70,360,400,30), NAVY, 20)

	_draw_player(Vector2(270,535 + sin(world_time * 2.0) * 4.0), 0.0, 1.35)
	_draw_heart(Vector2(150 + sin(world_time*1.7)*7.0, 510), 10.0, Color(ORANGE, 0.82))
	_draw_heart(Vector2(402 + cos(world_time*1.4)*8.0, 555), 7.0, Color(GOLD, 0.88))
	_draw_heart(Vector2(378 + sin(world_time*1.2)*5.0, 475), 5.0, Color(CYAN, 0.90))

	# Carved starting-gate flag shape; the whole screen starts the game.
	var button_shadow := PackedVector2Array([Vector2(145,681),Vector2(405,681),Vector2(379,735),Vector2(270,758),Vector2(161,735),Vector2(135,681)])
	draw_colored_polygon(button_shadow, NAVY)
	var button := PackedVector2Array([Vector2(148,671),Vector2(392,671),Vector2(369,723),Vector2(270,744),Vector2(171,723),Vector2(148,671)])
	draw_colored_polygon(button, ORANGE)
	_draw_centered_text("LET'S SLIDE!", Rect2(155,680,230,45), CREAM, 34)
	_draw_centered_text("TAP ANYWHERE", Rect2(145,775,250,30), NAVY, 18)

	if best_distance > 0:
		_draw_centered_text("PERSONAL BEST  %05d M" % best_distance, Rect2(95,825,350,36), GOLD, 22)
	_draw_centered_text("WIGGLE  •  ZOOM  •  DO YOUR BEST", Rect2(42,886,456,31), GLACIER, 16)


func _draw_game_over() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEW), Color(NAVY, 0.56))
	var panel := PackedVector2Array([Vector2(57,210),Vector2(483,210),Vector2(499,254),Vector2(476,723),Vector2(64,723),Vector2(41,254)])
	draw_colored_polygon(panel, NAVY)
	var inner := PackedVector2Array([Vector2(68,222),Vector2(472,222),Vector2(486,258),Vector2(465,710),Vector2(75,710),Vector2(54,258)])
	draw_colored_polygon(inner, CREAM)
	_draw_centered_text("YOU WERE SO SPEEDY!", Rect2(76,248,388,53), GLACIER, 31)

	var tier_color := ORANGE
	var tier := "BRONZE RUN"
	if int(distance) >= 700:
		tier_color = GOLD; tier = "GOLD RUN"
	elif int(distance) >= 300:
		tier_color = CYAN; tier = "ICE RUN"
	draw_circle(Vector2(270,421), 102.0, NAVY)
	draw_circle(Vector2(270,411), 94.0, tier_color)
	draw_circle(Vector2(270,411), 74.0, CREAM)
	_draw_centered_text("%05d" % int(distance), Rect2(185,371,170,60), NAVY, 49)
	_draw_centered_text("METERS", Rect2(205,430,130,28), GLACIER, 19)
	_draw_centered_text(tier, Rect2(130,523,280,34), tier_color, 23)
	if new_best:
		_draw_centered_text("OH MY GOSH — NEW BEST!", Rect2(90,564,360,38), GOLD, 25)
	else:
		_draw_centered_text("BEST  %05d M" % best_distance, Rect2(135,568,270,34), GLACIER, 22)

	var retry := PackedVector2Array([Vector2(130,624),Vector2(410,624),Vector2(391,678),Vector2(270,698),Vector2(149,678)])
	draw_colored_polygon(retry, NAVY)
	var retry_in := PackedVector2Array([Vector2(139,630),Vector2(401,630),Vector2(383,670),Vector2(270,689),Vector2(157,670)])
	draw_colored_polygon(retry_in, ORANGE)
	_draw_centered_text("AGAIN! AGAIN!", Rect2(150,637,240,40), CREAM, 30)
	# The athlete cannot resist peeking back onto the podium.
	_draw_player(Vector2(270,752), 0.0, 0.72)
	if game_over_age > 0.45:
		_draw_centered_text("TAP ANYWHERE — BACK ON THE ICE", Rect2(75,816,390,30), CREAM, 18)


func _draw_particles() -> void:
	for particle in particles:
		var alpha := clampf(float(particle.life) / float(particle.max), 0.0, 1.0)
		var c: Color = particle.c
		if str(particle.get("shape", "square")) == "heart":
			_draw_heart(particle.p, float(particle.size), Color(c, alpha))
		else:
			draw_rect(Rect2(particle.p - Vector2.ONE * float(particle.size) * 0.5, Vector2.ONE * float(particle.size)), Color(c, alpha))


func _draw_snow() -> void:
	for flake in snow:
		draw_circle(flake.p, float(flake.r), Color(CREAM, float(flake.a)))


func _draw_grain() -> void:
	for i in range(grain.size()):
		var c := NAVY if i % 3 else CREAM
		draw_circle(grain[i], 0.65 if i % 5 else 1.0, Color(c, 0.055))


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(25):
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)


func _draw_heart(center: Vector2, size: float, color: Color) -> void:
	var r := size * 0.36
	draw_circle(center + Vector2(-r, -r * 0.25), r, color)
	draw_circle(center + Vector2(r, -r * 0.25), r, color)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-size * 0.69, -size * 0.12),
		center + Vector2(size * 0.69, -size * 0.12),
		center + Vector2(0, size * 0.82)
	]), color)


func _draw_text(text: String, pos: Vector2, color: Color, size: int) -> void:
	draw_string(POSTER_FONT, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _draw_centered_text(text: String, rect: Rect2, color: Color, size: int) -> void:
	var text_size := POSTER_FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	var pos := Vector2(rect.position.x + (rect.size.x - text_size.x) * 0.5, rect.position.y + (rect.size.y + text_size.y) * 0.5 - 3.0)
	draw_string(POSTER_FONT, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
