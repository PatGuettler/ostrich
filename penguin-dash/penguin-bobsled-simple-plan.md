# Build Plan: Penguin Dash

## 1. Game Concept

**Game name: Penguin Dash**

A single-lane endless runner. The penguin slides down an Olympic-style
bobsled track **belly-first** — flat on his stomach, flippers and feet
flailing/paddling loosely and semi-randomly as he slides for a fun,
out-of-control comic energy (not a stiff, controlled pose) — rather than
running or skating upright. Banked walls, curves, twists. As the track curves, the
penguin visually rides up and down the banked walls (like a real bobsled
run) purely as a visual/speed effect, not as separate lanes to steer
between. The player's only input is **tap to hop** over obstacles —
mainly sea lions lunging onto the track, plus ice chunks, gaps, gates,
etc. Hit an obstacle = run over. Score = distance traveled, optionally
plus fish collected along the way.

**Core loop:** slide down the curving track → obstacle appears → tap to
hop → keep going, track gets faster/curvier → die → see score → retry.

This is intentionally scoped down from the "15 penguins + shop" version —
one lane, one input, one obstacle-dodging mechanic. Much faster to build
and much easier to actually finish.

## 2. Input Model — Important
There is **no on-screen button of any kind**. The entire screen is the
input surface: a tap/click anywhere on the screen triggers the hop. No
visible UI element, no fixed "jump zone" — this should feel like a true
one-button game where the whole display is the button.

In Godot terms: this means listening for a general
`InputEventScreenTouch` / `_unhandled_input` tap anywhere on the
viewport (not a `Button` or `TouchScreenButton` node tied to a specific
screen region). Worth calling out explicitly to whoever builds this, since
it's a common default to accidentally add a corner jump button instead.

## 3. What "curving track" means mechanically
Important distinction: the curves are **not steering lanes** — the player
never moves left/right. Instead:
- The camera/track visually banks and curves (like a real bobsled chute),
  which is achieved by curving the 3D track mesh (or, in 2D, by shifting
  the horizon/background and tilting the player sprite) while the
  player's actual gameplay position stays effectively fixed to "on the
  track."
- This can be built as a **2D game with a fake-3D curving background**
  (much simpler, similar to how Subway Surfers-style games or old-school
  "tunnel" games fake curvature), or as an actual **3D track spline** in
  Godot if you want the wall-riding to look fully real.

**Recommendation for "simple":** build this in 2D first with a curving,
banking background and a tilting player sprite to sell the bobsled-curve
feeling, rather than jumping straight to a full 3D spline track. You can
upgrade to 3D later once the core hop mechanic is proven fun — the tap
mechanic and obstacle logic don't change either way, only the visual
presentation does.

## 4. Minimum Feature Set
- [ ] Penguin auto-slides forward down the track at increasing speed
- [ ] Track curves/banks visually (background + tilt), giving the
      "riding up and down bobsled walls" feel
- [ ] Tap = hop (simple up-arc jump, gravity-based) — the penguin
      briefly lifts off his belly into a small hop arc, then lands back
      down flat on his stomach to keep sliding, not on his feet
- [ ] Obstacles spawn ahead: sea lions (lunge/pop up), ice chunks, gates
- [ ] Collision = game over
- [ ] Distance-based score
- [ ] Restart flow
- [ ] Speed increases with distance

## 5. Stretch Features (only after the above is fun)
- Fish collectibles for bonus score
- 2-3 obstacle "personalities": sea lion lunges from the side wall,
  ice block sits center-track, gate requires precise timing
- Simple leaderboard (Google Play Games Services)
- A market/shop with two parts: expensive penguin upgrades that unlock
  real gameplay skills (steep cost curve, a genuine long-term goal), and
  a cheap, high-variety shorts wardrobe (100 color/pattern variants) for
  frequent cosmetic purchases — see Section 9.8 for full detail
- Sound/particles (ice spray on landing, splash if a sea lion "gets" you)

## 6. Obstacle Ideas (single-lane appropriate)
Since there's no left/right steering, every obstacle needs to be dodgeable
by **jump timing alone**:
- **Sea lion lunge** — pops up from the side wall onto the track, forcing
  a hop; could have a short "tell" animation (splash/bark) as a fairness cue
