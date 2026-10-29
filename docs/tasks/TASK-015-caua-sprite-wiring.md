---
id: TASK-015
story: US02
title: Point the game and its tests at the delivered Cauã sprites to fix the broken test suite
status: completa # proposta | aceita | em progresso | completa
depends_on: [] # task ids that must be completed first
supersedes: [] # TASK-002 and TASK-012 stay completa; this wires what they left stale
---

# TASK-015 - Point the game and its tests at the delivered Cauã sprites

## Objective
`main` has 8 failing tests since the placeholder `assets/images/caua_mouth_closed.webp` and `caua_mouth_open.webp` were removed (TASK-012 sprite set). The game loads the new sprites in `assets/images/caua/` and the suite is green again, with no new behavior.

## Source
- Observation: failing suite on `main` after PR #7 (reported by the TASK-013 and TASK-001 gate runs).
- Inputs: `assets/images/caua/caua_mouth_closed_eyes_open.webp`, `caua_mouth_open_eyes_open.webp` (final art, do not regenerate).

## Scope
- In: `lib/game/components/caua_player_component.dart` and `lib/game/caua_candies_game.dart` sprite names/paths (closed = `caua_mouth_closed_eyes_open`, open = `caua_mouth_open_eyes_open`, under the `caua/` folder); `test/assets/caua_mouth_sprites_test.dart` and `test/game/caua_game_screen_test.dart` updated to the new files and rules (exists, valid WebP, size budget, open and closed differ, `pubspec.yaml` declares `assets/images/caua/`).
- Out: blink, chewing and "eca" frames and any animation (TASK-009, TASK-011); new art; belt, items and HUD.

## Atomic Sub-tasks
- [x] T1 - Switch the player component and game preload to the new open/closed sprite paths. _Verify:_ `CauaCandiesGame.onLoad` and the component load without a missing-asset error.
- [x] T2 - Update the two stale test files to the new sprite files. _Verify:_ `flutter test` is fully green via `check-green.sh`.

## Definition of Done
- `flutter analyze` clean and `flutter test` green (exit 0 from `check-green.sh`).
- No reference to `assets/images/caua_mouth_open.webp` or `caua_mouth_closed.webp` remains.

## Open Questions
- None.
