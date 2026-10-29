---
id: TASK-003
story: US03
title: Build conveyor belt with scored food items and HUD
status: em progresso # proposta | aceita | em progresso | completa
depends_on: [TASK-002] # needs the mouth open/closed state for the z >= 0.95 decision
supersedes: []
---

# TASK-003 - Build conveyor belt with scored food items and HUD

## Objective
Items travel down a pseudo-3D conveyor belt toward Cauã at a constant per-phase speed. When they arrive, the mouth state decides the outcome: sweets give +2, fruits give +1, and forbidden items cost 1 HP and play a comic sound. A HUD at the top shows the score and HP icons.

## Source
- Story: `US03` (`docs/product/stories/user_stories_index_details.md`)
- Architecture: section 2 (projection math, decision boundary at `z >= 0.95`), section 3 (component hierarchy, `GameManager`), section 4 (phase speed/composition table, read only), section 5 (GC and recycling, fixed 720x1280 viewport)

## Acceptance Criteria Mapping
| Story AC | Task deliverable |
| :--- | :--- |
| AC1 - Items advance at constant speed per phase | `FoodItemComponent` advances `z` by `baseSpeed * phaseMultiplier * dt` (linear, no easing, frame-rate independent). Multiplier comes from a const phase config (`PhaseConfig`) read through `GameManager.level`; only the Phase 1 value (1.0x) is exercised here. |
| AC2 - Sweets +2 (Pirulito, Donut, Granulado, Bala, Cupcake, Algodão-doce, Chiclete) with festive SFX | Item type table with 7 sweets; on ingestion `GameManager.addScore(2)`; festive SFX played via `AudioController`. |
| AC2 - Fruits +1 (Morango, Banana, Melancia, Uva, Laranja) with positive SFX | Item type table with 5 fruits; on ingestion `GameManager.addScore(1)`; positive SFX. |
| AC2 - Forbidden items -1 HP (Brócolis, Sabão, Meia suja, Cebola) with comic SFX | Item type table with 4 hazards; on ingestion `GameManager.loseHp()` (min 0, max 3) plus comic "yuck/oops" SFX and the screen shake from architecture section 2. |
| AC3 - Score counter and HP icons at the top | `GameHud` Flutter overlay in `lib/ui/` driven by `ValueListenable<int>` for score and HP (3 icons, big and high contrast). |
| Architecture decision rule (not a story AC, required for AC2) | Pure `projectDepth(z)` function plus `decideOutcome(z, mouthOpen)`. Open mouth ingests. Closed mouth deflects laterally and despawns with no penalty. |

## Scope
- In (under `lib/game/`, `lib/ui/`, `lib/audio/`, `assets/`):
  - `lib/game/managers/`: `GameManager` (score, HP, level, `GameState`, `ValueNotifier`s), `PhaseConfig` (const table), `ItemType` and `ItemCategory` (sealed or enum) with points and HP effect.
  - `lib/game/projection.dart` (or equivalent): pure projection and decision functions.
  - `lib/game/components/`: `ConveyorBeltComponent`, `ItemSpawnerComponent`, `FoodItemComponent`.
  - `lib/ui/`: `GameHud` overlay, registered in the game screen overlay map.
  - `.webp` sprites for the 9 items, and `.mp3` SFX (festive, positive, comic) registered in `pubspec.yaml` and `lib/audio/sounds.dart`.
  - Wiring of these components into the game world, which sits on top of whatever TASK-002 provides.
- Out:
  - Mouth toggle input and `CauaPlayerComponent` sprites/state (TASK-002). This task only reads its mouth-open flag.
  - Phase transitions, targets (10/20/30), "Fase 2 - Mais Rápido!" banner (TASK-004). Here, `GameManager` exposes `level` and score and the config table, but does not advance levels.
  - Victory screen and confetti (TASK-005). Game-over/zero-HP behavior is not specified by US03 (see Open Questions).
  - Tutorial overlay (TASK-006), title screen (TASK-001).
  - Refactoring or renaming the template `EndlessRunner`/`EndlessWorld` (OBS-002). New code is built under `lib/game/` and does not copy the template's endless-runner pattern.
  - Tests (owned by `test-author`).

