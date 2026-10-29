### Product Vision & Scope (Executive Summary)
- **Stack & Infra:** 100% client-side 2D arcade game built with Flutter + Flame Engine, targeting mobile browsers via static hosting (GitHub Pages/Vercel) at zero infrastructure cost.
- **UX & Audience:** Frictionless web access via QR Code (no login/install) tailored for 6-year-olds at Cauã's birthday party (hard deadline: Nov 4, 2026).
- **Core Loop:** Responsive single-tap control toggling Cauã's mouth state (open/closed) against a conveyor belt: Sweets (+2 pts), Fruits (+1 pt), Forbidden Items (-1 HP).
- **Progression & Outcome:** 3 progressive speed tiers (L1: 10 pts, L2: 20 pts, L3: final celebration challenge) ending in an individual confetti victory screen with guaranteed positive reinforcement.
- **Performance Budget:** Ultra-lean static assets (`.webp` / compressed `.mp3` under `assets/`), sub-3s first load over 4G, and preloaded assets during initial title animation.

### Key Development Directories & Context Mapping
- `lib/game/`: Core gameplay domain (custom Flame game loop, player mouth state, conveyor belt logic, scoring/HP managers).
- `lib/flame_game/`: Reusable baseline components from Flutter template (`components/`, `effects/`, `endless_world.dart`).
- `lib/audio/`: Sound effect handlers, BGM controllers, and track manifests.
- `lib/ui/`: Flutter overlay widgets, HUD (score & HP counter), interactive tutorial overlay, and celebration dialogs.
- `assets/`: Static game bundles (`assets/images/`, `assets/sfx/`, `assets/music/`).
- `docs/`: System documentation loaded on-demand (`docs/architecture/` and `docs/product/stories/` for JIT story context).

### Orchestration & Governance Rule
- **Main Loop as Sole Coordinator:** The Main Loop/Lead Agent operates strictly as the central coordinator for all code-implementation tasks. Sub-agents or delegated execution units may only modify local code. **Only the Main Loop is authorized to commit, push to Git, and perform project bookkeeping (e.g., updating user story status, implementation-index, task indexes, or progress logs).**

## Rules: 

#### Non-Blocking Observations & Living Memory

### 1. Classification & Ingestion
* Any non-blocking finding (`INFO`, non-cosmetic `WARNING`) raised during spec review or code audit MUST be registered in `docs/observations-memory.md`.
* Blockers (`CRITICAL`, `ERROR`) are STRICTLY FORBIDDEN in memory files; they must be resolved before artifact merge.

### 2. Context Protection & Lean Memory
* `docs/observations-memory.md` MUST ONLY contain `Open` or `In Progress` entries.
* Narrative prose, conversational logs, and session diaries are strictly prohibited.
* **Migration Rule:** When an item transitions to `Resolved` or `Won't Fix`, the agent MUST move both the table row and the detail block verbatim to `docs/history/resolved-observations.md`, appending the resolving commit SHA, PR number, or ADR reference, and delete it from `docs/observations-memory.md`.

### 3. Human Presentation Protocol
* When a human operator requests pending observations, the agent MUST NOT output raw file contents or conversational commentary.
* The output MUST follow this strict condensed format:
  ```text
  [<ID>] <SEVERITY> | <CATEGORY> | Target: <TARGET>
  Summary: <SHORT_SUMMARY>
  Action: <RESOLUTION_TRIGGER>

#### Implementation Progress Index Governance

### 1. Authority & Scope
* The implementation progress index is the single machine-readable source of truth for code delivery state.
* It is distinct from `tasks.md` (the static planned design) and `CHANGELOG.md` (the human release log).

### 2. Operational Invariants
* **Read-Before-Execute:** Agents MUST read this index before starting work to identify the active resume point.
* **Atomic Transition Commit:** When completing a task, the agent MUST update its state and commit SHA in the exact same commit that delivers the code changes.
* **Zero Narrative & Zero Log Dumps:** The table MUST NOT store test coverage dumps, execution terminal logs, or session diaries.
* **Field Integrity:**
  * `State`: Strict enum: `todo` | `in_progress` | `committed`.
  * `Commit SHA`: 7-character hexadecimal SHA. No parenthetical essays. If grouped into an atomic scaffold unit, cite only the shared SHA and the ADR reference.

### 3. Human Presentation Protocol
When instructed to report progress, the agent MUST output strictly in this condensed format:
```text
Component: <COMPONENT_NAME> (<SPEC_NAME>)
Status: <COMPLETED_TASKS>/<TOTAL_TASKS> tasks committed (<PERCENTAGE>%)
Active: Task <TASK_ID> - <SUMMARY> (<STATE>)
Next: Task <TASK_ID> - <SUMMARY>