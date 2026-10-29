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
| `OBS-008` | WARNING | PERFORMANCE_NFR | `build/web`, `assets/music/` | Open | Release build is 45 MB (canvaskit 36 MB, template music 4.4 MB); 3.5 MB payload and 3 s 4G budgets unmeasured |
| `OBS-009` | INFO | MAINTAINABILITY | `lib/game/components/caua_player_component.dart` | Open | Sprite is assigned in both `onLoad` and `onMount`; one resync would suffice |
| `OBS-010` | WARNING | LIFECYCLE | `lib/game/caua_candies_game.dart` | Open | Game disposes an injected `MouthController`; ownership should be tracked |
| `OBS-011` | INFO | ERROR_HANDLING | `lib/game/caua_candies_game.dart` | Open | `images.loadAll` failure is unhandled and leaves a blank screen |
| `OBS-012` | INFO | UX_KIDS | `lib/game/caua_game_screen.dart` | Open | Back button overlay on the game screen can be hit by a child during play |
| `OBS-013` | INFO | DESIGN | `lib/game/projection.dart` | Open | Projection pixel constants (y 1180/400, x 360) are placeholders |
| `OBS-014` | INFO | DESIGN | `lib/game/managers/phase_config.dart` | Open | Phase 3 composition (25/30/45) is a product-owner value, may be retuned |
| `OBS-015` | INFO | MAINTAINABILITY | `lib/game/managers/game_manager.dart` | Open | `level` and `state` are plain fields, not `ValueNotifier`s |
| `OBS-021` | INFO | MAINTAINABILITY | `lib/game/components/conveyor_belt_component.dart` | Open | `baseSpeed`, `halfWidthBottom`, `stripeCount` live in the component, outside `projection.dart` / `phase_config.dart` |
| `OBS-025` | INFO | PERFORMANCE_NFR | `lib/game/components/item_spawner_component.dart` | Open | Spawner creates a new `FoodItemComponent` per spawn (no pooling); restart does not reset `_elapsed` |
| `OBS-026` | INFO | TEST_COVERAGE | `lib/game/components/item_spawner_component.dart` | Open | No test for the not-spawning-when-not-playing path; `GameState` only has `playing` today |
| `OBS-030` | INFO | MAINTAINABILITY | `lib/game/item_sprites.dart` | Open | `itemSpriteAssetList` is a manual copy of `itemSpriteAssets`; 16 item types share 9 sprites (banana looks like the grape) |
| `OBS-031` | INFO | TEST_COVERAGE | `lib/audio/audio_controller.dart` | Open | Mute handling inside `AudioController.playSfx` is not covered by `sounds_test.dart` |

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
* **Finding:** `flutter build web --release` output is 45 MB on disk: `canvaskit` 36 MB (only one variant is fetched by the browser), template `assets/music` 4.4 MB, `main.dart.js` 2.7 MB.
* **Risk/Impact:** Payload under 3.5 MB and first load under 3 s on 4G are not verified; template music inflates the bundle.
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
