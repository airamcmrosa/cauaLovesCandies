import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/components/caua_player_component.dart';
import 'package:caua_loves_candies/game/managers/mouth_controller.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
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
  late ui.Image closedImage;
  late ui.Image openImage;
  late ui.Image baseClosed;
  late ui.Image baseOpen;
  late MouthController controller;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    baseClosed = await _makeImage();
    baseOpen = await _makeImage();
  });

  setUp(() {
    controller = MouthController();
    // The images cache owns (and disposes) what it is given, so hand it clones.
    closedImage = baseClosed.clone();
    openImage = baseOpen.clone();
  });

  tearDown(() => controller.dispose());

  void preload(FlameGame game) {
    game.images.add(CauaPlayerComponent.closedSpriteName, closedImage);
    game.images.add(CauaPlayerComponent.openSpriteName, openImage);
  }

  group('CauaPlayerComponent', () {
    testWithFlameGame('shows the closed sprite by default after load', (
      game,
    ) async {
      preload(game);
      final player = CauaPlayerComponent(mouthController: controller);
      await game.ensureAdd(player);

      expect(player.sprite, isNotNull);
      expect(player.sprite!.image, same(closedImage));
    });

    testWithFlameGame(
      'shows the open sprite when the controller is already open',
      (game) async {
        controller.toggle();
        preload(game);
        final player = CauaPlayerComponent(mouthController: controller);
        await game.ensureAdd(player);

        expect(player.sprite!.image, same(openImage));
      },
    );

    testWithFlameGame('toggle swaps sprite immediately, without a game tick', (
      game,
    ) async {
      preload(game);
      final player = CauaPlayerComponent(mouthController: controller);
      await game.ensureAdd(player);

      controller.toggle();
      expect(player.sprite!.image, same(openImage));

      controller.toggle();
      expect(player.sprite!.image, same(closedImage));

      controller.toggle();
      controller.reset();
      expect(player.sprite!.image, same(closedImage));
    });

    testWithFlameGame('removal detaches the listener', (game) async {
      preload(game);
      final player = CauaPlayerComponent(mouthController: controller);
      await game.ensureAdd(player);

      player.removeFromParent();
      game.update(0);
      await game.ready();
      expect(player.isMounted, isFalse);

      expect(() => controller.toggle(), returnsNormally);
      expect(player.sprite!.image, same(closedImage));
      expect(() => controller.toggle(), returnsNormally);
      expect(player.sprite!.image, same(closedImage));
    });

    testWithFlameGame('missing preload fails loudly', (game) async {
      final player = CauaPlayerComponent(mouthController: controller);

      player.parent = game;
      await expectLater(player.onLoad(), throwsA(anything));
    });
  });
}
