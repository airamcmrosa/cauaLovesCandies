---
id: TASK-010
story: US05
title: Build reusable animated stars and confetti particle effects (victory burst and hit sparkle)
status: aceita # proposta | aceita | em progresso | completa
depends_on: [TASK-003] # needs the game world and the item-ingested event to anchor the hit sparkle
supersedes: []
---

# TASK-010 - Build reusable animated stars and confetti particle effects (victory burst and hit sparkle)

## Objective
Stars and confetti appear on screen as animated particles (burst, spin, fall, fade), replacing the stars/confetti that used to be drawn inside the Cauã images. One effect component serves the final victory and the small sparkle when Cauã eats a sweet or fruit.

## Source
- Story: `US05` AC1 (confetti/fireworks on finishing Phase 3); the hit sparkle is design polish tied to US03 ingestion
- Architecture: section 3 (`ParticleCelebrationComponent`), section 5 (60 FPS, GC limits, payload budget)
- Art spec: confetti/star colors in `docs/product/design/color-palette.md` (TASK-008)

## Decision: library vs. sprites
- **No new dependency.** Flame already ships `ParticleSystemComponent` (`flame` is in `pubspec.yaml`); pub.dev `confetti` is a Flutter-widget effect that does not live in the Flame world and would add payload for no gain.
- **No new sprites.** Confetti pieces (small rounded rectangles and circles) and the 5-point star are drawn procedurally with cached `Paint`s and one cached rounded-star `Path`, tinted from palette tokens. Zero extra assets, crisp at any size, and the tint set cannot drift from the palette.
- Fallback only if profiling on a mid-range phone fails: a single white star `.webp` tinted per particle (still no per-color sprites).

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| US05 AC1 - Confetti/fireworks 2D on finishing Phase 3 | `victory` preset: initial multicolor burst of confetti and stars from the screen center-top, then a light falling rain, all animated (velocity, gravity, rotation, fade); self-removes when finished. |
| Polish (not a story AC) | `hitSparkle` preset: 6-8 small `accent-lemon` stars popping at the mouth when a sweet or fruit is ingested, ~0.6 s, no penalty to frame rate. |

## Scope
- In:
  - `lib/game/components/particle_celebration_component.dart` (view only, no game rules): factory/presets `CelebrationPreset.victory` and `CelebrationPreset.hitSparkle`, injectable `Random`, fixed particle count cap per preset (e.g. victory <= 80, sparkle <= 8), cached `Paint`s and star `Path`, palette-token colors (`#FFE98A #FF8FC0 #7CC8FF #A8F0D1 #B79CFF #FFB36B`).
  - Hook for the hit sparkle: an `onItemIngested` callback/notifier exposed by TASK-003's game code, consumed by the game class to spawn the sparkle at the mouth position.
  - Self-removal on completion and on restart.
- Out:
  - Wiring the victory preset to `GameState.victory`, the SFX and the overlay (TASK-005 T5/T6).
  - Phase-transition confetti (out of scope per TASK-005 PM decisions).
  - Title-screen logo twinkle (TASK-001 may reuse the star painter; not required here).
  - Cauã reaction poses (see TASK-009 Open Questions).
  - Tests (owned by `test-author`).

## Atomic Sub-tasks
Each item is one unit for the orchestrate-phase loop (flutter-dev, audit, tests).
- [ ] T1 - Implement the star `Path` + confetti shapes and the `victory` preset on Flame `ParticleSystemComponent` (burst + rain, rotation, gravity, fade, cap, seedable `Random`, cached `Paint`s, self-removal). _Verify:_ triggering it shows animated multicolor confetti and stars at 60 FPS on a mid-range phone; no per-frame allocations in `update`/`render`; component is gone from the world after it ends.
- [ ] T2 - Add the `hitSparkle` preset (small star pop at a given position, reusing T1 painters). _Verify:_ eating 10 items in a row shows 10 independent sparkles, particle count stays under the cap, no frame drops, no leftover components.
- [ ] T3 - Expose the ingestion event from the TASK-003 game code and spawn `hitSparkle` at the mouth position only for sweets and fruits (not hazards). _Verify:_ sweet and fruit show a sparkle, hazard shows none, closed-mouth deflection shows none.
- [ ] T4 - Lifecycle and restart: effects are removed on restart/`GameState` change, no listener leaks. _Verify:_ `dart format --set-exit-if-changed lib`, `flutter analyze`, `flutter build web --release` pass; repeating victory/restart 10 times keeps a stable component count.
- [ ] T5 - Handoff list for `test-author`. _Verify:_ names seeded-`Random` determinism, particle cap per preset, self-removal, no sparkle on hazards.

## Definition of Done
- Stars and confetti are animated particles; no image asset contains baked stars or confetti.
- Performance/web constraints honored (60 FPS, no hot-path allocations, zero new dependencies, zero new assets).

## Open Questions
- None.
