extends Node

signal availability_changed(available: bool)
signal sign_in_failed()
signal score_submit_finished(success: bool, meters: int)
signal score_queued(meters: int)
signal scores_loaded(rows: Array)
signal scores_load_failed(message: String)
signal ready_to_show()

const LEADERBOARD_ID_SETTING := "ostrich_dash/play_games/longest_dash_leaderboard_id"
const NO_PENDING_SCORE := -1
const TOP_RESULTS := 20

var leaderboards_client: PlayGamesLeaderboardsClient
var sign_in_client: PlayGamesSignInClient
var available := false
var authenticated := false
var leaderboard_id := ""
var _pending_show_after_sign_in := false
var _auth_check_started := false
var _awaiting_manual_sign_in := false
var _pending_score_meters := NO_PENDING_SCORE
var _last_submitted_meters := 0

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
	leaderboards_client.top_scores_loaded.connect(_on_top_scores_loaded)
	available = true
	availability_changed.emit(true)
	print(
		"LeaderboardService: ready id_len=%d id_tail=%s"
		% [leaderboard_id.length(), leaderboard_id.substr(maxi(leaderboard_id.length() - 4, 0))]
	)
	_check_authentication()

func _check_authentication() -> void:
	if not available or not is_instance_valid(sign_in_client) or _auth_check_started:
		return
	_auth_check_started = true
	sign_in_client.is_authenticated()

func submit_longest_dash(meters: int) -> void:
	if not available or not is_instance_valid(leaderboards_client):
		return
	var score := maxi(meters, 0)
	if score <= 0:
		return
	if not authenticated:
		_pending_score_meters = maxi(_pending_score_meters, score)
		score_queued.emit(score)
		_check_authentication()
		return
	_submit_score_now(score)

## Starts sign-in if needed. Empty string means already authenticated.
func begin_global_scores() -> String:
	if not available or not is_instance_valid(leaderboards_client):
		if leaderboard_id.is_empty():
			return "setup"
		return "unavailable"
	if not authenticated:
		_pending_show_after_sign_in = true
		_awaiting_manual_sign_in = true
		if is_instance_valid(sign_in_client):
			sign_in_client.sign_in()
		return "signing_in"
	return ""

func fetch_scores() -> void:
	if not available or not is_instance_valid(leaderboards_client):
		scores_load_failed.emit("unavailable")
		return
	if not authenticated:
		scores_load_failed.emit("signed_out")
		return
	leaderboards_client.load_top_scores(
		leaderboard_id,
		PlayGamesLeaderboardVariant.TimeSpan.TIME_SPAN_ALL_TIME,
		PlayGamesLeaderboardVariant.Collection.COLLECTION_PUBLIC,
		TOP_RESULTS,
		true
	)

func show_native_leaderboard() -> void:
	if not available or not authenticated or not is_instance_valid(leaderboards_client):
		return
	leaderboards_client.show_leaderboard_for_time_span_and_collection(
		leaderboard_id,
		PlayGamesLeaderboardVariant.TimeSpan.TIME_SPAN_ALL_TIME,
		PlayGamesLeaderboardVariant.Collection.COLLECTION_PUBLIC
	)

func _submit_score_now(meters: int) -> void:
	if not is_instance_valid(leaderboards_client):
		return
	_last_submitted_meters = meters
	print(
		"LeaderboardService: submitting %d m to id_tail=%s"
		% [meters, leaderboard_id.substr(maxi(leaderboard_id.length() - 4, 0))]
	)
	leaderboards_client.submit_score(leaderboard_id, meters)

func _flush_pending_score() -> void:
	if _pending_score_meters == NO_PENDING_SCORE:
		return
	var meters := _pending_score_meters
	_pending_score_meters = NO_PENDING_SCORE
	_submit_score_now(meters)

func _on_user_authenticated(is_authenticated: bool) -> void:
	authenticated = is_authenticated
	_auth_check_started = false
	var was_awaiting_manual := _awaiting_manual_sign_in
	_awaiting_manual_sign_in = false
	if not is_authenticated:
		_pending_show_after_sign_in = false
		if was_awaiting_manual:
			push_warning(
				"LeaderboardService: Play Games sign-in failed. Check OAuth SHA-1 (Play App Signing), consent Audience test users, and Play Games testers."
			)
			sign_in_failed.emit()
		return
	_flush_pending_score()
	if _pending_show_after_sign_in:
		_pending_show_after_sign_in = false
		ready_to_show.emit()

func _on_score_submitted(is_submitted: bool, submitted_leaderboard_id: String) -> void:
	print(
		"LeaderboardService: submit result success=%s meters=%d board=%s"
		% [str(is_submitted), _last_submitted_meters, submitted_leaderboard_id]
	)
	score_submit_finished.emit(is_submitted, _last_submitted_meters)
	if not is_submitted:
		push_warning(
			"LeaderboardService: score was not submitted for %s" % submitted_leaderboard_id
		)

func _on_top_scores_loaded(loaded_leaderboard_id: String, leaderboard_scores: PlayGamesLeaderboardScores) -> void:
	if loaded_leaderboard_id != leaderboard_id:
		return
	var rows: Array = []
	if leaderboard_scores != null:
		for entry: PlayGamesLeaderboardScore in leaderboard_scores.scores:
			rows.append({
				"rank": entry.rank,
				"display_rank": entry.display_rank,
				"name": entry.score_holder_display_name,
				"score": entry.raw_score,
				"display_score": entry.display_score,
			})
	print("LeaderboardService: loaded %d rows" % rows.size())
	scores_loaded.emit(rows)
