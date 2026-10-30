import 'dart:math';
import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/components/caua_player_component.dart';
import 'package:caua_loves_candies/game/components/caua_pose.dart';
import 'package:caua_loves_candies/game/item_sprites.dart';
import 'package:caua_loves_candies/game/managers/blink_controller.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/mouth_controller.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Always returns 0 so the idle gap is exactly [BlinkController.minGapSeconds].
class _ZeroRandom implements Random {
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => 0;
  @override
  int nextInt(int max) => 0;
}

const double _gap = BlinkController.minGapSeconds;
const double _step = BlinkController.stepSeconds;

Future<ui.Image> _makeImage() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 1, 1),
    ui.Paint()..color = const ui.Color(0xFFFFFFFF),
  );
  return recorder.endRecording().toImage(1, 1);
}

void main() {
  late ui.Image base;
  late MouthController mouth;
  late BlinkController blink;
  late Map<String, ui.Image> images;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    base = await _makeImage();
  });

  setUp(() {
    mouth = MouthController();
    blink = BlinkController(random: _ZeroRandom());
    images = {};
  });

  tearDown(() {
    mouth.dispose();
    blink.dispose();
  });

  /// Registers one distinct image per sprite name, except [skip].
  void preload(FlameGame game, {Set<String> skip = const {}}) {
    // Flame's image cache can be shared across games; start clean.
    game.images.clearCache();
    for (final name in CauaPlayerComponent.allSpriteNames) {
      if (skip.contains(name)) continue;
      final img = base.clone();
      images[name] = img;
      game.images.add(name, img);
    }
  }

  String nameOf(CauaPose pose, EyeState eye) =>
      CauaPlayerComponent.allSpriteNames[pose.index * 3 + eye.index];

  ui.Image imageOf(CauaPose pose, EyeState eye) => images[nameOf(pose, eye)]!;

  // Drives the blink controller through the sequence (via the component).
  void toHalf1(CauaPlayerComponent p) => p.update(_gap);
  void toShut(CauaPlayerComponent p) => p.update(_step);

  group('sprite table', () {
    for (final pose in [CauaPose.mouthClosed, CauaPose.mouthOpen]) {
      for (final eye in EyeState.values) {
        testWithFlameGame('mouth-driven ${pose.name} + ${eye.name}', (
          game,
        ) async {
          preload(game);
          if (pose == CauaPose.mouthOpen) mouth.toggle();
          final p = CauaPlayerComponent(
            mouthController: mouth,
            blinkController: blink,
          );
          await game.ensureAdd(p);
          toHalf1(p);
          if (eye == EyeState.open) {
            // Finish the blink: half -> shut -> half -> open.
            toShut(p);
            p.update(_step);
            p.update(_step);
          } else if (eye == EyeState.shut) {
            toShut(p);
          }
          expect(blink.state.value, eye);
          expect(p.sprite!.image, same(imageOf(pose, eye)));
        });
      }
    }

    for (final eye in EyeState.values) {
      testWithFlameGame('win override + ${eye.name}', (game) async {
        preload(game);
        final p = CauaPlayerComponent(
          mouthController: mouth,
          blinkController: blink,
        );
        await game.ensureAdd(p);
        p.poseOverride = CauaPose.win;
        if (eye != EyeState.open) toHalf1(p);
        if (eye == EyeState.shut) toShut(p);
        expect(blink.state.value, eye);
        expect(p.sprite!.image, same(imageOf(CauaPose.win, eye)));

        // Mouth taps do not affect the win pose.
        mouth.toggle();
        expect(p.sprite!.image, same(imageOf(CauaPose.win, eye)));
      });
    }

    testWithFlameGame('clearing poseOverride restores the mouth pose', (
      game,
    ) async {
      preload(game);
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      p.poseOverride = CauaPose.win;
      p.poseOverride = null;
      expect(
        p.sprite!.image,
        same(imageOf(CauaPose.mouthClosed, EyeState.open)),
      );
    });

    testWithFlameGame('without a blink controller eyes stay open', (
      game,
    ) async {
      preload(game);
      final p = CauaPlayerComponent(mouthController: mouth);
      await game.ensureAdd(p);
      p.update(100);
      mouth.toggle();
      expect(p.sprite!.image, same(imageOf(CauaPose.mouthOpen, EyeState.open)));
    });
  });

  group('missing frame fallback (same pose)', () {
    testWithFlameGame('missing half uses open', (game) async {
      preload(game, skip: {nameOf(CauaPose.mouthClosed, EyeState.half)});
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      toHalf1(p);
      expect(blink.state.value, EyeState.half);
      expect(
        p.sprite!.image,
        same(imageOf(CauaPose.mouthClosed, EyeState.open)),
      );
    });

    testWithFlameGame('missing open uses half', (game) async {
      preload(game, skip: {nameOf(CauaPose.mouthClosed, EyeState.open)});
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      expect(
        p.sprite!.image,
        same(imageOf(CauaPose.mouthClosed, EyeState.half)),
      );
    });

    testWithFlameGame('missing shut uses half', (game) async {
      preload(game, skip: {nameOf(CauaPose.mouthClosed, EyeState.shut)});
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      toHalf1(p);
      toShut(p);
      expect(blink.state.value, EyeState.shut);
      expect(
        p.sprite!.image,
        same(imageOf(CauaPose.mouthClosed, EyeState.half)),
      );
    });

    testWithFlameGame('missing shut and half uses open', (game) async {
      preload(
        game,
        skip: {
          nameOf(CauaPose.mouthClosed, EyeState.shut),
          nameOf(CauaPose.mouthClosed, EyeState.half),
        },
      );
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      toHalf1(p);
      toShut(p);
      expect(
        p.sprite!.image,
        same(imageOf(CauaPose.mouthClosed, EyeState.open)),
      );
    });

    testWithFlameGame('fallback never crosses poses', (game) async {
      preload(game, skip: {nameOf(CauaPose.mouthOpen, EyeState.half)});
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      mouth.toggle();
      toHalf1(p);
      expect(p.sprite!.image, same(imageOf(CauaPose.mouthOpen, EyeState.open)));
    });
  });

  group('blink integration', () {
    testWithFlameGame('tap during a blink keeps the current eye frame', (
      game,
    ) async {
      preload(game);
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      toHalf1(p);
      toShut(p);
      expect(
        p.sprite!.image,
        same(imageOf(CauaPose.mouthClosed, EyeState.shut)),
      );

      mouth.toggle();
      expect(p.sprite!.image, same(imageOf(CauaPose.mouthOpen, EyeState.shut)));

      // The blink continues with the new mouth.
      p.update(_step);
      expect(p.sprite!.image, same(imageOf(CauaPose.mouthOpen, EyeState.half)));
    });

    testWithFlameGame('no tick when blinkEnabled is false', (game) async {
      preload(game);
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      )..blinkEnabled = false;
      await game.ensureAdd(p);
      p.update(_gap * 4);
      expect(blink.state.value, EyeState.open);

      p.blinkEnabled = true;
      p.update(_gap);
      expect(blink.state.value, EyeState.half);
    });

    testWithFlameGame('after removal: listeners gone and no tick', (
      game,
    ) async {
      preload(game);
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      final before = p.sprite!.image;

      p.removeFromParent();
      game.update(0);
      await game.ready();
      expect(p.isMounted, isFalse);

      // Mouth notifier no longer swaps the sprite.
      mouth.toggle();
      expect(p.sprite!.image, same(before));

      // Update does not tick the blink controller.
      p.update(_gap * 4);
      expect(blink.state.value, EyeState.open);

      // Blink notifier no longer swaps the sprite.
      blink.tick(_gap);
      expect(blink.state.value, EyeState.half);
      expect(p.sprite!.image, same(before));

      // The component did not dispose the controller it does not own.
      expect(() => blink.tick(_step), returnsNormally);
    });
  });

  group('blinkEnabled reset (T4)', () {
    testWithFlameGame('disabling mid-blink forces open eyes', (game) async {
      preload(game);
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      toHalf1(p);
      toShut(p);
      expect(
        p.sprite!.image,
        same(imageOf(CauaPose.mouthClosed, EyeState.shut)),
      );

      p.blinkEnabled = false;
      expect(blink.state.value, EyeState.open);
      expect(
        p.sprite!.image,
        same(imageOf(CauaPose.mouthClosed, EyeState.open)),
      );
    });

    testWithFlameGame('no blink while disabled, even after a long time', (
      game,
    ) async {
      preload(game);
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      toHalf1(p);
      p.blinkEnabled = false;
      for (var i = 0; i < 20; i++) {
        p.update(_gap);
        expect(blink.state.value, EyeState.open);
      }
    });

    testWithFlameGame('after re-enable first blink is at least 2.5 s away', (
      game,
    ) async {
      preload(game);
      final p = CauaPlayerComponent(
        mouthController: mouth,
        blinkController: blink,
      );
      await game.ensureAdd(p);
      toHalf1(p);
      p.blinkEnabled = false;
      p.update(_gap * 4);
      p.blinkEnabled = true;

      p.update(_gap - 0.01);
      expect(blink.state.value, EyeState.open);
      p.update(0.01);
      expect(blink.state.value, EyeState.half);
    });
  });

  group('CauaCandiesGame ownership', () {
    testWithGame<CauaCandiesGame>(
      'disposes its blink controller after removing the player',
      () {
        final game = CauaCandiesGame(random: _ZeroRandom());
        for (final name in [
          ...CauaPlayerComponent.allSpriteNames,
          ...itemSpriteAssetList,
        ]) {
          game.images.add(name, base.clone());
        }
        return game;
      },
      (game) async {
        await game.ready();
        // The test harness calls onRemove (and fails on any throw) at teardown.
        expect(game.isMounted, isTrue);
      },
    );
  });

  group('CauaCandiesGame blink wiring (T4)', () {
    CauaCandiesGame makeGame() {
      final game = CauaCandiesGame(random: _ZeroRandom());
      for (final name in [
        ...CauaPlayerComponent.allSpriteNames,
        ...itemSpriteAssetList,
      ]) {
        game.images.add(name, base.clone());
      }
      return game;
    }

    CauaPlayerComponent playerOf(CauaCandiesGame g) =>
        g.world.children.whereType<CauaPlayerComponent>().single;

    ui.Image frame(CauaCandiesGame g, CauaPose pose, EyeState eye) =>
        g.images.fromCache(nameOf(pose, eye));

    testWithGame<CauaCandiesGame>(
      'blinkEnabled stays on in the tutorial and while playing',
      makeGame,
      (game) async {
        await game.ready();
        expect(game.gameManager.state, GameState.tutorial);
        game.update(0.001);
        expect(playerOf(game).blinkEnabled, isTrue);
        game.gameManager.dismissTutorial();
        game.update(0.001);
        expect(playerOf(game).blinkEnabled, isTrue);
        // Eyes open before the first gap elapses, half once it does.
        expect(
          playerOf(game).sprite!.image,
          same(frame(game, CauaPose.mouthClosed, EyeState.open)),
        );
        game.update(_gap);
        expect(
          playerOf(game).sprite!.image,
          same(frame(game, CauaPose.mouthClosed, EyeState.half)),
        );
      },
    );

    testWithGame<CauaCandiesGame>('restart resets the blink', makeGame, (
      game,
    ) async {
      await game.ready();
      game.update(_gap);
      game.update(_step);
      expect(
        playerOf(game).sprite!.image,
        same(frame(game, CauaPose.mouthClosed, EyeState.shut)),
      );

      await game.restart();
      game.update(0);
      expect(
        playerOf(game).sprite!.image,
        same(frame(game, CauaPose.mouthClosed, EyeState.open)),
      );
      game.update(_gap - 0.2);
      expect(
        playerOf(game).sprite!.image,
        same(frame(game, CauaPose.mouthClosed, EyeState.open)),
      );
      game.update(0.21);
      expect(
        playerOf(game).sprite!.image,
        same(frame(game, CauaPose.mouthClosed, EyeState.half)),
      );
    });
  });
}
