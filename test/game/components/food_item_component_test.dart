import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/components/conveyor_belt_component.dart';
import 'package:caua_loves_candies/game/components/food_item_component.dart';
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

  Future<ui.Image> makeImage() async {
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawRect(const ui.Rect.fromLTWH(0, 0, 2, 2), ui.Paint());
    return recorder.endRecording().toImage(2, 2);
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sprite = Sprite(await makeImage());
  });

  setUp(() {
    gm = GameManager();
    mouth = MouthController();
    game = FlameGame();
  });

  tearDown(() {
    gm.dispose();
    mouth.dispose();
  });

  Future<FoodItemComponent> spawn(
    ItemType type, {
    List<ItemType>? ingested,
    List<ItemType>? deflected,
    bool deflectRight = true,
  }) async {
    final item = FoodItemComponent(
      type: type,
      gameManager: gm,
      mouthController: mouth,
      sprite: sprite,
      onIngested: ingested?.add,
      onDeflected: deflected?.add,
      deflectRight: deflectRight,
    );
    await game.ensureAdd(item);
    return item;
  }

  /// Seconds needed at the current phase to reach [z] from the start.
  double dtFor(double z) =>
      z / (ConveyorBeltComponent.baseSpeed * gm.phase.speedMultiplier);

  /// Steps the item in two updates to just past the decision boundary, with a
  /// small last step so a deflect slide has not yet covered its distance.
  void reach(FoodItemComponent item) {
    item.update(dtFor(0.94));
    item.update(dtFor(0.02));
  }

  bool removed(FoodItemComponent item) {
    game.update(0);
    return !game.children.contains(item);
  }

  group('depth advance', () {
    for (var level = 1; level <= kPhases.length; level++) {
      test('level $level advances z by baseSpeed * multiplier * dt', () async {
        gm.level = level;
        final item = await spawn(ItemType.donut);
        item.update(0.1);
        expect(
          item.z,
          closeTo(
            ConveyorBeltComponent.baseSpeed *
                kPhases[level - 1].speedMultiplier *
                0.1,
            1e-12,
          ),
        );
        item.update(0.2);
        expect(
          item.z,
          closeTo(
            ConveyorBeltComponent.baseSpeed *
                kPhases[level - 1].speedMultiplier *
                0.3,
            1e-12,
          ),
        );
      });
    }

    test('starts at z 0 and undecided', () async {
      final item = await spawn(ItemType.donut);
      expect(item.z, 0.0);
      expect(item.outcome, ItemOutcome.undecided);
    });
  });

  group('decision boundary', () {
    test('not decided just below 0.95', () async {
      mouth.toggle();
      final item = await spawn(ItemType.donut);
      item.update(dtFor(0.94));
      expect(item.z, closeTo(0.94, 1e-9));
      expect(item.outcome, ItemOutcome.undecided);
      expect(removed(item), isFalse);
      expect(gm.score.value, 0);
    });

    test('decided at exactly z >= 0.95', () async {
      mouth.toggle();
      final item = await spawn(ItemType.donut);
      item.update(dtFor(0.94));
      item.update(dtFor(0.01) + 1e-9);
      expect(item.outcome, ItemOutcome.ingest);
    });

    test('decision is taken once, later updates do not re-score', () async {
      mouth.toggle();
      final ingested = <ItemType>[];
      final item = await spawn(ItemType.donut, ingested: ingested);
      reach(item);
      item.update(0.016);
      item.update(0.016);
      expect(gm.score.value, 2);
      expect(ingested, [ItemType.donut]);
    });
  });

  group('ingest with open mouth', () {
    final cases = <ItemType, (int, int)>{
      ItemType.donut: (2, 3),
      ItemType.banana: (1, 3),
      ItemType.broccoli: (0, 2),
    };
    cases.forEach((type, expected) {
      test(
        '${type.name} gives score ${expected.$1}, hp ${expected.$2}',
        () async {
          mouth.toggle();
          final ingested = <ItemType>[];
          final item = await spawn(type, ingested: ingested);
          reach(item);
          expect(gm.score.value, expected.$1);
          expect(gm.hp.value, expected.$2);
          expect(item.outcome, ItemOutcome.ingest);
          expect(removed(item), isTrue);
          expect(ingested, [type]);
        },
      );
    });

    test('ingest does not fire onDeflected', () async {
      mouth.toggle();
      final deflected = <ItemType>[];
      final item = await spawn(ItemType.donut, deflected: deflected);
      reach(item);
      expect(deflected, isEmpty);
    });

    test('item is removed from the game tree', () async {
      mouth.toggle();
      final item = await spawn(ItemType.donut);
      reach(item);
      game.update(0);
      expect(game.children.contains(item), isFalse);
    });
  });

  group('deflect with closed mouth', () {
    for (final type in [ItemType.donut, ItemType.banana, ItemType.broccoli]) {
      test('${type.name} changes neither score nor HP', () async {
        final deflected = <ItemType>[];
        final ingested = <ItemType>[];
        final item = await spawn(
          type,
          deflected: deflected,
          ingested: ingested,
        );
        reach(item);
        expect(item.outcome, ItemOutcome.deflect);
        expect(gm.score.value, 0);
        expect(gm.hp.value, GameManager.maxHp);
        expect(deflected, [type]);
        expect(ingested, isEmpty);
        expect(removed(item), isFalse);
      });
    }

    test('z is frozen while deflecting', () async {
      final item = await spawn(ItemType.donut);
      reach(item);
      final frozen = item.z;
      item.update(0.01);
      item.update(0.01);
      expect(item.z, frozen);
    });

    test('opening the mouth after the decision does not ingest', () async {
      final item = await spawn(ItemType.donut);
      reach(item);
      mouth.toggle();
      item.update(0.01);
      expect(item.outcome, ItemOutcome.deflect);
      expect(gm.score.value, 0);
    });

    test('slides the full deflectDistance then is removed', () async {
      final deflected = <ItemType>[];
      final item = await spawn(ItemType.donut, deflected: deflected);
      reach(item);
      final startX = item.position.x;
      final lateralAtDecision = FoodItemComponent.deflectSpeed * dtFor(0.02);
      final remaining =
          (FoodItemComponent.deflectDistance - lateralAtDecision) /
          FoodItemComponent.deflectSpeed;

      item.update(0.2);
      expect(removed(item), isFalse);
      expect(
        item.position.x - startX,
        closeTo(FoodItemComponent.deflectSpeed * 0.2, 1e-6),
      );

      item.update(remaining - 0.2 + 1e-6);
      expect(removed(item), isTrue);
      expect(deflected, hasLength(1));
      expect(gm.score.value, 0);
      expect(gm.hp.value, GameManager.maxHp);
    });

    test('deflectRight false slides to the left', () async {
      final item = await spawn(ItemType.donut, deflectRight: false);
      reach(item);
      final startX = item.position.x;
      item.update(0.1);
      expect(item.position.x, lessThan(startX));
    });

    test('item is removed from the game tree after the slide', () async {
      final item = await spawn(ItemType.donut);
      reach(item);
      item.update(
        FoodItemComponent.deflectDistance / FoodItemComponent.deflectSpeed +
            0.01,
      );
      game.update(0);
      expect(game.children.contains(item), isFalse);
    });
  });

  group('removal past the near plane', () {
    test('a single huge step leaves no item in the tree', () async {
      mouth.toggle();
      final item = await spawn(ItemType.donut);
      item.update(10);
      expect(removed(item), isTrue);
      expect(item.z, greaterThan(1.0));
      game.update(0);
      expect(game.children.contains(item), isFalse);
    });
  });
}
