# Ostrich Dash

A complete Godot 4 endless runner based on `ostrich-dash-full-plan.md`. Its key art, five characters, obstacles, pickups, powers, effects, medals, track surfaces, prop clusters, and six biome environments share one original premium animated-film 3D art direction. Gameplay uses polished 2.5D generated plates over a lightweight 3D track, with synthesized sound effects.

## Play

Open this folder in Godot 4.5+ and press **F6/F5**, or run:

```bash
godot --path /home/pat/dev/ostrich
godot --editor --path /home/pat/dev/ostrich
```

Controls:

- Left/right arrows or A/D: switch lanes
- Up arrow, W, or Space: jump
- Down arrow or S: duck
- E or Q: activate a fully charged power-up
- P or Escape: pause
- Mobile: swipe sideways to switch lanes, swipe up to jump, and swipe down to duck; keyboard-style arrow buttons are automatically hidden

## Included systems

- 3-lane endless running with a smooth speed ramp
- Jump, duck, lane switch, laptop arrow keys, and swipe-only mobile controls
- Hurdles, walls, cones, drones, slippery patches, and rival runners
- Forward trip for foot-level impacts, elevated-bar spin, camera shake, and generated feather/dust bursts
- Classic Stadium, Beach, Night, Desert, Snow, and Jungle biomes, each with unique generated vista art
- Background changes every 225 meters; non-stadium biomes are reshuffled for every complete tour with no consecutive repeats
- Distance score, clean-dodge combo, near-misses, feathers, and personal best
- Shield, Magnet, Slow-Mo, and Score Rush chargeable power-ups
- Persistent feather wallet, four unlockable skins, and biome medals
- Daily 15-feather challenge and persistent save data
- Pause, results, retry, shop, and loadout screens
- Generated title art, app icon, runners, rivals, hazards, rewards, effects, medals, surfaces, biome props, vistas, and grandstands—no external game art

## Validation

Run the automated menu/gameplay smoke test with:

```bash
godot --headless --fixed-fps 60 --path /home/pat/dev/ostrich --script res://tests/smoke_test.gd
```

Create deterministic 1280×720 visual-audit captures for every biome, both obstacle groups, effects, the trip pose, and the shop with:

```bash
godot --fixed-fps 60 --path /home/pat/dev/ostrich --script res://tests/art_capture.gd
```

Captures are written outside the project package to `user://art_audit/`. The complete object list and generation provenance are in [`docs/ART_INVENTORY.md`](docs/ART_INVENTORY.md) and [`assets/generated/gameplay/GENERATION_NOTES.md`](assets/generated/gameplay/GENERATION_NOTES.md).

Save data is stored by Godot at `user://ostrich_dash_save.cfg`.

## Mobile ad bar

Android/iOS banner ads use the bundled MIT-licensed Poing Studios Godot AdMob integration. The native banner owns a reserved band at the bottom of the screen; the 3D viewport, menus, HUD, results, shop, and touch area are all resized to end above it.

Development uses Google's official test banner IDs from `config/admob.example.json`. Never test with production ad IDs. To preview the reserved layout on desktop without loading an ad:

```bash
godot --path /home/pat/dev/ostrich -- --preview-ad-bar
```

## Privacy and store listing

The home screen's **Privacy & Data** button opens the shared Grapegames policy used by Peregrine. Use these same public URLs for the Ostrich Dash store listing:

- Privacy policy: <https://patguettler.github.io/privacy-policy.html>
- Data deletion: <https://patguettler.github.io/privacy-policy.html#data-deletion>
- Developer website: <https://patguettler.github.io>
- AdMob authorization: <https://patguettler.github.io/app-ads.txt>

Release and data-practice notes are in [`docs/PRIVACY_AND_RELEASE.md`](docs/PRIVACY_AND_RELEASE.md).

## Google Play CI

The project includes a signed Android App Bundle pipeline matching Peregrine's internal-track delivery approach. Pushes to `main` or `master` build, validate, smoke-test, and upload `com.grapegames.ostrichdash` to Google Play internal testing after the repository secrets and Play Console app are configured.

See [`docs/PLAY_ANDROID.md`](docs/PLAY_ANDROID.md) for the immutable package-name decision, required secrets, Play service-account permissions, and local export instructions.
