---
title: Pending Observations Memory
status: Reference (Living Memory)
purpose: Durable backlog of non-blocking observations (INFO/WARNING) surfaced by reviews
indexed_by: AGENTS.md
---

# Pending Observations Memory

Durable, append-only memory of non-blocking observations raised during reviews
(spec reviews, code reviews, audits). A finding lands here when it is real but
does NOT block the current artifact: typically `INFO` and non-cosmetic `WARNING`
items from a `SpecReviewReport`, or deferred follow-ups.

This is a backlog, not a changelog. Blockers are never parked here: they must be
fixed before the artifact is committed. This file holds only `Open` and
`In Progress` items. When an observation is resolved (`Resolved` or `Won't Fix`),
its index row and full detail block are migrated verbatim to the archive at
[`docs/history/resolved-observations.md`](/docs/history/resolved-observations.md)
and removed entirely from this file, to keep this working memory lean and avoid
context bloat (AGENTS.md §10.C). The resolving commit SHA or ADR id is recorded on
the migrated entry, so audit history is preserved in the archive (append-only).

## Conventions

- **ID:** `OBS-XXX`, zero-padded, never reused.
- **Status:** `Open`, `In Progress`, `Resolved`, `Won't Fix`.
- **Source:** where it came from (for example `spec-reviewer / infra-tier3-provisioning / F1`).
- When an item reaches `Resolved` / `Won't Fix`, migrate its row and detail block
  to `docs/history/resolved-observations.md` (with the resolving commit SHA or ADR
  id appended) and remove it from this file. Do not keep resolved rows here.
- Do not use em dashes in files authored in this repository tier where that rule applies.

## Observation Index

| ID | Severity | Category | Summary | Source | Target | Status |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- |