---
id: TASK-017
story: -
title: Normalize the Cauã frames to one size, position and skin tone (post-processing only)
status: aceita # proposta | aceita | em progresso | completa
depends_on: [] # task ids that must be completed first
supersedes: [] # TASK-012 stays completa; this fixes inconsistencies seen when frames are swapped on screen
---

# TASK-017 - Normalize the Cauã frames

## Objective
When the title avatar or the game swaps Cauã frames, the face must not jump or change color. All 13 frames share the same head size, position on the canvas and skin tone.

## Source
- Product owner feedback during the TASK-001 HIL (2026-10-29): the transition sprites differ in skin color and size.
- Inputs: `assets/images/caua/*.webp` (13 frames). The three frames added later (`caua_chew_eyes_open`, `caua_mouth_closed_eyes_half`, `caua_mouth_open_eyes_open`) came from separate generations and differ from the ten earlier ones.

## Scope
- In: `assets/images/caua/*.webp` post-processing only (scale and align the head to the reference frames, color-match the skin tone and hair/shirt as needed), a test that locks the invariants.
- Out: regenerating or redrawing art (the owner does not want to regenerate sprites), changing frame names or the `.webp` format, animation code (TASK-009, TASK-011).

## Atomic Sub-tasks
- [ ] T1 - Measure every frame: opaque bounding box, head height, anchor point and mean skin color; choose the reference (the ten earlier frames). _Verify:_ a table of the 13 frames with the deltas to the reference.
- [ ] T2 - Normalize the outliers: scale and translate to the same canvas (512x512), same head size and anchor, and color-match the skin tone to the reference without banding or halo. Keep the unmodified masters out of `assets/`. _Verify:_ a contact sheet of all 13 frames on a dark and a magenta background shows no jump or tone shift.
- [ ] T3 - Lock the invariants with a test: same canvas size, head height and anchor within tolerance, mean skin color delta under a threshold. _Verify:_ `flutter test` green via `check-green.sh`.

## Definition of Done
- The 13 frames are visually consistent when swapped; sizes stay within the asset budget; the suite is green.

## Open Questions
- None.
