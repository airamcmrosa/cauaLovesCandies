---
id: TASK-000
story: US00
title: <short imperative title>
status: proposta # proposta | aceita | em progresso | completa
depends_on: [] # task ids that must be completed first
supersedes: [] # ids of wrongly completed tasks this one corrects (see README rules)
---

# TASK-000 - <title>

## Objective
One or two sentences: the user-visible outcome this task delivers.

## Source
- Story: `US00` (`docs/product/stories/user_stories_index_details.md`)
- Architecture: sections of `docs/architecture/architecture.md` it touches

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| AC1 | concrete behavior or artifact that satisfies it |

## Scope
- In: what this task builds (files/dirs under `lib/`, `assets/`).
- Out: neighboring concerns owned by other tasks (cite their ids).

## Atomic Sub-tasks
Each item is one unit for the orchestrate-phase loop (flutter-dev, audit, tests).
- [ ] T1 - <one-line text>. _Verify:_ <observable check>

## Definition of Done
- Every story AC above is demonstrably met.
- Performance/web constraints honored (60 FPS, no hot-path allocations, assets `.webp`/`.mp3`).

## Open Questions
- None, or a bullet per question for the PM.
