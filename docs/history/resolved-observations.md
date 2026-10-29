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
| `OBS-002` | INFO | MAINTAINABILITY | `lib/flame_game/endless_runner.dart` | Resolved | Template names (`EndlessRunner`, `EndlessWorld`) still in use | 52a87ee |
| `OBS-022` | WARNING | LIFECYCLE | `lib/audio/audio_controller.dart` | Resolved | `dispose()` leaves settings listeners and the `onPlayerComplete` subscription attached | 7400c93 |
| `OBS-027` | INFO | MAINTAINABILITY | `lib/ui/title_loading_indicator.dart` | Resolved | Idle, Loading and Done branches are dead code after the spinner-first change | 7400c93 |
| `OBS-033` | WARNING | LIFECYCLE | `lib/audio/audio_controller.dart` | Resolved | `_startingMusic` guard drops a start request made during an in-flight start; a mute during a start can still end up playing | 7400c93 |
| `OBS-034` | INFO | LIFECYCLE | `lib/audio/audio_controller.dart` | Resolved | `_handleSongFinished` ignores `audioOn` and dispose state | 7400c93 |

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

### `OBS-002`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `lib/flame_game/endless_runner.dart`
* **Source:** `manual / package rename review`
* **Status:** Resolved
* **Finding:** The package was renamed to `caua_loves_candies`, but the game class `EndlessRunner`, `EndlessWorld` and the Dash/enemy template assets remain.
* **Risk/Impact:** Template mechanics may be mistaken for product patterns by sub-agents reading `lib/**`.
* **Resolution Trigger:** Tasks that replace the endless runner loop with the conveyor belt game.
* **Resolved By:** 52a87ee (`lib/flame_game/`, `lib/level_selection/` and Dash/enemy assets removed)

### `OBS-022`
* **Severity:** WARNING
* **Category:** LIFECYCLE
* **Target:** `lib/audio/audio_controller.dart`
* **Source:** `audit / TASK-001 T3`
* **Status:** Resolved
* **Finding:** `AudioController.dispose()` leaves the settings listeners and the `onPlayerComplete` subscription attached (pre-existing from the template).
* **Risk/Impact:** Leaks if the controller is ever disposed and recreated while settings live on.
* **Resolution Trigger:** TASK-001 T6 self-audit (listeners disposed on screen removal).
* **Resolved By:** 7400c93 (TASK-001 T6 self-audit)

### `OBS-027`
* **Severity:** INFO
* **Category:** MAINTAINABILITY
* **Target:** `lib/ui/title_loading_indicator.dart`
* **Source:** `audit / TASK-001 T4`
* **Status:** Resolved
* **Finding:** After the title screen became spinner-first, the Idle, Loading and Done branches of `TitleLoadingIndicator` are unreachable.
* **Risk/Impact:** Dead code that may mislead readers.
* **Resolution Trigger:** TASK-001 T6 self-audit: reduce the widget to the Failed state.
* **Resolved By:** 7400c93 (TASK-001 T6 self-audit)

### `OBS-033`
* **Severity:** WARNING
* **Category:** LIFECYCLE
* **Target:** `lib/audio/audio_controller.dart`
* **Source:** `audit / TASK-001 T5`
* **Status:** Resolved
* **Finding:** The `_startingMusic` guard drops a start request made while a start is in flight (a tap, or toggle off then on). A mute during an in-flight start can still end with music playing.
* **Risk/Impact:** Rare race: music audible while the toggle shows muted, or a retry that never happens.
* **Resolution Trigger:** TASK-001 T6 self-audit: re-check the desired state after the in-flight start completes.
* **Resolved By:** 7400c93 (TASK-001 T6 self-audit)

### `OBS-034`
* **Severity:** INFO
* **Category:** LIFECYCLE
* **Target:** `lib/audio/audio_controller.dart`
* **Source:** `audit / TASK-001 T5`
* **Status:** Resolved
* **Finding:** `_handleSongFinished` does not check `audioOn` or the disposed state before starting the next track.
* **Risk/Impact:** A finished track could restart while muted or after dispose.
* **Resolution Trigger:** TASK-001 T6 self-audit.
* **Resolved By:** 7400c93 (TASK-001 T6 self-audit)
