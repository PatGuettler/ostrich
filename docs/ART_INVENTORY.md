# Ostrich Dash gameplay art inventory

This is the production checklist for bringing every visible gameplay element up to the cute, polished 3D-rendered quality of `assets/generated/ostrich_dash_key_art.png` and the six biome vistas.

**Production status: complete.** Every replacement listed below is generated, integrated, and covered by the gameplay smoke test. Deterministic visual captures for all six biomes, obstacle families, effects, trip pose, and shop are produced by `tests/art_capture.gd`.

## Art direction anchor

- Premium family-friendly animated-film 3D rendering
- Lovable toy-like silhouettes with expressive faces where appropriate
- Soft rounded forms, tactile feather/fabric/rubber/paint textures
- Teal, coral, sunshine yellow, cream, and midnight-blue core palette
- Warm rim light, clean readable values, and no text/logos/watermarks inside generated assets
- Gameplay runners face away from the third-person follow camera; front-facing character plates remain available for portraits and menus

## Existing generated images

| Existing image | Current use | Decision |
| --- | --- | --- |
| `ostrich_dash_key_art.png` | Home screen | Keep; master style reference |
| `ostrich_dash_icon.png` | App/launcher icon | Keep; face and character reference |
| `ui/ostrich_dash_menu_logo.png` | Startup title crest | Keep; transparent, phone-readable generated branding |
| `classic_stadium_vista.png` | Classic backdrop | Keep |
| `classic_stadium_crowd.png` | Former side-grandstand layer | Retain as source art but do not render; the complete vista already contains the crowd |
| `beach_track_vista.png` | Beach backdrop | Keep |
| `night_games_vista.png` | Night backdrop | Keep |
| `desert_circuit_vista.png` | Desert backdrop | Keep |
| `snow_games_vista.png` | Snow backdrop | Keep |
| `jungle_track_vista.png` | Jungle backdrop | Keep |

## Player and characters

| Visible object | Current render | Replacement |
| --- | --- | --- |
| Classic ostrich | Spheres, capsules, boxes, torus | Transparent polished rear-view runner sprite; front view in shop |
| Midnight skin | Primitive recolor | Matching rear-view midnight-purple runner sprite |
| Golden skin | Primitive recolor | Matching rear-view sunshine-gold runner sprite |
| Bubblegum skin | Primitive recolor | Matching rear-view candy-pink runner sprite |
| Rival runner | Pink spheres/capsules | Cute rear-view competitive pink emu/ostrich split into a body, two independently animated stride layers, and a planted shadow |
| Run motion | Primitive leg/wing swing | Two independently masked high-detail leg/shoe layers pivot from the hips with alternating extension, recovery lift, depth, body bob, lean, and shadow |
| Jump/duck | Bone-like primitive transforms | Sprite lift/squash/tilt while preserving collision behavior |
| Trip/gate flip/spin | Whole primitive rig rotation | Forward stumble for low hits, one neck-pivot revolution over gates, and a separate airborne spin using finished character art |

## Obstacles and pickups

| Visible object | Current render | Replacement |
| --- | --- | --- |
| Foot-level wall/hurdle | Two boxes | Padded colorful athletics hurdle |
| Overhead bar | Three boxes | Cute striped limbo/training gate |
| Traffic cone | Cone and box | Soft toy-like safety cone |
| Drone | Sphere, bars, torus rotors | Friendly expressive referee drone |
| Slippery patch | Flattened transparent sphere | Glossy splash-shaped puddle |
| Feather collectible | Capsule and box | Glowing cream-and-gold feather |

## Power-ups, rewards, and effects

| Visible object | Current render | Replacement |
| --- | --- | --- |
| Shield | Text only | Puffy teal shield icon |
| Magnet | Text only | Horseshoe magnet with feather sparkles |
| Slow-Mo | Text only | Friendly stopwatch icon |
| Score Rush | Text only | Winged gold star/score burst icon |
| Collision burst | Primitive capsules | Feather/dust/sparkle effect sprites |
| Bronze/Silver/Gold medals | Text only | Cute winged medal badges |

## Environment foreground

| Biome | Current foreground | Replacement cluster |
| --- | --- | --- |
| Classic Stadium | Primitive poles, flags, rails, lights | Single complete stadium vista; no duplicate foreground plates |
| Beach Track | Flat water, capsule palms | Palm, surfboard, flowers, pennants |
| Night Games | Capsule poles and sphere lamps | Neon floodlight, glowing pennants, star lights |
| Desert Circuit | Flattened rocks and primitive cactus | Rounded canyon rocks, flowering cactus, windsock |
| Snow Games | Flattened snow and cone trees | Puffy snowbank, frosted pine, lantern, pennants |
| Jungle Track | Capsule trunks and sphere leaves | Ruin stone, broad leaves, orchids, bamboo pennants |

## Track and ground surfaces

| Surface | Current render | Replacement |
| --- | --- | --- |
| Running track | Flat colored box | Six 1254×1254 high-detail rubber/sand/ice/dirt materials, tiled at world scale, plus procedural lane markings |
| Side ground | Flat colored box | Six coordinated high-detail biome materials with mipmapped anisotropic filtering |
| Player grounding | None | Soft animated oval shadow |

## UI surfaces

| Screen/object | Current render | Replacement or polish |
| --- | --- | --- |
| HUD feather count | Diamond character | Feather art icon |
| Power button | Text-only button | Matching power icon plus text/state |
| Skin shop cards | Solid color swatches | Actual character skin portraits |
| Biome medals | Single text line | Bronze/silver/gold badge art and clearer cards |
| Startup menu | Basic text title and generic stacked controls | Generated dimensional title crest, bundled Noto Sans Display type, bold CTA hierarchy, stat/loadout chips, and responsive glass card |
| Panels/buttons | Flat dark StyleBox | Layered soft-glass panels, highlights, shadows, rounded color accents, bold embedded display font |
| Touch controls | Arrow text | Mobile remains swipe-only; desktop controls stay unobtrusive |
| Results/pause/toast | Flat modal panels | Same polished panel language with small character/reward art accents |

## Generated production asset set

The integration uses a small number of high-resolution transparent plates and atlases so mobile draw calls and package size remain controlled:

1. `runner_classic.png`
2. `runner_midnight.png`
3. `runner_golden.png`
4. `runner_bubblegum.png`
5. `rival_runner.png`
6. `runner_classic_back.png`
7. `runner_midnight_back.png`
8. `runner_golden_back.png`
9. `runner_bubblegum_back.png`
10. `rival_runner_back.png`
11. `runner_classic_body_back.png`
12. `runner_midnight_body_back.png`
13. `runner_golden_body_back.png`
14. `runner_bubblegum_body_back.png`
15. `obstacle_atlas.png` — 3×2 cells
16. `reward_power_atlas.png` — 3×2 cells
17. `biome_prop_atlas.png` — 3×2 cells
18. `effects_medals_atlas.png` — 3×2 cells
19. `surface_atlas.png` — 3×2 cells

The six surface cells are also losslessly split into `gameplay/surfaces/` as recoverable sources. Runtime uses the separately generated 1254×1254 production materials in `gameplay/surfaces/hd/` because Godot's 3D material sampler requires ordinary textures rather than atlas regions.

All generated files are stored under `assets/generated/gameplay/` and consumed by code. Existing procedural collision and movement logic remains authoritative even when its placeholder geometry is hidden.
