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
## TASK-001 - Animated title screen (US01)

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | Product assets and single BGM track | committed | 60f7139 |
| T2 | AssetPreloader | committed | 2f4ac89 |
| T3 | AudioController unlock and manifests | committed | bf097de |
| T4 | TitleScreen and sub-widgets | committed | 25c3ab0 |
| T5 | Router wiring | todo | - |
| T6 | Self-audit pass | todo | - |

## TASK-002 - Single-tap mouth control (US02)

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | MouthState enum and MouthController | committed | 9951742 |
| T2 | Open/closed Caua sprites (.webp) | committed | 480785d |
| T3 | CauaPlayerComponent | committed | 01076f7 |
| T4 | CauaCandiesGame with tap input | committed | ed43ea3 |
| T5 | Route/entry for manual verification | committed | be7f350 |

## TASK-014 - Remove Endless Runner template residue

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | Audit lib, assets, tests and docs for template residue | committed | 52a87ee |
| T2 | Delete residue and fix references | committed | 52a87ee |

## TASK-013 - UX palette corrections

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | Palette doc tokens, rule 4 and art tables | committed | c7be0de |
| T2 | palette.dart getters | committed | 547b686 |

## TASK-015 - Caua sprite wiring

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | Player component loads the delivered open/closed sprites | committed | fdfa0d7 |
| T2 | Stale sprite test updated to assets/images/caua | committed | fdfa0d7 |
