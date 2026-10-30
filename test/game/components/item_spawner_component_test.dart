import 'dart:math';
import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/components/food_item_component.dart';
import 'package:caua_loves_candies/game/components/item_spawner_component.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:caua_loves_candies/game/managers/mouth_controller.dart';
import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:caua_loves_candies/game/projection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameManager gm;
  late MouthController mouth;
  late FlameGame game;
  late Sprite sprite;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawRect(const ui.Rect.fromLTWH(0, 0, 2, 2), ui.Paint());
    sprite = Sprite(await recorder.endRecording().toImage(2, 2));
  });

  setUp(() {
    gm = GameManager()..dismissTutorial();
    mouth = MouthController();
    game = FlameGame();
  });

  tearDown(() {
    gm.dispose();
    mouth.dispose();
  });

  group('pickItemType distribution', () {
    const draws = 20000;

    Map<ItemCategory, double> shares(PhaseConfig phase, int seed) {
      final random = Random(seed);
      final counts = {for (final c in ItemCategory.values) c: 0};
      for (var i = 0; i < draws; i++) {
        final category = pickItemType(random, phase).category;
        counts[category] = counts[category]! + 1;
      }
      return {for (final e in counts.entries) e.key: e.value / draws};
    }

    test('phase 1 is about 70/20/10 sweets/fruit/hazard', () {
      final s = shares(kPhases[0], 42);
      expect(s[ItemCategory.sweet], closeTo(0.70, 0.02));
      expect(s[ItemCategory.fruit], closeTo(0.20, 0.02));
      expect(s[ItemCategory.hazard], closeTo(0.10, 0.02));
    });

    test('phase 2 is about 50/30/20 sweets/fruit/hazard', () {
      final s = shares(kPhases[1], 7);
      expect(s[ItemCategory.sweet], closeTo(0.50, 0.02));
      expect(s[ItemCategory.fruit], closeTo(0.30, 0.02));
      expect(s[ItemCategory.hazard], closeTo(0.20, 0.02));
    });

    test('same seed gives the same sequence', () {
      final a = Random(5);
      final b = Random(5);
      for (var i = 0; i < 200; i++) {
        expect(pickItemType(a, kPhases[0]), pickItemType(b, kPhases[0]));
      }
    });

    test('every type of every category is reachable', () {
      final random = Random(1);
      final seen = <ItemType>{};
      for (var i = 0; i < 5000; i++) {
        seen.add(pickItemType(random, kPhases[1]));
      }
      expect(seen, containsAll(ItemType.values));
    });
  });

  group('ItemSpawnerComponent', () {
    ItemSpawnerComponent makeSpawner({
      List<ItemType>? ingested,
      List<ItemType>? deflected,
    }) => ItemSpawnerComponent(
      gameManager: gm,
      mouthController: mouth,
      random: Random(42),
      spriteFor: (_) => sprite,
      onIngested: ingested?.add,
      onDeflected: deflected?.add,
    );

    List<FoodItemComponent> items() =>
        game.children.whereType<FoodItemComponent>().toList();

    /// Updates the spawner alone so items do not move, then flushes the tree.
    void tick(ItemSpawnerComponent spawner, double dt) {
      spawner.update(dt);
      game.update(0);
    }

    test('spawns nothing before the interval elapses', () async {
      final spawner = makeSpawner();
      await game.ensureAdd(spawner);
      tick(spawner, ItemSpawnerComponent.spawnIntervalSeconds - 0.01);
      expect(items(), isEmpty);
    });

    test('spawns one item at z 0 when the interval elapses', () async {
      final spawner = makeSpawner();
      await game.ensureAdd(spawner);
      tick(spawner, ItemSpawnerComponent.spawnIntervalSeconds);
      expect(items(), hasLength(1));
      expect(items().single.z, 0.0);
      expect(items().single.outcome, ItemOutcome.undecided);
    });

    test('spawns repeatedly on the interval', () async {
      final spawner = makeSpawner();
      await game.ensureAdd(spawner);
      for (var i = 0; i < 3; i++) {
        tick(spawner, ItemSpawnerComponent.spawnIntervalSeconds);
      }
      expect(items(), hasLength(3));
    });

    test('accumulates small steps across updates', () async {
      final spawner = makeSpawner();
      await game.ensureAdd(spawner);
      for (var i = 0; i < 6; i++) {
        tick(spawner, ItemSpawnerComponent.spawnIntervalSeconds / 6);
      }
      expect(items(), hasLength(1));
    });

    for (var level = 1; level <= kPhases.length; level++) {
      test(
        'cadence at level $level scales with the speed multiplier',
        () async {
          gm.level = level;
          final spawner = makeSpawner();
          await game.ensureAdd(spawner);
          final mult = kPhases[level - 1].speedMultiplier;
          const interval = ItemSpawnerComponent.spawnIntervalSeconds;
          tick(spawner, interval / mult - 0.01);
          expect(items(), isEmpty);
          tick(spawner, 0.02);
          expect(items(), hasLength(1));
        },
      );
    }

    test('hooks are forwarded to spawned items (ingest)', () async {
      mouth.toggle();
      final ingested = <ItemType>[];
      final deflected = <ItemType>[];
      final spawner = makeSpawner(ingested: ingested, deflected: deflected);
      await game.ensureAdd(spawner);
      tick(spawner, ItemSpawnerComponent.spawnIntervalSeconds);
      final item = items().single;
      item.update(10);
      expect(ingested, [item.type]);
      expect(deflected, isEmpty);
    });

    test('hooks are forwarded to spawned items (deflect)', () async {
      final ingested = <ItemType>[];
      final deflected = <ItemType>[];
      final spawner = makeSpawner(ingested: ingested, deflected: deflected);
      await game.ensureAdd(spawner);
      tick(spawner, ItemSpawnerComponent.spawnIntervalSeconds);
      final item = items().single;
      item.update(0.95 / 0.25);
      item.update(10);
      expect(deflected, [item.type]);
      expect(ingested, isEmpty);
    });
  });

  group('tutorial gating', () {
    List<FoodItemComponent> items() =>
        game.children.whereType<FoodItemComponent>().toList();

    ItemSpawnerComponent make() => ItemSpawnerComponent(
      gameManager: gm,
      mouthController: mouth,
      random: Random(42),
      spriteFor: (_) => sprite,
    );

    setUp(() => gm = GameManager());

    test('spawns nothing over many updates during the tutorial', () async {
      final spawner = make();
      await game.ensureAdd(spawner);
      for (var i = 0; i < 200; i++) {
        spawner.update(0.5);
        game.update(0);
      }
      expect(items(), isEmpty);
    });

    test('existing items stay put and score/HP are unchanged', () async {
      final spawner = make();
      await game.ensureAdd(spawner);
      final item = FoodItemComponent(
        type: ItemType.donut,
        gameManager: gm,
        mouthController: mouth,
        sprite: sprite,
        deflectRight: true,
      );
      await game.ensureAdd(item);
      for (var i = 0; i < 20; i++) {
        game.update(0.5);
      }
      expect(item.z, 0.0);
      expect(items(), [item]);
      expect(gm.score.value, 0);
      expect(gm.hp.value, GameManager.maxHp);
    });

    test('spawns again after dismissTutorial', () async {
      final spawner = make();
      await game.ensureAdd(spawner);
      spawner.update(100);
      game.update(0);
      expect(items(), isEmpty);
      gm.dismissTutorial();
      spawner.update(ItemSpawnerComponent.spawnIntervalSeconds);
      game.update(0);
      expect(items(), hasLength(1));
    });
  });
}
