extends Node

const SAVE_PATH := "user://ostrich_dash_save.cfg"
const SKINS := [
	"Classic", "Midnight", "Golden", "Bubblegum", "Aurora", "Emerald",
	"Sunset", "Frost", "Celestial", "Rose Gold", "Electric Lime", "Royal Peacock",
]
# Classic stays free so a new player can run. Every additional runner is a
# major long-term unlock; the full wardrobe costs 15,050,000 feathers.
const SKIN_COSTS := [0, 25000, 75000, 150000, 300000, 500000, 750000, 1000000, 1500000, 2250000, 3500000, 5000000]
const ABILITY_SHIELD := 0
const ABILITY_MAGNET := 1
const ABILITY_SLOW_MO := 2
const ABILITY_RESCUE := 3
const ABILITY_DOUBLE_JUMP := 4
const ABILITY_FEATHER_FRENZY := 5
const ABILITY_GLIDE := 6
const ABILITY_MIRACLE := 7
# Gifts belong to runners, not a separate loadout. Later, more expensive
# runners start closer to a charge, recharge faster, and stay active longer.
# icon_cell points into reward_power_atlas.png; aura_color keeps gifts readable
# even when two abilities share the same cute buddy art.
const RUNNER_ABILITIES := [
	{"name": "Feather Guard", "kind": ABILITY_SHIELD, "duration": 4.0, "start_charge": 0.0, "charge_rate": 1.00, "icon_cell": 1, "aura_color": "#4de9ff", "description": "Blocks one crash"},
	{"name": "Moon Magnet", "kind": ABILITY_MAGNET, "duration": 4.5, "start_charge": 4.0, "charge_rate": 1.04, "icon_cell": 2, "aura_color": "#ff69b4", "description": "Pulls nearby feathers to you"},
	{"name": "Golden Flock", "kind": ABILITY_FEATHER_FRENZY, "duration": 5.0, "start_charge": 7.0, "charge_rate": 1.08, "icon_cell": 5, "aura_color": "#ffc84d", "pickup_multiplier": 2, "description": "Every feather collected counts twice"},
	{"name": "Bubble Double", "kind": ABILITY_DOUBLE_JUMP, "duration": 5.4, "start_charge": 10.0, "charge_rate": 1.12, "icon_cell": 4, "aura_color": "#ff76cf", "description": "Jump again in the air for a double jump"},
	{"name": "Aurora Glide", "kind": ABILITY_GLIDE, "duration": 5.8, "start_charge": 13.0, "charge_rate": 1.16, "icon_cell": 0, "aura_color": "#79f5d2", "description": "Float farther with slow, gentle falls"},
	{"name": "Emerald Pull", "kind": ABILITY_MAGNET, "duration": 6.2, "start_charge": 16.0, "charge_rate": 1.20, "icon_cell": 2, "aura_color": "#45e08b", "description": "Pulls feathers from across the track"},
	{"name": "Sunset Time", "kind": ABILITY_SLOW_MO, "duration": 6.6, "start_charge": 19.0, "charge_rate": 1.24, "icon_cell": 3, "aura_color": "#a28cff", "description": "Slows the whole obstacle course"},
	{"name": "Frost Phantom", "kind": ABILITY_RESCUE, "duration": 7.0, "start_charge": 22.0, "charge_rate": 1.28, "icon_cell": 4, "aura_color": "#a8eeff", "description": "Glide safely through every obstacle"},
	{"name": "Celestial Double", "kind": ABILITY_DOUBLE_JUMP, "duration": 7.4, "start_charge": 25.0, "charge_rate": 1.32, "icon_cell": 4, "aura_color": "#889cff", "description": "A long-lasting midair double jump"},
	{"name": "Rose Gold Rush", "kind": ABILITY_FEATHER_FRENZY, "duration": 7.8, "start_charge": 28.0, "charge_rate": 1.36, "icon_cell": 5, "aura_color": "#ff8fab", "pickup_multiplier": 3, "description": "Every feather collected counts triple"},
	{"name": "Lime Lightning", "kind": ABILITY_SLOW_MO, "duration": 8.2, "start_charge": 31.0, "charge_rate": 1.40, "icon_cell": 3, "aura_color": "#c7ff3d", "description": "Freezes hazards into super slow motion"},
	{"name": "Peacock Miracle", "kind": ABILITY_MIRACLE, "duration": 8.6, "start_charge": 35.0, "charge_rate": 1.45, "icon_cell": 5, "aura_color": "#35e6d0", "pickup_multiplier": 3, "description": "Double jump, feather pull, triple rewards, and safety"},
]

