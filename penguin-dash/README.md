# Penguin Dash 3D

A portrait, one-tap 3D mountain runner built with the free, open-source Godot engine. The penguin slides head-first down a banked spline chute; tap or click anywhere to hop over sea lions, crystal clusters, gates, and track gaps.

## Run

Open `project.godot` in Godot 4.4+ and press **F5**, or from this directory run:

```bash
godot --path .
```

Controls:

- Tap/click anywhere, <kbd>Space</kbd>, <kbd>Enter</kbd>, or <kbd>↑</kbd> to hop.
- Tap anywhere on the menu to start and anywhere on the medal screen to retry.

The default scene is a fully 3D, code-built Alpine course with a follow camera, banked chute geometry, snowbank rails, low-poly mountain ranges, a Meshy AI head-first penguin, modeled hazards, lighting, fog, and a procedural night sky. The original AI-created gouache art remains in the title presentation and is also used as the ice chute's painted surface texture. See `assets/art/README.md` for the art direction and prompt record. The original 2D implementation remains available as `main.tscn`; the 3D game starts from `main_3d.tscn`. The personal best is saved locally in `user://penguin_dash_3d_save.json`.

## Scope

This build implements the playable 3D MVP and presentation pass from the plan: escalating speed, distance score, fish pickups, four obstacle types, collision/game-over/retry, procedural banking, local best score, custom HUD/menu/medal screen, a generated-art title presentation, and the Meshy Joy penguin with walk/run clips on the belly-first slide.

The plan's account/service-backed stages—Google Play leaderboards, the large market economy, and AdMob—are intentionally not part of this standalone core build.
