# Gameplay art generation notes

All assets in this directory were created for Ostrich Dash on 2026-08-23 with Codex's built-in image-generation workflow. The existing `ostrich_dash_key_art.png`, `ostrich_dash_icon.png`, and biome vistas were used only as character/style/palette/lighting references. No third-party game art, logos, brands, or copyrighted characters were used.

## Shared direction

Premium family-friendly animated-film 3D; rounded tactile toy forms; expressive, readable mobile silhouettes; soft feather, rubber, fabric, painted-metal, stone, snow, and foliage materials; teal, coral, sunshine yellow, warm cream, and midnight blue; no text, logos, watermarks, real brands, or Olympic imagery.

## Character plates

- `runner_classic.png`: one full-body black-and-cream ostrich runner with turquoise eyes, coral legs, teal visor and shoes, front three-quarter running pose, genuine transparent alpha.
- `runner_midnight.png`: precise Classic recolor with midnight/navy feathers and purple gear.
- `runner_golden.png`: precise Classic recolor with chocolate/amber feathers and golden gear.
- `runner_bubblegum.png`: precise Classic recolor with berry/magenta feathers and pink gear.
- `rival_runner.png`: distinct friendly pink-and-coral emu rival with purple headband and shoes, matching proportions and camera.

## Atlas prompts and fixed cell maps

### `obstacle_atlas.png` — 3 columns × 2 rows

Rounded padded athletics hazards on transparent alpha, equal isolated cells, front three-quarter camera:

1. low coral/teal hurdle
2. tall striped duck-under training gate
3. soft orange safety cone
4. friendly teal referee drone
5. glossy turquoise slippery puddle
6. chunky cream/yellow/coral foam wall

### `reward_power_atlas.png` — 3 columns × 2 rows

Magical reward objects with small-mobile-icon silhouettes on transparent alpha:

1. luminous cream/gold ostrich feather
2. puffy teal/coral feather shield
3. teal/coral horseshoe feather magnet
4. winged cyan slow-motion stopwatch
5. winged golden score star
6. teal/coral daily reward feather pouch

### `biome_prop_atlas.png` — 3 columns × 2 rows

Authored trackside story clusters on transparent alpha:

1. Classic Stadium lamp, pennants, flower planters
2. Beach palm, surfboard, tropical flowers
3. Night floodlights, neon pennants, star lamps
4. Desert flowering cactus, rounded rocks, windsock
5. Snow bank, frosted pine, warm lantern, icy flags
6. Jungle mossy ruin, orchids, broad leaves, bamboo pennants

### `effects_medals_atlas.png` — 3 columns × 2 rows

Airy gameplay bursts and consistent achievement badges on transparent alpha:

1. feather-and-star burst
2. cream running dust puff
3. teal/gold/coral sparkle collision burst
4. bronze winged footprint medal
5. silver winged footprint medal
6. gold winged footprint medal

### `surface_atlas.png` — 3 columns × 2 rows

Opaque top-down, seamless, uniformly lit material swatches:

1. terracotta stadium rubber
2. warm beach sand
3. midnight synthetic track
4. burnt-orange desert clay
5. blue-white packed snow
6. cocoa jungle earth and moss

Godot's 3D material path does not sample `AtlasTexture` regions consistently, so the surface atlas is losslessly split into the six runtime textures under `surfaces/` by `scripts/ci/split_surface_atlas.gd`. The atlas remains the generated source of truth.

## Alpha handling

Every transparent runtime asset is validated with `scripts/ci/check_image_alpha.gd`. Some generated atlas responses visually baked the preview checkerboard; those were first sent through the image generator's background-extraction mode. Two remaining checker-backed atlases were then mechanically converted to true RGBA using `scripts/ci/remove_checker_alpha.gd`, which flood-fills only bright neutral pixels connected to the canvas edge so cream art and colored glows remain intact.

## Runtime and audit

- Generated art is consumed by `scripts/dash_player.gd` and `scripts/main.gd`.
- Hidden procedural player geometry remains only as an animation/collision rig.
- `tests/art_capture.gd` deterministically captures all six biomes, both obstacle groups, effects, the trip pose, and the shop to `user://art_audit/`.
- `tests/smoke_test.gd` asserts required art exists, generated runner/obstacle/pickup sprites are active, primitive player meshes are hidden, and shop portraits/medals are populated.
