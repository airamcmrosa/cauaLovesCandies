---
id: TASK-012
story: -
title: Integrate the delivered Cauã sprite set (background removal, naming, missing frames, release format)
status: em progresso # proposta | aceita | em progresso | completa
depends_on: [] # task ids that must be completed first
supersedes: []
---

# TASK-012 - Integrate the delivered Cauã sprite set (background removal, naming, missing frames, release format)

## Objective
Turn the Gemini-generated Cauã images into game-ready transparent sprites with the names TASK-009 and TASK-011 load, and track what is still missing.

## Source
- Story: none (art pipeline enabler for TASK-009, TASK-011, TASK-005)
- Inputs: the `.jpeg`/`.jpg` masters in `assets/images/caua/` (cream background with a white sticker border)

## Scope
- In: `assets/images/caua/` outputs, naming, the "Frames do Cauã" section of `color-palette.md`, Gemini prompts for missing frames (`gemini-art-prompts.md`, section 6), release-format conversion.
- Out: loading/animating the sprites (TASK-009, TASK-011, TASK-005).

## Atomic Sub-tasks
- [x] T1 - Remove the background of the 10 kept images (an 11th, an unused smiling variant, was discarded by the product owner) and export 512x512 PNGs with alpha, keeping the white sticker border. Method: threshold on the white border, flood the connected non-white region from the image edge as background, keep the largest blob, 1 px feather. Side effect: the confetti and stars baked into the 3 `win` images are dropped with the background. _Verify:_ preview on a dark background shows clean edges and no cream fringe (done, 10/10).
- [x] T2 - Map file names to the pose model and update `color-palette.md` ("Frames do Cauã"). Mapping used: `happy-eyes-open` -> `caua_mouth_closed_eyes_open`; `happy-eyes-closed` -> `caua_mouth_closed_eyes_shut`; `waiting-mouth-open-semi-open-eyes` -> `caua_mouth_open_eyes_half`; `waiting-mouth-open-eyes-closed` -> `caua_mouth_open_eyes_shut`; `eating-eyes-semi-open` -> `caua_chew_eyes_half`; `eating-mouth-closed-eyes-closed-2` -> `caua_chew_eyes_shut`; `erk` -> `caua_eca`; `win-eyes-{open,semi-open,closed}` -> `caua_win_eyes_{open,half,shut}`. _Verify:_ 10 PNGs present with these names (done).
- [ ] T3 - Product owner generates the 3 missing frames with the section 6 prompts: `caua_mouth_closed_eyes_half`, `caua_mouth_open_eyes_open`, `caua_chew_eyes_open`; drop the images in `assets/images/caua/` and rerun the cutout. _Verify:_ 3 more PNGs present and visually consistent with their siblings.
- [ ] T4 - Release format: convert the sprites to `.webp` with alpha (`cwebp`), move the original `.jpeg`/`.jpg` masters and PNG masters out of `assets/` (for example to `.dev/art-source/caua/`) so they do not ship, and report sizes. Reason: the 10 PNGs weigh about 1.9 MB together (about 185 KB each, 220 KB for `win`), too much for the 3.5 MB total budget. _Verify:_ `assets/images/caua/` holds only `.webp`; combined size reported and well under budget; TASK-009 registers the folder in `pubspec.yaml`.

## Definition of Done
- All 13 frames (9 blink + 3 chew + `eca`) exist as transparent assets with the agreed names; only `.webp` ships.

## Open Questions
- None. The unused smiling variant (`eating-mouth-closed-eyes-closed.jpeg` and its PNG) was discarded by the product owner.
