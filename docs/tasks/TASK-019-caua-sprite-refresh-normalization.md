---
id: TASK-019
story: -
title: Adopt the refreshed Cauã sprite set and normalize it to the TASK-017 invariants (post-processing only)
status: em progresso # proposta | aceita | em progresso | completa
depends_on: [] # none
supersedes: [] # TASK-017 stays completa; this re-applies its invariants to a new delivery
---

# TASK-019 - Adopt the refreshed Cauã sprite set and normalize it

## Objective
The product owner delivered a refreshed set of the 13 Cauã frames. After this task the game ships the refreshed art, and every frame still satisfies the TASK-017 invariants (same canvas, head size, anchor, skin tone, no halo), so swapping frames on screen causes no jump or color shift.

## Source
- Product owner decision (2026-10-31): normalize the refreshed frames instead of keeping the old ones.
- Inputs (outside the repo, never committed as-is): `../cauaLovesCandies-inputs/caua-refresh-2026-10-31/*.webp` (13 files, same names as `assets/images/caua/`). They were rejected by `test/assets/caua_frames_invariants_test.dart` when dropped in unmodified: opaque bbox top at 36-37 px instead of 26, bbox height 441 instead of 461 (tolerance 4), and partial-alpha pixels without a measurable halo check passing.
- Reference for the invariants: the committed frames on `main` (the TASK-017 result) and the test above.

## Scope
- In: post-processing the 13 inputs (scale and translate the head to 512x512 with the reference anchor, color-match skin, hair and shirt, clean edges without halo) and writing the result to `assets/images/caua/*.webp`; keeping or adjusting the invariants test only if the refreshed art legitimately changes a reference value (any change to a tolerance or reference needs a stated reason in the report).
- Out: regenerating or redrawing art, renaming frames, changing the `.webp` format or the 512x512 canvas, animation or gameplay code (TASK-009, TASK-011), the BGM (TASK-018).

## Atomic Sub-tasks
- [x] T1 - Measure the 13 inputs against the committed reference frames (opaque bbox, head height, anchor, mean skin, hair and shirt, halo) and choose the reference frames (default: the committed ones). _Verify:_ a table of the 13 frames with the deltas, written to the scratchpad or the report, not to the repo.
- [x] T2 - Normalize every input: scale and translate to the same canvas and anchor, color-match without banding, remove halo; keep inputs and intermediates out of `assets/`. _Verify:_ a contact sheet of the 13 frames on dark and magenta backgrounds shows no jump or tone shift, and the user compares old versus new.
- [x] T3 - Replace the 13 files in `assets/images/caua/` and run the invariants test unchanged. _Verify:_ `test/assets/caua_frames_invariants_test.dart` green, each frame 512x512 with real alpha and within the existing size limit (<= 30 KB), total asset payload still under 3.5 MB.
- [x] T4 - Full gate. _Verify:_ `dart format --set-exit-if-changed lib test`, `flutter analyze`, `flutter test` and `flutter build web --release` pass; sprite wiring tests (TASK-015) stay green.

## Definition of Done
- The refreshed art ships, all 13 frames pass the TASK-017 invariants, and the suite is green.
- The user has compared old and new in the contact sheet and approved the look.

## Open Questions
- Does the refreshed art change anything the product owner expects to be visible (expression, outfit, proportions) that normalization must preserve rather than match to the old reference? The coordinator reports the visual differences it sees in T1.
