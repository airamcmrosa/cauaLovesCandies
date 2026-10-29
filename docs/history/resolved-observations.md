---
title: Resolved Observations
status: Archive
schema_version: 1.0.0
indexed_by: AGENTS.md
---

# Resolved Observations

Items moved verbatim from `docs/observations-memory.md` once `Resolved` or `Won't Fix`.

## Index

| ID | Severity | Category | Target Artifact | Status | Short Summary | Resolution |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `OBS-004` | INFO | MAINTAINABILITY | `docs/`, `AGENTS.md` | Resolved | Project docs are untracked and not versioned | 2c4b6a1 |

---

## Detailed Items

### `OBS-004`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `docs/`, `AGENTS.md`
* **Source:** `manual / baseline commit`
* **Status:** Resolved
* **Finding:** Only this file and the agents/skill are versioned; the rest of `docs/` and `AGENTS.md` are untracked, though agents list them as resources.
* **Risk/Impact:** A fresh worktree from `main` lacks the docs the flow reads.
* **Resolution Trigger:** Commit `docs/` and `AGENTS.md` before the first `orchestrate-phase` run.
* **Resolved By:** 2c4b6a1 (docs and AGENTS.md committed)