var total_feathers := 0
var best_distance := 0.0
var selected_skin := 0
var owned_skins: Array[int] = [0]
var biome_bests: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var daily_date := ""
var daily_complete := false
var music_enabled := true
var save_enabled := true

func _ready() -> void:
	load_save()

func load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	total_feathers = int(cfg.get_value("progress", "feathers", 0))
	best_distance = float(cfg.get_value("progress", "best_distance", 0.0))
	selected_skin = clampi(int(cfg.get_value("loadout", "skin", 0)), 0, SKINS.size() - 1)
	var saved_owned: Array = cfg.get_value("progress", "owned_skins", [0])
	owned_skins.clear()
	for item in saved_owned:
		owned_skins.append(int(item))
	if 0 not in owned_skins:
		owned_skins.append(0)
	var saved_bests: Array = cfg.get_value("progress", "biome_bests", biome_bests)
	for i in mini(saved_bests.size(), biome_bests.size()):
		biome_bests[i] = float(saved_bests[i])
	daily_date = str(cfg.get_value("daily", "date", ""))
	daily_complete = bool(cfg.get_value("daily", "complete", false))
	music_enabled = bool(cfg.get_value("settings", "music_enabled", true))
	var today := Time.get_date_string_from_system()
	if daily_date != today:
		daily_date = today
		daily_complete = false

func save() -> void:
	if not save_enabled:
		return
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "feathers", total_feathers)
	cfg.set_value("progress", "best_distance", best_distance)
	cfg.set_value("progress", "owned_skins", owned_skins)
	cfg.set_value("progress", "biome_bests", biome_bests)
	cfg.set_value("loadout", "skin", selected_skin)
	cfg.set_value("daily", "date", daily_date)
	cfg.set_value("daily", "complete", daily_complete)
	cfg.set_value("settings", "music_enabled", music_enabled)
	cfg.save(SAVE_PATH)

func finish_run(distance: float, feathers: int, biome: int) -> Dictionary:
	var old_best := best_distance
	total_feathers += feathers
	best_distance = maxf(best_distance, distance)
	if biome >= 0 and biome < biome_bests.size():
		biome_bests[biome] = maxf(biome_bests[biome], distance)
	var daily_bonus := 0
	if not daily_complete and feathers >= 15:
		daily_complete = true
		daily_bonus = 25
		total_feathers += daily_bonus
	save()
	return {"new_best": distance > old_best, "daily_bonus": daily_bonus}

func buy_or_equip_skin(index: int) -> bool:
	if index < 0 or index >= SKINS.size():
		return false
	if index in owned_skins:
		selected_skin = index
		save()
		return true
	var cost: int = SKIN_COSTS[index]
	if total_feathers < cost:
		return false
	total_feathers -= cost
	owned_skins.append(index)
	selected_skin = index
	save()
	return true

func selected_ability() -> Dictionary:
	return RUNNER_ABILITIES[clampi(selected_skin, 0, RUNNER_ABILITIES.size() - 1)]

func selected_ability_kind() -> int:
	return int(selected_ability().kind)

func set_music_enabled(enabled: bool) -> void:
	music_enabled = enabled
	save()

func medal_for_biome(index: int) -> String:
	if index < 0 or index >= biome_bests.size():
		return "—"
	var value := biome_bests[index]
	if value >= 900.0:
		return "GOLD"
	if value >= 600.0:
		return "SILVER"
	if value >= 300.0:
		return "BRONZE"
	return "—"
