# Ostrich Dash gameplay art inventory

This is the production checklist for bringing every visible gameplay element up to the cute, polished 3D-rendered quality of `assets/generated/ostrich_dash_key_art.png` and the twelve biome vistas.

**Production status: complete.** Every replacement listed below is generated, integrated, and covered by the gameplay smoke test. Deterministic visual captures for all twelve biomes, matching obstacle families, effects, trip pose, and shop are produced by `tests/art_capture.gd`.

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
| `candy_carnival_vista.png` | Candy Carnival backdrop | New original generated vista |
| `volcano_valley_vista.png` | Volcano Valley backdrop | New original generated vista |
| `cloud_kingdom_vista.png` | Cloud Kingdom backdrop | New original generated vista |
| `savanna_sunrise_vista.png` | Savanna Sunrise backdrop | New original generated vista |
| `crystal_caverns_vista.png` | Crystal Caverns backdrop | New original generated vista |
| `moonbase_marathon_vista.png` | Moonbase Marathon backdrop | New original generated vista |

## Player and characters

| Visible object | Current render | Replacement |
| --- | --- | --- |
| Classic ostrich | Spheres, capsules, boxes, torus | Transparent polished rear-view runner sprite; front view in shop |
| Midnight skin | Primitive recolor | Matching rear-view midnight-purple runner sprite |
| Golden skin | Primitive recolor | Matching rear-view sunshine-gold runner sprite |
| Bubblegum skin | Primitive recolor | Matching rear-view candy-pink runner sprite |
| Aurora skin | None | Premium navy/violet portrait plus a violet-and-cyan gameplay color treatment |
| Emerald skin | None | Premium forest-green portrait plus a bright emerald gameplay color treatment |
| Sunset skin | None | Premium coral/tangerine portrait plus a warm sunset gameplay color treatment |
| Frost skin | None | Premium ice-blue/lavender portrait plus a glacier-blue gameplay color treatment |
| Celestial skin | None | Premium cobalt/cyan/gold portrait plus a starry gameplay color treatment |
| Rose Gold skin | None | Premium blush/champagne portrait plus a warm metallic gameplay color treatment |
| Electric Lime skin | None | Premium lime/charcoal portrait plus a high-energy gameplay color treatment |
| Royal Peacock skin | None | Premium teal/royal-purple portrait plus a jewel-toned gameplay color treatment |
| Rival runner | Pink spheres/capsules | Cute rear-view competitive pink emu/ostrich split into a body, two independently animated stride layers, and a planted shadow |
| Run motion | Primitive leg/wing swing | Generated six-frame rear-view leg/shoe sprite sheet with contact, push-off, passing, and mirrored stride poses, plus body bob, lean, and shadow |
| Jump/duck | Rigid sprite lift/squash that appeared to pass through hazards | Dedicated transparent rear-view avoidance poses: the jump tucks both feet fully above the hurdle and leaves a planted shrinking ground shadow; the duck bends both knees, plants both shoes, and folds the long neck into a pronounced S-curve beneath the gate. Crossfades hide the ordinary body/leg layers so duplicate limbs never show, while the collision capsule changes with the visible pose. |
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

Every biome uses a separate transparent six-cell obstacle atlas with the same collision-safe cell map. Beach hazards use surf and sand forms; Night uses neon; Desert uses sandstone; Snow uses ski gear; Jungle uses logs and ruins; Candy uses confectionery; Volcano uses basalt and lava; Cloud uses clouds and rainbows; Savanna uses carved timber and watering holes; Crystal uses gems; and Moonbase uses friendly space hardware. Classic retains the athletics training set.

Most feather trails remain on open lanes. Some obstacle patterns place high feathers across low hazards or low feathers beneath overhead hazards, so the entire trail is collected only by committing to the correct jump or duck. After 650 meters, occasional three-lane commitment rows block every lane with one consistent hazard family and use the same feather-height cue to telegraph the required action.

## Runner gifts, rewards, and effects

| Visible object | Current render | Replacement |
| --- | --- | --- |
| Guard gift | Text only | Puffy teal shield buddies orbit inside a luminous cyan protection shell for the entire active timer |
| Feather-pull gift | Text only | Horseshoe magnets orbit the runner inside a pink attraction aura for the entire active timer |
| Reflex gift | Text only | Friendly stopwatches orbit inside a lavender time-warp aura for the entire active timer |
| Rescue gift | Text only | Winged gold stars orbit inside a sunny crash-rescue aura for the entire active timer |
| Double-jump gift | Text only | A star buddy and bright aura signal that a second swipe or key press works in midair |
| Glide gift | Text only | Feather buddies surround the runner while airborne gravity is reduced |
| Feather-frenzy gift | Text only | Reward-pouch buddies signal double or triple feather pickup value |
| Peacock Miracle | Text only | A prestige aura combines double jump, feather pull, triple rewards, and continuous obstacle safety |
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
| Candy Carnival | None | Candy arches, balloons, sprinkle shrubs, and frosting clouds |
| Volcano Valley | None | Friendly lava caldera, basalt, ember palms, and festival pennants |
| Cloud Kingdom | None | Floating islands, cloud grandstands, rainbow arches, and golden flags |
| Savanna Sunrise | None | Golden acacia raceway and distant sunrise festival dressing in the complete vista |
| Crystal Caverns | None | Luminous crystal arena and mineral lakes in the complete vista |
| Moonbase Marathon | None | Lunar grandstands, habitat domes, and Earthrise in the complete vista |

## Track and ground surfaces

