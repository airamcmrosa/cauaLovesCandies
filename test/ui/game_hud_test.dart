import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/ui/game_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _full = 'assets/images/ui/heart_full.webp';
const _empty = 'assets/images/ui/heart_empty.webp';

Finder _hearts(String asset) => find.byWidgetPredicate(
  (w) =>
      w is Image &&
      w.image is AssetImage &&
      (w.image as AssetImage).assetName == asset,
);

void main() {
  late GameManager gm;

  setUp(() => gm = GameManager());
  tearDown(() => gm.dispose());

  Future<void> pump(WidgetTester tester, {Widget? below}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (below != null) Positioned.fill(child: below),
              GameHud(gameManager: gm),
            ],
          ),
        ),
      ),
    );
  }

  group('hearts', () {
    for (final hp in [3, 2, 1, 0]) {
      testWidgets('shows $hp filled of ${GameManager.maxHp} total', (
        tester,
      ) async {
        gm.hp.value = hp;
        await pump(tester);
        expect(_hearts(_full), findsNWidgets(hp));
        expect(_hearts(_empty), findsNWidgets(GameManager.maxHp - hp));
      });
    }

    testWidgets('updates when HP is lost via the manager', (tester) async {
      await pump(tester);
      expect(_hearts(_full), findsNWidgets(3));
      gm.loseHp();
      await tester.pump();
      expect(_hearts(_full), findsNWidgets(2));
      expect(_hearts(_empty), findsNWidgets(1));
    });
  });

  group('score', () {
    testWidgets('starts at 0', (tester) async {
      await pump(tester);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('updates after addScore', (tester) async {
      await pump(tester);
      gm.addScore(2);
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      gm.addScore(1);
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsNothing);
    });

    testWidgets('each notifier change is reflected on the next frame', (
      tester,
    ) async {
      await pump(tester);
      for (var expected = 2; expected <= 6; expected += 2) {
        gm.addScore(2);
        await tester.pump();
        expect(find.text('$expected'), findsOneWidget);
      }
      gm.addScore(0);
      gm.addScore(-1);
      await tester.pump();
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('score change does not alter hearts', (tester) async {
      await pump(tester);
      gm.addScore(2);
      await tester.pump();
      expect(_hearts(_full), findsNWidgets(3));
    });
  });

  testWidgets('taps pass through the HUD to the widget beneath', (
    tester,
  ) async {
    var taps = 0;
    await pump(
      tester,
      below: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => taps++,
        child: const SizedBox.expand(),
      ),
    );
    await tester.tapAt(const Offset(400, 300));
    expect(taps, 1);
    // Also tap directly on the score pill area.
    await tester.tap(find.text('0'), warnIfMissed: false);
    expect(taps, 2);
  });
}
