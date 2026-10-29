---
title: Implementation Progress Index
status: Reference (agent-readable implementation state)
---

# Implementation Progress Index

Agent-facing (Kiro/Claude) source of truth for **implementation** state. It is distinct from:

- the per-tier `tasks.md` (the authored plan), and
- `CHANGELOG.md` (the released-change log).

An agent MUST read this index before starting or resuming work, and MUST update the
relevant row in the same task-scoped commit that lands a task (ADR-023 Decisions 1,
5, 7). States: `todo`, `in progress`, `committed`. Committed rows keep their commit
SHA as append-only history.

---
## TASK-002 - Single-tap mouth control (US02)

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | MouthState enum and MouthController | committed | 9951742 |
| T2 | Open/closed Caua sprites (.webp) | committed | 480785d |
| T3 | CauaPlayerComponent | committed | PENDING |
| T4 | CauaCandiesGame with tap input | todo | - |
| T5 | Route/entry for manual verification | todo | - |
