# Cauã Loves Candies

2D arcade birthday game built with Flutter + Flame, played in the mobile
browser (QR code, no login, no install). One tap toggles Cauã's mouth against a
conveyor belt: sweets +2, fruits +1, forbidden items -1 HP. Three speed tiers end
in a confetti victory screen. 100% client-side, hosted as a static site.

## Prerequisites

- Flutter stable with Dart `^3.8.0` (see `pubspec.yaml`). Last checked with
  Flutter 3.47.7 / Dart 3.13.5.
- Chrome for local web runs.

```bash
flutter pub get
```

## Run locally

```bash
# Chrome
flutter run -d chrome

# Phone on the same Wi-Fi: serve on all interfaces, then open http://<your-LAN-IP>:8080
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080

# Release web build (CI uses the repository name as base href)
flutter build web --release --base-href "/cauaLovesCandies/"
```

The deploy pipeline is `.github/workflows/ci-cd.yml` (analyze, test with
coverage gate, then web build and publish). The architecture doc still shows a
`--web-renderer canvaskit` flag; current Flutter no longer offers it, so omit it.

## Tests and quality

```bash
flutter analyze --fatal-infos            # same flag as CI
flutter test                             # all tests
flutter test test/game/caua_candies_game_test.dart   # one file
flutter test --coverage                  # writes coverage/lcov.info
scripts/check-coverage.sh coverage/lcov.info 90      # fails below min line coverage
dart format .
```

`.kiro/skills/orchestrate-phase/scripts/check-green.sh <log-file>` is a
deterministic gate for a saved `flutter test` log: prints one JSON line and exits
0 (GREEN), 1 (RED) or 2 (log missing/empty). Example:

```bash
flutter test 2>&1 | tee /tmp/test.log
.kiro/skills/orchestrate-phase/scripts/check-green.sh /tmp/test.log
```

## Directory map

| Path | Purpose |
| :--- | :--- |
| `lib/game/` | Flame game, player component, managers (score, HP, phases, mouth state), 9:16 projection |
| `lib/audio/` | Audio controller, song and sound manifests |
| `lib/main_menu/`, `lib/settings/`, `lib/player_progress/` | Flutter screens and persistence |
| `lib/style/` | Palette, responsive layout, buttons, page transitions |
| `assets/` | `images/`, `sfx/`, `music/`, `fonts/`, `icons/` |
| `test/` | Tests mirroring `lib/` (`game/`, `style/`, `assets/`, smoke test) |
| `docs/` | `architecture/`, `product/stories/`, `tasks/`, `history/`, `templates/` |
| `.claude/agents/` | Sub-agents (flutter-dev, test-author, quality-analyzer, spec-reviewer, build-test-runner) |

AGENTS.md also plans `lib/ui/` (HUD, tutorial, celebration overlays) and
`lib/flame_game/`; neither exists yet.

## Developer notes

**Performance budget** ([architecture](docs/architecture/architecture.md)):
total payload under 3.5 MB uncompressed, first load under 3 s over 4G, textures
as `.webp`, audio as compressed `.mp3`. Final sprites are not regenerated.
The game renders in a fixed 720x1280 (9:16) virtual viewport, letterboxed.

**Audio on the web:** mobile browsers block autoplay. The `AudioContext` is
unlocked by an explicit user tap (the title screen); if playback is blocked,
retry on the first tap.

**Assets:** every asset folder, including nested ones, must be listed in
`pubspec.yaml` under `flutter: assets:` (Flutter does not recurse). Example, for
a new `assets/images/fx/`:

```yaml
  assets:
    - assets/images/fx/
```

Licenses and sources: [`assets/music/CREDITS.TXT`](assets/music/CREDITS.TXT),
[`assets/sfx/README.md`](assets/sfx/README.md),
[`assets/images/README.md`](assets/images/README.md).

**Tasks and governance** ([`docs/tasks/README.md`](docs/tasks/README.md)):
- Status flow: `proposta` -> `aceita` -> `em progresso` -> `completa`.
- A `completa` task is never reopened; create a new task with
  `supersedes: [<old id>]` and note "Superseded by" on the old index row.
- Only the Main Loop (lead agent) commits, pushes and updates indexes, task
  status and progress logs. Sub-agents only edit local code.
- Non-blocking review findings go in
  [`docs/observations-memory.md`](docs/observations-memory.md) (Open or In
  Progress only; resolved ones move to `docs/history/resolved-observations.md`).

See [`AGENTS.md`](AGENTS.md) and [`CLAUDE.md`](CLAUDE.md) for the full rules.
