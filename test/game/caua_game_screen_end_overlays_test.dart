import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/caua_game_screen.dart';
import 'package:caua_loves_candies/ui/game_over_overlay.dart';
import 'package:caua_loves_candies/ui/victory_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('screen registers victory and gameOver overlays and the '
      'cards build', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CauaGameScreen()));
    final widget = tester.widget<GameWidget<CauaCandiesGame>>(
      find.byType(GameWidget<CauaCandiesGame>),
    );
    final map = widget.overlayBuilderMap!;
    expect(map, contains(CauaCandiesGame.victoryOverlayKey));
    expect(map, contains(CauaCandiesGame.gameOverOverlayKey));
    // Neither end card is active at start.
    expect(
      widget.initialActiveOverlays ?? const <String>[],
      isNot(contains(CauaCandiesGame.victoryOverlayKey)),
    );

    final game = CauaCandiesGame();
    addTearDown(() {
      game.gameManager.dispose();
      game.mouthController.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Stack(
            children: [
              map[CauaCandiesGame.victoryOverlayKey]!(context, game),
              map[CauaCandiesGame.gameOverOverlayKey]!(context, game),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(VictoryOverlay), findsOneWidget);
    expect(find.byType(GameOverOverlay), findsOneWidget);
  });
}
