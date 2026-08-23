# Gameplay art generation notes

All assets in this directory were created for Ostrich Dash on 2026-08-23 with Codex's built-in image-generation workflow. The existing `ostrich_dash_key_art.png`, `ostrich_dash_icon.png`, and biome vistas were used only as character/style/palette/lighting references. No third-party game art, logos, brands, or copyrighted characters were used.

## Shared direction

Premium family-friendly animated-film 3D; rounded tactile toy forms; expressive, readable mobile silhouettes; soft feather, rubber, fabric, painted-metal, stone, snow, and foliage materials; teal, coral, sunshine yellow, warm cream, and midnight blue; no text, logos, watermarks, real brands, or Olympic imagery.

## Character plates

Front-facing plates are reserved for the menu and skin shop. Gameplay deliberately uses separate rear-facing plates so the camera follows behind the character and the ostrich runs away down the track.

- `runner_classic.png`: one full-body black-and-cream ostrich runner with turquoise eyes, coral legs, teal visor and shoes, front three-quarter running pose, genuine transparent alpha.
- `runner_midnight.png`: precise Classic recolor with midnight/navy feathers and purple gear.
- `runner_golden.png`: precise Classic recolor with chocolate/amber feathers and golden gear.
- `runner_bubblegum.png`: precise Classic recolor with berry/magenta feathers and pink gear.
- `rival_runner.png`: distinct friendly pink-and-coral emu rival with purple headband and shoes, matching proportions and camera.
- `runner_classic_back.png`: Classic runner seen directly from behind and slightly above, with a readable feather fan, visor back, running legs, and one shoe sole.
- `runner_midnight_back.png`: rear-view Midnight runner with navy plumage and purple gear.
- `runner_golden_back.png`: rear-view Golden runner with amber/chocolate plumage and sunshine-gold gear.
- `runner_bubblegum_back.png`: rear-view Bubblegum runner with cream/pink plumage and candy-pink gear.
- `rival_runner_back.png`: rear-view pink-and-coral rival, oriented in the same down-track direction.

Rear-view generation prompt family: isolated full-body premium animated-film 3D ostrich runner, viewed directly from behind and slightly above as if followed by a game camera, centered mid-stride running away, transparent background, readable feather fan and legs, no face/front view, text, logo, scenery, track, shadow, or duplicate character. Each skin retained its established palette and accessories. The built-in image-generation workflow produced one image per skin; edge-connected neutral checker pixels were then mechanically converted to true alpha with `scripts/ci/remove_checker_alpha.gd`.

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
- Rear-facing runner plates are used on the track; front-facing runner plates remain in the skin shop.
- Classic Stadium uses only its single complete vista at runtime. The former crowd/roof/rail layering and duplicated foreground plates are intentionally disabled.
- Hidden procedural player geometry remains only as an animation/collision rig.
- `tests/art_capture.gd` deterministically captures all six biomes, both obstacle groups, effects, the trip pose, the neck-pivot gate flip, and the shop to `user://art_audit/`.
- `tests/smoke_test.gd` asserts required art exists, generated runner/obstacle/pickup sprites are active, primitive player meshes are hidden, and shop portraits/medals are populated.
