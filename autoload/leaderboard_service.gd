extends Node

signal availability_changed(available: bool)

const LEADERBOARD_ID_SETTING := "ostrich_dash/play_games/longest_dash_leaderboard_id"

var leaderboards_client: PlayGamesLeaderboardsClient
var sign_in_client: PlayGamesSignInClient
var available := false
var authenticated := false
var leaderboard_id := ""
var _pending_show_after_sign_in := false
var _auth_check_started := false

func _ready() -> void:
	leaderboard_id = str(ProjectSettings.get_setting(LEADERBOARD_ID_SETTING, "")).strip_edges()
	if not OS.has_feature("android") or leaderboard_id.is_empty():
		return
	if GodotPlayGameServices.initialize() != GodotPlayGameServices.PlayGamesPluginError.OK:
		push_warning("LeaderboardService: native Play Games plugin is missing from this build")
		return
	sign_in_client = PlayGamesSignInClient.new()
	sign_in_client.name = "PlayGamesSignInClient"
	add_child(sign_in_client)
	sign_in_client.user_authenticated.connect(_on_user_authenticated)
	leaderboards_client = PlayGamesLeaderboardsClient.new()
	leaderboards_client.name = "LongestDashLeaderboardsClient"
	add_child(leaderboards_client)
	leaderboards_client.score_submitted.connect(_on_score_submitted)
	available = true
	availability_changed.emit(true)
	_check_authentication()

func _check_authentication() -> void:
	if not available or not is_instance_valid(sign_in_client) or _auth_check_started:
		return
	_auth_check_started = true
	sign_in_client.is_authenticated()

func submit_longest_dash(meters: int) -> void:
	if not available or not authenticated or not is_instance_valid(leaderboards_client):
		return
	leaderboards_client.submit_score(leaderboard_id, maxi(meters, 0))

## Returns an empty string when the native leaderboard UI was requested.
## Otherwise returns a short status token for menu toasts.
func show_global_scores() -> String:
	if not available or not is_instance_valid(leaderboards_client):
		if leaderboard_id.is_empty():
			return "setup"
		return "unavailable"
	if not authenticated:
		_pending_show_after_sign_in = true
		if is_instance_valid(sign_in_client):
			sign_in_client.sign_in()
		return "signing_in"
	_open_leaderboard_ui()
	return ""

func _open_leaderboard_ui() -> void:
	if not is_instance_valid(leaderboards_client):
		return
	leaderboards_client.show_leaderboard_for_time_span_and_collection(
		leaderboard_id,
		PlayGamesLeaderboardVariant.TimeSpan.TIME_SPAN_ALL_TIME,
		PlayGamesLeaderboardVariant.Collection.COLLECTION_PUBLIC
	)

func _on_user_authenticated(is_authenticated: bool) -> void:
	authenticated = is_authenticated
	_auth_check_started = false
	if not is_authenticated:
		_pending_show_after_sign_in = false
		return
	if _pending_show_after_sign_in:
		_pending_show_after_sign_in = false
		_open_leaderboard_ui()

func _on_score_submitted(is_submitted: bool, submitted_leaderboard_id: String) -> void:
	if not is_submitted:
		push_warning(
			"LeaderboardService: score was not submitted for %s" % submitted_leaderboard_id
		)
