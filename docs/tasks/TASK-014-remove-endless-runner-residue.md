---
id: TASK-014
story: -
title: Remove Endless Runner template residue and keep only the reusable skeleton
status: completa
depends_on: []
supersedes: []
---

# TASK-014 - Remove Endless Runner template residue

## Objective
The repository contains only code and assets that belong to Cauã Loves Candies or that are an editable skeleton for it.

## Source
- Observation: `OBS-002` (resolved, see `docs/history/resolved-observations.md`)
- Architecture: project structure (`lib/`, `assets/`)

## Scope
- In: delete `lib/flame_game/`, `lib/level_selection/`, Dash/enemy/scenery art, `ember.png`, `banner.png`, runner SFX (jump, double jump, hit), `README copy.md`; trim `router.dart`, `SfxType`, main menu and `pubspec.yaml` assets; rewrite README and smoke test.
- Out: template BGM tracks (removed with TASK-001), `player_progress` and `playerName` (kept in settings).

## Atomic Sub-tasks
- [x] T1 - Audit `lib/`, `assets/`, tests and docs for template residue. _Verify:_ manifest of deleted and kept files.
- [x] T2 - Delete residue and fix references. _Verify:_ `flutter analyze` clean, `flutter test` green (86 tests).

## Definition of Done
- No reference to `EndlessRunner`, `EndlessWorld` or `level_selection` remains in `lib/`, `test/`, `pubspec.yaml`.
- Analyze and tests pass.

## Open Questions
- None.
