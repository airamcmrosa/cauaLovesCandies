---
id: TASK-006
story: US06
title: Add hands-on tutorial overlay at first play
status: em progresso # proposta | aceita | em progresso | completa
depends_on: [TASK-002, TASK-003] # needs the tap/mouth control and the running conveyor to pause, slow down and start
supersedes: []
---

# TASK-006 - Add hands-on tutorial overlay at first play

## Objective
When the player taps JOGAR, Phase 1 opens with the belt held in a pause/slow-motion state under a semi-transparent overlay showing a tapping finger, Cauã's mouth toggling open/closed in sync, and a green check for sweets/fruits versus a red X for broccoli. The first tap fades the overlay out and starts the belt immediately, with the whole lesson readable in under 3 seconds and without text.

## Source
- Story: `US06` (`docs/product/stories/user_stories_index_details.md`)
- Architecture: section 4 (onboarding / title screen box lists the "Hands-on Visual Finger Tap Overlay (US06)" before Phase 1), section on Flutter overlays in `lib/ui/` (presentational only, state via `ValueListenable`), GameManager `GameState` (domain owner of pause/running).

## Current State (what exists vs what must be built)
- Exists: `lib/flame_game/endless_runner.dart` and `endless_world.dart` (template runner, see OBS-002), `lib/level_selection/instructions_dialog.dart` (template text dialog, not the US06 overlay), `lib/main_menu/main_menu_screen.dart`, `lib/router.dart`, `lib/flame_game/game_screen.dart` (hosts the game widget and overlays).
- Does not exist: `lib/ui/` directory, `lib/game/` directory, `GameManager`, Caua mouth component, any tutorial widget or assets.
- Those game pieces come from TASK-002 (tap/mouth) and TASK-003 (conveyor, GameManager). This task must build on them and must not extend the template runner mechanics (OBS-002).

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| AC1 Automatic display on JOGAR, paused/slow-motion Phase 1, semi-transparent overlay | `TutorialOverlay` Flutter widget registered as a Flame overlay and shown automatically when the game screen opens Phase 1 for a new session; `GameManager` exposes a tutorial state (`GameState.tutorial`) during which belt time scale is 0 (or reduced, per Open Question 1); scrim uses a semi-transparent color from `lib/style/palette.dart`. |
| AC2 Animated tapping finger + mouth alternating open/closed in sync | Looping animation controller drives a finger tap (press scale + ripple) and swaps a mouth image open/closed on the same tick of the loop (single controller, so they cannot drift). |
| AC3 Candy/fruit icon -> green check; forbidden item (broccoli) -> red X | Two icon rows in the overlay: sweet + fruit sprites with a green check, broccoli sprite with a red X; icons are symbols only, no text; colors are high-contrast and not the only cue (shape differs: check vs X). |
| AC4 First tap fades overlay out (fade-out) and belt starts immediately | Full-screen tap target on the overlay; on tap, `GameManager` leaves `tutorial` state (belt starts at once, not after the fade), and the overlay plays a short opacity fade-out (about 250 ms) then is removed from the overlay stack. Tap is consumed only once. |
| AC5 Understood in under 3 seconds | One animation loop of at most 1.5 s showing two full open/close cycles within 3 s; zero text; maximum 3 visual groups (finger+mouth, check row, X row) laid out on one screen without scrolling. |

## Scope
- In:
  - `lib/ui/tutorial_overlay.dart` (presentational widget: receives `ValueListenable`/callback props, no game logic) and small private sub-widgets (finger, mouth, check/X row).
  - Tutorial state in the game domain: add the `tutorial` value to `GameState` and a `dismissTutorial()` transition in `GameManager` (`lib/game/managers/`), plus belt time-scale gating in the conveyor update (consumed from TASK-003 code).
  - Overlay registration/wiring in the game screen (`lib/flame_game/game_screen.dart` and the game class), overlay key constant.
  - Tutorial visuals in `assets/images/` as `.webp` (finger, open mouth, closed mouth if not already provided by TASK-002, green check, red X); reuse existing candy/fruit/broccoli sprites from TASK-003 where available; register in `pubspec.yaml` and preload with the other images.
  - Logic for "show only once per session" (see Open Questions 4).