- **Ice block** — static obstacle, straightforward hop
- **Low ice arch / gate** — requires *not* jumping (duck) or jumping through
  a gap at the right height, if you want a secondary input; otherwise skip
  this one to keep it strictly one-button
- **Gap in the track** — hop across a missing section
- **Double sea lion** — two obstacles close together, testing a quick
  double-tap or jump timing (if using variable jump height)

Keeping every obstacle solvable with a single tap (not a duck+jump combo)
keeps this genuinely one-button, matching your "simple" goal.

## 7. Tech Recommendation
Godot 4.x still applies here — same reasoning as before (free, real
cross-platform, easy Android export), but the scope is now much smaller:
- 2D scene, not 3D
- One Player scene, one generic Obstacle scene with a type variable,
  one Spawner script
- No shop, no PenguinData resource system, no currency for the MVP.
  The penguin-upgrade market and shorts wardrobe (Section 9.8) come
  later and will need a `PenguinData` Resource (per-penguin cost/skill)
  plus a simple `ShortsData` Resource (per-variant color/pattern/price)
  once you get there — worth keeping this in mind for Stage 6's
  architecture even though it's not needed for the MVP.

This is a much smaller, more finishable project than the earlier plan.

---

## 8. Visual & Art Direction — "Alpine Poster" Style

The single biggest risk to this game feeling generic is shipping with
Godot's default look: default gray `Panel`/`Button` theme, default
system font, flat placeholder sprites left unpolished. **This section
exists to make sure that never happens** — every screen below should be
built against a custom style, not Godot's out-of-the-box theme.

### 8.1 The core idea
Most penguin runners on the Play Store use the same soft, rounded,
candy-colored flat-vector "mobile game" look. Instead, base this game on
**vintage Winter Olympics travel poster art** from the 1920s–1960s —
bold flat color blocks, strong diagonal compositions, geometric
sun/aurora-ray bursts, thick confident linework, a limited saturated
palette, and a fine halftone/paper-grain texture overlay for warmth. No
existing penguin runner uses this look — it's confident, distinctive,
and still simple enough to actually build and animate at small scope.

Call this the **"Alpine Poster"** style throughout the rest of this doc.

### 8.2 Color palette (keep it tight — 5 colors + white/black)
- **Glacier Blue** `#1B4B6B` — deep background sky/shadow tone
- **Ice Cyan** `#6FD8E8` — track ice, highlights, cool light
- **Ember Orange** `#F4692A` — obstacles, danger accents, CTA buttons
- **Snow Cream** `#F7F2E7` — UI panel background, snow highlights
  (never pure white — keeps the poster-paper warmth)
- **Midnight Navy** `#0E1F2E` — outlines, text, deep shadow
- **Gold Accent** `#E8B23D` — score numbers, medals, currency, rare highlights

Every screen pulls from this exact palette. No screen introduces a new
color outside this set — that consistency is what makes a small game
feel designed rather than assembled.

### 8.3 Typography
- Headers/scores: a bold, condensed, geometric display font (Art Deco /
  Olympic-scoreboard feeling — e.g. something like "Bebas Neue" or a
  similar free condensed display font, used in all-caps).
- Body/UI text: a simple rounded-but-sturdy sans (readable at small
  mobile sizes, not the display font at small scale).
- Never use Godot's default project font — import both fonts as a first
  step and set them in a custom `Theme` resource applied project-wide.

### 8.4 Texture & shading language
- Flat color fills (no gradients except sky backgrounds and aurora
  effects) with a **subtle screen-space grain/halftone overlay**
  (~5-8% opacity) over the whole game — this single shader/post-process
  effect does more to sell "designed art style" than almost anything
  else, and it's cheap to implement.
- Thick (3-4px at base resolution) dark navy outlines on all characters
  and foreground objects, poster-illustration style.
- No soft drop shadows or glassy bevels anywhere — flat poster shapes
  with hard-edged offset shadows instead (a shape duplicated, offset,
  and recolored navy — classic screen-print poster technique).

### 8.5 Sound identity (brief, ties into the look)
- A warm, slightly brassy/orchestral "Olympic fanfare" motif for
  menu/victory moments, not generic chiptune — reinforces the vintage
  Winter Games theme.
