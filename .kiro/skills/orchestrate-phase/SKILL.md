---
name: orchestrate-phase
description: Main Loop flow to deliver a story/phase one atomic task at a time in an isolated git worktree. Checks the worktree, creates a new worktree and branch from main, then per task delegates concise briefs to flutter-dev, quality-analyzer, a human-in-the-loop checkpoint, test-author, build-test-runner (run tests) and build-test-runner (artifact, gated by a deterministic green-check script). Only the Main Loop does bookkeeping, commit and push. Use when asked to implement or complete a story, phase or task range.
---

# Orchestrate a Phase (Main Loop)

Deliver one story/phase **one atomic task at a time**, in an isolated worktree.
Normative rules live in `AGENTS.md` (Orchestration & Governance, Observations Memory,
Implementation Progress Index) and in `docs/architecture/architecture.md`. This skill
owns the *loop*, not new rules.

Target: **$ARGUMENTS** (a story under `docs/product/stories/` plus a phase or task
range). If empty or ambiguous, read the story and ask before touching anything.

## Roles (binding)

Only the **Main Loop** (this session; `main_agent` / `kiro_default` in kiro-cli) does
bookkeeping, `git commit` and `git push`. Sub-agents write files and hand back; they
never run git or touch bookkeeping files.

| # | Step | Who | Artifact (repo root, gitignored `.dev/`) |
| :-- | :-- | :-- | :-- |
| 1 | Implement | `flutter-dev` | production files in `lib/**`, `assets/**`, `pubspec.yaml` |
| 2 | Quality analysis | `quality-analyzer` (read-only) | `.dev/audits/task-<id>-audit.json` |
| 3 | HIL checkpoint | human (asked by Main Loop) | approval recorded in the Main Loop reply |
| 4 | Author tests | `test-author` | `test/**` + `.dev/test-authoring/task-<id>-tests.json` |
| 5 | Run tests | `build-test-runner` (stage A) | `.dev/test-runs/task-<id>-<YYYYMMDD-HHMMSS>.log` |
| 6 | Generate artifact | `build-test-runner` (stage B) + `scripts/check-green.sh` | `.dev/test-runs/task-<id>-verification.json` |
| 7 | Bookkeeping, commit, push | Main Loop | commit SHA in the implementation index |

**Artifact rule.** No step advances on a verbal verdict. A missing artifact is a hard
STOP for the task. Step 6 is GREEN only if `check-green.sh` exits 0; the agent's
opinion of the log is never the source of truth.

## Delegation mechanics

Each sub-agent runs in its own context.

- **Claude Code (default):** Agent tool with `subagent_type` set to `flutter-dev`,
  `quality-analyzer`, `test-author` or `build-test-runner` (defined in
  `.claude/agents/<name>.md`).
- **kiro-cli:** `kiro-cli chat --agent <name> --no-interactive "<brief>"` (defined in
  `.kiro/agents/<name>.json`). Requires the Main Loop agent to allow `kiro-cli`.
- **Neither available:** STOP and tell the owner. Do not silently self-perform the
  roles; Direct Action Mode needs explicit owner authorization, and every gate
  artifact must still be produced.

**Brief rule (concise, relevant only).** Each brief carries just: task id and text,
closed requirement/acceptance ids, the exact doc sections or files to read (paths with
section names, never "read the docs"), the files changed so far (steps 2+), and the
artifact path to write. No history, no neighboring tasks, no pasted file contents.
Template:

```text
Task <id>: <one-line text>. Closes: <ids>.
Read only: <story path + section>, <architecture section>, <files>.
Do: <the single job for this role>. Do not: <out-of-scope for this role>.
Write: <artifact path>. Return: <=5 lines (status + artifact path).
```

## Preconditions (once, before the loop)

1. **Worktree check.** Run `git worktree list` and `git status --porcelain` in the
   current checkout. Report existing worktrees and uncommitted changes to the user.
   Never delete or reuse a worktree you did not create in this run.
2. **Create a fresh worktree and branch from `main`:**

   ```sh
   git worktree add ../cauaLovesCandies-wt/<branch> -b <branch> main
   ```

   `<branch>` = `feat/<story-slug>-phase-<n>` (or `-tasks-<a>-<b>`). If the branch
   already exists, pick a new name; never reset or force it. Do all remaining work with
   the worktree as working directory.
