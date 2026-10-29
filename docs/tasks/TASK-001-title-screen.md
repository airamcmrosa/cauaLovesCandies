---
id: TASK-001
story: US01
title: Build the animated title screen with JOGAR button, BGM unlock and asset preload
status: em progresso # proposta | aceita | em progresso | completa
depends_on: [] # task ids that must be completed first
supersedes: [] # ids of wrongly completed tasks this one corrects (see README rules)
---

# TASK-001 - Build the animated title screen with JOGAR button, BGM unlock and asset preload

## Objective
When a child opens the QR link, they see a colorful, animated "Cauã Loves Candies" title, Cauã's cartoon avatar and a big JOGAR button. The first tap unlocks web audio and starts cheerful BGM while sprites and sounds preload in the background; JOGAR enters the match only once preload is done.

## Source
- Story: `US01` (`docs/product/stories/user_stories_index_details.md`)
- Architecture: section 4 (Onboarding / Title Screen state), section 5 (Web Audio Unlock, fixed 9:16 virtual resolution), section 1 (sub-3s SLA, payload under 3.5 MB)

## Current State (what exists vs. what must be built)
- Exists (template baseline): `lib/main_menu/main_menu_screen.dart` (template banner, "A Flutter game template.", Play/Settings buttons, routes to `/play` level selection), `lib/router.dart` (`/`, `/play`, `/play/session/:level`, `/settings`), `lib/audio/audio_controller.dart` (audioplayers-based; preloads SFX only in its constructor; picks songs from template `songs.dart`), `lib/style/wobbly_button.dart`, `lib/style/responsive_screen.dart`, `lib/style/palette.dart`.
- Exists but not a product pattern (OBS-002): `lib/flame_game/endless_runner.dart`, `endless_world.dart`, level selection screens. Do not extend or depend on them for this task.
- Missing: `lib/game/components/` and `lib/game/managers/` and `lib/ui/` are empty; there is no Cauã avatar asset, no title/logo asset, no cheerful BGM track dedicated to the product, no preload orchestration for sprites, no audio-unlock gate, no JOGAR button.
- Assets present are template placeholders (`.png`, `dash/`, `ember.png`); they are not part of the product bundle and must not be preloaded.

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| AC1 Animated title "Cauã Loves Candies" | `TitleScreen` widget in `lib/ui/` with an implicit/explicit-animation title (e.g. bounce/scale-in then gentle loop) using Flutter animation widgets, text "Cauã Loves Candies" (or a `.webp` logo if provided). Replaces template banner and "A Flutter game template." text. |
| AC2 Cauã avatar (vector/cartoon) | Avatar `.webp` under `assets/images/` (or a `CustomPainter` vector if no art is supplied) displayed centered on the title screen, with a light idle animation (bobbing). |
| AC3 Big highlighted "JOGAR" button | Large JOGAR button (minimum ~64 logical px height, full-width-ish, high contrast, child-friendly) built from/restyled over `WobblyButton`; label is literally "JOGAR". Enabled only when preload completes (shows a short loading state before). |
| AC4 Cheerful BGM with tap-to-unlock | First user tap on the title screen (an explicit "Toque para ligar o som" prompt or the first tap anywhere/JOGAR) unlocks the web AudioContext, then BGM starts looping. Amended 2026-10-29 by the product owner: BGM tries to start on menu entry on every platform; if the browser blocks the first `play()`, the first tap retries through `AudioController.unlockAndStartMusic()`. Respects existing `SettingsController` audio/music toggles. |
| AC5 Background preload of all sprites and sounds | `AssetPreloader` (plain Dart + `ValueListenable<PreloadState>`) started when the title screen mounts: loads product images via Flame `Images.loadAll` (cache shared with the game), SFX/BGM via `AudioCache`/`FlameAudio.audioCache.loadAll`. Runs during the title animation; JOGAR navigation waits for completion. |

## Scope
- In:
  - `lib/ui/title_screen.dart` (presentational widget), small sub-widgets (animated title, avatar, JOGAR button, loading indicator) in `lib/ui/`.
  - `lib/game/managers/asset_preloader.dart` (plain Dart, injectable asset lists, progress via `ValueNotifier`).
  - Audio-unlock wiring in `lib/audio/` (`AudioController` method to start BGM after an explicit tap; product BGM entry in `songs.dart`; product SFX manifest entry for the button tap in `sounds.dart`).
  - Route `/` pointing to the new title screen in `lib/router.dart`; the JOGAR target route is a placeholder to the game screen (see Out).
  - `assets/images/` (avatar, optional logo, `.webp`), `assets/music/` (one compressed BGM `.mp3`), `pubspec.yaml` asset registration.
  - Removing the template main menu texts/banner from the entry path (keeping Settings reachable is optional; see Open Questions).
- Out:
  - Game scene, conveyor, Cauã in-game sprites logic: TASK-002 (tap control) and TASK-003 (conveyor + scoring); phases: TASK-004; victory: TASK-005.
  - Tutorial overlay shown after JOGAR: TASK-006.
  - Final art of food items / in-game sprites beyond what the preloader manifest must list (manifest lists only files that exist; later tasks append their assets).
  - Tests (owned by test-author).

