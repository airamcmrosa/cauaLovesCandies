---
id: TASK-005
story: US05
title: Build victory celebration and friendly game-over screens with instant restart
status: aceita # proposta | aceita | em progresso | completa
depends_on: [TASK-003, TASK-004] # GameManager (score/HP/GameState) and phase progression emitting victory
supersedes: []
---

# TASK-005 - Build victory celebration and friendly game-over screens with instant restart

## Objective
When the player finishes Phase 3, confetti/fireworks burst, a celebration SFX plays and a congratulation message with a big "JOGAR NOVAMENTE" button appears. When HP reaches zero, a friendly "Tente de Novo!" screen appears. Both end states restart the game instantly, with a clean `GameManager` reset and no leaked components.

## Source
- Story: `US05` (`docs/product/stories/user_stories_index_details.md`)
- Architecture: section 3 (`ParticleCelebrationComponent`, `GameManager`, `AudioManager`), section 4 (confetti victory overlay, zero-latency loop reset), section 5 (web audio/perf constraints)

## Current Codebase State
- Exists (template, reuse or replace): `lib/flame_game/game_win_dialog.dart` (generic "Well done!" dialog using `NesContainer`/`NesButton`, routes to level selection; not the US05 content), `lib/audio/sounds.dart` (`SfxType` enum has no celebration/victory entry), `lib/audio/audio_controller.dart`, `lib/style/palette.dart`.
- Does not exist yet: `lib/game/` (no `GameManager`, no `ParticleCelebrationComponent`), `lib/ui/` (no overlays), any celebration SFX asset under `assets/sfx/`.
- OBS-002: `EndlessRunner`/`EndlessWorld` template names are still in use in `lib/flame_game/`. This task must not rename them; it attaches to whatever game class TASK-003 settled on and integrates through its public API only.

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| AC1 - Confetti/fireworks 2D on finishing Phase 3 | `ParticleCelebrationComponent` in `lib/game/components/` built on Flame `ParticleSystemComponent`; added to the world on the victory `GameState` transition and removed when the burst ends or on restart. |
| AC2 - Message "Parabéns, você ajudou o Cauã a comer todos os doces! Feliz Aniversário, Cauã!" | `VictoryOverlay` widget in `lib/ui/` showing this exact string (single const), large high-contrast text. |
| AC3 - Celebration SFX | New `SfxType.victory` entry (filename + volume mappings in `lib/audio/sounds.dart`) plus a compressed `.mp3` in `assets/sfx/`; played once when victory starts, honoring the existing mute setting. |
| AC4 - Big "JOGAR NOVAMENTE" button | Button in `VictoryOverlay` labeled exactly `JOGAR NOVAMENTE`, minimum 72 logical px tall and full-width within the card; callback `onPlayAgain`. |
| AC5 - HP zero shows friendly "Tente de Novo!" with instant restart | `GameOverOverlay` widget in `lib/ui/` with title `Tente de Novo!`, encouraging non-punitive copy (see Open Questions), and a big restart button using the same `onPlayAgain` callback; shown when `GameManager` enters its lost/game-over state. |
| Architecture s4 - zero-latency reset | `GameManager.reset()` (or equivalent from TASK-003) restores level 1, score 0, HP 3, state playing; the game removes spawned items and the celebration component, hides overlays, and resumes in the same frame with no route change or asset reload. |

## Scope
- In:
  - `lib/game/components/particle_celebration_component.dart` (view only, no game rules).
  - `lib/ui/victory_overlay.dart` and `lib/ui/game_over_overlay.dart` (presentational, `const` constructors, callbacks and props only).
  - Registering both overlays in the Flame `GameWidget` `overlayBuilderMap` and showing/hiding them from `GameState` changes via a `ValueListenable`.
  - `SfxType.victory` mapping and one compressed celebration `.mp3` in `assets/sfx/`, registered in `pubspec.yaml` if not covered by the existing folder entry; also preloaded with the other SFX.
  - Restart wiring: reset call, removal of leftover components, listener cleanup.
  - Retiring the template `GameWinDialog` from the play flow if it becomes unreferenced (do not leave dead code).
- Out:
  - Title screen and audio unlock: TASK-001.
  - Tap/mouth control: TASK-002.
  - Conveyor, spawner, scoring and `GameManager` core logic: TASK-003.
  - Phase thresholds, speed multipliers and detecting that Phase 3 is complete (this task only reacts to the resulting state): TASK-004.
  - Tutorial finger-tap overlay: TASK-006.
  - Phase-transition confetti between L1/L2/L3 (architecture mentions it; US05 covers only the final victory, see Open Questions).
  - Persisting any result (no personal data, no leaderboard).
  - Tests (owned by `test-author`).

