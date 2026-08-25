extends Node

signal availability_changed(available: bool)

const LEADERBOARD_ID_SETTING := "ostrich_dash/play_games/longest_dash_leaderboard_id"

var leaderboards_client: PlayGamesLeaderboardsClient
var available := false
var leaderboard_id := ""

func _ready() -> void:
	leaderboard_id = str(ProjectSettings.get_setting(LEADERBOARD_ID_SETTING, "")).strip_edges()
	if not OS.has_feature("android") or leaderboard_id.is_empty():
		return
	if GodotPlayGameServices.initialize() != GodotPlayGameServices.PlayGamesPluginError.OK:
		return
	leaderboards_client = PlayGamesLeaderboardsClient.new()
	leaderboards_client.name = "LongestDashLeaderboardsClient"
	add_child(leaderboards_client)
	available = true
	availability_changed.emit(true)

func submit_longest_dash(meters: int) -> void:
	if available and is_instance_valid(leaderboards_client):
		leaderboards_client.submit_score(leaderboard_id, maxi(meters, 0))

func show_global_scores() -> bool:
	if not available or not is_instance_valid(leaderboards_client):
		return false
	leaderboards_client.show_leaderboard_for_time_span_and_collection(
		leaderboard_id,
		PlayGamesLeaderboardVariant.TimeSpan.TIME_SPAN_ALL_TIME,
		PlayGamesLeaderboardVariant.Collection.COLLECTION_PUBLIC
	)
	return true
