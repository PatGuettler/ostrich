# Ostrich Dash — Full Build Plan (Godot 4, 3D)

Handoff doc for implementation. Contains full game design, technical architecture, and starter code references.

---

## PART 1 — GAME DESIGN

### Concept
Endless 3-lane runner starring an ostrich sprinting down an Olympic-style track. Player dodges hurdles, ducks under bars, and switches lanes to survive as long as possible. Core hook: hitting a bar makes the ostrich's neck wrap around it and spin, accompanied by a loud comedic ostrich boom/honk.

### Core Mechanics
- Auto-run forward, increasing speed over distance
- Swipe Up → Jump
- Swipe Down → Duck (shrinks collision shape)
- Swipe Left/Right → Lane switch (3 lanes)
- Hitting an unavoidable obstacle triggers the signature hit-spin fail animation

### Signature Fail Animation ("Bar Spin")
1. Ostrich neck catches the bar
2. 2–3 fast pinwheel rotations around the bar (procedural or hand-keyed)
3. Camera zoom/shake on impact
4. Loud ostrich boom + cartoon "boing" layered SFX
5. Feather puff particle burst
6. Dizzy stumble → ragdoll collapse → results screen

### Environments (Rotating Biomes)
Cycle every N meters or at distance milestones. Each swaps track texture, background parallax, music, and obstacle skins:
1. Classic Stadium (red track, crowd)
2. Beach Track (sand, ocean, seagulls)
3. Night Olympics (floodlights, fireworks)
4. Desert Circuit (dust storms reduce visibility)
5. Snow Games (icy patches, reduced traction)
6. Jungle Track (vine obstacles, drum stings)

### Obstacles
- Hurdles/bars (duck) — triggers hit-spin on fail
- Low walls/cones (jump)
- Puddles/ice patches (temporary slip/control reversal)
- Rival runners (weave around — original animal designs, e.g. flamingo, roadrunner)
- Flying drones/cameras (duck at head height)

### Rewards & Progression
- **Currency:** Feathers, collected mid-run
- **Shop:** skins (outfits, national colors, gold-medal skin), power-ups (Speed Burst, Shield, Feather Magnet, Slow-Mo Reflex)
- **Unlocks:** biomes gated behind feather totals/distance milestones
- **Meta:** daily challenges, bronze/silver/gold medal achievements per biome, leaderboards, combo multiplier for consecutive clean dodges

### Scoring
Distance-based score + combo multiplier for clean clears + feather bonus. Results screen shows distance, feathers, near-misses, personal best.

### Originality Notes
- Original mascot, art style, sound design, and the bar-spin gag are the differentiators — genre mechanics (lane-switch swiping) are common conventions, not protectable IP
- Avoid real Olympic branding/rings — use a generic "International Track Games" reskin
- No reused art, level layouts, or character designs from other runner games

---

## PART 2 — TECHNICAL ARCHITECTURE (Godot 4.x, 3D)

### Project Setup
1. New Godot 4 project, 3D template
2. Autoload singleton: `GameManager` (game_manager.gd)
3. Input Map actions: `swipe_up`, `swipe_down`, `swipe_left`, `swipe_right` (bind to touch swipe gestures for mobile export, arrow keys for editor testing)

### Scene Structure
```
Main (Node3D)
├── Player (CharacterBody3D) — player.gd
│   ├── CollisionShape3D
│   ├── AnimationPlayer  (clips: run, jump, duck, hit_spin, dizzy_stumble)
│   ├── HitSFX (AudioStreamPlayer3D)
│   ├── MeshInstance3D / ostrich rig
│   └── Camera3D (third-person follow, or child of a SpringArm3D)
├── TrackSpawner (Node3D) — obstacle_spawner.gd
│   └── (spawns Segment nodes ahead of player, recycles behind)
├── Obstacles/ (scenes: Hurdle.tscn, Wall.tscn, IcePatch.tscn, Drone.tscn)
│   └── each: Area3D + CollisionShape3D + body_entered signal → calls player.trigger_hit()
├── Feather.tscn (Area3D, collectible, body_entered → player.collect_feather())
├── UI (CanvasLayer)
│   ├── HUD (distance, feather count, power-up charge)
│   ├── PreRunMenu (loadout: skin + power-up select)
│   └── ResultsScreen (distance, feathers, retry/shop/share buttons)
└── EnvironmentManager (Node3D) — swaps biome assets (track material, skybox/parallax, obstacle skins, music track) based on distance thresholds
```

