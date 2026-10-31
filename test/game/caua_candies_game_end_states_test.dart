import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/components/caua_player_component.dart';
import 'package:caua_loves_candies/game/components/food_item_component.dart';
import 'package:caua_loves_candies/game/components/particle_celebration_component.dart';
import 'package:caua_loves_candies/game/item_sprites.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:flame/events.dart';
import 'package:flutter/widgets.dart';
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
      ...CauaPlayerComponent.allSpriteNames,
      ...itemSpriteAssetList,
    ]) {
      game.images.add(name, baseImage.clone());
    }
    // Hosts register the overlay builders; stand-ins keep Flame's asserts quiet.
    for (final key in [
      CauaCandiesGame.victoryOverlayKey,
      CauaCandiesGame.gameOverOverlayKey,
    ]) {
      game.overlays.addEntry(key, (_, _) => const SizedBox.shrink());
    }
    return game;
  }

  Iterable<ParticleCelebrationComponent> confetti(CauaCandiesGame g) => g
      .world
      .children
      .whereType<ParticleCelebrationComponent>()
      .where((c) => c.preset == CelebrationPreset.victory);

  group('GameManager lost state', () {
    test('third HP loss moves playing to lost and freezes time', () {
      final gm = GameManager()..dismissTutorial();
      gm
        ..loseHp()
        ..loseHp();
      expect(gm.state, GameState.playing);
      gm.loseHp();
      expect(gm.hp.value, 0);
      expect(gm.state, GameState.lost);
      expect(gm.timeScale, 0);
      gm.dispose();
    });

    test('lost is notified once and reset returns to playing', () {
      final gm = GameManager()..dismissTutorial();
      final seen = <GameState>[];
      gm.stateNotifier.addListener(() => seen.add(gm.state));
      for (var i = 0; i < 5; i++) {
        gm.loseHp();
      }
      expect(seen, [GameState.lost]);
      gm.reset();
      expect(seen, [GameState.lost, GameState.playing]);
      expect(gm.hp.value, GameManager.maxHp);
      expect(gm.score.value, 0);
      expect(gm.level, 1);
      gm.dispose();
    });

    test('victory is not overridden by later HP loss', () {
      final gm = GameManager()..dismissTutorial();
      gm.addScore(kPhases.last.targetScore);
      expect(gm.state, GameState.victory);
      gm
        ..loseHp()
        ..loseHp()
        ..loseHp();
      expect(gm.state, GameState.victory);
      gm.dispose();
    });
  });

  group('end states in the game', () {
    testWithGame<CauaCandiesGame>(
      'victory adds confetti and overlay once',
      buildGame,
      (game) async {
        await game.ready();
        final gm = game.gameManager..dismissTutorial();
        gm.addScore(kPhases.last.targetScore);
        await game.ready();
        expect(confetti(game).length, 1);
        expect(
          game.overlays.isActive(CauaCandiesGame.victoryOverlayKey),
          isTrue,
        );
        expect(
          game.overlays.isActive(CauaCandiesGame.gameOverOverlayKey),
          isFalse,
        );
        gm.addScore(5);
        await game.ready();
        expect(confetti(game).length, 1);
      },
    );

    testWithGame<CauaCandiesGame>(
      'lost shows game over overlay only',
      buildGame,
      (game) async {
        await game.ready();
        final gm = game.gameManager..dismissTutorial();
        for (var i = 0; i < 3; i++) {
          gm.loseHp();
        }
        expect(
          game.overlays.isActive(CauaCandiesGame.gameOverOverlayKey),
          isTrue,
        );
        expect(
          game.overlays.isActive(CauaCandiesGame.victoryOverlayKey),
          isFalse,
        );
        expect(confetti(game), isEmpty);
      },
    );

    testWithGame<CauaCandiesGame>('taps are ignored in end states', buildGame, (
      game,
    ) async {
      await game.ready();
      final gm = game.gameManager..dismissTutorial();
      for (var i = 0; i < 3; i++) {
        gm.loseHp();
      }
      final wasOpen = game.mouthController.isOpen;
      game.onTapDown(
        TapDownEvent(1, game, TapDownDetails(globalPosition: Offset.zero)),
      );
      expect(game.mouthController.isOpen, wasOpen);
    });

    testWithGame<CauaCandiesGame>(
      'restart from victory and lost is clean, 10 repetitions are stable',
      buildGame,
      (game) async {
        await game.ready();
        final gm = game.gameManager..dismissTutorial();
        final baseline = game.world.children.length;
        for (var i = 0; i < 10; i++) {
          if (i.isEven) {
            gm.addScore(kPhases.last.targetScore);
          } else {
            for (var h = 0; h < 3; h++) {
              gm.loseHp();
            }
          }
          await game.ready();
          await game.restart();
          await game.ready();
          expect(gm.state, GameState.playing);
          expect(gm.score.value, 0);
          expect(gm.hp.value, GameManager.maxHp);
          expect(gm.level, 1);
          expect(confetti(game), isEmpty);
          expect(game.world.children.whereType<FoodItemComponent>(), isEmpty);
          expect(
            game.overlays.isActive(CauaCandiesGame.victoryOverlayKey),
            isFalse,
          );
          expect(
            game.overlays.isActive(CauaCandiesGame.gameOverOverlayKey),
            isFalse,
          );
          expect(game.world.children.length, baseline);
        }
      },
    );
  });
}
