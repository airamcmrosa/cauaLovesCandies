# Tasks Index

One task per user story, plus corrective tasks. Template: [`TEMPLATE.md`](./TEMPLATE.md).
Only the Main Loop (PM) edits this index and task `status` fields.

**Statuses:** `proposta` → `aceita` → `em progresso` → `completa`

**Rule:** a `completa` task is never reopened. If it was done wrong, create a new task and
link both ways (`supersedes` in the new task, a "Superseded by" note in the old row).

| Task | Story | Title | Status | Depends on | File |
| :--- | :--- | :--- | :--- | :--- | :--- |
| TASK-001 | US01 | Build the animated title screen with JOGAR button, BGM unlock and asset preload | aceita | - | [TASK-001](./TASK-001-title-screen.md) |
| TASK-002 | US02 | Implement single-tap mouth open/close control | completa | - | [TASK-002](./TASK-002-tap-mouth-control.md) |
| TASK-003 | US03 | Build conveyor belt with scored food items and HUD | em progresso | TASK-002 | [TASK-003](./TASK-003-conveyor-scoring.md) |
| TASK-004 | US04 | Implement 3-phase progression with rising speed and phase banner | aceita | TASK-003 | [TASK-004](./TASK-004-phase-progression.md) |
| TASK-005 | US05 | Build victory celebration and friendly game-over screens with instant restart | aceita | TASK-003, TASK-004, TASK-010 | [TASK-005](./TASK-005-victory-screen.md) |
| TASK-006 | US06 | Add hands-on tutorial overlay at first play | aceita | TASK-002, TASK-003 | [TASK-006](./TASK-006-tutorial-overlay.md) |
| TASK-007 | - | Define the Candy Pastel palette and Cauã character art direction, and apply the palette to lib/style | completa (Superseded by TASK-008) | - | [TASK-007](./TASK-007-visual-identity-palette.md) |
| TASK-008 | - | Correct art prompts so stars/confetti are never baked into sprites, and specify the Cauã blink frames | completa | - | [TASK-008](./TASK-008-art-direction-animated-effects-fix.md) |
| TASK-009 | US02 | Animate Cauã blinking with the open, half and closed eye sprites | aceita | TASK-002, TASK-003 | [TASK-009](./TASK-009-caua-blink-animation.md) |
| TASK-010 | US05 | Build reusable animated stars and confetti particle effects (victory burst and hit sparkle) | aceita | TASK-003 | [TASK-010](./TASK-010-animated-stars-confetti.md) |
| TASK-011 | US03 | Add Cauã chewing and "eca" reactions and enforce arrival spacing that respects their duration | aceita | TASK-002, TASK-003, TASK-009 | [TASK-011](./TASK-011-caua-reactions-chewing-eca.md) |
| TASK-012 | - | Integrate the delivered Cauã sprite set (background removal, naming, missing frames, release format) | completa | - | [TASK-012](./TASK-012-caua-sprite-set-integration.md) |
| TASK-013 | - | Apply the approved UX palette corrections (belt colors, tutorial check/cross, serrated forbidden aura) | completa | - | [TASK-013](./TASK-013-ux-palette-corrections.md) |
| TASK-014 | - | Remove Endless Runner template residue and keep only the reusable skeleton | completa | - | [TASK-014](./TASK-014-remove-endless-runner-residue.md) |
| TASK-015 | US02 | Point the game and its tests at the delivered Cauã sprites to fix the broken test suite | completa | - | [TASK-015](./TASK-015-caua-sprite-wiring.md) |
| TASK-016 | - | Show a friendly full-screen error with a reload button on any uncaught failure | em progresso | - | [TASK-016](./TASK-016-global-error-screen.md) |
| TASK-017 | - | Normalize the Cauã frames to one size, position and skin tone (post-processing only) | aceita | - | [TASK-017](./TASK-017-caua-sprite-normalization.md) |
