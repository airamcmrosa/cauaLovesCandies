---
id: TASK-016
story: -
title: Show a friendly full-screen error with a reload button on any uncaught failure
status: em progresso # proposta | aceita | em progresso | completa
depends_on: [] # task ids that must be completed first
supersedes: []
---

# TASK-016 - Global error screen with reload prompt

## Objective
If anything throws in the app (Flutter framework, async/platform errors, the Flame game, preload failures that are not recoverable), the child sees a clear, friendly full-screen message asking them (or an adult) to reload the page, with a big reload button, instead of a blank or frozen screen.

## Source
- Product owner request during the TASK-001 HIL (2026-10-29): "any failure in the system, any throw, must show an error so the user reloads the page".
- Architecture: web static delivery (no backend), section 5 (web constraints).

## Scope
- In:
  - `lib/ui/error_screen.dart`: full-screen widget, pt-BR copy (for example "Ops! Algo deu errado." and "Recarregar"), large high-contrast button, Candy Pastel palette, no stack traces shown.
  - A reload abstraction with a web implementation (`window.location.reload()` through `package:web` or `dart:js_interop`) and a non-web fallback, selected by conditional import.
  - Global hooks in `lib/main.dart`: `FlutterError.onError`, `PlatformDispatcher.instance.onError`, `runZonedGuarded` and `ErrorWidget.builder`, all routing to one reporter that logs with `package:logging` and switches the app to the error screen (only the first error, to avoid loops).
  - Game-level failures (Flame `onLoad`/update exceptions) reach the same path.
- Out: retry/recovery logic for specific failures (the title screen keeps its own "Tentar de novo" for a failed preload; TASK-001), remote error reporting or analytics (privacy: nothing leaves the device).

## Atomic Sub-tasks
- [ ] T1 - Add the `ErrorScreen` widget and the reload abstraction (web and fallback, conditional import). _Verify:_ the widget shows the message and a reload button; tapping it calls the injected reload function.
- [ ] T2 - Add the error reporter and wire the global hooks in `lib/main.dart` so any uncaught error replaces the app UI with `ErrorScreen`. _Verify:_ throwing from a widget build, from an async callback and from a Flame component shows the error screen once; no error loop.
- [ ] T3 - Self-audit: English-only code, no PII in logs, analyze and format clean. _Verify:_ `flutter analyze` and `dart format --set-exit-if-changed lib` exit 0.

## Definition of Done
- Any uncaught failure shows the error screen with a working reload button (web).
- Tests cover the screen, the reporter (first error only) and the injected reload; the suite is green via `check-green.sh`.

## Open Questions
- None.