## Atomic Sub-tasks
Each item is one unit for the orchestrate-phase loop (flutter-dev, audit, tests).
- [x] T1 - Add the pure projection module: `scale(z)`, `y(z)`, `x(z)` by linear interpolation, plus `decideOutcome(z, mouthOpen)` with the `z >= 0.95` boundary. Constants (bottom/horizon scale, y, mouth x, spawn x) are in one const place. _Verify:_ z=0 returns scale 1.00 and the bottom y; z=1 returns scale 0.25 and the horizon y; z=0.94 gives "not decided", z=0.95 gives ingest (open) or deflect (closed). No Flame imports. No allocations (returns records or writes into a reused `Vector2`).
- [x] T2 - Add `ItemType`/category definitions (7 sweets, 5 fruits, 4 hazards; unified catalog, see PM Decisions) with points and HP delta, and the const `PhaseConfig`/`kPhases` table in `lib/game/managers/phase_config.dart` (speed 1.0/1.35/1.65x, composition 70/20/10 for Phase 1, 50/30/20 for Phase 2). _Verify:_ all 9 story items present and the values match story AC2 and architecture section 4. No scattered literals elsewhere.
- [x] T3 - Add `GameManager` (plain Dart): `ValueNotifier<int>` score and HP (clamped 0..3), `level`, `GameState`, methods `addScore`/`loseHp`/`reset`, and a `dispose`. _Verify:_ no `flutter/material.dart` or Flame import. Sweet adds 2, fruit adds 1, hazard removes 1 HP and never goes below 0. Listeners are notified once per change.
- [x] T4 - Add `ConveyorBeltComponent`: trapezoidal lane from the bottom to the horizon with scrolling stripes at the current phase speed. All `Paint`/`Path` objects cached. _Verify:_ the belt renders in the 720x1280 viewport, stripes scroll at constant speed, and no per-frame allocations in `update`/`render`.
- [x] T5 - Add `FoodItemComponent`: advances `z` with `dt`, applies T1 to scale, position and priority, and at `z >= 0.95` asks the decision function using the mouth state from TASK-002. The mouth state is read from the `MouthController` defined in TASK-002 (`state == MouthState.open`). Ingest reports the item type to `GameManager` and plays the SFX. Deflect moves laterally and calls `removeFromParent()` with no penalty. Items past `z > 1.0` are removed. _Verify:_ an item reaches the mouth in a constant time per speed, an open mouth changes score/HP per category, a closed mouth changes nothing and the item disappears, and no leaked components.
- [x] T6 - Add `ItemSpawnerComponent`: spawns items at `z = 0` on an interval, choosing the category from the phase composition with an injectable `Random`. Pool or recycle components. _Verify:_ over many spawns with a seeded `Random`, the Phase 1 mix is approximately 70/20/10. It stops spawning when the game state is not "playing".
- [ ] T7 - Add the item sprites (9 `.webp`) and 3 SFX `.mp3` (festive, positive, comic), register them in `pubspec.yaml`, `lib/audio/sounds.dart` and the image preload list, and play them through `AudioController`. Add the screen shake on hazard ingestion. _Verify:_ assets load without errors, the total added payload is stated in the report and stays within the 3.5 MB budget, and SFX respect the existing mute setting.
- [ ] T8 - Add the `GameHud` overlay (`lib/ui/`): score counter and 3 HP icons at the top, using `ValueListenableBuilder`, `const` widgets, and no game logic. Register it in the game screen overlay map. _Verify:_ the score and HP update immediately after ingestion, the HUD does not block taps on the game area, and text and icons are large and high contrast.
- [ ] T9 - Wire everything into the game world and screen (belt, spawner, `GameManager` injected through constructors, HUD overlay, mouth state from TASK-002), with `dispose` of notifiers and removal of listeners in `onRemove`. _Verify:_ `dart format --set-exit-if-changed lib`, `flutter analyze` and `flutter build web --release` pass. Manual run: items flow, scoring and HP match the story, 60 FPS holds, and there are no leaks after repeated play.

## Definition of Done
- Every story AC above is demonstrably met.
- Performance/web constraints honored (60 FPS, no hot-path allocations, assets `.webp`/`.mp3`).
- Components do not own score, HP or level. Only `GameManager` does.
- Test hand-off listed for `test-author`: projection and decision functions, `GameManager` rules, `PhaseConfig` values, spawner composition with a seeded `Random`, and the `GameHud` listener updates.

## PM Decisions (resolved questions)
- Size: stays ONE task for US03 (one task per story); the 9 sub-tasks are independently implementable in order.
- Zero HP: out of scope here (HP clamps at 0, no consequence); the `lost` state and game-over screen belong to TASK-005.
- Speeds: architecture values 1.0 / 1.35 / 1.65 are the source of truth (see TASK-004 decisions). This task owns `PhaseConfig`/`kPhases` with speed and composition only; TASK-004 extends it with target score and banner text.
- Phase 3 composition: placeholder here (e.g. 30/40/30 sweets/fruit/hazard weighted toward bonus items); TASK-004 may tune it in the same table.
- Art/audio: placeholders acceptable (9 sprites, 3 SFX); real art is owned by the product owner; SFX must be CC0/royalty-free with license recorded.
- Item catalog is the union of the US03 list and the palette/art list: sweets Pirulito, Rosquinha/Donut, Granulado, Bala, Cupcake, Algodão-doce, Chiclete; fruits Morango, Banana, Melancia, Uva, Laranja; hazards Brócolis, Sabão, Meia suja, Cebola. No "meleca" sprite. Art prompts: `docs/product/design/gemini-art-prompts.md`.
- Arrival spacing at the mouth and the post-ingestion Cauã reactions are owned by TASK-011 (it extends the spawner after this task lands).
- Mouth interface: consume `MouthController` from TASK-002; do not reference `CauaPlayerComponent`.
- `GameState` is created here with `playing` only; later tasks add `victory` (TASK-004), `lost` (TASK-005), `tutorial` (TASK-006).
- Screen shake on hazard ingestion: confirmed, per architecture section 2.
