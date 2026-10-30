import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/components/caua_player_component.dart';
import 'package:caua_loves_candies/game/components/conveyor_belt_component.dart';
import 'package:caua_loves_candies/game/components/food_item_component.dart';
import 'package:caua_loves_candies/game/item_sprites.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ui.Image baseImage;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      const ui.Rect.fromLTWH(0, 0, 1, 1),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    baseImage = await recorder.endRecording().toImage(1, 1);
  });

  CauaCandiesGame buildGame() {
    final game = CauaCandiesGame();
    for (final name in [
      CauaPlayerComponent.closedSpriteName,
      CauaPlayerComponent.openSpriteName,
      ...itemSpriteAssetList,
    ]) {
      game.images.add(name, baseImage.clone());
    }
    return game;
  }

  FoodItemComponent item(CauaCandiesGame game) => FoodItemComponent(
    type: ItemType.donut,
    gameManager: game.gameManager,
    mouthController: game.mouthController,
    sprite: Sprite(baseImage.clone()),
  );

  group('restart returns to phase 1', () {
    testWithGame<CauaCandiesGame>(
      'phase, speed multiplier and phaseChanged are reset',
      buildGame,
      (game) async {
        await game.ready();
        final gm = game.gameManager;
        gm.addScore(20);
        expect(gm.currentPhase.value, 3);
        expect(gm.phaseChanged.value, 3);

        final emitted = <int?>[];
        gm.phaseChanged.addListener(() => emitted.add(gm.phaseChanged.value));
        await game.restart();
        await game.ready();

        expect(gm.currentPhase.value, 1);
        expect(gm.currentSpeedMultiplier, kPhases[0].speedMultiplier);
        expect(gm.phaseChanged.value, isNull);
        expect(emitted, [null]);
      },
    );

    testWithGame<CauaCandiesGame>(
      'no stale items remain and new items move at phase 1 speed',
      buildGame,
      (game) async {
        await game.ready();
        final gm = game.gameManager;
        gm.addScore(20);
        await game.world.ensureAdd(item(game));
        expect(
          game.world.children.whereType<FoodItemComponent>(),
          hasLength(1),
        );

        await game.restart();
        await game.ready();
        game.update(0);
        expect(game.world.children.whereType<FoodItemComponent>(), isEmpty);

        final fresh = item(game);
        await game.world.ensureAdd(fresh);
        final z0 = fresh.z;
        fresh.update(0.1);
        expect(
          fresh.z - z0,
          closeTo(
            ConveyorBeltComponent.baseSpeed * kPhases[0].speedMultiplier * 0.1,
            1e-9,
          ),
        );
      },
    );
  });

  group('dispose', () {
    test('removing the game disposes all five notifiers exactly once', () {
      final gm = GameManager();
      final game = CauaCandiesGame(gameManager: gm);
      game.onRemove();
      for (final n in [
        gm.score,
        gm.hp,
        gm.currentPhase,
        gm.phaseChanged,
        gm.finalTargetReached,
      ]) {
        expect(() => n.addListener(() {}), throwsFlutterError);
      }
    });

    testWithGame<CauaCandiesGame>(
      'removing a loaded game does not throw (testWithGame also removes it)',
      buildGame,
      (game) async {
        await game.ready();
        game.gameManager.addScore(10);
        expect(() => game.removeFromParent(), returnsNormally);
      },
    );
  });
}
