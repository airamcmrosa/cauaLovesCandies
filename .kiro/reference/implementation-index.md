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
| T5 | Router wiring | committed | e94cfcc |
| T6 | Self-audit pass | committed | 7400c93 |
| T7 | Falling candies on the title edges | committed | 2a1a9c2 |

## TASK-002 - Single-tap mouth control (US02)

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | MouthState enum and MouthController | committed | 9951742 |
| T2 | Open/closed Caua sprites (.webp) | committed | 480785d |
| T3 | CauaPlayerComponent | committed | 01076f7 |
| T4 | CauaCandiesGame with tap input | committed | ed43ea3 |
| T5 | Route/entry for manual verification | committed | be7f350 |

## TASK-003 - Conveyor belt, scoring and HUD (US03)

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | Pure projection and ingest/deflect decision | committed | 8d1d414 |
| T2 | ItemType catalog and PhaseConfig table | committed | c430e25 |
| T3 | GameManager with score, HP and level | committed | 774d7a5 |
| T4 | ConveyorBeltComponent | committed | 5aa4eb7 |
| T5 | FoodItemComponent | committed | e970d10 |
| T6 | ItemSpawnerComponent | committed | 04042c8 |
| T7 | Item sprites and SFX registration | committed | e7e22da |
| T8 | GameHud overlay | committed | f2625df |
| T9 | World and screen wiring | committed | 05edb96 |
| T10 | Reaction sounds eurk and hmm | committed | cc78420 |

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

## TASK-016 - Global error screen

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | ErrorScreen and reload abstraction | committed | 0d55a17 |
| T2 | Error reporter and global hooks in main.dart | committed | 6d3a715 |
| T3 | Self-audit pass | committed | c755519 |

## TASK-017 - Caua frame normalization

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | Measure the 13 frames | committed | 3d61618 |
| T2 | Normalize the three outlier frames | committed | 3d61618 |
| T3 | Invariants test | committed | 3d61618 |

## TASK-009 - Caua blink animation (US02)

| Task | Summary | State | Commit SHA |
| :--- | :--- | :--- | :--- |
| T1 | EyeState and BlinkController | committed | ea0793f |
| T2 | Eye-state sprites | committed | 73aaf6a |
| T3 | CauaPlayerComponent blink table | committed | ca97f7e |
| T4 | blinkEnabled wiring and reset | in_progress | - |
| T5 | Self-audit pass | todo | - |