- Crunchy, physical ice/snow sounds for hops and landings — real texture,
  not cartoon "boing."

### 8.6 Background Music
Cute, memorable background music matters as much as the sound effects
for making this feel like a real, polished game rather than a tech demo.

- **Style:** a light, playful orchestral/brass "Winter Games" theme —
  think a small ensemble of woodwinds, glockenspiel/xylophone twinkles,
  and a bouncy pizzicato string or plucked-banjo rhythm underneath. Should
  feel warm and a little silly (a penguin sport, not a serious one),
  matching the vintage Olympic-poster charm rather than generic mobile
  chiptune loops.
- **Tempo should track gameplay speed:** as the run speeds up with
  distance, the music can subtly increase in tempo/energy (or crossfade
  into a slightly more intense variation of the same theme) so the music
  reinforces the difficulty ramp rather than staying static while
  everything else escalates.
- **Separate cues needed:**
  - Main menu loop — relaxed, a full statement of the theme, sets the
    charming tone before play starts
  - In-run loop — a tighter, slightly punchier variation of the same
    melody so it feels connected to the menu theme, not a different song
  - Game-over "medal ceremony" stinger — a short triumphant brass flourish
    on a new personal best, a gentler descending phrase on a normal
    "better luck next time" result
  - Market/leaderboard loop — a calmer, glockenspiel-forward variation,
    since these are browsing screens, not action screens
- **Keep loops short and seamless** (15-30 second seamless loops are
  standard for mobile) — this is a game played in 30-second bursts, so
  the music needs to loop cleanly without an awkward seam, more than it
  needs to be long.
- **Practical note for the build:** compose or source one core melodic
  theme and create the menu/in-run/market variations as re-arrangements
  of that same theme (different instrumentation/tempo/energy) rather than
  entirely separate songs — this keeps the whole game feeling like one
  cohesive piece of music, reinforces brand identity, and is far less
  work than writing 4 unrelated tracks.

---

## 9. Screen-by-Screen Design

### 9.1 Main Menu
- Full-bleed background: a poster-style illustration of the bobsled
  chute cutting diagonally across the screen under an aurora-streaked
  night sky (Glacier Blue sky, Ice Cyan aurora ribbons, geometric
  sunburst/starburst behind the title).
- Title treatment: game name set in the bold display font, arced
  slightly along the curve of the track behind it — like text on a
  vintage travel poster banner — in Snow Cream with a Midnight Navy
  outline and a small Gold Accent underline flourish.
- The penguin mascot lies belly-down center-low in a confident,
  ready-to-launch sliding pose (flippers braced back, chin up, the sled
  chute visible ahead), rendered in the same flat-poster illustration
  style as the background, not a cutout sticker sitting on top of it.
- Primary "PLAY" button: not a default rounded rectangle — style it as a
  **carved ice medallion / starting-gate flag shape** (a small pennant or
  shield silhouette) in Ember Orange with a Midnight Navy outline and
  bold Snow Cream label text.
- Secondary buttons (Leaderboard, Market, Settings) as smaller flag-
  pennant icons along the bottom edge, consistent shape family with the
  Play button but scaled down — never default square icon buttons.
- Subtle looping animation: aurora ribbons slowly drift, a snow-flurry
  particle layer drifts diagonally across the whole screen at low
  opacity — cheap, but makes the menu feel alive rather than a static image.

### 9.2 In-Game HUD / Objective Header (top of screen)
This is the "pretty header/box" you asked about — the goal is that the
player always knows the objective (go as far as possible, grab fish)
without it reading like a debug overlay.

- A single **horizontal ribbon banner** across the very top of the
  screen, styled like a fluttering ski-race pennant banner (flag-shaped
  notches at each end), in Snow Cream with a Midnight Navy outline,
  pinned to the top edge as if strung across the track like a race-start
  banner.
- Inside the ribbon, left-to-right:
  - A small flip-number **distance counter** styled like an analog
    scoreboard/odometer (dark navy digits on cream tiles, Gold Accent
    frame) — ticks up smoothly as the run progresses.
  - A small **fish icon + count**, fish icon drawn in the same flat
    poster style, count in the condensed display font.
