# Gameplay art generation notes

All assets in this directory were created for Ostrich Dash from 2026-08-23 through 2026-08-26 with Codex's built-in image-generation workflow. The existing `ostrich_dash_key_art.png`, `ostrich_dash_icon.png`, and biome vistas were used only as character/style/palette/lighting references. No third-party game art, logos, brands, or copyrighted characters were used.

## Shared direction

Premium family-friendly animated-film 3D; rounded tactile toy forms; expressive, readable mobile silhouettes; soft feather, rubber, fabric, painted-metal, stone, snow, and foliage materials; teal, coral, sunshine yellow, warm cream, and midnight blue; no text, logos, watermarks, real brands, or Olympic imagery.

## Character plates

Front-facing plates are reserved for the menu and skin shop. Gameplay deliberately uses separate rear-facing plates so the camera follows behind the character and the ostrich runs away down the track.

- `runner_classic.png`: one full-body black-and-cream ostrich runner with turquoise eyes, coral legs, teal visor and shoes, front three-quarter running pose, genuine transparent alpha.
- `runner_midnight.png`: precise Classic recolor with midnight/navy feathers and purple gear.
- `runner_golden.png`: precise Classic recolor with chocolate/amber feathers and golden gear.
- `runner_bubblegum.png`: precise Classic recolor with berry/magenta feathers and pink gear.
- `runner_aurora.png`: precise Classic identity and pose with navy/violet feathers, cyan/violet gear, and a coordinated dark aurora studio vignette for the premium shop card.
- `runner_emerald.png`: precise Classic identity and pose with emerald/forest feathers, lime/gold gear, and a coordinated dark green studio vignette for the premium shop card.
- `runner_sunset.png`: precise Classic identity and pose with coral/tangerine/raspberry feathers, orange/rose/gold gear, and a coordinated warm studio vignette for the premium shop card.
- `runner_frost.png`: precise Classic identity and pose with ice-blue/silver/lavender feathers, glacier-cyan/lavender gear, and a coordinated cool studio vignette for the premium shop card.
- `runner_celestial.png`: exact Classic identity/pose recolored in cobalt, cyan, violet, and gold with a starry studio vignette.
- `runner_rose_gold.png`: exact Classic identity/pose recolored in blush, champagne, copper, and cream with a warm studio vignette.
- `runner_electric_lime.png`: exact Classic identity/pose recolored in electric lime, charcoal, teal, and white with an energetic studio vignette.
- `runner_royal_peacock.png`: exact Classic identity/pose recolored in peacock teal, royal purple, sapphire, and gold with a jewel-toned studio vignette.
- `rival_runner.png`: distinct friendly pink-and-coral emu rival with purple headband and shoes, matching proportions and camera.
- `runner_classic_back.png`: Classic runner seen directly from behind and slightly above, with a readable feather fan, visor back, running legs, and one shoe sole.
- `runner_midnight_back.png`: rear-view Midnight runner with navy plumage and purple gear.
- `runner_golden_back.png`: rear-view Golden runner with amber/chocolate plumage and sunshine-gold gear.
- `runner_bubblegum_back.png`: rear-view Bubblegum runner with cream/pink plumage and candy-pink gear.
- `rival_runner_back.png`: rear-view pink-and-coral rival, oriented in the same down-track direction.
- `runner_*_body_back.png`: four rear-view, legless production body layers. These sit in front of the generated run-cycle sheet so only one clean pair of legs is visible at a time.
- `runner_classic_legs_run_sheet.png`: transparent 3×2 sheet containing six rear-view leg-and-shoe poses—contact, push-off, passing, then mirrored—with consistent hip anchors for a planted, readable run cycle.

Rear-view generation prompt family: isolated full-body premium animated-film 3D ostrich runner, viewed directly from behind and slightly above as if followed by a game camera, centered mid-stride running away, transparent background, readable feather fan and legs, no face/front view, text, logo, scenery, track, shadow, or duplicate character. Each skin retained its established palette and accessories. The built-in image-generation workflow produced one image per skin; edge-connected neutral checker pixels were then mechanically converted to true alpha with `scripts/ci/remove_checker_alpha.gd`.

Legless body edit prompt family: remove only both legs and running shoes from the matching rear-view skin; naturally complete the underside with matching feathers; preserve the exact rear view, scale, centered framing, head, neck, visor, body, and tail fan; transparent background; no shadow, text, watermark, or added object. The image tool's RGB previews baked their neutral checker, so only the edited feather underside was retained: the untouched upper character uses the original RGBA pixels, while the lower edit received a saturation/darkness alpha reconstruction and a hard transparent safety cutoff below the body. All four final layers were visually inspected and validated as 1024×1536 RGBA.

Run-cycle sheet prompt: precise object edit using `runner_classic_back.png` as the anatomy and material reference; render only the same two coral-scaled ostrich legs and teal running shoes from the rear in six sequential contact, push-off, passing, and mirrored poses; keep identical hip anchors, shoe tread, laces, proportions, lighting, and animated-film 3D finish; transparent background; no body, track, shadow, text, grid, duplicate character, or extra legs. It was generated in Codex's built-in image-generation mode. The built-in background-extraction edit was moderation-blocked, so the project's edge-connected neutral-checker removal script produced the final true-alpha RGBA sheet without altering the colored leg art.

