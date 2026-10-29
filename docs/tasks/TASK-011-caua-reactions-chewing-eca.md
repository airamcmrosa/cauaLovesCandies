---
id: TASK-011
story: US03
title: Add Cauã chewing and "eca" reactions and enforce arrival spacing that respects their duration
status: aceita # proposta | aceita | em progresso | completa
depends_on: [TASK-002, TASK-003, TASK-009] # mouth control, ingestion outcome and spawner, sprite table with the pose/eye model
supersedes: []
---

# TASK-011 - Add Cauã chewing and "eca" reactions and enforce arrival spacing that respects their duration

## Objective
When Cauã eats a sweet or fruit he chews, stepping through three sprites (eyes open, half open, closed). When he eats a forbidden item his face turns to "eca" instead of the happy chew. The next item never reaches the mouth before the reaction animation has finished, so the player always sees the full reaction.

## Source
- Story: `US03` (ingestion outcomes, AC2) and `US02` AC3 (clear visual feedback)
- Architecture: section 2 (decision boundary `z >= 0.95`, ingestion vs. deflection), section 3 (`CauaPlayerComponent`, spawner), section 5 (60 FPS, GC limits)
- Art: `docs/product/design/color-palette.md`, "Frames do Cauã"; sprites delivered by TASK-012

## Behavior
| Outcome at the decision boundary | Cauã shows | Duration |
| :--- | :--- | :--- |
| Mouth open, sweet or fruit ingested | chew sequence: `caua_chew_eyes_open` -> `caua_chew_eyes_half` -> `caua_chew_eyes_shut`, one frame per step, then back to idle-closed | `kChewStep` 0.16 s x 3, plus `kReactionRecover` 0.12 s = 0.60 s |
| Mouth open, forbidden item ingested | `caua_eca` held, then back to idle-closed | `kEcaHold` 0.60 s |
| Mouth closed (item deflected) | no reaction, idle pose continues | - |

## Input rule: release opens after eating (decided by the product owner)
Tap-down still toggles the mouth immediately (US02 unchanged). Additionally, if the finger is still down when ingestion closes the mouth, releasing it opens the mouth right away, even in the middle of the chew or `eca` (the animation is cancelled). Lifting the finger and tapping again also works. Implemented with `onTapUp`/`onTapCancel` and a single `isPointerDown` flag; extra simultaneous touches are ignored.

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| US03 AC2 - sweets/fruits give a positive outcome | Chew sequence plays once per ingested sweet/fruit, in the fixed three-sprite order. |
| US03 AC2 - forbidden items are penalized with a comic reaction | `eca` pose plays once per ingested hazard, together with the existing comic SFX and shake. |
| US02 AC1/AC2 - instant toggle (extended) | Finger held after ingestion: release opens the mouth in the same frame; tap-down toggle latency is unchanged. |
| US02 AC3 - clear visual feedback | Reactions are visually distinct from idle-open and idle-closed at ~120 px. |
| Pacing rule (PM, from the product owner) | At the decision boundary, consecutive item arrivals are at least `kMinArrivalGap` apart in every phase, including right after a phase change. |

## Scope
- In:
  - `lib/game/managers/caua_reaction_timings.dart`: pure Dart consts `kChewStep` (0.16 s), `kReactionRecover` (0.12 s), `kEcaHold` (0.60 s), derived `kChewTotal`, and `kMinArrivalGap = max(kChewTotal, kEcaHold) + 0.20 s` (0.80 s). Single source of truth, no magic numbers elsewhere.
  - `lib/game/managers/caua_reaction_controller.dart`: pure Dart, `enum CauaReaction { none, chew, eca }`, `ValueNotifier` for reaction and step index, dt-driven, seedless, `start(ItemCategory)`, `cancel()`, `reset()`, `dispose()`.
  - `CauaPlayerComponent` shows the reaction sprites while a reaction is active (chew and eca take precedence over idle/blink; blink resumes at idle).
  - Spawner change in TASK-003 code so that the arrival gap at the mouth is never below `kMinArrivalGap`, across speed multipliers 1.0 / 1.35 / 1.65 and across the phase-change speed jump (items already on the belt must not bunch up closer than the gap).
