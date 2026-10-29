---
id: TASK-013
story: -
title: Apply the approved UX palette corrections (belt colors, tutorial check/cross, serrated forbidden aura)
status: completa # proposta | aceita | em progresso | completa
depends_on: [] # task ids that must be completed first
supersedes: [] # TASK-007 stays completa; its doc is amended here, see TASK-008 for the same pattern
---

# TASK-013 - Apply the approved UX palette corrections (belt colors, tutorial check/cross, serrated forbidden aura)

## Objective
Fix the contrast and color-blindness issues found in the UX review, so grape/gum items stay visible on the belt in every phase and forbidden items are recognizable by shape, not by color alone.

## Source
- UX review of `docs/product/design/color-palette.md` (high-priority findings 1 to 4), approved by the product owner.

## Scope
- In: `docs/product/design/color-palette.md` and `lib/style/palette.dart` (same hex values in both).
  - `belt-base` `#CDB8F0` -> `#BFA6EC`; `belt-stripe` `#B79CFF` -> `#8F72D6`; thick `ink` contour on the belt edges.
  - Tutorial check: `#2E9E6B` symbol on an `accent-mint` `#A8F0D1` circle; cross: cream symbol on `danger-soft` `#FF7A7A`; the symbol shape carries the meaning.
  - Composition rule 4 (forbidden items): serrated/wavy solid aura (shape, not glow) plus the "eca" face, only on hazards; sweets and fruits never have faces.
  - Gemini prompts (`gemini-art-prompts.md`) already cite the new belt values; align any leftover fallback mention.
- Out: the remaining medium/low findings (lemon outline, `ink-soft`, shirt color, phase confetti colors), not yet approved; widget restyling in the UI tasks.

## Atomic Sub-tasks
- [x] T1 - Update the palette doc tokens, rule 4 and the item/art tables. _Verify:_ the doc lists the new belt hexes, check/cross colors and the serrated-aura rule.
- [x] T2 - Update `lib/style/palette.dart` getters (`beltBase`, `beltStripe`) and add check/cross tokens if absent, without renaming existing getters. _Verify:_ `flutter analyze` clean; doc and code hex values identical.

## Definition of Done
- Doc and `palette.dart` hold identical hex values; existing `Palette` consumers compile unchanged.

## Open Questions
- None.
