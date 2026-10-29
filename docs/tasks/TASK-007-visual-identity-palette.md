---
id: TASK-007
story: -
title: Define the Candy Pastel palette and Cauã character art direction, and apply the palette to lib/style
status: completa # proposta | aceita | em progresso | completa
depends_on: [] # task ids that must be completed first
supersedes: [] # ids of wrongly completed tasks this one corrects (see README rules)
---

# TASK-007 - Define the Candy Pastel palette and Cauã character art direction, and apply the palette to lib/style

## Objective
Give the game a single child-friendly "color candies" visual identity and a consistent Cauã character brief, so the Gemini-generated art (TASK-001..006) and the Flutter UI share the same colors.

## Source
- Story: none (cross-cutting design enabler for all stories)
- Architecture: none touched

## Scope
- In: `docs/product/design/color-palette.md` (tokens, composition rules, Gemini base prompt, character traits, pose prompts, approval checklist); `lib/style/palette.dart` (existing getters remapped to the new tokens, new token getters added).
- Out: generating the art (user, via Gemini); restyling `WobblyButton` / `NesButton` and `main.dart` theme (follow-up inside the UI tasks); per-asset integration.

## Atomic Sub-tasks
- [x] T1 - Write the palette and art-direction doc. _Verify:_ file exists with tokens, prompts and checklist.
- [x] T2 - Add character section and pose prompts using `.dev/test-runs/` references. _Verify:_ five pose prompts present.
- [x] T3 - Apply the palette to `lib/style/palette.dart` without renaming used getters. _Verify:_ `flutter analyze` reports no issues.

## Definition of Done
- Doc and `palette.dart` hold identical hex values.
- Existing `Palette` consumers (router, main, menu, settings, level selection, win dialog) compile unchanged.

## Open Questions
- None.
