---
title: Active Observations Memory
status: Living Memory
schema_version: 1.0.0
indexed_by: AGENTS.md
---

# Active Observations Memory

Lean, append-only registry of non-blocking observations (INFO / WARNING). Blocker items (CRITICAL / ERROR) are strictly prohibited here and must be resolved prior to artifact approval. Resolved items move to `docs/history/resolved-observations.md`.

## Observation Index

| ID | Severity | Category | Target Artifact | Status | Short Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `OBS-001` | WARNING | OPERABILITY_NFR | `.github/workflows/deploy.yml` | Open | GitHub Pages deploy workflow referenced in architecture but not created |
| `OBS-002` | INFO | MAINTAINABILITY | `lib/flame_game/endless_runner.dart` | Open | Template names (`EndlessRunner`, `EndlessWorld`) still in use |
| `OBS-003` | INFO | MAINTAINABILITY | `.kiro/skills/new-adr/`, `.kiro/reference/` | Open | Legacy content from the previous project (ADR skill, PIT-002/003, pending observations) |
| `OBS-005` | INFO | OPERABILITY_NFR | `.claude/agents/` | Open | Custom sub-agent types load only at session start; fallback is general-purpose |
| `OBS-006` | INFO | MAINTAINABILITY | repo root, `.gitignore` | Open | Stray files (`.gitignore copy`, `README copy.md`, `.idx/`) and local folder name mismatch |
| `OBS-007` | INFO | ASSET_BUDGET | `assets/images/caua_mouth_*.webp`, `assets/images/README.md` | Open | Placeholder Caua sprites are 512x512 and the README CC0 header does not cover them |
| `OBS-008` | WARNING | PERFORMANCE_NFR | `build/web`, `assets/music/` | Open | Release build is 45 MB (canvaskit 36 MB, template music 4.4 MB); 3.5 MB payload and 3 s 4G budgets unmeasured |

---

## Detailed Items

### `OBS-001`
* **Severity:** WARNING
* **Category:** OPERABILITY_NFR
* **Target:** `.github/workflows/deploy.yml`
* **Source:** `manual / repo rename review`
* **Status:** Open
* **Finding:** `docs/architecture/architecture.md` section 6 describes a GitHub Actions deploy to GitHub Pages with `--base-href "/cauaLovesCandies/"`, but no `.github/workflows/` exists.
* **Risk/Impact:** No automated static delivery; base-href is only validated by hand.
* **Resolution Trigger:** Story or task that implements CI/CD and Pages deployment.

### `OBS-002`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `lib/flame_game/endless_runner.dart`
* **Source:** `manual / package rename review`
* **Status:** Open
* **Finding:** The package was renamed to `caua_loves_candies`, but the game class `EndlessRunner`, `EndlessWorld` and the Dash/enemy template assets remain.
* **Risk/Impact:** Template mechanics may be mistaken for product patterns by sub-agents reading `lib/**`.
* **Resolution Trigger:** Tasks that replace the endless runner loop with the conveyor belt game.

### `OBS-003`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `.kiro/skills/new-adr/`, `.kiro/reference/pitfalls/`, `.kiro/reference/pending/`
* **Source:** `manual / agent roster adaptation`
* **Status:** Open
* **Finding:** These files still describe the previous project (ADRs, `apps/dashboard`, .NET tiers, a separate pending-observations file duplicating this registry).
* **Risk/Impact:** Conflicting governance sources; agents may follow obsolete rules.
* **Resolution Trigger:** Dedicated cleanup task: remove or rewrite them and keep this file as the single registry.

### `OBS-005`
* **Severity:** INFO
* **Category:** OPERABILITY_NFR
* **Target:** `.claude/agents/`
* **Source:** `manual / DEP-1 delegation`
* **Status:** Open
* **Finding:** Agents defined mid-session (for example `flutter-dev`) cannot be invoked by `subagent_type` until the Claude Code session restarts.
* **Risk/Impact:** Delegation silently falls back to a general-purpose agent with the role rules in the brief.
* **Resolution Trigger:** First session started after this PR merges; confirm `flutter-dev` resolves by name.

### `OBS-006`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** repo root, `.gitignore`
* **Source:** `manual / .gitignore review`
* **Status:** Open
* **Finding:** Untracked `.gitignore copy`, `README copy.md` and `.idx/`; `.gitignore` carries a stray `.README copy.md` entry; the local folder is still named `cauaLoveCandies` while the repository is `cauaLovesCandies`.
* **Risk/Impact:** Clutter and confusion between local path and remote name.
* **Resolution Trigger:** Owner removes the copies and renames the local folder outside the session.

### `OBS-007`
* **Severity:** INFO
* **Category:** ASSET_BUDGET
* **Target:** `assets/images/caua_mouth_closed.webp`, `assets/images/caua_mouth_open.webp`, `assets/images/README.md`
* **Source:** `audit / TASK-002 T2`
* **Status:** Open
* **Finding:** Generated placeholder sprites are 512x512 and the README header attributes all art in the directory to CC0 (Erick Zanardo), with only a one-line placeholder exception.
* **Risk/Impact:** Licensing note may become stale once final art lands; 512 px may exceed the on-screen size.
* **Resolution Trigger:** Delivery of the final Caua art: update the README licensing note and downsize if the on-screen sprite is much smaller.

### `OBS-008`
* **Severity:** WARNING
* **Category:** PERFORMANCE_NFR
* **Target:** `build/web`, `assets/music/`
* **Source:** `build log / TASK-002 T2`
* **Status:** Open
* **Finding:** `flutter build web --release` output is 45 MB on disk: `canvaskit` 36 MB (only one variant is fetched by the browser), template `assets/music` 4.4 MB, `main.dart.js` 2.7 MB.
* **Risk/Impact:** Payload under 3.5 MB and first load under 3 s on 4G are not verified; template music inflates the bundle.
* **Resolution Trigger:** TASK-001 (preload and BGM) or a dedicated task: measure transferred bytes over throttled 4G, drop unused template assets, consider the skwasm/html renderer.
