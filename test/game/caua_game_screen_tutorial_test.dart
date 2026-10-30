import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/caua_game_screen.dart';
import 'package:caua_loves_candies/game/components/food_item_component.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/ui/tutorial_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CauaCandiesGame currentGame(WidgetTester tester) => tester
      .widget<GameWidget<CauaCandiesGame>>(
        find.byType(GameWidget<CauaCandiesGame>),
      )
      .game!;

  Future<CauaCandiesGame> open(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CauaGameScreen()));
    // The game loads asynchronously; pump until the overlay layer is built.
    for (
      var i = 0;
      i < 20 && find.byType(TutorialOverlay).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    return currentGame(tester);
  }

  const key = CauaCandiesGame.tutorialOverlayKey;
  const fade = TutorialOverlay.fadeDuration;

  group('CauaGameScreen tutorial overlay', () {
    testWidgets(
      'registers hud, phase banner and tutorial overlays, all initially active',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: CauaGameScreen()));
        final widget = tester.widget<GameWidget<CauaCandiesGame>>(
          find.byType(GameWidget<CauaCandiesGame>),
        );
        expect(CauaCandiesGame.tutorialOverlayKey, 'tutorial');
        expect(CauaCandiesGame.hudOverlayKey, 'hud');
        expect(widget.overlayBuilderMap, contains('hud'));
        expect(widget.overlayBuilderMap, contains('tutorial'));
        expect(widget.overlayBuilderMap, contains('phaseBanner'));
        expect(widget.initialActiveOverlays, [
          'hud',
          'phaseBanner',
          'tutorial',
        ]);
      },
    );

    testWidgets('shows the overlay on open with the manager in tutorial', (
      tester,
    ) async {
      final game = await open(tester);

      expect(find.byType(TutorialOverlay), findsOneWidget);
      expect(game.overlays.isActive(key), isTrue);
      expect(game.gameManager.state, GameState.tutorial);
      expect(game.gameManager.timeScale, 0.0);
    });

    testWidgets('belt does not spawn items while the tutorial is shown', (
      tester,
    ) async {
      final game = await open(tester);
      for (var i = 0; i < 20; i++) {
        game.update(0.5);
      }
      expect(game.world.children.whereType<FoodItemComponent>(), isEmpty);
    });

    testWidgets('tap dismisses immediately, overlay removed after the fade', (
      tester,
    ) async {
      final game = await open(tester);

      await tester.tap(find.byType(TutorialOverlay));
      await tester.pump();
      // Still fading, but the game is already playing.
      expect(game.gameManager.state, GameState.playing);
      expect(find.byType(TutorialOverlay), findsOneWidget);
      expect(game.overlays.isActive(key), isTrue);

      await tester.pump(fade + const Duration(milliseconds: 50));
      await tester.pump();
      expect(find.byType(TutorialOverlay), findsNothing);
      expect(game.overlays.isActive(key), isFalse);
      expect(game.overlays.activeOverlays, isNot(contains(key)));
      expect(game.overlays.isActive(CauaCandiesGame.hudOverlayKey), isTrue);
    });

    testWidgets('repeated taps during the fade are no-ops', (tester) async {
      final game = await open(tester);

      await tester.tap(find.byType(TutorialOverlay));
      await tester.pump(const Duration(milliseconds: 50));
      expect(game.gameManager.state, GameState.playing);
      await tester.tap(find.byType(TutorialOverlay), warnIfMissed: false);
      await tester.tap(find.byType(TutorialOverlay), warnIfMissed: false);
      await tester.pump();

      expect(game.gameManager.state, GameState.playing);
      await tester.pump(fade + const Duration(milliseconds: 50));
      await tester.pump();
      expect(game.overlays.isActive(key), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('restart removes the overlay and stays in playing', (
      tester,
    ) async {
      final game = await open(tester);
      expect(game.overlays.isActive(key), isTrue);

      await game.restart();
      await tester.pump();
      await tester.pump();

      expect(game.overlays.isActive(key), isFalse);
      expect(find.byType(TutorialOverlay), findsNothing);
      expect(game.gameManager.state, GameState.playing);
    });

    testWidgets(
      'stale overlay with state playing builds nothing and is removed',
      (tester) async {
        final game = await open(tester);
        game.gameManager.dismissTutorial();
        // Re-activate the key to force a rebuild of the builder while playing.
        game.overlays.remove(key);
        await tester.pump();
        game.overlays.add(key);
        await tester.pump();
        await tester.pump();

        expect(find.byType(TutorialOverlay), findsNothing);
        expect(game.overlays.isActive(key), isFalse);
      },
    );
  });
}
