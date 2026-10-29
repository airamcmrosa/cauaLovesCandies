---
id: TASK-002
story: US02
title: Implement single-tap mouth open/close control
status: em progresso # proposta | aceita | em progresso | completa
depends_on: [] # task ids that must be completed first
supersedes: [] # ids of wrongly completed tasks this one corrects (see README rules)
---

# TASK-002 - Implement single-tap mouth open/close control

## Objective
A single tap anywhere on the game canvas instantly toggles Cauã's mouth between open and closed, with a clearly different sprite for each state and no perceptible input lag on mobile browsers. The mouth state is exposed by a plain Dart manager so later tasks (conveyor decision boundary, tutorial) can read it.

## Source
- Story: `US02` (`docs/product/stories/user_stories_index_details.md`)
- Architecture: section 2 (decision boundary reads mouth OPEN/CLOSED), section 3 (`CauaCandiesGame` with `TapCallbacks`, `CauaPlayerComponent` toggling `MouthOpen` / `MouthClosed` sprites, plain Dart managers), section 5 (fixed 720x1280 virtual resolution, 60 FPS, GC limits).

## Current State (what exists vs. what must be built)
- Exists: `lib/game/components/` and `lib/game/managers/` are empty directories; `lib/ui/` is empty.
- Exists (template, not a product pattern, see OBS-002): `lib/flame_game/endless_runner.dart` (`EndlessRunner`, `EndlessWorld`), `lib/flame_game/components/player.dart` (Dash runner with jump/`PlayerState`), and Dash/enemy template assets. Jump-on-tap behavior in the template must not be reused as the mouth mechanic.
- To build: `MouthState` model/manager, `CauaPlayerComponent`, tap handling on the game, and open/closed `.webp` sprites.

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| AC1 - Mouth toggles instantly on click/tap | `MouthController` (plain Dart, `ValueNotifier<MouthState>`, `toggle()`); game-level `TapCallbacks.onTapDown` calls `toggle()` once per tap, anywhere on screen. Default state is closed. |
| AC2 - Immediate response, no input lag on mobile browser | Toggle triggered on `onTapDown` (not `onTapUp`); state change and sprite swap applied in the same frame; no animation/tween delay, no async work, no allocations in the tap or `update`/`render` path. |
| AC3 - Clear visual feedback for open vs. closed | `CauaPlayerComponent` swaps between two visually distinct `.webp` sprites (mouth open / mouth closed) by listening to the controller; positioned at the horizon head position of the scene. |

## Scope
- In:
  - `lib/game/managers/mouth_state.dart` (enum `MouthState { closed, open }`) and `lib/game/managers/mouth_controller.dart` (plain Dart, `ValueNotifier`, `toggle()`, `reset()`).
  - `lib/game/components/caua_player_component.dart` (sprite swap driven by the controller; listener removed in `onRemove`).
  - Tap input on the game class via `TapCallbacks` (global tap, not tied to a hit area).
  - open/closed Cauã sprites as `.webp` under `assets/images/` (final names chosen in T2, registered in `pubspec.yaml`).
- Out:
  - Title screen, audio unlock, and "Tap to Start" flow (TASK-001).
  - Conveyor, items, `z >= 0.95` decision boundary, scoring, HP, deflection (TASK-003).
  - Phase progression (TASK-004), victory overlay (TASK-005), tutorial finger-tap overlay (TASK-006).
  - Tap sound effects (not in US02 ACs).
  - Renaming/removing template classes (`EndlessRunner`, `Player`), tracked by OBS-002; this task only avoids depending on them.
  - Tests (owned by `test-author`).

## Atomic Sub-tasks
Each item is one unit for the orchestrate-phase loop (flutter-dev, audit, tests).
- [x] T1 - Create `MouthState` enum and `MouthController` in `lib/game/managers/` (no Flame/Flutter material imports; `ValueNotifier<MouthState>`, default `closed`, `toggle()`, `reset()`, `dispose()`). _Verify:_ `flutter analyze` clean; `toggle()` alternates closed/open and notifies listeners exactly once per call.
- [ ] T2 - Add open/closed Cauã mouth sprites as `.webp` under `assets/images/` and register them in `pubspec.yaml`; keep each file small (combined well under the 3.5 MB budget). _Verify:_ `flutter build web --release` succeeds; assets resolve at runtime; file sizes reported.
- [ ] T3 - Create `CauaPlayerComponent` in `lib/game/components/` that receives a `MouthController` via constructor, shows the matching sprite, swaps on `ValueNotifier` change (no per-frame polling, no allocations in `render`), and removes its listener in `onRemove`. _Verify:_ changing the controller state switches the visible sprite on the next frame; no leaked listener after removal.
- [ ] T4 - Create the product game class `CauaCandiesGame` (FlameGame with `TapCallbacks`) in `lib/game/` with fixed 720x1280 viewport, owning the `MouthController`, adding `CauaPlayerComponent` at the horizon head position, and calling `toggle()` in `onTapDown`. Do not extend or modify `EndlessRunner`. _Verify:_ running the web build, each tap anywhere on the canvas flips open/closed on touch-down with no visible delay; double-tap yields two toggles.
- [ ] T5 - Wire a minimal route/entry so `CauaCandiesGame` can be launched for manual verification (reuse the existing `GameWidget`/router pattern; no changes to title screen behavior). _Verify:_ game screen loads from the router, renders Cauã closed by default, and holds 60 FPS in Chrome DevTools on a throttled mobile profile.

## Definition of Done
- Every story AC above is demonstrably met.
- Performance/web constraints honored (60 FPS, no hot-path allocations, assets `.webp`/`.mp3`).
- `dart format --set-exit-if-changed lib`, `flutter analyze`, and `flutter build web --release` pass.
- Mouth state is readable from outside the component (for TASK-003) without referencing the component.

## PM Decisions (resolved questions)
- Sprites: placeholder `.webp` art is acceptable for this task; final Cauã artwork is an external dependency owned by the product owner.
- Tap area: whole canvas, HUD/overlays are non-interactive.
- Playing-state gating: this task toggles unconditionally; TASK-003/004 gate input by `GameState` once it exists.
- `reset()` callers: TASK-004 (phase change) and TASK-005 (restart).
- Coexistence: `CauaCandiesGame` coexists with the template `EndlessRunner` until TASK-003 replaces the route target (OBS-002).
