extends Node

const SAVE_PATH := "user://ostrich_dash_save.cfg"
const SKINS := ["Classic", "Midnight", "Golden", "Bubblegum"]
const SKIN_COSTS := [0, 60, 150, 240]
const POWERS := ["Shield", "Magnet", "Slow-Mo", "Score Rush"]

var total_feathers := 0
var best_distance := 0.0
var selected_skin := 0
var selected_power := 0
var owned_skins: Array[int] = [0]
var biome_bests: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var daily_date := ""
var daily_complete := false
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
	selected_power = clampi(int(cfg.get_value("loadout", "power", 0)), 0, POWERS.size() - 1)
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
	cfg.set_value("loadout", "power", selected_power)
	cfg.set_value("daily", "date", daily_date)
	cfg.set_value("daily", "complete", daily_complete)
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

func set_power(index: int) -> void:
	selected_power = posmod(index, POWERS.size())
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
