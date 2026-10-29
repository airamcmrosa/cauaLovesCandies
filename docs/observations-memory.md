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
| `OBS-022` | WARNING | LIFECYCLE | `lib/audio/audio_controller.dart` | Open | `dispose()` leaves settings listeners and the `onPlayerComplete` subscription attached |
| `OBS-023` | INFO | UX_KIDS | `lib/audio/audio_controller.dart` | Open | Mobile browsers usually reject the first `play()`; retry only works if T4/T5 call `unlockAndStartMusic()` on first tap |
| `OBS-024` | INFO | ERROR_HANDLING | `lib/audio/audio_controller.dart` | Open | SFX `play()` and music `pause()` are not awaited or caught; `playSfx` doc comment is inverted |

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

### `OBS-022`
* **Severity:** WARNING
* **Category:** LIFECYCLE
* **Target:** `lib/audio/audio_controller.dart`
* **Source:** `audit / TASK-001 T3`
* **Status:** Open
* **Finding:** `AudioController.dispose()` leaves the settings listeners and the `onPlayerComplete` subscription attached (pre-existing from the template).
* **Risk/Impact:** Leaks if the controller is ever disposed and recreated while settings live on.
* **Resolution Trigger:** TASK-001 T6 self-audit (listeners disposed on screen removal).

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
