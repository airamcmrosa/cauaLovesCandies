import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/caua_game_screen.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/mouth_state.dart';
import 'package:caua_loves_candies/ui/tutorial_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<CauaCandiesGame> open(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CauaGameScreen()));
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
    return tester
        .widget<GameWidget<CauaCandiesGame>>(
          find.byType(GameWidget<CauaCandiesGame>),
        )
        .game!;
  }

  const fade = TutorialOverlay.fadeDuration;

  final taps = <String, Offset Function(WidgetTester)>{
    'center': (t) => t.getCenter(find.byType(TutorialOverlay)),
    'corner': (t) =>
        t.getTopLeft(find.byType(TutorialOverlay)) + const Offset(4, 4),
  };

  group('tutorial dismissing tap is not double-handled', () {
    for (final entry in taps.entries) {
      testWidgets('tap at ${entry.key} only dismisses, no mouth flicker', (
        tester,
      ) async {
        final game = await open(tester);
        var notifications = 0;
        void listener() => notifications++;
        game.mouthController.state.addListener(listener);
        addTearDown(() => game.mouthController.state.removeListener(listener));
        final score = game.gameManager.score.value;
        final hp = game.gameManager.hp.value;
        expect(game.mouthController.state.value, MouthState.closed);

        final point = entry.value(tester);
        await tester.tapAt(point);
        await tester.pump();

        expect(game.gameManager.state, GameState.playing);
        expect(game.mouthController.state.value, MouthState.closed);
        expect(notifications, 0);

        // Second and third taps during the fade are also swallowed.
        await tester.pump(const Duration(milliseconds: 80));
        await tester.tapAt(point);
        await tester.pump(const Duration(milliseconds: 80));
        await tester.tapAt(point);
        await tester.pump(const Duration(milliseconds: 40));

        expect(game.mouthController.state.value, MouthState.closed);
        expect(notifications, 0);

        await tester.pump(fade + const Duration(milliseconds: 50));
        await tester.pump();
        expect(find.byType(TutorialOverlay), findsNothing);
        expect(game.mouthController.state.value, MouthState.closed);
        expect(notifications, 0);
        expect(game.gameManager.score.value, score);
        expect(game.gameManager.hp.value, hp);
      });
    }

    testWidgets('after the fade one tap toggles the mouth exactly once', (
      tester,
    ) async {
      final game = await open(tester);
      var notifications = 0;
      void listener() => notifications++;
      game.mouthController.state.addListener(listener);
      addTearDown(() => game.mouthController.state.removeListener(listener));

      await tester.tap(find.byType(TutorialOverlay));
      await tester.pump();
      await tester.pump(fade + const Duration(milliseconds: 50));
      await tester.pump();
      expect(find.byType(TutorialOverlay), findsNothing);
      expect(notifications, 0);

      final center = tester.getCenter(find.byType(GameWidget<CauaCandiesGame>));
      await tester.tapAt(center);
      await tester.pump();

      expect(notifications, 1);
      expect(game.mouthController.state.value, MouthState.open);
      expect(game.gameManager.state, GameState.playing);
      expect(game.gameManager.score.value, 0);
      expect(game.gameManager.hp.value, GameManager.maxHp);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