- No extra text like "GO FAR / AVOID OBSTACLES" cluttering play — the
  objective should be taught in under 3 seconds by the first obstacle
  appearing, not explained in a text box. A single one-time tutorial
  overlay ("TAP TO HOP") can appear centered on the very first launch
  only, styled as a chalk/paint-stroke instruction on the ice itself
  (like a starting-line stencil), then never shown again.
- On a near-miss or fish grab, small Gold Accent particle bursts and a
  quick scale-pulse on the relevant HUD number — reinforces feedback
  without adding new UI elements.

### 9.3 Gameplay — Background & Track
- The track itself: carved Ice Cyan ice with visible **linear tool-marks**
  (like real bobsled ice grooves) running along its length, subtly
  brighter on the banked curve walls to sell the "riding up the wall" feel.
- Side walls of the chute rendered as thick poster-style ice blocks with
  hard navy outlines, slightly darker Glacier Blue in shadowed sections.
- Background beyond the track: layered parallax mountain silhouettes in
  flat Glacier Blue tones (2-3 depth layers scrolling at different
  speeds), aurora ribbons drifting slowly in Ice Cyan/Gold, and a
  scattered geometric star field — all rendered in the same flat poster
  language as the menu, so the whole game feels like one continuous
  illustration rather than "menu is pretty, gameplay is placeholder."
- Small environmental poster details scattered along the track edge for
  flavor (not obstacles): stylized crowd-barrier flags, a distant
  scoreboard tower, string-light bunting — Olympic-venue dressing that
  reinforces the theme without affecting gameplay.

### 9.4 Player Character — Sliding Animation
The penguin's belly-slide should feel loose, floppy, and a little
chaotic — this is a big part of the game's charm and comic energy, not
just a locomotion animation to get out of the way.

- **Flippers and feet move semi-randomly** while sliding, not in a
  fixed repeating cycle — think a loose, slightly wobbly flail, like the
  penguin is having a great time and not fully in control, rather than a
  disciplined athletic paddle stroke.
- **Implementation approach:** rather than one fixed looping animation,
  drive the flipper/foot movement with either (a) a small set of
  randomized animation frames/poses that get selected and blended at
  slightly randomized intervals, or (b) simple procedural motion (e.g. a
  noise function or randomized tween offsets driving flipper rotation)
  layered on top of the base sliding pose. Either approach avoids the
  "obviously looping" look a single fixed animation would have, which
  matters a lot at this scope since the player stares at this character
  for the entire run.
- **Speed should affect the flailing:** as the run speeds up with
  distance (Section 8.6 ties music tempo to this too), the limb movement
  can get slightly faster/more energetic, reinforcing the sense of
  building speed and mild chaos without needing new animation states.
- **Keep it readable, not distracting:** the flailing is a charm layer
  behind the actual gameplay-critical silhouette (the hop pose, the
  landing pose) — those two poses should stay clean and clear even while
  idle-slide limb motion is randomized, so hop timing never gets harder
  to read because a flipper happened to be mid-flail.

### 9.5 Obstacles & Collectibles — Character Design
- **Sea lion**: the star antagonist — chunky, flat-poster-illustrated,
  a rounded whiskered silhouette in a deep gray-blue (kept close to the
  Glacier Blue family so it reads as "belongs in this world," with Snow
  Cream belly and Ember Orange open-mouth "lunge" pose). Give it a clear
  wind-up frame (rearing back, whiskers flick) as the fairness "tell"
  before it lunges onto the track.
- **Ice block obstacle**: simple faceted Ice Cyan crystal shape with
  navy outline, small cracked-highlight detail — reads instantly as
  "solid, don't touch."
- **Fish collectible**: a small, cheerful, single-color-block fish (Gold
  Accent body, simple navy line details) with a soft idle bob/wiggle
  animation and a sparkle particle on collection — should read as
  unambiguously "good" against the sea lion's "bad" silhouette language.
- Keep a strict **silhouette read rule**: obstacles are angular/spiky or
  open-mouthed, collectibles are round/soft and gold-toned. Even
  colorblind or fast-glancing players should be able to tell danger from
  reward by shape alone.