## Atomic Sub-tasks
Each item is one unit for the orchestrate-phase loop (flutter-dev, audit, tests).
- [ ] T1 - Add `SfxType.victory` to `lib/audio/sounds.dart` (filename list and volume switch kept exhaustive) and add a short, compressed celebration `.mp3` to `assets/sfx/` (keep under ~100 KB; record credit/license in `assets/sfx/README.md` is out of scope for code, flag it). _Verify:_ `flutter analyze` clean; asset is listed in `pubspec.yaml` coverage; audio plays once via `AudioController.playSfx(SfxType.victory)` and is skipped when SFX are muted.
- [ ] T2 - Implement `ParticleCelebrationComponent` (confetti burst plus a few firework-style radial bursts) using Flame particles with a fixed particle count cap, cached `Paint`s, injectable `Random`, and self-removal when finished. _Verify:_ triggering it shows colorful 2D particles over the playfield at 60 FPS on a mid-range phone; no per-frame allocations in `update`/`render`; component is gone from the world after the burst ends.
- [ ] T3 - Implement `VictoryOverlay` (`lib/ui/victory_overlay.dart`) with the exact AC2 message, a "JOGAR NOVAMENTE" button (big touch target, high contrast, child-friendly palette from `Palette`) and an `onPlayAgain` callback; no game logic. _Verify:_ widget renders the exact strings on a 9:16 viewport without overflow; button tap invokes the callback once.
- [ ] T4 - Implement `GameOverOverlay` (`lib/ui/game_over_overlay.dart`) with title "Tente de Novo!", encouraging copy, and a big restart button using `onPlayAgain`; no blame wording, no score-shaming. _Verify:_ renders without overflow on small and large phones; button tap invokes the callback once.
- [ ] T5 - Add `GameState.lost` and the transition in `GameManager` when HP reaches 0 (TASK-003 only clamps HP). Wire end states: listen to `GameManager`'s `GameState` notifier; on victory add `ParticleCelebrationComponent`, play `SfxType.victory` once, show `VictoryOverlay`; on HP zero show `GameOverOverlay`; pause spawner/input while an overlay is visible. Register overlays in `overlayBuilderMap`. _Verify:_ finishing Phase 3 shows confetti + message + SFX + button; losing the 3rd HP shows "Tente de Novo!"; neither fires twice.
- [ ] T6 - Implement instant restart: `onPlayAgain` calls `GameManager.reset()`, removes all `FoodItemComponent`s and any `ParticleCelebrationComponent`, hides the overlay and resumes Phase 1 without navigation or asset reloading. _Verify:_ from both end states, one tap returns to a fresh Phase 1 (score 0, HP 3, level 1) within the same frame sequence; repeating victory/restart 10 times shows a stable component count (no leak) and no duplicated listeners or audio.
- [ ] T7 - Cleanup and lifecycle: dispose notifiers/listeners in `onRemove`/`dispose`, stop any celebration audio on restart or exit, remove or retarget the template `GameWinDialog` if unused. _Verify:_ `dart format --set-exit-if-changed lib`, `flutter analyze` and `flutter build web --release` pass; no unused template code remains from this flow.
- [ ] T8 - Hand off test coverage list to `test-author`. _Verify:_ handoff names: reset restores all `GameManager` fields; victory/game-over overlay strings and callbacks; celebration component self-removal with seeded `Random`; no double trigger of victory SFX.

## Definition of Done
- Every story AC above is demonstrably met, with the in-game Portuguese strings matching the story exactly.
- Restart from either end state is a single tap, resets `GameManager` fully and leaks no components, listeners or audio.
- Performance/web constraints honored (60 FPS, no hot-path allocations, assets `.webp`/`.mp3`, total payload within the 3.5 MB budget, no `dart:io`).
- No network calls, analytics or persisted personal data.

## PM Decisions (resolved questions)
- Victory threshold: owned by TASK-004 (total score 30, `GameState.victory`); this task only consumes it.
- "Tente de Novo!" body copy approved: "Quase lá! O Cauã ainda quer mais doces." (with accents).
- Victory SFX: CC0/royalty-free sample, license recorded; no generated jingle needed.
- Victory screen shows the message and button only, no final score.
- Confetti on phase transitions is out of scope.
- HP-zero restart goes back to Phase 1 (same `reset()` as victory). Restart skips the tutorial.
