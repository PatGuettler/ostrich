# Ostrich Dash global leaderboard

Ostrich Dash integrates Google Play Games Services (PGS) v2 and the Godot Play Game Services 3.4.0 plugin for one native Android leaderboard:

- Name: `Longest Dash`
- Order: Larger is better
- Score format: Numeric integer
- Unit: meters
- Submission: when the result screen opens
- Entry points: `GLOBAL SCORES` on Home and Results

On Android, PGS handles platform authentication and opens Google's native all-users ranking screen. On desktop, debug builds, or Android builds without IDs, the buttons show a friendly setup message and gameplay continues normally.

## One-time Play Console setup

1. In Play Console, create/link the Play Games Services project for `com.grapegames.ostrichdash`.
2. Add the release app credential with the correct package and signing certificate SHA-1.
3. Create the `Longest Dash` leaderboard, set larger scores as better, and use meters as its display unit.
4. Add tester accounts and publish the Play Games Services configuration before testing an internal release.
5. Save the numeric Games project ID and generated leaderboard ID as GitHub Actions secrets:
   - `OSTRICH_DASH_PLAY_GAMES_APP_ID`
   - `OSTRICH_DASH_LEADERBOARD_ID`

The release workflow requires both values. It injects them into temporary copies of `export_presets.cfg` and `project.godot`, then restores the checked-in blank placeholders. Do not commit production IDs.

The current implementation uses `com.google.android.gms:play-services-games-v2:21.0.0`. The vendored plugin is MIT-licensed under `addons/GodotPlayGameServices/`.

Official references:

- <https://developer.android.com/games/pgs/android/android-signin>
- <https://developer.android.com/games/pgs/android/leaderboards>
- <https://github.com/godot-sdk-integrations/godot-play-game-services>
