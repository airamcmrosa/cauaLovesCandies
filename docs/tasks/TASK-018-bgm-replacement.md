---
id: TASK-018
story: -
title: Replace the BGM with the custom birthday song
status: em progresso # proposta | aceita | em progresso | completa
depends_on: [] # none
supersedes: []
---

# TASK-018 - Replace the BGM with the custom birthday song

## Objective
The game plays the custom song `caua_loves_candies_song.mp3` as its only BGM.

## Source
- Product owner decision (2026-10-31): the new song replaces `tropical_fantasy.mp3` for good. This supersedes the TASK-001 amendment of 2026-10-29.

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| BGM | `lib/audio/songs.dart` lists `caua_loves_candies_song.mp3`; `AssetPreloader.defaultAudioPaths` preloads it; `tropical_fantasy.mp3` and its `CREDITS.TXT` are removed. |

## Scope
- In: `assets/music/`, `lib/audio/songs.dart`, `lib/game/managers/asset_preloader.dart`, stale references in `README.md` and `docs/observations-memory.md` (OBS-017).
- Out: gameplay code, audio mixing, and the refreshed Cauã sprites (they fail the TASK-017 invariants and need a product-owner decision; not part of this task).

## Atomic Sub-tasks
- [x] T1 - Swap the BGM file and its references. _Verify:_ `flutter analyze` and `flutter test` green; no reference to `tropical_fantasy` remains outside history docs.
- [x] T2 - Fix stale docs (README credits link, OBS-017). _Verify:_ no dead link to `CREDITS.TXT`.

## Definition of Done
- Song plays from the title screen after the unlock tap; payload still under the 3.5 MB budget.

## Open Questions
- The song credit in `songs.dart` is "Gemini" (AI-generated); the product owner should confirm usage terms alongside the other AI assets.
