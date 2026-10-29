import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/components/caua_player_component.dart';
import 'package:caua_loves_candies/game/managers/mouth_controller.dart';
import 'package:caua_loves_candies/game/managers/mouth_state.dart';
import 'package:flame/components.dart';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ui.Image> _makeImage() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 1, 1),
    ui.Paint()..color = const ui.Color(0xFFFFFFFF),
  );
  return recorder.endRecording().toImage(1, 1);
}

void main() {
  late ui.Image baseImage;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    baseImage = await _makeImage();
  });

  // Pre-adds the images under the expected names so that images.loadAll in
  // onLoad hits the cache and never touches the real asset bundle.
  CauaCandiesGame buildGame({MouthController? controller}) {
    final game = CauaCandiesGame(mouthController: controller);
    game.images.add(CauaPlayerComponent.closedSpriteName, baseImage.clone());
    game.images.add(CauaPlayerComponent.openSpriteName, baseImage.clone());
    return game;
  }

  void tapDown(CauaCandiesGame game) {
    game.onTapDown(
      TapDownEvent(
        1,
        game,
        TapDownDetails(globalPosition: const Offset(10, 10)),
      ),
    );
  }

  group('CauaCandiesGame', () {
    void gameTest(String name, Future<void> Function(CauaCandiesGame) body) =>
        testWithGame<CauaCandiesGame>(name, buildGame, body);

    gameTest('adds a closed, centered 480x480 player to the world after load', (
      game,
    ) async {
      await game.ready();
      final players = game.world.children.whereType<CauaPlayerComponent>();
      expect(players, hasLength(1));
      final player = players.single;
      expect(player.position.x, closeTo(360, 1e-9));
      expect(player.position.y, closeTo(800, 1e-9));
      expect(player.size.x, closeTo(480, 1e-9));
      expect(player.size.y, closeTo(480, 1e-9));
      expect(player.anchor, Anchor.center);
      expect(game.mouthController.state.value, MouthState.closed);
    });

    gameTest('uses a fixed 720x1280 viewport', (game) async {
      await game.ready();
      expect(CauaCandiesGame.virtualWidth, 720);
      expect(CauaCandiesGame.virtualHeight, 1280);
      final viewport = game.camera.viewport;
      expect(viewport, isA<FixedResolutionViewport>());
      final fixed = viewport as FixedResolutionViewport;
      expect(fixed.resolution.x, closeTo(720, 1e-9));
      expect(fixed.resolution.y, closeTo(1280, 1e-9));
    });

    gameTest('a tap down toggles open and a second toggles back to closed', (
      game,
    ) async {
      await game.ready();
      tapDown(game);
      expect(game.mouthController.state.value, MouthState.open);
      tapDown(game);
      expect(game.mouthController.state.value, MouthState.closed);
    });

    gameTest('a double tap yields two toggles', (game) async {
      await game.ready();
      var changes = 0;
      game.mouthController.state.addListener(() => changes++);
      tapDown(game);
      tapDown(game);
      expect(changes, 2);
      expect(game.mouthController.state.value, MouthState.closed);
    });

    gameTest('toggles on tap down without requiring tap up', (game) async {
      await game.ready();
      tapDown(game);
      expect(game.mouthController.state.value, MouthState.open);
    });

    gameTest('mouthController is the controller driving the player sprite', (
      game,
    ) async {
      await game.ready();
      final player = game.world.children
          .whereType<CauaPlayerComponent>()
          .single;
      final closedSprite = player.sprite;
      tapDown(game);
      expect(game.mouthController.state.value, MouthState.open);
      expect(player.sprite, isNot(same(closedSprite)));
      tapDown(game);
      expect(player.sprite!.image, same(closedSprite!.image));
    });
  });

  group('CauaCandiesGame with injected controller', () {
    final injected = MouthController();
    void gameTest(String name, Future<void> Function(CauaCandiesGame) body) =>
        testWithGame<CauaCandiesGame>(
          name,
          () => buildGame(controller: injected),
          body,
        );

    gameTest('exposes and drives the injected controller', (game) async {
      await game.ready();
      expect(game.mouthController, same(injected));
      tapDown(game);
      expect(injected.state.value, MouthState.open);
    });
  });
}