### 9.6 Game Over Screen — "Medal Ceremony"
- Instead of a generic "YOU DIED" panel: a **podium/medal-ceremony**
  styled screen. The penguin stands on a small flat-poster podium shape,
  final distance shown as a "medal" — a Gold/Ice-Cyan/Ember circular
  badge (color depending on a simple performance tier: bronze/silver/gold
  distance thresholds) with the score in the display font at its center.
- "RETRY" as the primary pennant-flag button (same shape family as Play),
  "SHARE" as a secondary smaller icon button next to it for the
  one-tap share-score image mentioned in Section 10.
- A one-time confetti/snow-particle burst on new personal best, using the
  Gold Accent color specifically so "new record" always reads as a
  distinct, special moment.

### 9.7 Leaderboard Screen
- Styled as a **scoreboard tower** — like the physical results board at
  an Olympic venue: a tall Midnight Navy board with rows of Snow Cream
  flip-tiles, rank number in Gold Accent on the left, player name and
  distance in the condensed display font.
- The player's own row (if visible on the current page) gets a subtle
  Ice Cyan highlight background band so it's instantly findable without
  needing a separate "your rank" callout box.
- Toggle between **Global** and **Friends** (see Section 10's retention
  point on friends leaderboards) as two small pennant-tab buttons at the
  top of the board, same shape family as menu buttons — not default
  Godot `TabContainer` tabs.
- Top 3 rows get small medal icons (gold/silver/bronze circular badges,
  same badge style as the game-over medal) instead of plain "1, 2, 3" —
  reinforces the Olympic framing everywhere consistently.

### 9.8 Market / Shop Screen
This version of the market is a real currency sink with two distinct
sections, since better penguins should feel like a genuine long-term
goal rather than a quick unlock — while the shorts are a lighter,
high-variety cosmetic layer players can dip into early and often.

**A. Penguin Upgrades (expensive, progression-driving)**
- Framed as an **"Athlete Roster"** board — a row of poster-style
  penguin portrait cards, styled like Olympic team ID cards (Snow Cream
  card stock, Midnight Navy border, a small event-flag icon in the
  corner).