| Surface | Current render | Replacement |
| --- | --- | --- |
| Running track | Flat colored box | Twelve high-detail rubber/sand/ice/dirt/mineral/lunar materials, tiled at world scale, plus procedural lane markings |
| Side ground | Flat colored box | Twelve coordinated high-detail biome materials with mipmapped anisotropic filtering |
| Player grounding | None | Soft animated oval shadow |

## UI surfaces

| Screen/object | Current render | Replacement or polish |
| --- | --- | --- |
| Race dashboard | Unlabeled four-value bar | Three large labeled stat cards plus Tour/Stage, current biome, next-world distance, reward, and checkpoint progress |
| Runner gift bubble | Detached meter and tiny corner button | Animated floating gift bubble beside the runner with ability art, charge instructions, embedded meter, mobile “Tap to use” state, and a visible seconds-remaining readout while its matching world aura follows the ostrich |
| Skin shop cards | Pastel candy cards | Twelve large character portraits, colored portrait bubbles, chunky unlock/wear buttons, and a responsive scrolling 2-column phone layout |
| Biome medals | Medal bubble gallery | Twelve individually tinted, rounded badge bubbles with a readable earned-medal summary |
| Startup menu | Dimensional title menu | Oversized responsive glass card, extra-rounded candy controls, bundled readable type, clear CTA hierarchy, stat/loadout pills, and a quiet in-card Privacy & Data footer |
| Music control | None | Readable in-card Music On/Off pill sharing the footer row; its preference persists between launches |
| Panels/buttons | Flat dark StyleBox | Layered soft-glass panels, highlights, shadows, rounded color accents, bold embedded display font |
| Touch controls | Arrow text | Mobile remains swipe-only; desktop controls stay unobtrusive |
| Results/pause/toast | Celebration UI | Oversized selected-runner art, biome prize bubble, four pastel stat cards, readable highlight pill, and candy actions |

### Result-screen object inventory

| Object | Cute production treatment |
| --- | --- |
| Dimmed run backdrop | Keeps the finished track visible behind the celebration instead of replacing the game world |
| Celebration sheet | Large warm-cream card with thick aqua rim, deep soft shadow, and oversized rounded corners |
| Result headline | Coral-and-gold candy bubble with a readable personal-best/crash-specific message |
| Finish caption | Friendly reaction copy instead of technical collision terminology |
| Runner portrait | Large selected-skin character art inside a mint portrait bubble |
| Biome badge | Winged medal art inside its own golden prize bubble, including a visible Bronze target when still locked |
| Distance card | Blue pastel stat bubble with an oversized value |
| Score card | Purple pastel stat bubble with an oversized value |
| Feather card | Gold pastel reward bubble with an oversized run total |
| Personal-best card | Pink pastel stat bubble highlighting the long-term target |
| Run highlight | Mint pill showing the best dodge streak, near misses, or daily reward |
| Run Again action | Large coral/gold primary candy button |
| Back Home action | Large aqua secondary candy button |
| Global Scores action | Opens the native Google Play Games “Longest Dash” leaderboard when its release IDs are configured |

## Generated production asset set

The integration uses a small number of high-resolution transparent plates and atlases so mobile draw calls and package size remain controlled:

1. `runner_classic.png`
2. `runner_midnight.png`
3. `runner_golden.png`
4. `runner_bubblegum.png`
5. `runner_aurora.png`
6. `runner_emerald.png`
7. `runner_sunset.png`
8. `runner_frost.png`
9. `runner_celestial.png`
10. `runner_rose_gold.png`
11. `runner_electric_lime.png`
12. `runner_royal_peacock.png`
13. `rival_runner.png`
14. `runner_classic_back.png`
15. `runner_midnight_back.png`
16. `runner_golden_back.png`
17. `runner_bubblegum_back.png`
18. `rival_runner_back.png`
19. `runner_classic_body_back.png`
20. `runner_midnight_body_back.png`
21. `runner_golden_body_back.png`
22. `runner_bubblegum_body_back.png`
23. `runner_classic_duck_back.png`, `runner_midnight_duck_back.png`, `runner_golden_duck_back.png`, and `runner_bubblegum_duck_back.png`
24. `runner_classic_jump_back.png`, `runner_midnight_jump_back.png`, `runner_golden_jump_back.png`, and `runner_bubblegum_jump_back.png`
25. `obstacle_atlas.png` — 3×2 cells
26. `reward_power_atlas.png` — 3×2 cells
27. `biome_prop_atlas.png` — 3×2 cells
28. `effects_medals_atlas.png` — 3×2 cells
29. `surface_atlas.png` — 3×2 cells

The six original surface cells are also losslessly split into `gameplay/surfaces/` as recoverable sources. Runtime uses twelve separately generated production materials in `gameplay/surfaces/hd/`, including savanna earth, crystal floor, and moon dust, because Godot's 3D material sampler requires ordinary textures rather than atlas regions.

All generated files are stored under `assets/generated/gameplay/` and consumed by code. Existing procedural collision and movement logic remains authoritative even when its placeholder geometry is hidden.

The eight premium additions use newly generated front portraits in the store. On the track they reuse the proven rear body plate and generated six-pose leg cycle with distinct palette modulation, preserving the readable follow camera while keeping the Android package lean. Each of the twelve shop cards also names that ostrich's intrinsic gift and its progressively stronger duration, starting charge, and recharge rate.

## Wardrobe progression target

Classic remains free so every new player can run. The other eleven runners cost 25,000, 75,000, 150,000, 300,000, 500,000, 750,000, 1,000,000, 1,500,000, 2,250,000, 3,500,000, and 5,000,000 feathers. The complete collection costs 15,050,000 feathers, making every new runner a major long-term achievement even for skilled players who sustain the 9× pickup multiplier. The smoke test enforces twelve entries, strictly increasing paid prices, and the full prestige total to prevent accidental economy regressions.
