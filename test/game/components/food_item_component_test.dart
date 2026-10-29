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

  /// Finishes the ingest tween (dt-driven) so the item can be removed.
  void finishTween(FoodItemComponent item) =>
      item.update(FoodItemComponent.ingestTweenDuration);

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
          expect(ingested, [type]);
          finishTween(item);
          expect(removed(item), isTrue);
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
      finishTween(item);
      game.update(0);
      expect(game.children.contains(item), isFalse);
    });

    test('item stays in the tree until the tween completes', () async {
      mouth.toggle();
      final item = await spawn(ItemType.donut);
      reach(item);
      item.update(FoodItemComponent.ingestTweenDuration * 0.5);
      expect(removed(item), isFalse);
    });
  });

  group('ingest tween', () {
    test('z is frozen at the decision z during the tween', () async {
      mouth.toggle();
      final item = await spawn(ItemType.donut);
      reach(item);
      expect(item.z, Projection.decisionZ);
      item.update(0.05);
      item.update(0.05);
      expect(item.z, Projection.decisionZ);
    });

    test('moves toward the mouth and shrinks to ingestEndScale', () async {
      mouth.toggle();
      final item = await spawn(ItemType.donut);
      reach(item);
      // A zero-dt tween step snaps to the tween start pose (decision z).
      item.update(0);
      final startY = item.position.y;
      final startScale = item.scale.x;
      expect(startY, closeTo(yAt(Projection.decisionZ), 1e-5));
      expect(startScale, closeTo(scaleAt(Projection.decisionZ), 1e-5));

      item.update(FoodItemComponent.ingestTweenDuration / 2);
      expect(item.position.y, lessThan(startY));
      expect(item.position.y, greaterThan(Projection.yMouth));
      expect(item.scale.x, lessThan(startScale));
      expect(item.scale.x, greaterThan(FoodItemComponent.ingestEndScale));
      expect(
        item.scale.x,
        closeTo((startScale + FoodItemComponent.ingestEndScale) / 2, 1e-5),
      );

      item.update(FoodItemComponent.ingestTweenDuration / 2);
      expect(item.position.x, closeTo(Projection.xMouth, 1e-5));
      expect(item.position.y, closeTo(Projection.yMouth, 1e-5));
      expect(item.scale.x, closeTo(FoodItemComponent.ingestEndScale, 1e-5));
      expect(removed(item), isTrue);
    });

    test('item is removed after ingestTweenDuration, not before', () async {
      mouth.toggle();
      final item = await spawn(ItemType.donut);
      reach(item);
      item.update(FoodItemComponent.ingestTweenDuration - 0.01);
      expect(removed(item), isFalse);
      item.update(0.01 + 1e-5);
      expect(removed(item), isTrue);
    });

    test('no double firing with further updates', () async {
      mouth.toggle();
      final ingested = <ItemType>[];
      final item = await spawn(ItemType.donut, ingested: ingested);
      reach(item);
      expect(gm.score.value, 2);
      for (var i = 0; i < 5; i++) {
        item.update(0.05);
      }
      expect(ingested, [ItemType.donut]);
      expect(gm.score.value, 2);
      expect(gm.hp.value, GameManager.maxHp);
    });

    test(
      'score and HP apply at the decision instant, before the tween',
      () async {
        mouth.toggle();
        final item = await spawn(ItemType.broccoli);
        reach(item);
        expect(gm.hp.value, GameManager.maxHp - 1);
        expect(item.outcome, ItemOutcome.ingest);
      },
    );

    test('mouth state changes during the tween do not affect it', () async {
      mouth.toggle();
      final item = await spawn(ItemType.donut);
      reach(item);
      mouth.toggle();
      item.update(0.05);
      expect(item.outcome, ItemOutcome.ingest);
      expect(gm.score.value, 2);
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
      expect(gm.score.value, 2);
      finishTween(item);
      expect(removed(item), isTrue);
      expect(item.z, Projection.decisionZ);
      game.update(0);
      expect(game.children.contains(item), isFalse);
    });
  });
}
