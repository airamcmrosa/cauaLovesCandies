import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/caua_game_screen.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CauaCandiesGame currentGame(WidgetTester tester) => tester
      .widget<GameWidget<CauaCandiesGame>>(
        find.byType(GameWidget<CauaCandiesGame>),
      )
      .game!;

  group('CauaGameScreen wiring', () {
    testWidgets('exposes the keyed parent and container', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CauaGameScreen()));
      expect(find.byKey(const Key('game parent')), findsOneWidget);
      expect(find.byKey(const Key('game container')), findsOneWidget);
    });

    testWidgets('registers the hud overlay and activates it at start', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: CauaGameScreen()));
      final widget = tester.widget<GameWidget<CauaCandiesGame>>(
        find.byType(GameWidget<CauaCandiesGame>),
      );
      expect(widget.overlayBuilderMap, contains('hud'));
      expect(widget.initialActiveOverlays, contains('hud'));
      expect(currentGame(tester).gameManager, isNotNull);
    });

    testWidgets('builds without an AudioController provider', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CauaGameScreen()));
      expect(tester.takeException(), isNull);
      expect(find.byType(GameWidget<CauaCandiesGame>), findsOneWidget);
    });
  });
}