Avoidance-pose prompt set (built-in image generation, one image per base runner color): precise object edit matching the established rear-view runner identity, palette, accessories, proportions, lighting, and premium animated-film 3D finish. Duck images (`runner_*_duck_back.png`) request a genuinely low crouch with deeply bent knees, both shoes planted, and the long neck curled forward and down into a pronounced S-curve with the head tucked near the feather fan. Jump images (`runner_*_jump_back.png`) request the apex of a forward jump with the body lifted, wings slightly spread, both legs bent and tucked beneath the body, and both shoe soles completely clear of the ground. Every prompt prohibits obstacles, floors, scenery, text, logos, duplicate characters, and extra limbs. The Golden jump needed a second built-in background-extraction pass whose prompt removed only its dark studio backdrop while preserving the exact runner pixels and clean edge detail. The generated neutral checker was mechanically converted to genuine transparent alpha with `scripts/ci/remove_checker_alpha.gd`, then verified with `scripts/ci/check_image_alpha.gd`.

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

## New biome vistas

`candy_carnival_vista.png`, `volcano_valley_vista.png`, and `cloud_kingdom_vista.png` were created in built-in image-generation mode as original wide 16:9 animated-film 3D worlds. The prompt family preserved only the established follow-camera composition: a centered vanishing point, broad empty three-lane track, crop-safe sides, and scenery kept outside the playable lanes. It requested a distinct candy festival, friendly volcanic valley, or floating cloud kingdom and prohibited runners, obstacles, text, logos, watermarks, and doubled imagery.

`savanna_sunrise_vista.png`, `crystal_caverns_vista.png`, and `moonbase_marathon_vista.png` were also created in built-in mode using the key art for finish and the stadium vista for composition. Their prompt set requested a centered empty three-lane follow-camera road, crop-safe scenery, high-detail animated-film 3D rendering, and one distinct golden savanna, luminous crystal arena, or friendly lunar race base. It prohibited characters, obstacles, text, logos, blank side strips, and doubled imagery.

## Biome-specific obstacle atlases

The eleven atlases under `obstacles/` give every non-Classic biome its own art while retaining the exact production 3×2 cell map: jump hurdle, tall duck gate, foot-level marker, flying hazard, slick patch, and wall. The built-in image-generation prompt used `obstacle_atlas.png` as the strict layout/camera/silhouette reference and the key art as the material/style reference. It requested one complete centered object per cell, premium cute animated-film 3D detail, transparent alpha, and no grid, labels, logos, scenery, or runner.

Theme sets are Beach surf gear, Night neon, Desert sandstone, Snow ski gear, Jungle logs and ruins, Candy confectionery, Volcano basalt and lava, Cloud clouds and rainbows, Savanna carved timber and watering holes, Crystal gems, and Moonbase space hardware. Edge-connected neutral checker pixels in opaque previews were removed with `scripts/ci/remove_checker_alpha.gd`; every final atlas passes `check_image_alpha.gd` and imports with mipmaps.

## High-detail runtime surfaces

The original 512×512 split swatches remain as recoverable source assets. Gameplay now uses twelve separately generated materials under `surfaces/hd/`: `classic_rubber_hd.png`, `beach_sand_hd.png`, `night_track_hd.png`, `desert_clay_hd.png`, `snow_pack_hd.png`, `jungle_earth_hd.png`, `candy_rubber_hd.png`, `volcano_rubber_hd.png`, `cloud_rubber_hd.png`, `savanna_earth_hd.png`, `crystal_floor_hd.png`, and `moon_dust_hd.png`.

Each was created in built-in image-generation edit mode using a matching swatch as the strict palette and material reference. The shared prompt requested a top-down, evenly lit, seamless tile with crisp large-, medium-, and fine-scale material structure and no objects, markings, text, perspective, blurry regions, or obvious repeated motifs. The final three prompts specifically requested detailed ochre savanna gravel and clay, violet mineral grains with aqua/amethyst flecks, and compacted silver-blue lunar dust with pebbles and micro-craters.

At runtime the HD swatches repeat four times per 24-meter track tile. All generated image imports include mipmaps, and 3D sprites/materials plus image-bearing UI controls request anisotropic mipmapped filtering. This prevents one low-frequency image from being enlarged across an entire world tile and preserves detail under camera perspective.

## Alpha handling

Every transparent runtime asset is validated with `scripts/ci/check_image_alpha.gd`. Some generated atlas responses visually baked the preview checkerboard; those were first sent through the image generator's background-extraction mode. Two remaining checker-backed atlases were then mechanically converted to true RGBA using `scripts/ci/remove_checker_alpha.gd`, which flood-fills only bright neutral pixels connected to the canvas edge so cream art and colored glows remain intact.

## Runtime and audit

- Generated art is consumed by `scripts/dash_player.gd` and `scripts/main.gd`.
- Rear-facing runner plates are used on the track; front-facing runner plates remain in the skin shop.
- Aurora, Emerald, Sunset, Frost, Celestial, Rose Gold, Electric Lime, and Royal Peacock were produced in built-in precise-object-edit mode. Their prompts preserved the exact ostrich identity, anatomy, running pose, scale, framing, full body, and both shoes; changed only the named feather/accessory palette; requested a dark coordinated studio vignette and detailed feathers/fabric/rubber; and prohibited text, logos, watermarks, crops, and extra objects. Gameplay applies matching tints to the rear body and six-pose leg sheet so all twelve choices retain the finished run animation.
- Classic Stadium uses only its single complete vista at runtime. The former crowd/roof/rail layering and duplicated foreground plates are intentionally disabled.
- Hidden procedural player geometry remains only as an animation/collision rig.
- `tests/art_capture.gd` deterministically captures all twelve biomes with their matching obstacles, both opposite run-stride extremes, effects, the trip pose, the neck-pivot gate flip, and the shop to `user://art_audit/`.
- `tests/smoke_test.gd` asserts required art exists, the six-frame detailed leg sheet is active, all runner gifts have functional mechanics (including double jump, feather frenzy, and glide), every biome spawns its own obstacle atlas, primitive player meshes are hidden, and shop portraits/medals are populated.
