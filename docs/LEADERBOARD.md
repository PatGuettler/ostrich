# Ostrich Dash global leaderboard

Ostrich Dash integrates Google Play Games Services (PGS) v2 and the Godot Play Game Services plugin for one Android leaderboard:

- Name: `Longest Dash`
- Order: Larger is better
- Score format: Numeric integer
- Unit: meters
- Submission: when the result screen opens
- Entry points: `GLOBAL SCORES` on Home and Results

On Android, tapping **GLOBAL SCORES** opens an in-app **Longest Dash** panel with the top public all-time ranks. **OPEN IN PLAY GAMES** still launches Google’s native UI. Players must allow **Let others see your game activity** in Play Games privacy or public ranks stay empty even after a successful submit.

A finished run’s distance is queued when unsigned-in and submitted as soon as sign-in succeeds. On desktop, debug builds, or Android builds without IDs, the panel shows local personal bests and a setup message.

## One-time Play Console setup

1. In Play Console, create/link the Play Games Services project for `com.grapegames.ostrichdash`.
2. Add the release app credential with the correct package and signing certificate SHA-1 (Play App Signing + upload key).
3. Create the `Longest Dash` leaderboard (larger is better, meters).
4. Add tester accounts under **Play Games Services → Testers** (separate from Play internal testing) and **publish** the Play Games Services configuration.
5. Save these GitHub Actions secrets:
   - `OSTRICH_DASH_PLAY_GAMES_APP_ID`
   - `OSTRICH_DASH_LEADERBOARD_ID`

Copy the leaderboard ID from Console; do not retype (easy to confuse `0`/`O` and `l`/`I`). The release workflow injects them into temporary copies of `export_presets.cfg` and `project.godot`, then restores blank placeholders. Do not commit production IDs.

The current implementation uses `com.google.android.gms:play-services-games-v2:21.0.0`. The vendored plugin is MIT-licensed under `addons/GodotPlayGameServices/`.

Official references:

- <https://developer.android.com/games/pgs/android/android-signin>
- <https://developer.android.com/games/pgs/android/leaderboards>
- <https://github.com/godot-sdk-integrations/godot-play-game-services>
