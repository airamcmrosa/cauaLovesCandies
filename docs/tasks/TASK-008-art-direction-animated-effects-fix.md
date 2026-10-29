---
id: TASK-008
story: -
title: Correct art prompts so stars/confetti are never baked into sprites, and specify the Cauã blink frames
status: completa # proposta | aceita | em progresso | completa
depends_on: [] # task ids that must be completed first
supersedes: [TASK-007] # TASK-007 pose prompts asked Gemini to draw stars (pose 3) and confetti (pose 5) inside the image
---

# TASK-008 - Correct art prompts so stars/confetti are never baked into sprites, and specify the Cauã blink frames

## Objective
Stars, sparkles and confetti must be animated in code, not drawn into images. Fix the art-direction doc so every future Gemini generation comes out clean, and define the file set for the Cauã blink animation.

## Source
- Story: none (corrects TASK-007, cross-cutting design enabler)
- Architecture: none touched

## Scope
- In: `docs/product/design/color-palette.md` (base prompt, poses 3 and 5, asset table, new "Frames de piscar" section, checklist); `docs/product/design/gemini-art-prompts.md` is produced by the UX review and already follows the same rule.
- Out: the animation code (TASK-009 blink, TASK-010 stars/confetti); generating the art (user, via Gemini).

## Atomic Sub-tasks
- [x] T1 - Add the "no stars/sparkles/confetti drawn" rule to the Gemini base prompt and remove the baked-in stars (pose 3) and confetti (pose 5). _Verify:_ no pose prompt asks for stars, sparkles or confetti around the character.
- [x] T2 - Mark confetti/stars in the asset table as code-animated (no sprite) and add the "Frames de piscar" section with the 6 file names under `assets/images/caua/`. _Verify:_ table lists `caua_mouth_{closed,open}_eyes_{open,half,shut}.webp`.
- [x] T3 - Extend the approval checklist (no baked effects, identical canvas across eye frames). _Verify:_ two new checklist items present.

## Definition of Done
- `color-palette.md` no longer instructs Gemini to draw stars or confetti.
- Blink frame naming is defined and referenced by TASK-009.

## Open Questions
- None.
