import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/caua_game_screen.dart';
import 'package:caua_loves_candies/router.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Widget host({Widget? child}) =>
      MaterialApp(home: child ?? const CauaGameScreen());

  CauaCandiesGame currentGame(WidgetTester tester) => tester
      .widget<GameWidget<CauaCandiesGame>>(
        find.byType(GameWidget<CauaCandiesGame>),
      )
      .game!;

  group('CauaGameScreen', () {
    testWidgets('shows a GameWidget and the back button', (tester) async {
      await tester.pumpWidget(host());

      expect(find.byType(GameWidget<CauaCandiesGame>), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
    });

    testWidgets('keeps the same game instance across rebuilds', (tester) async {
      await tester.pumpWidget(host());
      final first = currentGame(tester);

      await tester.pumpWidget(host());
      await tester.pump();
      final second = currentGame(tester);

      expect(identical(first, second), isTrue);
    });

    testWidgets('back button navigates to /', (tester) async {
      final testRouter = GoRouter(
        initialLocation: '/caua',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('home')),
            routes: [
              GoRoute(path: 'caua', builder: (_, _) => const CauaGameScreen()),
            ],
          ),
        ],
      );
      addTearDown(testRouter.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: testRouter));
      expect(find.byType(CauaGameScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('home'), findsOneWidget);
      expect(find.byType(CauaGameScreen), findsNothing);
    });
  });

  group('router', () {
    List<String> childPaths(GoRoute route) =>
        route.routes.whereType<GoRoute>().map((r) => r.path).toList();

    test('has caua route under / alongside settings', () {
      final root = router.configuration.routes.whereType<GoRoute>().single;
      expect(root.path, '/');

      final children = childPaths(root);
      expect(children, containsAll(<String>['caua', 'settings']));
    });
  });
}