- Out:
  - The base tap-down toggle (TASK-002; this task only adds the release-after-eating rule on top), scoring and HP rules (TASK-003), blink (TASK-009).
  - Sprite delivery and conversion (TASK-012).
  - Celebration particles (TASK-010); the hit sparkle may start together with the chew.
  - Tests (owned by `test-author`).

## Atomic Sub-tasks
Each item is one unit for the orchestrate-phase loop (flutter-dev, audit, tests).
- [ ] T1 - Create `caua_reaction_timings.dart` and `CauaReactionController` (chew = 3 steps then recover, eca = hold then recover, dt-driven, no `Timer`/`Future`, `cancel()` and `reset()` return to `none`). _Verify:_ `flutter analyze` clean; with simulated `dt`, chew emits steps 0, 1, 2 in order, finishes at `kChewTotal` and never skips a step on a long `dt`; eca finishes at `kEcaHold`.
- [ ] T2 - Hook the controller to the ingestion outcome from TASK-003: sweet/fruit -> `chew`, hazard -> `eca`, deflection -> nothing. On ingestion the mouth state is set to closed (the chewing face and the controller must agree), using a `MouthController` method that notifies once. _Verify:_ after eating, `MouthState` is `closed` and the sprite is the chew/eca frame on the same frame; deflected items trigger no reaction.
- [ ] T3 - Extend `CauaPlayerComponent` to render the reaction sprites (chew frame by step index, `caua_eca`), resolved once in `onLoad` into the existing sprite table (no per-frame allocation). A tap during a reaction cancels it and applies the toggle in that same frame (input always wins). _Verify:_ tap latency is unchanged versus TASK-002; no leaked listener after `onRemove`.
- [ ] T3b - Add the release-after-eating rule: track `isPointerDown` via `onTapDown`/`onTapUp`/`onTapCancel` in `CauaCandiesGame`; when a reaction ends the mouth-closed state caused by ingestion while the pointer is still down, the next `onTapUp` (or `onTapCancel`) calls `MouthController.open()`-equivalent once and cancels the active reaction. Normal tap-down toggles stay untouched, and a release with no preceding ingestion does nothing. _Verify:_ press, eat, keep holding, release: mouth opens in that frame; press, release before eating: no extra toggle; second finger down/up does not change state; `onTapCancel` (finger dragged off or interrupted) behaves like a release only in the post-ingestion case.
- [ ] T4 - Enforce `kMinArrivalGap` in the spawner/belt logic, including the phase-change speed jump (for example by spacing spawns in time using the speed in effect at the decision boundary, or by easing the speed change on in-flight items; implementer chooses, the guarantee is what is verified). _Verify:_ a deterministic simulation across all three phases and a forced phase change shows every consecutive arrival pair `>= kMinArrivalGap` apart; phase composition percentages are unchanged.
- [ ] T5 - Restart and lifecycle: `reset()` on restart (TASK-005 flow), reactions cleared on `GameState` change, controller disposed. _Verify:_ `dart format --set-exit-if-changed lib`, `flutter analyze`, `flutter build web --release` pass; after restart no reaction is left playing.
- [ ] T6 - Handoff list for `test-author`. _Verify:_ names chew step order and timing, eca timing, cancel on tap, release-after-eating (held finger, released finger, cancel, second finger), mouth forced closed after ingestion, no reaction on deflection, minimum arrival gap per phase and across a phase change, reset.

## Definition of Done
- Every sweet/fruit ingestion shows the full three-sprite chew, every hazard ingestion shows `eca`, and no next item arrives before the reaction ends.
- Performance/web constraints honored (60 FPS, no hot-path allocations, assets already budgeted by TASK-012).

## PM Decisions
- Ingestion closes the mouth: the chew face has a closed mouth, so the `MouthController` state must be `closed` right after eating; the player taps again, or releases a held finger, to open for the next item. Approved by the product owner; still worth watching in playtest.
- A tap or a release-after-eating during a reaction wins over the animation (responsiveness is the core promise of US02).
- Timing values are starting points to be tuned in playtest with 6-year-olds; they live only in `caua_reaction_timings.dart`.
- Until `caua_chew_eyes_open` is delivered (TASK-012), the chew sequence runs on the two available frames (`half`, `shut`) with the same total duration.

## Open Questions
- None.
