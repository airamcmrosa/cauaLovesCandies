@AGENTS.md

## Task Governance (`docs/tasks/`)

- Task statuses: `proposta` → `aceita` → `em progresso` → `completa`. The index is `docs/tasks/README.md`; only the Main Loop (PM) updates it and the task `status` fields.
- **A `completa` task is NEVER reopened.** If it was delivered wrong, create a NEW task that fixes it and link them both ways: `supersedes: [<old id>]` in the new task, and a "Superseded by <new id>" note on the old row in the index. The old task stays `completa`.
- The current task is indexed in Claude's memory (`MEMORY.md` → `current-task.md`); update it whenever a task changes to `em progresso` or `completa`.
