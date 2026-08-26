# Ostrich Dash

A complete Godot 4 endless runner based on `ostrich-dash-full-plan.md`. Its key art, twelve runner colorways, rival character, obstacles, pickups, runner gifts, effects, medals, track surfaces, prop clusters, and nine biome environments share one original premium animated-film 3D art direction. A third-person follow camera looks over the rear-facing ostrich as it runs away down a lightweight 3D track, with polished 2.5D generated plates and synthesized sound effects.

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
- E or Q: activate the equipped ostrich's fully charged runner gift
- P or Escape: pause
- Android system Back: pause/resume during a run, or return from Shop/Results to Home
- Mobile: swipe sideways to switch lanes, swipe up to jump, and swipe down to duck; no on-screen arrow buttons are created
- Android: rotate the device at any time; gameplay, menus, HUD, shop, camera framing, and the ad-safe area reflow for portrait or landscape

## Included systems

- 3-lane endless running with a smooth speed ramp
- A generated six-pose rear-view leg-and-shoe run cycle with contact, push-off, and passing poses, plus jump, duck, lane switch, laptop arrow keys, and swipe-only mobile controls
- More breathable hazard spacing with occasional late-run two-lane patterns and clearly telegraphed three-lane skill rows that require a jump or duck, plus hurdles, walls, cones, drones, slippery patches, and independently animated rival runners
- Mixed feather routes: most trails use clear lanes, while some cross hazards with high jump-feathers or low duck-feathers that reward committing to the correct move
- Forward trip for foot-level impacts, neck-pivot flip over duck-under gates, camera shake, and generated feather/dust bursts
- Distinct dramatic bird reactions: a rising-and-falling startled squawk for a neck flip and a stumbling yelp with impact thud for a foot-level trip
- Nine unique generated biomes: Classic Stadium, Beach, Night, Desert, Snow, Jungle, Candy Carnival, Volcano Valley, and Cloud Kingdom
- Each 225-meter biome is a visible Tour stage with next-world progress and a +5 feather checkpoint reward; clearing all nine stages awards a +25 Tour bonus before a reshuffled tour begins
- Large labeled Distance, Feathers, and Dodge Streak cards keep the important run stats readable in both orientations
- Every ostrich owns one built-in runner gift—there is no separate ability setting. Its gift charges from clean dodges and feathers, then activates from the floating bubble beside the runner
- Later unlocks start with more charge, recharge faster, last longer, and strengthen their shield, feather-pull, obstacle-slow, or crash-rescue effect so wardrobe progress helps extend runs
- Every active runner gift visibly follows the ostrich for its full timer with a color-coded aura and orbiting generated shield, magnet, clock, or rescue-star buddies
- Original looping background music with a saved Music On/Off control on the home screen
- Full celebration result sheet with selected-runner art, biome medal progress, four readable stat bubbles, daily/streak highlights, and large retry/home/global-score actions
- Native Google Play Games `Longest Dash` global scoreboard entry points on Home and Results
- Persistent feather wallet, twelve unlockable colorways, and nine biome medals
- Prestige wardrobe progression: paid runners climb from 25,000 to 5,000,000 feathers, with 15,050,000 feathers required for the complete collection
- Daily 15-feather challenge and persistent save data
- Pause, results, retry, shop, and loadout screens
- Generated title art, app icon, front-view shop portraits, rear-view gameplay runners, rivals, hazards, rewards, effects, medals, surfaces, biome props, and vistas—no external game art

## Validation

Run the automated menu/gameplay smoke test with:

```bash
godot --headless --fixed-fps 60 --path /home/pat/dev/ostrich --script res://tests/smoke_test.gd
```

Create deterministic visual-audit captures for every biome, both obstacle groups, effects, the trip pose, the shop, and portrait gameplay/menu/shop layouts with:

```bash
godot --fixed-fps 60 --path /home/pat/dev/ostrich --script res://tests/art_capture.gd
```

Captures are written outside the project package to `user://art_audit/`, including both halves of the scrolling portrait shop. The complete object list and generation provenance are in [`docs/ART_INVENTORY.md`](docs/ART_INVENTORY.md) and [`assets/generated/gameplay/GENERATION_NOTES.md`](assets/generated/gameplay/GENERATION_NOTES.md).

To capture the four runner-gift effect families directly from portrait gameplay:

```bash
godot --fixed-fps 60 --path /home/pat/dev/ostrich --script res://tests/art_capture.gd -- --powers-only
```

Rebuild the Google Play screenshot galleries from direct in-game captures with:

```bash
godot --fixed-fps 60 --path /home/pat/dev/ostrich --script res://tests/art_capture.gd -- --store-listing
python3 scripts/build_play_store_assets.py
```

This store mode captures only real gameplay frames; it does not create marketing composites or add text overlays.

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

The project includes a signed Android App Bundle pipeline matching Peregrine. Pushes to `main` or `master` build, validate, smoke-test, and upload `com.grapegames.ostrichdash` to Google Play internal testing after the repository secrets and Play Console app are configured.

See [`docs/PLAY_ANDROID.md`](docs/PLAY_ANDROID.md) for the immutable package-name decision, required secrets, Play service-account permissions, leaderboard setup, and local export instructions.
