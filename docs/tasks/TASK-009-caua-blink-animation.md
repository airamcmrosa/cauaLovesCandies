---
id: TASK-009
story: US02
title: Animate Cauã blinking with the open, half and closed eye sprites
status: em progresso # proposta | aceita | em progresso | completa
depends_on: [TASK-002, TASK-003] # CauaPlayerComponent/MouthController (002) and GameState for the pause switch in T4 (003)
supersedes: []
---

# TASK-009 - Animate Cauã blinking with the open, half and closed eye sprites

## Objective
Cauã blinks naturally at random intervals in the idle-closed, idle-open and victory poses, using the three eye-state sprites each pose has, so the character feels alive without ever delaying or hiding the mouth open/closed feedback.

## Source
- Story: `US02` (extends AC3, clear visual feedback for open vs. closed; `docs/product/stories/user_stories_index_details.md`)
- Architecture: section 3 (`CauaPlayerComponent`), section 5 (60 FPS, GC limits, `.webp` assets, preload)
- Art spec: "Frames de piscar" in `docs/product/design/color-palette.md` (TASK-008)

## Current State
- TASK-002 delivers `MouthController` and `CauaPlayerComponent` with one sprite per mouth state (2 sprites). This task replaces that lookup with a 2x3 table; it must not change the tap path or `MouthController` API.
- The sprites come from the product owner via Gemini (external dependency). TASK-012 delivers the background-removed PNGs and the naming; three frames are still missing (`caua_mouth_closed_eyes_half`, `caua_mouth_open_eyes_open`, plus `caua_chew_eyes_open` used by TASK-011). Until a frame arrives, fall back to the nearest eye state of the same pose (half falls back to open, open falls back to half).

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| AC3 - Clear visual feedback for open vs. closed | Mouth state still dominates: a tap swaps the mouth sprite on the same frame, regardless of the current eye state. The eye frames never hide or alter the mouth shape. |
| Polish (not a story AC) | Idle blink: open -> half -> shut -> half -> open, one blink every 2.5 to 5 s at random. |

## Scope
- In:
  - `lib/game/managers/blink_controller.dart`: pure Dart (no Flame/Flutter imports). `enum EyeState { open, half, shut }`, `ValueNotifier<EyeState>`, `tick(double dt)`, `reset()`, injectable `Random`, constant timings (step ~70 ms per frame, so a blink lasts ~280 ms; interval 2.5-5 s). No `Timer`, no `Future`; driven only by `dt`.
  - Extend `CauaPlayerComponent` with a preloaded `Sprite` table indexed by (`CauaPose`, `EyeState`) where `CauaPose` is `mouthClosed`, `mouthOpen` or `win`, updated when either notifier changes (no per-frame lookups that allocate, listeners removed in `onRemove`).
  - 9 `.webp` blink sprites under `assets/images/caua/` named `caua_{mouth_closed,mouth_open,win}_eyes_{open,half,shut}.webp` (converted from the TASK-012 PNGs), registered in `pubspec.yaml`, preloaded with the other game assets.
  - `blinkEnabled` switch on the component so other states can pause blinking.
- Out:
  - Mouth toggle logic and tap input (TASK-002).
  - Chewing and "eca" reaction poses (they do not blink; owned by TASK-011).
  - Showing the victory pose on the victory screen (TASK-005); this task only makes the `win` pose blink when it is on screen.
  - Stars and confetti (TASK-010).
  - Tests (owned by `test-author`).

## Atomic Sub-tasks
Each item is one unit for the orchestrate-phase loop (flutter-dev, audit, tests).
- [x] T1 - Create `EyeState` and `BlinkController` in `lib/game/managers/` (dt-driven sequence open -> half -> shut -> half -> open, random 2.5-5 s gap, seedable `Random`, `reset()` returns to `open` and re-arms the gap, `dispose()`). _Verify:_ `flutter analyze` clean; with a fixed seed and simulated `dt`, the notifier emits exactly the 5-step sequence once per interval and never skips a step even on a long `dt`.
- [x] T2 - Add the 9 eye-state sprites under `assets/images/caua/` (`.webp`, same canvas size for all nine) and register them in `pubspec.yaml`; report each file size and the combined total. _Verify:_ `flutter build web --release` succeeds; all nine resolve at runtime; the nine images share identical dimensions; combined size stays well under the 3.5 MB budget.
- [ ] T3 - Extend `CauaPlayerComponent` to take a `BlinkController`, build the (pose, eye) `Sprite` table once in `onLoad`, and swap on either notifier change; tick the blink controller from `update(dt)`. _Verify:_ tapping during a blink shows the new mouth state in the next frame with the current eye frame; no allocations in `update`/`render`; no leaked listener after `onRemove`.
- [ ] T4 - Wire `blinkEnabled` and reset: blinking pauses (eyes `open`) while `GameState` is not `playing`, `tutorial` or `victory` (the `win` pose blinks on the victory screen), and `reset()` is called on restart (TASK-005 flow). _Verify:_ no blink on the game-over screen; after restart the first blink is at least 2.5 s away.
- [ ] T5 - Self-audit and handoff list for `test-author`. _Verify:_ `dart format --set-exit-if-changed lib`, `flutter analyze`, `flutter build web --release` pass. Suggested coverage: blink sequence order, interval bounds with seeded `Random`, long-`dt` catch-up, `reset()`, sprite-table index for all 9 combinations, listener cleanup.

## Definition of Done
- Every AC above is demonstrably met; tap latency is unchanged versus TASK-002.
- Blink is visible on both mouth poses and never hides the mouth state.
- Performance/web constraints honored (60 FPS, no hot-path allocations, assets `.webp`).

## Open Questions
- None. Chewing/"eca" reactions moved to TASK-011.
