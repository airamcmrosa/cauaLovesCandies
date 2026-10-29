---
title: Active Observations Memory
status: Living Memory
schema_version: 1.0.0
indexed_by: AGENTS.md
---

# Active Observations Memory

Lean, append-only registry of non-blocking observations (INFO / WARNING). Blocker items (CRITICAL / ERROR) are strictly prohibited here and must be resolved prior to artifact approval.

## Field Schema
* **ID:** `OBS-XXX` (sequential, zero-padded, unique, never recycled).
* **Severity:** `INFO` | `WARNING`.
* **Category:** `ARCHITECTURE` | `SECURITY_PRIVACY` | `STATE_INTEGRITY` | `OPERABILITY_NFR` | `PERFORMANCE` | `MAINTAINABILITY`.
* **Status:** `Open` | `In Progress`.

---

## Observation Index

| ID | Severity | Category | Target Artifact | Status | Short Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `OBS-001` | INFO | SECURITY_PRIVACY | `infra/bootstrap/main.tf` | Open | Wildcard resource scope in IAM bootstrap deploy policy |
| `OBS-002` | INFO | STATE_INTEGRITY | `apps/dashboard/core/contract.ts` | Open | SignalR contract unmerged; consuming temporary typed stub |
| `OBS-003` | WARNING | OPERABILITY_NFR | `infra/specs/waf/requirements.md` | Open | Missing CloudWatch metrics and sampling logs on WAF rule |

---

## Detailed Items

### `OBS-001`
* **Severity:** INFO
* **Category:** SECURITY_PRIVACY
* **Target:** `infra/bootstrap/main.tf`
* **Source:** `spec-reviewer / infra-tier3-provisioning / F1`
* **Status:** Open
* **Finding:** IAM policy claims scoped Secrets Manager access but omits explicit statement and defaults to `resources=["*"]` on ECS/ECR actions.
* **Risk/Impact:** Over-permissive deployment credentials violating least-privilege boundaries.
* **Resolution Trigger:** Next infrastructure refactor or dedicated IAM hardening task.

### `OBS-002`
* **Severity:** INFO
* **Category:** STATE_INTEGRITY
* **Target:** `apps/dashboard/core/contract.ts`
* **Source:** `manual / PR #1 review`
* **Status:** Open
* **Finding:** SignalR contract dependency unmerged in `shared-contracts/`. Interim typed stub active.
* **Risk/Impact:** Potential schema divergence if PR #1 contract evolves before integration.
* **Resolution Trigger:** Merge of PR #1 and update to shared contracts package.

### `OBS-003`
* **Severity:** WARNING
* **Category:** OPERABILITY_NFR
* **Target:** `infra/specs/waf/requirements.md`
* **Source:** `spec-reviewer / infra-tier3-provisioning / F1`
* **Status:** Open
* **Finding:** WAF edge rate-limit rule (2000 req / 5-min) lacks metrics emission and sample request logging.
* **Risk/Impact:** Operators cannot validate false positives or rule evasion without manual log aggregation.
* **Resolution Trigger:** ADR-020 phase 2 rollout (observability baseline tasks).