- Each new penguin should be **meaningfully and steeply more expensive**
  than the last — this is intentional: cheap unlocks feel disposable,
  expensive ones feel like an achievement. Suggested cost curve is
  exponential rather than linear (e.g. roughly 3-5x the previous
  penguin's cost each tier), so the top-tier penguin represents dozens
  of serious runs of fish-collecting, not a couple of lucky attempts.
- Give each unlockable penguin a real, distinct skill so the steep price
  feels justified by a genuine gameplay benefit, not just a reskin. Full
  15-penguin roster and skills below.

**Full Penguin Roster (15) — build all at once, priced on an exponential
curve from cheapest to most expensive:**

| # | Name | Skill | Playstyle effect |
|---|---|---|---|
| 1 | **Waddles** (Starter) | None — baseline stats | The default athlete, free from the start |
| 2 | **Glider** | Tap again while airborne (single or multiple extra taps) to flutter and extend hang time | Player actively controls how long they stay up — great for clearing wide gaps, but landing timing stays in the player's hands rather than being auto-shifted |
| 3 | **Featherweight** | Lower gravity, higher jump arc | Floatier control, better vertical clearance |
| 4 | **Magnet** | Pulls nearby fish toward it automatically | Boosts fish income for faster future unlocks |
| 5 | **Lucky** | Fish worth +50% currency | Faster overall progression, no survival benefit |
| 6 | **Turbo** | Hold-to-boost briefly increases slide speed | Risk/reward — faster but harder to react |
| 7 | **Shield** | Survives one obstacle hit per run | Forgiving of a single mistake |
| 8 | **Ninja** | Short tap-triggered dash with brief invincibility | Precision tool for tight obstacle clusters |
| 9 | **Tank** | Smashes through small obstacles without dying | Simplifies early obstacle types |
| 10 | **Ice Skater** | Higher base slide speed from the start | Higher risk, higher score ceiling |
| 11 | **Bubble** | Periodic regenerating shield (~every 20s) | Sustained survivability on long runs |
| 12 | **Golden** | +25% currency from all sources | Best "economy" pick, snowballs future unlocks |
| 13 | **Comet** | Highest top speed, fastest acceleration | Hardest to control, highest skill ceiling |
| 14 | **Rocket** | Limited jetpack burst flies over an entire obstacle row, recharges over distance | Strategic "get out of danger" tool |
| 15 | **Cosmic** (Legendary) | Small combined bonus: modest speed, air time, currency, and 1 free hit | Capstone reward for reaching the top of the roster |

Cost curve suggestion: exponential, e.g. Glider priced low, Cosmic priced
at the very top of what a dedicated player could realistically save
toward — each tier meaningfully more expensive than the last so climbing
the roster feels like a real achievement, not a shopping list.

**Critical constraint — jump-affecting skills must never cause "bad
landings":** Any skill that changes jump trajectory or air time needs to
avoid silently landing the penguin on an obstacle it was trying to
clear — this would read as the upgrade punishing the player rather than
rewarding them.

- **Active/player-controlled skills (preferred approach — this is why
  Glider is designed as a tap-to-flutter skill rather than a passive
  longer hang time):** if the player triggers extra hang time themselves
  via additional taps while airborne, the landing point stays under
  their control and reaction, not something the game silently changes
  underneath them. This sidesteps the whole problem for that skill —
  the player can choose *not* to flutter if an obstacle is coming up
  fast, exactly like a normal jump-timing decision. Apply this same
  "player must actively trigger it" pattern to any other jump-modifying
  skill where possible.
- **Passive/automatic skills (e.g. Featherweight's lower gravity, higher
  arc):** these change trajectory without the player choosing to, so
  they still need a safety guarantee from the obstacle spawner itself.
  Two ways to guarantee it, and the spawner should implement whichever
  fits the build:
  - **Obstacle-spacing side:** generate obstacle gaps based on the
    *widest* possible jump arc among all penguins (not just baseline),
    so no penguin's automatic trajectory can ever land inside a gap
    that's too short for it.
  - **Landing-safety check:** have the spawner query the penguin's
    actual predicted landing point for passive-trajectory skills and
    guarantee clear track there before placing the next obstacle.

Either way, this needs explicit playtesting once Glider and
Featherweight are implemented in Stage 6 — test Glider's flutter timing
window and Featherweight's arc against the full obstacle set
specifically, not just against the baseline penguin.

- Locked penguin cards show a frosted-ice silhouette (same treatment as
  Section 9.8's original locked-item styling) with the price in Gold
  Accent beneath — displayed as a hard number so the cost feels real
  and weighty, not vague.
- Selecting/equipping a penguin uses the same Gold "EQUIPPED" ribbon
  banner treatment as other equip states in this doc, for consistency.

**B. Shorts Wardrobe (cheap, high-variety cosmetic)**
- Every penguin wears a pair of **short shorts** as their signature
  competition gear — this is the wardrobe customization layer.
- **100 total color/pattern variants** to collect, displayed as a dense
  swatch grid (like a folded-shorts drawer or a rack of team uniforms)
  rather than 100 individual large cards — small square swatches with a
  navy outline, each showing the actual shorts shape filled with its
  color/pattern.
- To make 100 variants achievable without needing 100 hand-authored art
  assets: build **one shorts silhouette** (the short-shorts shape with a
  simple waistband line and side stripe detail) and generate the 100
  variants procedurally from a shared palette/pattern system, e.g.:
  - ~40 solid colors across the Alpine Poster palette family plus
    complementary hues (kept harmonious with the game's overall look —
    avoid colors that clash with the established 5-color system)
  - ~30 two-tone variants (base color + side-stripe accent color, like
    real athletic shorts)
  - ~20 pattern variants (polka dot, chevron, star, flag-stripe —
    simple flat repeating patterns that read at small size)
  - ~10 "rare/special" variants (metallic gold, aurora-gradient,
    a small trophy-star print) priced higher and used as prestige/
    achievement rewards
  This means the art team builds one clean shape + a handful of pattern
  masks, and color/pattern combinations do the rest of the work —
  practical for an indie scope while still hitting 100 real items.
- Shorts should be **cheap relative to penguin upgrades** — priced to be
  bought casually after a single good run, so this layer stays
  satisfying and frequent even while the player is saving up for the
  next expensive penguin. This dual pacing (slow expensive goal +
  frequent cheap rewards) is a deliberate retention mechanic: it gives
  players something to spend on immediately even during a long savings
  grind toward the next penguin.
- Equipped shorts show on the penguin everywhere — main menu idle pose,
  in-game sprite, and the game-over medal-ceremony podium — so a cosmetic
  purchase is visible across the whole game, not just in the shop.

**Practical build note:** because shorts are purely a recolored/
patterned overlay on one shared sprite, this can be implemented as a
single shader or per-instance color/pattern parameter rather than 100
separate sprite files — worth specifying this to whoever builds it so
the art pipeline doesn't balloon.



### 9.9 Ad Bar (banner ads)
A persistent banner ad anchored to the bottom edge of the screen,
present during core gameplay and menu screens.

- **Placement:** fixed to the bottom of the screen, standard mobile
  banner size (320x50 or adaptive banner), never overlapping the tap
  input area used for hopping — leave a safe margin above the ad bar so
  an accidental tap near the bottom doesn't hit an ad instead of
  triggering a jump.
- **Visual integration:** rather than a jarring raw ad unit sitting on
  top of the Alpine Poster art, frame it with a thin Midnight Navy
  border strip matching the game's outline weight, so it reads as part
  of the screen's "frame" rather than a foreign overlay. The ad content
  itself can't be restyled, but the border/frame around it can match.
- **Where it shows:** menu, market, leaderboard, and game-over screens
  are natural fits for a banner. For live gameplay, consider whether a
  banner during the run is worth the screen space and mild distraction
  risk versus only showing it on menu/game-over/market screens — a
  banner competing for attention during split-second obstacle timing
  could hurt the "just one more run" feel this game depends on for
  retention (Section 10). Worth deciding deliberately rather than
  defaulting to "always on."
- **Network/SDK:** Google AdMob is the standard choice for Android
  banner ads and integrates with Godot via a community plugin
  (`godot-admob` or similar) — worth checking current plugin
  compatibility with your Godot version when you get to this stage.
- **Respect required screen space:** make sure the ad bar height is
  accounted for in the Section 9.2 HUD layout and in the overall canvas
  scaling setup, so it doesn't overlap or get overlapped by the
  in-game ribbon banner or obstacles near the bottom of the track.

---

## 10. What Would Make This Attract More Players
Mechanically simple games like this live or die on feel, theme, and
retention hooks — not on adding more systems. Worth building these in
deliberately rather than as an afterthought.

**Hook (first 10 seconds)**
- Nail the "bobsled slam" feel: screen shake, a satisfying camera bank
  into curves, chunky sound + haptic feedback on hop and near-misses.
  Simple mechanics succeed on juice (see Flappy Bird, Crossy Road), not
  depth.
- Make the sea lion a character, not just a hazard — a memorable lunge
  animation and a "gotcha" bark/sound on catching the penguin gives
  players something to talk about and screenshot/clip.

**Differentiation (why pick this over the many existing penguin runners)**
- The bobsled-bank visual and Alpine Poster art style (Section 8) are
  genuinely rare in this space — lean hard into full Olympic
  presentation: track flags, crowd noise/cheering, the medal-ceremony
  game-over screen instead of a generic death screen.
- A consistent, charming visual identity matters more than mechanical
  depth at this scope. Most successful ultra-simple runners win on
  charm, not features.

**Retention loop (why people come back)**
- Daily streak or "beat yesterday's run" framing shown on app open, even
  without a shop/currency economy.
- Friends leaderboard, not just a global one — global leaderboards feel
  unbeatable after week one; friend leaderboards keep people checking
  back to reclaim the top spot.
- Keep session length matched to how this genre actually gets played:
  short 30-second bursts. Death-to-restart must be one tap with zero
  loading friction — no menus in the way of "just one more run."

**Distribution / discoverability**
- ASO (App Store Optimization): title, icon, and first screenshots
  should immediately show the bobsled-track + sea-lion hook and the
  distinctive poster art style — that's the differentiator versus the
  dozens of generic "penguin runner" listings, so lead with it rather
  than burying it.
- Design a few obstacle moments as intentional "near-miss" beats (sea
  lion lunges just past the penguin) — these are exactly the kind of
  dramatic close-call clips that perform well on TikTok/Reels/Shorts.
  Worth tuning obstacle timing with shareability in mind.
- Add a one-tap "share your score" image on the game-over screen —
  free word-of-mouth distribution, low build cost.

**Practical takeaway for the build order:** none of this requires new
gameplay systems — it folds into Stage 4 (Score + polish pass) and
Stage 5 (Leaderboard) below. Add a "Stage 4.5 — Juice & Theme pass"
focused specifically on screen shake, sound, sea lion personality, and
the Olympic presentation layer before considering the game done, since
this is where a simple mechanic becomes an actually attractive game
rather than a generic clone.

## 11. Staged Build Order

**Stage 1 — Slide + hop + curve feel**
Player auto-slides belly-down (flat sliding pose, not standing/running),
tap to hop with gravity, background scrolls with a curving/banking
pattern (sine-wave style track curvature) and the player sprite tilts to
match. No obstacles yet — just confirm the "bobsled feel" reads correctly
before adding danger. Placeholder art is fine here.

**Stage 2 — Obstacles + collision + game over**
Spawn sea lions and ice blocks ahead on the track, collision detection,
game over + restart. Still placeholder art.

**Stage 3 — Difficulty ramp**
Speed and obstacle frequency increase with distance; introduce obstacle
variety (sea lion lunge timing, gaps) in stages rather than all at once.

**Stage 4 — Score + core polish pass**
Distance score, best-score local save, the ribbon-banner HUD from
Section 9.2, basic sound effects and hop/land animation polish.

**Stage 4.5 — Art direction & theme pass**
Build the custom Godot `Theme` resource (fonts, colors from Section 8.2,
no default panels/buttons), replace all placeholder art and UI with the
Alpine Poster style across every screen in Section 9 (menu, HUD, game
over, leaderboard, market), add the grain/halftone post-process shader,
implement sea lion personality animation, the medal-ceremony game-over
screen, and the background music cues from Section 8.6 (menu, in-run,
market, and game-over stinger variations).

**Stage 5 (optional) — Leaderboard**
Google Play Games Services integration for global + friends "furthest
distance" leaderboards, styled per Section 9.7, once the core game is
fun and stable.

**Stage 6 — Penguin market & shorts wardrobe (build in full)**
Athlete Roster screen with all 15 penguins from Section 9.8 at their full
exponential price curve, plus the complete 100-variant Shorts Wardrobe
built on the procedural color/pattern system so it doesn't require 100
hand-drawn assets. This is the biggest scope item in the whole plan —
build the `PenguinData` and `ShortsData` Resource architecture first
(one resource file per item, read generically by the shop UI) so adding
all 15 penguins and all 100 shorts is a data-entry task rather than 115
separate pieces of custom logic. When implementing Glider, build it as
an active tap-to-flutter skill (extra taps while airborne extend hang
time) rather than a passive stat change — this keeps landing timing in
the player's control. For Featherweight's passive arc change, apply the
landing-safety constraint from Section 9.8 and playtest against the
actual obstacle spacing before considering it done.

**Stage 7 (optional) — Ad integration**
Integrate AdMob (or chosen network) for the bottom banner ad bar from
Section 9.9, sized and placed with a safe margin above the tap-to-hop
input zone. Decide during this stage whether the banner shows during
live gameplay or only on menu/game-over/market screens — test both for
impact on session length and retry rate before locking in, since this
directly affects the "just one more run" retention loop in Section 10.

## 12. Suggested First Prompt to Claude Code
> "I'm building a simple 2D Godot 4 mobile game called Penguin Dash: a
> penguin slides belly-first down a single-lane bobsled-style track that
> curves and banks left/right visually (like a real bobsled run), while
> the player only taps anywhere on the screen to hop over obstacles — no
> left/right steering, no on-screen buttons. Let's build in stages.
> Start with Stage 1 only: the auto-slide movement (belly-down sliding
> pose), tap-to-hop physics, and a scrolling background/track that
> curves and banks to sell the bobsled feeling, using placeholder art.
> No obstacles yet."

Then work through Stages 2–6 one at a time, testing on an actual Android
device after each stage. Save the art-direction pass (Stage 4.5) for
after the core mechanic is proven fun — don't front-load art before the
gameplay is validated.
