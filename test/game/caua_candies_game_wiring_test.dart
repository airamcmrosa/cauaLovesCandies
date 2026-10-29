import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/components/caua_player_component.dart';
import 'package:caua_loves_candies/game/components/conveyor_belt_component.dart';
import 'package:caua_loves_candies/game/components/food_item_component.dart';
import 'package:caua_loves_candies/game/components/item_spawner_component.dart';
import 'package:caua_loves_candies/game/item_sprites.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:caua_loves_candies/game/managers/mouth_controller.dart';
import 'package:caua_loves_candies/game/projection.dart';
import 'package:caua_loves_candies/game/screen_shake.dart';
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

  CauaCandiesGame buildGame({GameManager? gm, MouthController? mouth}) {
    final game = CauaCandiesGame(gameManager: gm, mouthController: mouth);
    for (final name in [
      CauaPlayerComponent.closedSpriteName,
      CauaPlayerComponent.openSpriteName,
      ...itemSpriteAssetList,
    ]) {
      game.images.add(name, baseImage.clone());
    }
    return game;
  }

  void gameTest(String name, Future<void> Function(CauaCandiesGame) body) =>
      testWithGame<CauaCandiesGame>(name, buildGame, body);

  group('world wiring', () {
    gameTest('adds belt, player, spawner and ScreenShake after load', (
      game,
    ) async {
      await game.ready();
      expect(
        game.world.children.whereType<ConveyorBeltComponent>(),
        hasLength(1),
      );
      expect(
        game.world.children.whereType<CauaPlayerComponent>(),
        hasLength(1),
      );
      expect(
        game.world.children.whereType<ItemSpawnerComponent>(),
        hasLength(1),
      );
      expect(game.world.children.whereType<ScreenShake>(), hasLength(1));
    });

    gameTest('player is below the belt, belt below items', (game) async {
      await game.ready();
      final player = game.world.children
          .whereType<CauaPlayerComponent>()
          .single;
      final belt = game.world.children
          .whereType<ConveyorBeltComponent>()
          .single;
      expect(player.priority, lessThan(belt.priority));
      expect(belt.priority, lessThan(0));
      // Items use priority in 0..1000, always at or above zero.
      expect(belt.priority, lessThan(0));
    });

    gameTest('camera anchors world origin to the viewport top-left', (
      game,
    ) async {
      await game.ready();
      expect(game.camera.viewfinder.anchor, Anchor.topLeft);
      expect(game.camera.viewfinder.position.x, 0);
      expect(game.camera.viewfinder.position.y, 0);
    });

    gameTest('background is fully transparent', (game) async {
      await game.ready();
      expect(game.backgroundColor().a, 0);
      expect(game.backgroundColor().toARGB32(), 0x00000000);
    });

    test('yMouth derives from the Projection constants', () {
      expect(
        Projection.yMouth,
        closeTo(
          Projection.yHorizon -
              (Projection.shoulderFraction - Projection.mouthFraction) *
                  Projection.playerSize,
          1e-9,
        ),
      );
      expect(Projection.yMouth, closeTo(440.4, 1e-9));
      expect(Projection.yMouth, lessThan(Projection.yHorizon));
    });

    test('game constants alias the Projection single source', () {
      expect(CauaCandiesGame.playerSize, Projection.playerSize);
      expect(CauaCandiesGame.playerCenterY, Projection.playerCenterY);
      expect(CauaCandiesGame.shoulderFraction, Projection.shoulderFraction);
    });
  });

  group('restart', () {
    test('before onLoad does not throw and resets the manager', () async {
      final gm = GameManager();
      final game = buildGame(gm: gm);
      gm.addScore(5);
      gm.loseHp();
      gm.level = 2;
      await game.restart();
      expect(gm.score.value, 0);
      expect(gm.hp.value, GameManager.maxHp);
      expect(gm.level, GameManager.initialLevel);
      gm.dispose();
      game.mouthController.dispose();
    });

    gameTest('recreates the spawner leaving exactly one', (game) async {
      await game.ready();
      final before = game.world.children
          .whereType<ItemSpawnerComponent>()
          .single;
      await game.restart();
      await game.ready();
      game.update(0);
      final spawners = game.world.children
          .whereType<ItemSpawnerComponent>()
          .toList();
      expect(spawners, hasLength(1));
      expect(spawners.single, isNot(same(before)));
    });

    gameTest('after load resets score, HP and level and clears items', (
      game,
    ) async {
      await game.ready();
      final gm = game.gameManager;
      gm.addScore(7);
      gm.loseHp();
      gm.level = 3;
      await game.world.ensureAdd(
        FoodItemComponent(
          type: ItemType.donut,
          gameManager: gm,
          mouthController: game.mouthController,
          sprite: Sprite(baseImage.clone()),
        ),
      );
      expect(game.world.children.whereType<FoodItemComponent>(), hasLength(1));
      await game.restart();
      await game.ready();
      game.update(0);
      expect(gm.score.value, 0);
      expect(gm.hp.value, GameManager.maxHp);
      expect(gm.level, GameManager.initialLevel);
      expect(game.world.children.whereType<FoodItemComponent>(), isEmpty);
    });
  });

  group('ownership', () {
    test('default-constructed game exposes its own gameManager', () {
      final a = CauaCandiesGame();
      final b = CauaCandiesGame();
      expect(a.gameManager, isA<GameManager>());
      expect(a.gameManager, same(a.gameManager));
      expect(a.gameManager, isNot(same(b.gameManager)));
    });

    test('injected GameManager is exposed as is', () {
      final gm = GameManager();
      final game = CauaCandiesGame(gameManager: gm);
      expect(game.gameManager, same(gm));
    });

    test(
      'removing the game disposes injected GameManager and MouthController',
      () {
        final gm = GameManager();
        final mouth = MouthController();
        final game = buildGame(gm: gm, mouth: mouth);
        game.onRemove();
        expect(() => gm.score.addListener(() {}), throwsFlutterError);
        expect(() => gm.hp.addListener(() {}), throwsFlutterError);
        expect(() => mouth.state.addListener(() {}), throwsFlutterError);
      },
    );
  });
}