- Out:
  - Title screen, JOGAR button, audio unlock, preloading screen: TASK-001.
  - Mouth tap toggle and input handling in gameplay: TASK-002.
  - Conveyor, spawning, scoring, HP, item sprites and `GameManager` base: TASK-003.
  - Phase transitions and speed multipliers: TASK-004.
  - Victory screen: TASK-005.
  - Persistent "tutorial seen" storage (no new persistence unless the PM answers Open Question 4 otherwise).
  - Writing tests (owned by test-author).
  - Removing the template `instructions_dialog.dart` (tracked under OBS-002).

## Atomic Sub-tasks
Each item is one unit for the orchestrate-phase loop (flutter-dev, audit, tests).
- [x] T1 - Add `tutorial` to `GameState` and `GameManager.dismissTutorial()` (tutorial -> playing, idempotent; double call is a no-op); entering Phase 1 from JOGAR starts in `tutorial`. _Verify:_ starting a game exposes `GameState.tutorial`; first `dismissTutorial()` yields running, second call changes nothing; manager has no Flutter/Flame imports.
- [x] T2 - Gate the conveyor and spawner on `GameState.tutorial` using `dt * timeScale` (0 or slow-motion factor held in the phase config const, not a scattered literal). _Verify:_ in tutorial state items do not advance (or advance at the reduced factor) and score/HP cannot change; on dismissal the belt moves at full Phase 1 speed on the next frame.
- [x] T3 - Create tutorial `.webp` assets (finger, green check, red X, mouth open/closed if missing) and register in `pubspec.yaml`; include in the preload list. _Verify:_ assets load without errors in `flutter build web --release`; total added payload is reported and the 3.5 MB budget is not exceeded.
- [x] T4 - Build `TutorialOverlay` widget: semi-transparent scrim, one looping `AnimationController` driving finger tap and mouth open/closed swap in sync, check row (sweet + fruit) and X row (broccoli), no text, `const` constructors, controller disposed in `dispose`. _Verify:_ on a 9:16 viewport all elements are visible without scroll; finger press and mouth change happen on the same loop tick; one loop is at most 1.5 s.
- [x] T5 - Add dismiss behavior: full-screen tap target calls `onDismiss` once, then the widget fades out (about 250 ms, `AnimatedOpacity`/`FadeTransition`) and signals removal. _Verify:_ first tap triggers `dismissTutorial()` immediately (belt moving while overlay still fading), overlay is gone after the fade, repeated taps during the fade do nothing.
- [x] T6 - Register the overlay in the game screen/game class (overlay key constant), show it when `GameState.tutorial` begins and remove it on dismissal; listen via `ValueListenable`, remove listeners on dispose. _Verify:_ tapping JOGAR leads to the overlay appearing with no extra tap; no leaked listeners after leaving the screen; restarting the game from the victory screen follows the decision in Open Question 4.
- [x] T7 - Ensure the dismissing tap behavior matches the decision for Open Question 2 (consume the tap versus also toggle the mouth) and that input is not double-handled between the overlay and the Flame tap handler. _Verify:_ one physical tap produces exactly one effect as specified; no mouth flicker on the first tap.
- [x] T8 - Self-audit and read-only verification. _Verify:_ `dart format --set-exit-if-changed lib` and `flutter analyze` are clean; `flutter build web --release` succeeds; no allocations added to `update`/`render` paths; English only.

## Definition of Done
- Every story AC above is demonstrably met.
- Performance/web constraints honored (60 FPS, no hot-path allocations, assets `.webp`/`.mp3`).
- Overlay holds no game logic; the tutorial state lives in `GameManager`.
- Tutorial adds no network calls, no text that requires reading, and does not auto-start BGM (audio unlock stays in TASK-001).
- Test coverage handoff for test-author: `GameManager` tutorial transitions (including idempotent dismissal), belt gating in tutorial state, and widget test for overlay dismissal (single callback, fade then removal).

## PM Decisions (resolved questions)
- Paused vs slow-motion: fully paused (time scale 0) during the tutorial.
- The dismissing tap only dismisses; it does not toggle the mouth.
- The belt starts at the instant of the tap; the first spawned item must be far enough from the mouth that the fade does not cost a decision window.
- Shown on every new game started from the title; not on instant restart from victory/game over; no persistence.
- Dismissal on a tap anywhere on screen.
- "Under 3 seconds": accepted as one loop of at most 1.5 s with all groups visible from frame 1; a hands-on check with a child is recommended before the party.
- Placeholders reuse TASK-002/003 art; art is owned by the product owner.
- `GameState.tutorial` is added by this task; `reset()` (TASK-005) returns to `playing`, not `tutorial`.