## Atomic Sub-tasks
Each item is one unit for the orchestrate-phase loop (flutter-dev, audit, tests).
- [x] T1 - Add product assets: Cauã avatar `.webp` (and optional logo `.webp`) in `assets/images/`, one cheerful BGM `.mp3` in `assets/music/`, register in `pubspec.yaml`; document licensing in the folder CREDITS. _Verify:_ `flutter build web --release` succeeds, added payload is reported and the total bundle stays under 3.5 MB.
- [x] T2 - Create `AssetPreloader` in `lib/game/managers/asset_preloader.dart`: constructor-injected image/audio path lists, exposes `ValueListenable<PreloadState>` (idle, loading with progress, done, failed), loads images with Flame `Images` and audio with `AudioCache`, logs with `package:logging`, no `flutter/material.dart` import. _Verify:_ state moves idle -> loading -> done on a normal run, and to failed (without crashing the app) when a path is missing.
- [x] T3 - Extend `AudioController` and manifests: add the product BGM to `songs.dart`, add a button-tap entry in `sounds.dart` if missing, and add a method to start BGM only after an explicit user tap (web unlock), honoring music/audio settings; no autoplay at construction. _Verify:_ opening the page in a mobile browser produces no sound until the first tap; after the tap the BGM loops; muting in settings silences it.
- [x] T4 - Build `TitleScreen` and sub-widgets in `lib/ui/`: animated title (AC1), animated avatar (AC2), large high-contrast JOGAR button (AC3), "tap to enable sound" affordance (AC4), loading indicator bound to `AssetPreloader` state (AC5). Use `const` constructors, `ValueListenableBuilder`, and the 9:16 responsive layout. No game logic. _Verify:_ at 360x640 and 412x915 viewports the title animates, avatar and JOGAR are fully visible, and JOGAR meets the large-target size.
- [ ] T5 - Wire the screen: update `lib/router.dart` so `/` shows `TitleScreen`, start preload on mount and dispose it cleanly, JOGAR plays the tap SFX and navigates to the game route once preload is done (and unlocks audio if not yet unlocked). Remove template banner/"A Flutter game template." copy from the entry flow. _Verify:_ cold start shows the title within the 3 s budget on throttled 4G, JOGAR is blocked/loading until preload completes, then navigates; no console errors.
- [ ] T6 - Self-audit pass: confirm no per-frame allocations in title animations, listeners/notifiers/audio players disposed on screen removal, English-only code, `dart format --set-exit-if-changed lib` and `flutter analyze` clean. _Verify:_ both commands exit 0 and a quick profile shows steady 60 FPS on the title.
- [ ] T7 - Add decorative falling candies on the left and right edges of the title screen (candy and lollipop sprites from `assets/images/items/`, rendered 30% smaller than their normal size, reusing the preloaded images, no per-frame allocations, behind the title content, not blocking taps). Added 2026-10-29 from the T5 HIL. _Verify:_ at 360x640 and 412x915 candies fall continuously along both edges without overlapping the logo, avatar or JOGAR, and the title stays at 60 FPS.

## Definition of Done
- Every story AC above is demonstrably met.
- Performance/web constraints honored (60 FPS, no hot-path allocations, assets `.webp`/`.mp3`, no audio before an explicit tap, preload during the title animation, payload under 3.5 MB).
- Test coverage to request from test-author: `AssetPreloader` state transitions (success and failure) with injected lists; `AudioController` does not start music before the unlock call and respects mute settings; `TitleScreen` widget test (title text, "JOGAR" button visible, disabled during loading, enabled when done).

## PM Decisions (resolved questions)
- Art: a `CustomPainter` vector placeholder is acceptable until final avatar/logo art arrives; art delivery is owned by the product owner.
- BGM: royalty-free/CC0 cheerful track; license must be recorded in `assets/music/CREDITS.TXT`. Amended by the product owner on 2026-10-29: one CC0 template track (`tropical_fantasy.mp3`) is reused to meet the payload budget; the other two were removed.
- Audio unlock: the first tap anywhere on the title, including JOGAR, unlocks audio and starts BGM. No separate prompt required beyond the affordance in T4. Amended 2026-10-29: BGM also tries to start on menu entry (including web); the first tap is only a retry if the browser blocked autoplay.
- JOGAR waits for preload and shows a short loading state; it is disabled until done. Amended 2026-10-29 by the product owner: the title screen itself only appears once preload is done; before that only a spinner is shown. In a failed preload JOGAR stays disabled and a retry button is shown.
- Settings: amended 2026-10-29 by the product owner: there is no Settings screen. A single sound toggle (speaker icon, persisted) lives on the title screen and mutes music and sound effects together.
- No localization; fixed strings "Cauã Loves Candies" and "JOGAR".
- Until TASK-002 provides its game route, JOGAR may route to the template game screen as a temporary stub; after TASK-002 T5 it targets `CauaCandiesGame`.
