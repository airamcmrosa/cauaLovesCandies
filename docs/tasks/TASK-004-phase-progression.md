---
id: TASK-004
story: US04
title: Implement 3-phase progression with rising speed and phase banner
status: em progresso # proposta | aceita | em progresso | completa
depends_on: [TASK-003] # needs GameManager, score tracking, conveyor speed and item spawner
supersedes: []
---

# TASK-004 - Implement 3-phase progression with rising speed and phase banner

## Objective
The conveyor gets faster each time the player reaches the phase score target (Phase 1 -> 2 -> 3), and a short non-blocking banner (e.g. "Fase 2 - Mais Rápido!") announces each phase change without pausing gameplay.

## Source
- Story: `US04` (`docs/product/stories/user_stories_index_details.md`)
- Architecture: section 3 (Flame component hierarchy: `GameManager`, `ConveyorBeltComponent`, `ItemSpawnerComponent`, `ParticleCelebrationComponent`) and section 4 (phase progression, speeds and targets)
- Existing code: `lib/level_selection/levels.dart` holds template levels (`winScore` 3 and 5) and `lib/flame_game/endless_runner.dart` / `endless_world.dart` are still the template runner (see OBS-002). None of this is the product phase model; the new config must not extend the template `gameLevels` list.

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| AC1 - Phase 1: initial speed (1.2x), target 10 pts | `PhaseConfig` entry 1 in the single const phase table (`speedMultiplier` 1.2, `targetScore` 10); `GameManager` starts at phase 1 and applies that multiplier to belt scroll and item `z` velocity |
| AC2 - Phase 2: medium speed (1.44x), target 20 pts | Entry 2 in the same table (`speedMultiplier` per Open Question 1, `targetScore` 20); `GameManager` advances 1 -> 2 when score reaches 10 |
| AC3 - Phase 3: fast speed (1.728x), target 30 pts | Entry 3 in the same table (`speedMultiplier` per Open Question 1, `targetScore` 30); `GameManager` advances 2 -> 3 when score reaches 20 and signals "phase 3 target reached" at 30 (hand-off to TASK-005 victory) |
| AC4 - Banner on phase change without freezing the game | `PhaseBannerOverlay` (Flutter widget in `lib/ui/`) driven by a `ValueListenable` phase-change event; auto-dismisses after ~1.5 s, is wrapped in `IgnorePointer`, and never pauses the Flame engine or consumes taps |

## Scope
- In:
  - `lib/game/managers/phase_config.dart`: immutable `PhaseConfig` (phase number, `speedMultiplier`, `targetScore`, banner text, optional spawn composition weights) and ONE const table `kPhases` with exactly 3 entries. No phase literals anywhere else.
  - `lib/game/managers/game_manager.dart` (extend the TASK-003 class): `ValueNotifier` for current phase, pure `advanceIfTargetReached()` logic, a phase-change event for the banner, injectable config for testability.
  - Wire `speedMultiplier` into belt scroll speed and item `z` velocity using `dt`-scaled movement (consumers read the current multiplier from `GameManager`; they hold no phase rules).
  - `lib/ui/phase_banner_overlay.dart`: presentational, `const` constructor, large high-contrast text, short show/hide animation.
  - Optional light cue on phase change (reuse `ParticleCelebrationComponent` burst if it exists from TASK-003/TASK-005; otherwise skip).
  - Restart path resets phase to 1 (called by restart flows owned by TASK-005).
- Out:
  - Conveyor rendering, item spawning base behavior, scoring and HP rules (TASK-003).
  - Tap control and mouth state (TASK-002).
  - Title screen and audio unlock (TASK-001).
  - Victory overlay, confetti finale, "Tente de Novo!" screen and restart UI (TASK-005).
  - Tutorial overlay (TASK-006).
  - Removing template `EndlessRunner` / `EndlessWorld` / `gameLevels` (OBS-002; owned by whichever task replaces the runner loop, not this one).
  - Writing tests (test-author owns them).

## Atomic Sub-tasks
Each item is one unit for the orchestrate-phase loop (flutter-dev, audit, tests).
- [x] T1 - Extend the `PhaseConfig` and `kPhases` table created in TASK-003 (`phase_config.dart`) with `targetScore` and banner text (3 entries; speed and composition already exist there). Do not create a second table. _Verify:_ `flutter analyze` clean; grep shows no phase speed/target literals outside this file.
- [x] T2 - Extend `GameManager` with a `ValueNotifier<int>` current phase, automatic advance when `score >= targetScore` of the active phase, and a phase-change event (not fired for phase 1 at start). _Verify:_ code review: reaching 10 moves to phase 2 and 20 to phase 3, each advance fires exactly once; manager imports no Flutter/Flame UI.
- [x] T3 - Expose `currentSpeedMultiplier` and make belt scroll and item `z` velocity consume it with `dt`-scaled movement (no per-frame allocations). _Verify:_ run the web build, phase 2 items visibly travel faster than phase 1; speed changes apply at the phase boundary without a jump or reset of items already on the belt.
- [x] T4 - Define behavior at the phase 3 target (30): add `GameState.victory`; `GameManager` flags the final target reached and stops advancing further (no phase 4); the victory UI is TASK-005. _Verify:_ no out-of-range index into `kPhases`; reaching 30 emits one "final target reached" signal.
- [x] T5 - Add `phase_banner_overlay.dart` listening to the phase-change event, shows "Fase N - ..." text for ~1.5 s then fades out, `IgnorePointer`, never pauses the game. _Verify:_ on phase change the banner appears while items keep moving and taps still toggle the mouth; banner disappears on its own.
- [x] T6 - Register the banner overlay with the game widget and ensure restart resets phase to 1 and clears any visible banner. _Verify:_ after restart the game runs at 1.0x and no stale banner or listener remains (notifiers disposed in `dispose`/`onRemove`).
- [x] T7 - Self-audit and handoff list for test-author. _Verify:_ `dart format --set-exit-if-changed lib`, `flutter analyze`, `flutter build web --release` pass. Suggested coverage: phase advance thresholds (9/10/19/20/29/30), event fires once, score jumping across a threshold, restart reset, config invariants (strictly increasing multiplier and target).

## Definition of Done
- Every story AC above is demonstrably met.
- Phase speeds, targets and banner texts live only in the one const `kPhases` table.
- Performance/web constraints honored (60 FPS, no hot-path allocations, assets `.webp`/`.mp3`); banner is a Flutter overlay so it adds no assets.
- Banner never blocks input or pauses the game loop.
- All user-facing code and comments are English except the banner copy, which follows the story language decision in Open Question 4.

## PM Decisions (resolved questions)
- Speeds: changed by the product owner at the T3 HIL (2026-10-29) to a geometric series, ratio 1.2 per phase: 1.2 / 1.44 / 1.728 (`kPhaseSpeedRatio`). Supersedes the earlier 1.0 / 1.35 / 1.65. US04 and the architecture diagram were updated to match.
- Phase 3 is a normal phase with target 30; reaching it moves `GameState` to `victory` (consumed by TASK-005).
- Score is cumulative: targets are total score 10 / 20 / 30; score never resets between phases.
- Banner copy in Portuguese, kept in `kPhases`: "Fase 2 - Mais Rápido!", "Fase 3 - Super Rápido!". Phase 1 shows no banner. Verify the font renders accents.
- Spawn composition stays in TASK-003's table; this task only wires speed.
- Items already on the belt at a phase change are kept and take the new multiplier immediately.