### Core Scripts (already drafted, attach as-is or adapt)

**player.gd** — CharacterBody3D controller
- Handles lane switching (lerp toward target X position), jump (vertical velocity + gravity), duck (temporary smaller CollisionShape3D), forward speed ramp over time
- `trigger_hit(obstacle)` — locks input, plays hit_spin → dizzy_stumble animations, plays HitSFX, emits `hit_obstacle` signal
- `collect_feather(amount)` — emits `collected_feather` signal
- Signals: `hit_obstacle`, `collected_feather`

**obstacle_spawner.gd** — Node3D, attach to TrackSpawner
- Spawns track segments ahead of player, recycles ones passed
- Each segment randomly populates 0–2 obstacles across the 3 lanes (never fully blocking all lanes) plus a feather line in an open lane
- Exposes `obstacle_scenes: Array[PackedScene]` — assign per-biome obstacle skins here

**game_manager.gd** — Autoload singleton
- Tracks `distance_traveled`, `feathers_this_run`, `total_feathers` (persisted via ConfigFile to `user://savegame.cfg`)
- `start_run(player)` connects to player's signals
- On `hit_obstacle`: stops run, saves feathers, emits `game_over(distance, feathers)` for the UI to consume

### Obstacle Scene Pattern (to be built)
Each obstacle (e.g. `Hurdle.tscn`):
- Area3D + CollisionShape3D sized to the bar
- On `body_entered(body)`: if body is Player and Player is NOT currently ducking (or is in wrong lane for a jump obstacle) → call `body.trigger_hit(self)`
- If Player successfully clears it (ducking/jumping in time) → no collision triggers, optionally emit a "clean clear" signal for combo multiplier tracking in GameManager

### Hit-Spin Animation — Two Implementation Options
1. **Hand-keyed:** Author `hit_spin` clip directly in AnimationPlayer on the ostrich rig — rotate neck bone + root around a pivot point at the bar's position over ~0.6s, ease-in/ease-out
2. **Procedural (more dynamic, less art time):** Script a tween that rotates the whole player mesh 720°–1080° around the obstacle's world position as an axis, combined with a squash/stretch on the neck bone if rigged. Procedural is faster to iterate on and recommended for MVP; swap to hand-keyed later for polish

