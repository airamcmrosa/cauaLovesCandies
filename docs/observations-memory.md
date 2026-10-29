---
title: Active Observations Memory
status: Living Memory
schema_version: 1.0.0
indexed_by: AGENTS.md
---

# Active Observations Memory

Lean, append-only registry of non-blocking observations (INFO / WARNING). Blocker items (CRITICAL / ERROR) are strictly prohibited here and must be resolved prior to artifact approval. Resolved items move to `docs/history/resolved-observations.md`.

## Observation Index

| ID | Severity | Category | Target Artifact | Status | Short Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `OBS-001` | WARNING | OPERABILITY_NFR | `.github/workflows/deploy.yml` | Open | GitHub Pages deploy workflow referenced in architecture but not created |
| `OBS-003` | INFO | MAINTAINABILITY | `.kiro/skills/new-adr/`, `.kiro/reference/` | Open | Legacy content from the previous project (ADR skill, PIT-002/003, pending observations) |
| `OBS-005` | INFO | OPERABILITY_NFR | `.claude/agents/` | Open | Custom sub-agent types load only at session start; fallback is general-purpose |
| `OBS-006` | INFO | MAINTAINABILITY | repo root, `.gitignore` | Open | Stray files (`.gitignore copy`, `.idx/`) and local folder name mismatch |
| `OBS-007` | INFO | ASSET_BUDGET | `assets/images/caua_mouth_*.webp`, `assets/images/README.md` | Open | Placeholder Caua sprites are 512x512 and the README CC0 header does not cover them |
| `OBS-008` | WARNING | PERFORMANCE_NFR | `build/web`, `assets/music/` | Open | Release build is 45 MB (canvaskit 36 MB, template music now one 1.6 MB track); 3.5 MB payload and 3 s 4G budgets unmeasured |
| `OBS-009` | INFO | MAINTAINABILITY | `lib/game/components/caua_player_component.dart` | Open | Sprite is assigned in both `onLoad` and `onMount`; one resync would suffice |
| `OBS-010` | WARNING | LIFECYCLE | `lib/game/caua_candies_game.dart` | Open | Game disposes an injected `MouthController`; ownership should be tracked |
| `OBS-011` | INFO | ERROR_HANDLING | `lib/game/caua_candies_game.dart` | Open | `images.loadAll` failure is unhandled and leaves a blank screen |
| `OBS-012` | INFO | UX_KIDS | `lib/game/caua_game_screen.dart` | Open | Back button overlay on the game screen can be hit by a child during play |
| `OBS-013` | INFO | DESIGN | `lib/game/projection.dart` | Open | Projection pixel constants (y 1180/400, x 360) are placeholders |
| `OBS-014` | INFO | DESIGN | `lib/game/managers/phase_config.dart` | Open | Phase 3 composition (25/30/45) is a product-owner value, may be retuned |
| `OBS-015` | INFO | MAINTAINABILITY | `lib/game/managers/game_manager.dart` | Open | `level` and `state` are plain fields, not `ValueNotifier`s |
| `OBS-016` | WARNING | LICENSING | `assets/images/README.md` | Open | AI-generated art and logo have no formally documented license |
| `OBS-017` | INFO | ASSET_BUDGET | `assets/music/tropical_fantasy.mp3` | Open | BGM is 1.65 MB of the 2.4 MB asset payload; re-encode at 64-96 kbps |
| `OBS-018` | INFO | DESIGN | `assets/images/game/belt_tile.webp` | Open | Delivered belt sprite (body ~#C8B0E8, arrows ~#7858B8) differs slightly from the approved hex (#BFA6EC, #8F72D6) |
| `OBS-019` | WARNING | PERFORMANCE_NFR | `lib/game/managers/asset_preloader.dart` | Open | Default `Images()` is a private cache, so preloaded sprites are not shared with the game (AC5) |
| `OBS-020` | INFO | PERFORMANCE_NFR | `lib/game/managers/asset_preloader.dart` | Open | Preload is sequential (slower on 4G than parallel); `dispose()` is not idempotent |
| `OBS-023` | INFO | UX_KIDS | `lib/audio/audio_controller.dart` | Open | Mobile browsers usually reject the first `play()`; retry only works if T4/T5 call `unlockAndStartMusic()` on first tap |
| `OBS-024` | INFO | ERROR_HANDLING | `lib/audio/audio_controller.dart` | Open | SFX `play()` and music `pause()` are not awaited or caught; `playSfx` doc comment is inverted |
| `OBS-028` | INFO | UX_KIDS | `lib/ui/title_screen.dart` | Open | Failed state has no message and a null `onRetry` leaves no way out; 48 px settings spacer may overflow below about 330 px height |
| `OBS-029` | INFO | UX_KIDS | `lib/ui/play_button.dart` | Open | White on #E5609D is about 3.4:1 contrast, passes only the large-text criterion |
| `OBS-035` | INFO | UX_KIDS | `lib/ui/title_logo.dart` | Open | Logo is about 25% narrower at 360 px width to clear the candy lanes; clearance is only 3.6 px at 320 px |
| `OBS-036` | INFO | ERROR_HANDLING | `lib/audio/audio_controller.dart` | Open | Futures of pause, stop and dispose are not awaited or handled; a platform failure would be an unhandled async error |
| `OBS-037` | INFO | MAINTAINABILITY | `lib/ui/bobbing_avatar.dart` | Open | `CurvedAnimation` in `BobbingAvatar` is never disposed |
| `OBS-021` | INFO | MAINTAINABILITY | `lib/game/components/conveyor_belt_component.dart` | Open | `baseSpeed`, `halfWidthBottom`, `stripeCount` live in the component, outside `projection.dart` / `phase_config.dart` |
| `OBS-025` | INFO | PERFORMANCE_NFR | `lib/game/components/item_spawner_component.dart` | Open | Spawner creates a new `FoodItemComponent` per spawn (no pooling); restart does not reset `_elapsed` |
| `OBS-026` | INFO | TEST_COVERAGE | `lib/game/components/item_spawner_component.dart` | Open | No test for the not-spawning-when-not-playing path; `GameState` only has `playing` today |
| `OBS-030` | INFO | MAINTAINABILITY | `lib/game/item_sprites.dart` | Open | `itemSpriteAssetList` is a manual copy of `itemSpriteAssets`; 16 item types share 9 sprites (banana looks like the grape) |
| `OBS-031` | INFO | TEST_COVERAGE | `lib/audio/audio_controller.dart` | Open | Mute handling inside `AudioController.playSfx` is not covered by `sounds_test.dart` |
| `OBS-039` | WARNING | UX_KIDS | `lib/game/caua_game_screen.dart` | Open | Game screen layout, sky vs belt harmony and ingest tween are unchecked on real phones; the original tiny-view root cause was never reproduced, only mitigated |
| `OBS-040` | INFO | MAINTAINABILITY | `lib/game/components/food_item_component.dart` | Open | One-frame position jump at the decision (y 522 to 515); the item stays 0.15 s in the tree during the tween; not asserted in tests |
| `OBS-043` | WARNING | UX_KIDS | `lib/audio/sounds.dart` | Open | `hmm` and `eurk` play at volume 1.0 versus 0.4 for other SFX (about 8 dB jump) and `hmm` plays on every good item |
| `OBS-032` | INFO | ERROR_HANDLING | `lib/ui/error_reporter.dart` | Open | Error messages are logged verbatim (local only); no fallback if `ErrorScreen` itself throws |
| `OBS-041` | WARNING | ERROR_HANDLING | `lib/ui/error_reporter.dart` | Open | `buildErrorWidget` does not check `hasError`; a throwing `ErrorScreen.build` could loop; the try/catch around the const `ErrorScreen` is dead code |
| `OBS-042` | INFO | ERROR_HANDLING | `lib/ui/error_reporter.dart` | Open | `ErrorFallback` has no reload button or `DefaultTextStyle` and is practically unreachable |
| `OBS-038` | INFO | ASSET_BUDGET | `assets/images/caua/` | Open | The three normalized Caua frames use webp quality 78 (not 85) to stay under 30 KB each |

---

## Detailed Items

### `OBS-001`
* **Severity:** WARNING
* **Category:** OPERABILITY_NFR
* **Target:** `.github/workflows/deploy.yml`
* **Source:** `manual / repo rename review`
* **Status:** Open
* **Finding:** `docs/architecture/architecture.md` section 6 describes a GitHub Actions deploy to GitHub Pages with `--base-href "/cauaLovesCandies/"`, but no `.github/workflows/` exists.
* **Risk/Impact:** No automated static delivery; base-href is only validated by hand.
* **Resolution Trigger:** Story or task that implements CI/CD and Pages deployment.

### `OBS-003`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `.kiro/skills/new-adr/`, `.kiro/reference/pitfalls/`, `.kiro/reference/pending/`
* **Source:** `manual / agent roster adaptation`
* **Status:** Open
* **Finding:** These files still describe the previous project (ADRs, `apps/dashboard`, .NET tiers, a separate pending-observations file duplicating this registry).
* **Risk/Impact:** Conflicting governance sources; agents may follow obsolete rules.
* **Resolution Trigger:** Dedicated cleanup task: remove or rewrite them and keep this file as the single registry.

### `OBS-005`
* **Severity:** INFO
* **Category:** OPERABILITY_NFR
* **Target:** `.claude/agents/`
* **Source:** `manual / DEP-1 delegation`
* **Status:** Open
* **Finding:** Agents defined mid-session (for example `flutter-dev`) cannot be invoked by `subagent_type` until the Claude Code session restarts.
* **Risk/Impact:** Delegation silently falls back to a general-purpose agent with the role rules in the brief.
* **Resolution Trigger:** First session started after this PR merges; confirm `flutter-dev` resolves by name.

### `OBS-006`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** repo root, `.gitignore`
* **Source:** `manual / .gitignore review`
* **Status:** Open
* **Finding:** Untracked `.gitignore copy` and `.idx/`; `.gitignore` carries a stray `.README copy.md` entry; the local folder is still named `cauaLoveCandies` while the repository is `cauaLovesCandies`.
* **Risk/Impact:** Clutter and confusion between local path and remote name.
* **Resolution Trigger:** Owner removes the copies and renames the local folder outside the session.

### `OBS-007`
* **Severity:** INFO
* **Category:** ASSET_BUDGET
* **Target:** `assets/images/caua_mouth_closed.webp`, `assets/images/caua_mouth_open.webp`, `assets/images/README.md`
* **Source:** `audit / TASK-002 T2`
* **Status:** Open
* **Finding:** Generated placeholder sprites are 512x512 and the README header attributes all art in the directory to CC0 (Erick Zanardo), with only a one-line placeholder exception.
* **Risk/Impact:** Licensing note may become stale once final art lands; 512 px may exceed the on-screen size.
* **Resolution Trigger:** Delivery of the final Caua art: update the README licensing note and downsize if the on-screen sprite is much smaller.

### `OBS-008`
* **Severity:** WARNING
* **Category:** PERFORMANCE_NFR
* **Target:** `build/web`, `assets/music/`
* **Source:** `build log / TASK-002 T2`
* **Status:** Open
* **Finding:** `flutter build web --release` output is 45 MB on disk: `canvaskit` 36 MB (only one variant is fetched by the browser), template `assets/music` was 4.4 MB (reduced to one 1.65 MB track in TASK-001 T1; assets now about 2.4 MB), `main.dart.js` 2.7 MB.
* **Risk/Impact:** Payload under 3.5 MB and first load under 3 s on 4G are not verified; the remaining BGM is the largest asset.
* **Resolution Trigger:** TASK-001 (preload and BGM) or a dedicated task: measure transferred bytes over throttled 4G, drop unused template assets, consider the skwasm/html renderer.

### `OBS-009`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `lib/game/components/caua_player_component.dart`
* **Source:** `audit / TASK-002 T3`
* **Status:** Open
* **Finding:** `CauaPlayerComponent` sets `sprite` in `onLoad` and again in `onMount` (resync), which duplicates the assignment.
* **Risk/Impact:** Harmless redundancy; may confuse a later reader about which one is authoritative.
* **Resolution Trigger:** Next touch of the component (for example TASK-003 or TASK-006): keep only the `onMount` resync.

### `OBS-010`
* **Severity:** WARNING
* **Category:** LIFECYCLE
* **Target:** `lib/game/caua_candies_game.dart`
* **Source:** `audit / TASK-002 T4`
* **Status:** Open
* **Finding:** `CauaCandiesGame.onRemove` disposes the `MouthController` even when the caller injected it. Flame also calls `game.onRemove` without removing children first, so the player's `removeListener` runs later or never; this is safe today only because `ValueNotifier.dispose` drops listeners.
* **Risk/Impact:** An external owner holding the same controller (HUD in TASK-003, tests) would hit a disposed notifier.
* **Resolution Trigger:** TASK-003 (first external reader of the controller): dispose only when the game created it, for example `_ownsController = mouthController == null`.

### `OBS-011`
* **Severity:** INFO
* **Category:** ERROR_HANDLING
* **Target:** `lib/game/caua_candies_game.dart`
* **Source:** `audit / TASK-002 T4`
* **Status:** Open
* **Finding:** `images.loadAll` has no handling for a missing or failed asset; a failure leaves a blank screen with an unhandled exception.
* **Risk/Impact:** Acceptable for bundled assets; matters once asset sets grow.
* **Resolution Trigger:** TASK-001 (`AssetPreloader`, which owns load failure state) or when load failure handling is introduced.

### `OBS-012`
* **Severity:** INFO
* **Category:** UX_KIDS
* **Target:** `lib/game/caua_game_screen.dart`
* **Source:** `audit / TASK-002 T5`
* **Status:** Open
* **Finding:** The manual-verification screen has a 56 px back button over the canvas that exits to `/` on tap.
* **Risk/Impact:** A 6-year-old tapping near the top-left corner during play could leave the match.
* **Resolution Trigger:** TASK-001 wiring or TASK-005 (game screen replaces the verification route): remove the button or move it behind the settings/pause flow.

### `OBS-013`
* **Severity:** INFO
* **Category:** DESIGN
* **Target:** `lib/game/projection.dart`
* **Source:** `audit / TASK-003 T1`
* **Status:** Open
* **Finding:** The architecture gives no pixel values for the projection; `yBottom=1180`, `yHorizon=400` and `x=360` (spawn and mouth) are placeholders chosen in the 720x1280 viewport.
* **Risk/Impact:** Items may not line up with the belt trapezoid or the mouth until the geometry is fixed.
* **Resolution Trigger:** TASK-003 T4 (belt geometry) or T9 (manual run): retune the constants in `Projection`.

### `OBS-014`
* **Severity:** INFO
* **Category:** DESIGN
* **Target:** `lib/game/managers/phase_config.dart`
* **Source:** `audit / TASK-003 T2`
* **Status:** Open
* **Finding:** Phase 3 composition is 25/30/45 (sweets/fruits/hazards), set by the product owner to make the final phase the hardest; not yet playtested.
* **Risk/Impact:** The final celebration challenge may feel too easy or too hard.
* **Resolution Trigger:** TASK-004 (phase progression) tunes the table, or the manual run in TASK-003 T9.

### `OBS-015`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `lib/game/managers/game_manager.dart`
* **Source:** `audit / TASK-003 T3`
* **Status:** Open
* **Finding:** `level` and `state` are plain fields; only `score` and `hp` are `ValueNotifier`s.
* **Risk/Impact:** Banner, victory, game-over and tutorial overlays cannot react to level or state changes without polling.
* **Resolution Trigger:** TASK-004 (level changes and banner): make `level` and `state` notifiers.

### `OBS-016`
* **Severity:** WARNING
* **Category:** LICENSING
* **Target:** `assets/images/README.md`
* **Source:** `audit / TASK-001 T1`
* **Status:** Open
* **Finding:** Cauã sprites, items, UI icons, logo and backgrounds are AI-generated placeholders and the README states licensing and origin are not formally documented.
* **Risk/Impact:** Unclear usage rights if the game is published beyond the private party link.
* **Resolution Trigger:** Product owner confirms the generator terms and the README records origin and license before the Nov 4, 2026 release.

### `OBS-017`
* **Severity:** INFO
* **Category:** ASSET_BUDGET
* **Target:** `assets/music/tropical_fantasy.mp3`
* **Source:** `audit / TASK-001 T1`
* **Status:** Open
* **Finding:** The only BGM track weighs 1.65 MB of the 2.4 MB asset payload.
* **Risk/Impact:** Under the 3.5 MB ceiling but heavy for the sub-3s first load on 4G.
* **Resolution Trigger:** TASK-001 T5 or the 4G measurement in OBS-008: re-encode at 64-96 kbps if the budget is tight.

### `OBS-018`
* **Severity:** INFO
* **Category:** DESIGN
* **Target:** `assets/images/game/belt_tile.webp`
* **Source:** `manual / TASK-013 HIL`
* **Status:** Open
* **Finding:** The delivered belt sprite measures body about #C8B0E8 and arrows about #7858B8, close to but not equal to the approved belt-base #BFA6EC and belt-stripe #8F72D6. The product owner chose not to regenerate sprites.
* **Risk/Impact:** Any belt drawn in code from `Palette` could differ slightly from the sprite.
* **Resolution Trigger:** First component that mixes the belt sprite with `Palette.beltBase`/`beltStripe` (TASK-003 follow-up or TASK-004).

### `OBS-019`
* **Severity:** WARNING
* **Category:** PERFORMANCE_NFR
* **Target:** `lib/game/managers/asset_preloader.dart`
* **Source:** `audit / TASK-001 T2`
* **Status:** Open
* **Finding:** `AssetPreloader` defaults to a private `Images()` cache instead of `Flame.images`, so sprites preloaded on the title screen are not reused by `CauaCandiesGame`.
* **Risk/Impact:** AC5 (shared cache) is not met; assets load twice and the game start may stall.
* **Resolution Trigger:** TASK-001 T5: inject `Flame.images` (or make it the default) when wiring the screen.

### `OBS-020`
* **Severity:** INFO
* **Category:** PERFORMANCE_NFR
* **Target:** `lib/game/managers/asset_preloader.dart`
* **Source:** `audit / TASK-001 T2`
* **Status:** Open
* **Finding:** Images and audio load sequentially, and `dispose()` is not idempotent; an internally created `Images` is never disposed.
* **Risk/Impact:** Slower preload on 4G than a parallel load; double dispose could throw.
* **Resolution Trigger:** TASK-001 T5 or the 4G measurement in OBS-008.


### `OBS-023`
* **Severity:** INFO
* **Category:** UX_KIDS
* **Target:** `lib/audio/audio_controller.dart`
* **Source:** `audit / TASK-001 T3`
* **Status:** Open
* **Finding:** The product owner chose BGM on menu entry for every platform; mobile browsers usually reject the first `play()`. The error is caught and logged, and the game runs silent until a retry.
* **Risk/Impact:** The party link may open silent on iOS Safari and Android Chrome until the first tap.
* **Resolution Trigger:** TASK-001 T4/T5 must call `unlockAndStartMusic()` on the first tap; test on iOS Safari and Android Chrome.

### `OBS-024`
* **Severity:** INFO
* **Category:** ERROR_HANDLING
* **Target:** `lib/audio/audio_controller.dart`
* **Source:** `audit / TASK-001 T3`
* **Status:** Open
* **Finding:** SFX `play()` and music `pause()` are not awaited or caught, and the `playSfx` documentation comment text is inverted.
* **Risk/Impact:** Unhandled async errors in rare player failures; misleading doc.
* **Resolution Trigger:** Next touch of `audio_controller.dart`.


### `OBS-028`
* **Severity:** INFO
* **Category:** UX_KIDS
* **Target:** `lib/ui/title_screen.dart`
* **Source:** `audit / TASK-001 T4`
* **Status:** Open
* **Finding:** The Failed state shows no message and a null `onRetry` leaves the user without a way out. The 48 px settings spacer is reserved even without settings and can overflow below about 330 px viewport height (landscape).
* **Risk/Impact:** A stuck screen on a failed preload; layout overflow in landscape.
* **Resolution Trigger:** TASK-001 T5 passes `onRetry`; the 9:16 portrait layout makes the overflow unlikely.

### `OBS-029`
* **Severity:** INFO
* **Category:** UX_KIDS
* **Target:** `lib/ui/play_button.dart`
* **Source:** `audit / TASK-001 T4`
* **Status:** Open
* **Finding:** The JOGAR label is white on #E5609D, about 3.4:1 contrast, which passes only the 3:1 large-text criterion.
* **Risk/Impact:** Acceptable for the large label; weaker for small text.
* **Resolution Trigger:** Palette review if smaller text is placed on that pink.



### `OBS-035`
* **Severity:** INFO
* **Category:** UX_KIDS
* **Target:** `lib/ui/title_logo.dart`, `lib/ui/falling_candies.dart`
* **Source:** `audit / TASK-001 T7`
* **Status:** Open
* **Finding:** To keep the logo clear of the falling-candy lanes it was narrowed by about 25% at 360 px width (about 234x98 px at rest); the measured clearance is 6.0 px at 360, 9.1 px at 412 and 3.6 px at 320.
* **Risk/Impact:** A smaller logo and a tight margin on very narrow phones. The product owner approved the screen at 360x640 and 412x915.
* **Resolution Trigger:** Real-device check on a 320 px wide phone, or a layout change to the candy lanes.

### `OBS-036`
* **Severity:** INFO
* **Category:** ERROR_HANDLING
* **Target:** `lib/audio/audio_controller.dart`
* **Source:** `audit / TASK-001 T6`
* **Status:** Open
* **Finding:** The futures returned by `pause`, `stop` and `dispose` on the audio players are not awaited or handled.
* **Risk/Impact:** A platform failure would surface as an unhandled async error (now routed to the global error screen by TASK-016).
* **Resolution Trigger:** Next touch of `audio_controller.dart`.

### `OBS-037`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `lib/ui/bobbing_avatar.dart`
* **Source:** `audit / TASK-001 T6`
* **Status:** Open
* **Finding:** The `CurvedAnimation` created by `BobbingAvatar` is not disposed with its controller.
* **Risk/Impact:** Negligible leak for one avatar instance.
* **Resolution Trigger:** Next touch of `bobbing_avatar.dart`.
### `OBS-021`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `lib/game/components/conveyor_belt_component.dart`
* **Source:** `audit / TASK-003 T4`
* **Status:** Open
* **Finding:** `ConveyorBeltComponent` defines `baseSpeed = 0.25` (z/s), `halfWidthBottom = 330` and `stripeCount = 10`. The belt stripes are rebuilt every frame without Dart allocations, and the 720x1280 render is only verifiable once wired (T9).
* **Risk/Impact:** Duplicated constants if `FoodItemComponent` (T5) re-declares speed; visual unverified until T9.
* **Resolution Trigger:** TASK-003 T5 reuses `baseSpeed` (or moves it to `phase_config.dart`); visual check at the T9 checkpoint.

### `OBS-025`
* **Severity:** INFO
* **Category:** PERFORMANCE_NFR
* **Target:** `lib/game/components/item_spawner_component.dart`
* **Source:** `audit / TASK-003 T6`
* **Status:** Open
* **Finding:** The task asks for pooling or recycling, but the spawner creates a new `FoodItemComponent` about every 1.4 s (items remove themselves). It uses `parent?.add` and does not reset `_elapsed` on restart. `spawnIntervalSeconds = 1.4` was chosen by the implementer, not taken from the docs; arrival spacing belongs to TASK-011.
* **Risk/Impact:** Low allocation rate, acceptable; a restart can inherit a stale timer if the spawner is reused.
* **Resolution Trigger:** TASK-003 T9 mounts it on an already mounted parent and recreates or resets it on restart; revisit pooling only if profiling shows GC hitches.

### `OBS-026`
* **Severity:** INFO
* **Category:** TEST_COVERAGE
* **Target:** `lib/game/components/item_spawner_component.dart`
* **Source:** `test authoring / TASK-003 T6`
* **Status:** Open
* **Finding:** The "does not spawn when state is not playing" test was not written because `GameState` only has `playing`.
* **Risk/Impact:** The paused/over spawning guard is uncovered until more states exist.
* **Resolution Trigger:** TASK-004, TASK-005 or TASK-006 adds `GameState` values; add the test then.

### `OBS-030`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `lib/game/item_sprites.dart`
* **Source:** `audit / TASK-003 T7`
* **Status:** Open
* **Finding:** `itemSpriteAssetList` duplicates the keys of `itemSpriteAssets`, and 16 item types reuse 9 sprites (donut and sprinkles use the cupcake, banana the grape, broccoli the onion). The product owner accepted the reuse; a test checks the list against the map and the files on disk.
* **Risk/Impact:** Some items look like others; the list can drift if the test is removed.
* **Resolution Trigger:** Delivery of dedicated art for the shared types, or derive the list from the map.

### `OBS-031`
* **Severity:** INFO
* **Category:** TEST_COVERAGE
* **Target:** `lib/audio/audio_controller.dart`
* **Source:** `test authoring / TASK-003 T7`
* **Status:** Open
* **Finding:** The mute handling inside `AudioController.playSfx` is not exercised by `test/audio/sounds_test.dart`.
* **Risk/Impact:** A regression could play SFX while muted.
* **Resolution Trigger:** The TASK-001 audio toggle rework (SFX and music muted together) adds the test.

### `OBS-039`
* **Severity:** WARNING
* **Category:** UX_KIDS
* **Target:** `lib/game/caua_game_screen.dart`
* **Source:** `audit / TASK-003 T9`
* **Status:** Open
* **Finding:** The 9:16 container size, the sky versus belt harmony, the head versus HUD clearance and the ingest tween were only checked on desktop Chrome. The original "game view under 1/100 of the screen" report was never reproduced; an explicit centered 9:16 container with a 360x640 minimum mitigates it.
* **Risk/Impact:** A phone could still render the game too small or misaligned (iOS Safari URL bar resize, landscape).
* **Resolution Trigger:** Real-device check on iOS Safari and Android Chrome (portrait, landscape, narrow window) before release; fix with a corrective task if it fails.

### `OBS-040`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `lib/game/components/food_item_component.dart`
* **Source:** `audit / TASK-003 T9`
* **Status:** Open
* **Finding:** At the decision the item keeps its previous pose (y about 522) and jumps to y 515 on the next update; it stays 0.15 s in the component tree while the ingest tween runs. The jump is not asserted in tests.
* **Risk/Impact:** Sub-pixel visual jump, no visible defect reported.
* **Resolution Trigger:** Next touch of `FoodItemComponent`.

### `OBS-043`
* **Severity:** WARNING
* **Category:** UX_KIDS
* **Target:** `lib/audio/sounds.dart`
* **Source:** `audit / TASK-003 T10`
* **Status:** Open
* **Finding:** The product-owner clips `hmm.mp3` and `eurk.mp3` play at volume 1.0 while the other SFX use 0.4, a jump of about 8 dB, and `hmm` plays on every positive item.
* **Risk/Impact:** Possible startling or fatiguing loudness for children; the real clip level was not checked by ear.
* **Resolution Trigger:** Product owner listens in the browser; consider 0.6 to 0.7 for `hmm`.
### `OBS-032`
* **Severity:** INFO
* **Category:** ERROR_HANDLING
* **Target:** `lib/ui/error_reporter.dart`
* **Source:** `audit / TASK-016 T2`
* **Status:** Open
* **Finding:** `ErrorReporter` logs the error message verbatim (local console only, no PII in this app) and has no fallback if `ErrorScreen` itself throws; later errors are ignored, so there is no loop.
* **Risk/Impact:** A failure inside the error screen would leave a broken UI without reload guidance.
* **Resolution Trigger:** TASK-016 T3 self-audit or a later hardening pass; add a minimal `Text`-only fallback if needed.

### `OBS-041`
* **Severity:** WARNING
* **Category:** ERROR_HANDLING
* **Target:** `lib/ui/error_reporter.dart`
* **Source:** `audit / TASK-016 T3`
* **Status:** Open
* **Finding:** `buildErrorWidget` does not consult `hasError`; if `ErrorScreen.build` itself threw, the builder could loop. The try/catch around the const `ErrorScreen` constructor is dead code because a const constructor cannot throw.
* **Risk/Impact:** Low: `ErrorScreen` is a simple stateless widget.
* **Resolution Trigger:** Next touch of `error_reporter.dart`: guard on `hasError` and drop the dead try/catch.

### `OBS-042`
* **Severity:** INFO
* **Category:** ERROR_HANDLING
* **Target:** `lib/ui/error_reporter.dart`
* **Source:** `audit / TASK-016 T3`
* **Status:** Open
* **Finding:** `ErrorFallback` (text only) has no reload button and no `DefaultTextStyle`, and is practically unreachable.
* **Risk/Impact:** None in normal operation.
* **Resolution Trigger:** Same pass as OBS-041.
### `OBS-038`
* **Severity:** INFO
* **Category:** ASSET_BUDGET
* **Target:** `assets/images/caua/caua_chew_eyes_open.webp`, `caua_mouth_closed_eyes_half.webp`, `caua_mouth_open_eyes_open.webp`
* **Source:** `audit / TASK-017 T2`
* **Status:** Open
* **Finding:** The three normalized frames are encoded at webp quality 78 instead of about 85 (26.4 to 27.1 KB each); at 85 they reached 31 to 32 KB, above the 30 KB per-file budget. The invariants test uses bbox height rather than head height because the win frames raise their fists.
* **Risk/Impact:** Slightly lower fidelity than the other ten frames; not visible in the contact sheet approved by the product owner.
* **Resolution Trigger:** Re-encode all 13 frames at one quality if the budget allows.
