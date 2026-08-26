# Ostrich Dash Android and Google Play delivery

The release package proposed for Ostrich Dash is:

```text
com.grapegames.ostrichdash
```

Google Play package names cannot be changed after the app is created. Confirm this value before creating the Play Console app or making the first upload. If a Play app already exists under another package, update `export_presets.cfg`, `.github/workflows/deploy-android.yml`, and the default in `scripts/ci/godot-export-android.sh` together.

## What the workflow does

`.github/workflows/deploy-android.yml` runs on pushes to `main` or `master`, and can also be started manually. It:

1. installs the pinned Godot 4.7.1 editor and Android export templates;
2. restores or creates Godot's Gradle Android build template;
3. installs the Poing AdMob Android binaries;
4. injects the release AdMob and Play Games leaderboard IDs without committing them;
5. signs and exports `builds/android/OstrichDash.aab`;
6. validates the AAB package, version, and signature;
7. runs the gameplay smoke test; and
8. uploads the verified bundle to Google Play's `internal` track with status completed, matching Peregrine. Closed testing cannot be auto-completed while the Play app is still a draft.

## GitHub Actions secrets

Create these repository secrets under **Settings → Secrets and variables → Actions**:

| Secret | Purpose |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded Play upload keystore |
| `KEY_ALIAS` | Alias inside the upload keystore |
| `KEYSTORE_PASSWORD` | Upload-keystore password |
| `SERVICE_ACCOUNT_JSON` | Complete Google Play Developer API service-account JSON |
| `OSTRICH_DASH_ADMOB_ANDROID_APP_ID` | Ostrich Dash AdMob App ID in `ca-app-pub-…~…` form |
| `OSTRICH_DASH_PLAY_GAMES_APP_ID` | Numeric Play Games Services project ID |
| `OSTRICH_DASH_LEADERBOARD_ID` | Generated ID of the `Longest Dash` leaderboard |

Encode an existing upload keystore on Linux without line wrapping:

```bash
base64 -w 0 /absolute/path/to/upload.keystore
```

Keep the original keystore and password backed up securely. Losing the Play upload key creates a recovery process; changing the app-signing identity is more consequential.

The workflow intentionally keeps Google's official test banner unit during internal testing. The real AdMob **App ID** is still required because it identifies the mobile app to the SDK. Switching to the production Bottom_Bar unit remains a separate, deliberate release step in `autoload/ad_bar_service.gd` (`TODO(ads-live)`).

Recorded production IDs (not served while testing):

- App ID: `ca-app-pub-2846735043546429~8644426679`
- Banner (Bottom_Bar): `ca-app-pub-2846735043546429/2907894583`

## One-time Play Console setup

1. Create Ostrich Dash in Play Console with package `com.grapegames.ostrichdash`.
2. Enable the Google Play Developer API for the Google Cloud project that owns the service account.
3. Invite that service account in Play Console and grant it release access to Ostrich Dash.
4. Keep the internal-testing track (this is how Peregrine ships). Add testers and complete any Console forms required before a release can be accepted. Do not point CI at closed testing until the Play app is no longer a draft.
5. Configure Play Games Services, create the larger-is-better `Longest Dash` leaderboard, add the release signing SHA-1 credential, publish its configuration, and add the generated ID as a CI secret. See `docs/LEADERBOARD.md`.
6. Add the shared Grapegames listing URLs:
   - Website: `https://patguettler.github.io`
   - Privacy policy: `https://patguettler.github.io/privacy-policy.html`
   - Data deletion: `https://patguettler.github.io/privacy-policy.html#data-deletion`
7. Declare **Contains ads** and complete Data safety, target-audience, and content-rating forms from the final build's behavior.

The Play API service account uploads releases; it does not replace creation and initial configuration of the Play Console app.

## Local export

The same script can build locally on Linux when Java 17, the Android SDK, and signing variables are available:

```bash
export ANDROID_HOME=/absolute/path/to/Android/Sdk
export OSTRICH_DASH_ADMOB_ANDROID_APP_ID='ca-app-pub-…~…'
export OSTRICH_DASH_PLAY_GAMES_APP_ID='123456789012'
export OSTRICH_DASH_LEADERBOARD_ID='CgkI...'
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=/absolute/path/to/upload.keystore
export GODOT_ANDROID_KEYSTORE_RELEASE_USER='your-key-alias'
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD='your-password'
VERSION_CODE=1 VERSION_NAME=1.0 ./scripts/ci/godot-export-android.sh
```

For an emulator/debug APK, use the `Android Debug` export preset. It has a separate debug package (`com.grapegames.ostrichdash.debug`) so it can coexist with the Play build.
Android allows sensor-aware portrait plus both landscape rotations. The camera framing, HUD, menus, results, shop, swipe threshold, and bottom ad-safe area adapt whenever the device orientation changes.
