# Tasks Index

One task per user story, plus corrective tasks. Template: [`TEMPLATE.md`](./TEMPLATE.md).
Only the Main Loop (PM) edits this index and task `status` fields.

**Statuses:** `proposta` → `aceita` → `em progresso` → `completa`

**Rule:** a `completa` task is never reopened. If it was done wrong, create a new task and
link both ways (`supersedes` in the new task, a "Superseded by" note in the old row).

| Task | Story | Title | Status | Depends on | File |
| :--- | :--- | :--- | :--- | :--- | :--- |
| TASK-001 | US01 | Build the animated title screen with JOGAR button, BGM unlock and asset preload | aceita | - | [TASK-001](./TASK-001-title-screen.md) |
| TASK-002 | US02 | Implement single-tap mouth open/close control | aceita | - | [TASK-002](./TASK-002-tap-mouth-control.md) |
| TASK-003 | US03 | Build conveyor belt with scored food items and HUD | aceita | TASK-002 | [TASK-003](./TASK-003-conveyor-scoring.md) |
| TASK-004 | US04 | Implement 3-phase progression with rising speed and phase banner | aceita | TASK-003 | [TASK-004](./TASK-004-phase-progression.md) |
| TASK-005 | US05 | Build victory celebration and friendly game-over screens with instant restart | aceita | TASK-003, TASK-004 | [TASK-005](./TASK-005-victory-screen.md) |
| TASK-006 | US06 | Add hands-on tutorial overlay at first play | aceita | TASK-002, TASK-003 | [TASK-006](./TASK-006-tutorial-overlay.md) |