3. **Base sanity.** In the worktree confirm `pubspec.yaml`, `lib/`, `docs/` and
   `.kiro/agents/` exist. Files that are untracked on `main` do NOT appear in a new
   worktree; if the base is missing, STOP and report instead of copying files in.
4. **Read the plan and state.** Read the story's task list and the implementation
   index (AGENTS.md: Read-Before-Execute) to find the ordered open tasks. Respect
   order; never batch. If a task's code already exists and verifies, reconcile the
   index instead of re-implementing.
5. **Preflight.** `flutter pub get` once in the worktree.

## Per-task loop (current atomic task `T`)

### 1. Implement (`flutter-dev`)
Brief: task, acceptance ids, the story section and architecture section it touches,
target files if known. Implement only `T`; no tests, no git. Read back the changed
file list.

### 2. Quality analysis (`quality-analyzer`)
Brief: task, acceptance ids, changed files. Read the persisted audit.
- `REJECTED` or any `CRITICAL`/`ERROR`: back to step 1 with the specific findings,
  then re-audit.
- Non-blocking `INFO` / non-cosmetic `WARNING`: register in
  `docs/observations-memory.md` (Main Loop only; blockers never go there).

### 3. HIL checkpoint (human in the loop)
Stop and show the user a condensed summary: task, files changed, audit verdict, open
non-blocking findings. Ask for explicit approval to proceed to tests. On rejection or
change requests, return to step 1 with the user's feedback. Do not continue silently.

### 4. Author tests (`test-author`)
Brief: task, acceptance ids, changed production files, the audit path only if it
lists coverage hints. Tests go under `test/` mirroring `lib/`. It must not edit
production code. Require the `TestAuthoringReport`.

### 5. Run tests (`build-test-runner`, stage A)
Brief: "stage A: run analyze and tests for task `<id>`, full output to the log path,
return log path and exit code only". Output never goes to the terminal.

### 6. Generate artifact (`build-test-runner`, stage B)
Brief: "stage B: run `bash .kiro/skills/orchestrate-phase/scripts/check-green.sh
<log>`, write the VerificationReport from its output". The Main Loop then re-runs the
same script itself; both must agree:

```sh
bash .kiro/skills/orchestrate-phase/scripts/check-green.sh .dev/test-runs/<log>
```

- Exit 0 (GREEN) and the report present: go to step 7.
- Exit 1 (RED): route to `flutter-dev` (production failure) or `test-author` (test
  failure) with only the failing test names; then redo from the affected step.
- Exit 2, no artifact, or 2 identical consecutive failures: HALT and report to the
  user; do not loop.

### 7. Bookkeeping, commit, push (Main Loop only)
Only after step 6 is GREEN with its artifact on disk:
1. **Bookkeeping:** set `T` to `committed` in the implementation index (State enum,
   7-char SHA per AGENTS.md; the SHA is backfilled in the same commit workflow), update
   the story's task status, and add any observations to `docs/observations-memory.md`
   (resolved items move to `docs/history/resolved-observations.md`).
2. **Stage precisely:** explicit paths only (production, tests, bookkeeping files).
   Never `git add .`; never stage `.dev/` or secrets.
3. **Commit** on the task branch with a short message (< 3 lines), ending with the
   repository's attribution lines. Never `--no-verify`.
4. **Push** the branch: `git push -u origin <branch>`. Never push to `main`, never
   force push. Merge happens through a PR the user opens or approves.

### 8. Advance
Next open task, back to step 1, until the phase is complete or a gate blocks.

## Phase wrap-up

- Index shows every phase task `committed` with a SHA; story task list reconciled.
- Report in the AGENTS.md progress format (Component / Status / Active / Next), plus
  the branch name, worktree path and any observations registered.
- Leave the worktree in place for review; remove it (`git worktree remove`) only when
  the user asks.

## Self-check

- [ ] Worktree and branch were created from `main`; nothing was committed on `main`.
- [ ] Every task went through steps 1 to 7 with its artifacts on disk and its own commit.
- [ ] Briefs were concise and scoped; no sub-agent received the whole story or repo.
- [ ] HIL approval was obtained for every task before tests were authored.
- [ ] GREEN came from `check-green.sh` exit 0, not from a verbal verdict.
- [ ] Only the Main Loop did bookkeeping, commit and push.
- [ ] English only; no em dashes in authored files.