### Biome/Environment Swapping
`EnvironmentManager` listens to `GameManager.distance_traveled` (or a distance-threshold signal) and swaps:
- Track mesh/material (per biome)
- Skybox or background parallax planes
- Obstacle skin overrides (pass biome ID into `obstacle_spawner.gd`'s scene selection)
- Music track (crossfade via AudioStreamPlayer)

### Audio Requirements
- Ostrich boom/honk (hit SFX) — record original or license from an SFX library; do not sample from other games
- Footsteps, crowd ambience, starting gun countdown, per-biome music loop, feather pickup chime, UI button sounds

### Asset Checklist
**Art**
- Ostrich rig with animations: run, jump, duck, hit_spin, dizzy_stumble, idle, celebration
- 6 biome tilesets + parallax/skybox sets
- Obstacle models per biome skin (hurdle, wall, ice patch, drone, vine, log)
- UI icons: feather, power-ups (speed/shield/magnet/slow-mo), medals

**Audio**
- Hit SFX, footsteps, crowd ambience, starting gun, 6 biome music loops, feather chime, UI SFX

### Suggested Build Order (MVP → Polish)
1. Player controller + single obstacle type + basic collision (no animation yet, capsule placeholder)
2. Obstacle spawner with pooling, single biome (Classic Stadium)
3. Hit-spin fail animation (procedural version) + SFX
4. Feather collection + scoring + GameManager save/load
5. Pre-run menu, HUD, results screen
6. Power-up system + shop
7. Add remaining 5 biomes + EnvironmentManager swapping
8. Achievements, leaderboards, daily challenges
9. Full audio pass, particle polish (feather puff, dust, screen shake), skins

### Export Targets
- Mobile: Android/iOS export via Godot's export presets; ensure touch swipe gestures mapped to Input Map actions
- Test on-device early for touch input feel and performance (obstacle pooling matters most here — avoid instancing/freeing every frame)

---

## Reference Scripts
Three starter scripts were drafted alongside this plan and should be provided together:
- `player.gd`
- `obstacle_spawner.gd`
- `game_manager.gd`

These are functional skeletons (Godot 4.x GDScript syntax) covering the systems above — extend/refactor as needed once real art and animations are in place.

---

## PART 3 — SOURCE CODE

### player.gd
```gdscript
extends CharacterBody3D
## Ostrich player controller — 3-lane endless runner
## Attach to a CharacterBody3D with a CollisionShape3D + AnimationPlayer + AudioStreamPlayer3D

signal hit_obstacle
signal collected_feather(amount: int)

@export var lane_distance: float = 2.5      # distance between lanes on X axis
@export var lane_switch_speed: float = 12.0  # how fast the ostrich slides between lanes
@export var jump_force: float = 9.0
@export var gravity: float = 22.0
@export var duck_duration: float = 0.5
@export var base_forward_speed: float = 10.0
@export var max_forward_speed: float = 26.0
@export var speed_ramp_per_sec: float = 0.15  # forward_speed increases over time

var current_lane: int = 0        # -1 = left, 0 = center, 1 = right
var target_x: float = 0.0
var is_ducking: bool = false
var is_jumping: bool = false
var is_stunned: bool = false     # true during hit-spin animation, ignores input
var forward_speed: float = 0.0
var duck_timer: float = 0.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var hit_sfx: AudioStreamPlayer3D = $HitSFX
@onready var standing_shape: Shape3D = collision_shape.shape  # cache default shape

func _ready() -> void:
	forward_speed = base_forward_speed

func _physics_process(delta: float) -> void:
	if not is_stunned:
		forward_speed = min(forward_speed + speed_ramp_per_sec * delta, max_forward_speed)
		_handle_input()
		_handle_duck(delta)

	_apply_gravity(delta)
	_apply_lane_movement(delta)

	velocity.z = -forward_speed  # running forward (adjust sign to your track orientation)
	move_and_slide()

func _handle_input() -> void:
	if Input.is_action_just_pressed("swipe_up") and is_on_floor() and not is_jumping:
		_jump()
	elif Input.is_action_just_pressed("swipe_down") and not is_ducking:
		_duck()
	elif Input.is_action_just_pressed("swipe_left"):
		_change_lane(-1)
	elif Input.is_action_just_pressed("swipe_right"):
		_change_lane(1)

func _jump() -> void:
	is_jumping = true
	velocity.y = jump_force
	anim_player.play("jump")

func _duck() -> void:
	is_ducking = true
	duck_timer = duck_duration
	# Shrink collision shape so the ostrich actually clears bar-height obstacles
	var duck_shape := CapsuleShape3D.new()
	duck_shape.radius = 0.5
	duck_shape.height = 0.6
	collision_shape.shape = duck_shape
	collision_shape.position.y = -0.5
	anim_player.play("duck")

func _handle_duck(delta: float) -> void:
	if is_ducking:
		duck_timer -= delta
		if duck_timer <= 0.0:
			is_ducking = false
			collision_shape.shape = standing_shape
			collision_shape.position.y = 0.0
			anim_player.play("run")

func _change_lane(direction: int) -> void:
	current_lane = clamp(current_lane + direction, -1, 1)
	target_x = current_lane * lane_distance

func _apply_lane_movement(delta: float) -> void:
	position.x = move_toward(position.x, target_x, lane_switch_speed * delta)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif is_jumping:
		is_jumping = false
		anim_player.play("run")

## Called by an obstacle's Area3D on collision when the ostrich fails to clear it
func trigger_hit(obstacle_pivot: Node3D) -> void:
	if is_stunned:
		return
	is_stunned = true
	velocity = Vector3.ZERO
	hit_sfx.play()  # loud ostrich boom/honk SFX assigned in the AudioStreamPlayer3D
	emit_signal("hit_obstacle")

	anim_player.play("hit_spin")  # neck-wrap spin animation, authored in AnimationPlayer
	await anim_player.animation_finished
	anim_player.play("dizzy_stumble")
	await anim_player.animation_finished
	# Game manager should listen to hit_obstacle signal and transition to results screen

func collect_feather(amount: int = 1) -> void:
	emit_signal("collected_feather", amount)
```

### obstacle_spawner.gd
```gdscript
extends Node3D
## Spawns and recycles obstacles/track segments ahead of the player.
## Attach to a Node3D in the main game scene; assign obstacle scenes per biome.

@export var player: CharacterBody3D
@export var segment_length: float = 20.0
@export var segments_ahead: int = 5
@export var lane_x_positions: Array[float] = [-2.5, 0.0, 2.5]

@export var obstacle_scenes: Array[PackedScene] = []  # hurdle, wall, ice_patch, etc.
@export var feather_scene: PackedScene

var spawned_segments: Array[Node3D] = []
var next_spawn_z: float = -segment_length

func _ready() -> void:
	for i in segments_ahead:
		_spawn_segment()

func _process(_delta: float) -> void:
	if player == null:
		return
	# Recycle segments once the player has passed them
	if spawned_segments.size() > 0:
		var oldest: Node3D = spawned_segments[0]
		if oldest.position.z > player.position.z + segment_length:
			oldest.queue_free()
			spawned_segments.pop_front()
			_spawn_segment()

func _spawn_segment() -> void:
	var segment := Node3D.new()
	segment.position.z = next_spawn_z
	add_child(segment)
	spawned_segments.append(segment)
	next_spawn_z -= segment_length

	_populate_segment(segment)

func _populate_segment(segment: Node3D) -> void:
	# Simple pattern: randomly place 0-2 obstacles across lanes, avoid blocking all 3
	var blocked_lanes: Array[int] = []
	var obstacle_count: int = randi_range(0, 2)

	for i in obstacle_count:
		if obstacle_scenes.is_empty():
			break
		var lane_index: int = randi_range(0, 2)
		if lane_index in blocked_lanes:
			continue
		blocked_lanes.append(lane_index)

		var obstacle_scene: PackedScene = obstacle_scenes[randi_range(0, obstacle_scenes.size() - 1)]
		var obstacle := obstacle_scene.instantiate()
		obstacle.position = Vector3(lane_x_positions[lane_index], 0, randf_range(-8.0, -2.0))
		segment.add_child(obstacle)

	# Feathers in an unblocked lane as a small reward
	if feather_scene:
		var open_lanes: Array[int] = [0, 1, 2].filter(func(l): return l not in blocked_lanes)
		if open_lanes.size() > 0:
			var feather_lane: int = open_lanes[randi_range(0, open_lanes.size() - 1)]
			for j in 4:
				var feather := feather_scene.instantiate()
				feather.position = Vector3(lane_x_positions[feather_lane], 1.0, -float(j) * 2.5)
				segment.add_child(feather)
```

### game_manager.gd
```gdscript
extends Node
## Autoload singleton (Project Settings > Autoload). Tracks run state, score, currency.

signal game_over(distance: float, feathers: int)

@export var player_path: NodePath

var distance_traveled: float = 0.0
var feathers_this_run: int = 0
var total_feathers: int = 0   # persisted between runs
var combo_multiplier: float = 1.0
var is_running: bool = false

var _player: CharacterBody3D
var _start_z: float = 0.0

func _ready() -> void:
	total_feathers = _load_feathers()

func start_run(player: CharacterBody3D) -> void:
	_player = player
	_start_z = player.position.z
	distance_traveled = 0.0
	feathers_this_run = 0
	combo_multiplier = 1.0
	is_running = true

	_player.hit_obstacle.connect(_on_hit_obstacle)
	_player.collected_feather.connect(_on_feather_collected)

func _process(_delta: float) -> void:
	if is_running and _player:
		distance_traveled = abs(_player.position.z - _start_z)

func _on_feather_collected(amount: int) -> void:
	feathers_this_run += int(amount * combo_multiplier)

func _on_hit_obstacle() -> void:
	is_running = false
	total_feathers += feathers_this_run
	_save_feathers()
	emit_signal("game_over", distance_traveled, feathers_this_run)

func _save_feathers() -> void:
	var config := ConfigFile.new()
	config.set_value("wallet", "feathers", total_feathers)
	config.save("user://savegame.cfg")

func _load_feathers() -> int:
	var config := ConfigFile.new()
	var err := config.load("user://savegame.cfg")
	if err != OK:
		return 0
	return config.get_value("wallet", "feathers", 0)
```
