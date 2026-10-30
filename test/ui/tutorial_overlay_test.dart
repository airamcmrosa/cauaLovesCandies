import 'package:caua_loves_candies/ui/tutorial_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _open = 'assets/images/caua/caua_mouth_open_eyes_open.webp';
const _closed = 'assets/images/caua/caua_mouth_closed_eyes_open.webp';
const _hand = 'assets/images/ui/tap_hand.webp';

Finder _asset(String name) => find.byWidgetPredicate(
  (w) =>
      w is Image &&
      w.image is AssetImage &&
      (w.image as AssetImage).assetName == name,
);

double _handScale(WidgetTester tester) {
  final transform = find
      .ancestor(of: _asset(_hand), matching: find.byType(Transform))
      .first;
  return tester.widget<Transform>(transform).transform.storage[0];
}

String _shownMouth(WidgetTester tester) {
  final openShown = _asset(_open).evaluate().isNotEmpty;
  final closedShown = _asset(_closed).evaluate().isNotEmpty;
  expect(openShown != closedShown, isTrue, reason: 'exactly one mouth shown');
  return openShown ? 'open' : 'closed';
}

Future<void> _pumpOverlay(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: TutorialOverlay())),
  );
}

void main() {
  group('layout', () {
    for (final size in const [Size(360, 640), Size(720, 1280)]) {
      testWidgets(
        'renders without exceptions at ${size.width}x${size.height}',
        (tester) async {
          await _pumpOverlay(tester, size);
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);
          expect(find.byType(TutorialOverlay), findsOneWidget);
          expect(find.byType(Scrollable), findsNothing);
        },
      );
    }

    testWidgets('contains no text', (tester) async {
      await _pumpOverlay(tester, const Size(360, 640));
      expect(find.byType(Text), findsNothing);
      expect(find.byType(RichText), findsNothing);
    });

    testWidgets('shows check row and X row badges', (tester) async {
      await _pumpOverlay(tester, const Size(360, 640));
      expect(_asset('assets/images/ui/icon_check.webp'), findsOneWidget);
      expect(_asset('assets/images/ui/icon_cross.webp'), findsOneWidget);
    });
  });

  group('animation', () {
    test('loop duration is at most 1.5 s', () {
      expect(
        TutorialOverlay.loopDuration,
        lessThanOrEqualTo(const Duration(milliseconds: 1500)),
      );
    });

    testWidgets('mouth swap is in sync with the finger press', (tester) async {
      await _pumpOverlay(tester, const Size(360, 640));
      // Start of loop: finger not yet pressed, mouth open.
      expect(_shownMouth(tester), 'open');
      expect(_handScale(tester), closeTo(1.0, 0.01));

      // First press peak (~131 ms): finger scaled down, mouth open.
      await tester.pump(const Duration(milliseconds: 131));
      expect(_handScale(tester), lessThan(0.84));
      expect(_shownMouth(tester), 'open');

      // Between taps: finger released, mouth still open.
      await tester.pump(const Duration(milliseconds: 319)); // 450 ms
      expect(_handScale(tester), closeTo(1.0, 0.01));
      expect(_shownMouth(tester), 'open');

      // Just before the second tap: still open.
      await tester.pump(const Duration(milliseconds: 290)); // 740 ms
      expect(_shownMouth(tester), 'open');

      // Second press peak (~881 ms): mouth closed at the same time.
      await tester.pump(const Duration(milliseconds: 141));
      expect(_handScale(tester), lessThan(0.84));
      expect(_shownMouth(tester), 'closed');

      // Released and still closed, then loop wraps back to open.
      await tester.pump(const Duration(milliseconds: 319)); // 1200 ms
      expect(_handScale(tester), closeTo(1.0, 0.01));
      expect(_shownMouth(tester), 'closed');
      await tester.pump(const Duration(milliseconds: 311)); // 1511 ms
      expect(_shownMouth(tester), 'open');
    });

    testWidgets('two open/close cycles occur within 3 s', (tester) async {
      await _pumpOverlay(tester, const Size(360, 640));
      final seen = <String>[];
      for (var i = 0; i < 60; i++) {
        final m = _shownMouth(tester);
        if (seen.isEmpty || seen.last != m) seen.add(m);
        await tester.pump(const Duration(milliseconds: 50));
      }
      // 3 s elapsed: open, closed, open, closed (two full cycles) at least.
      expect(seen.take(4), ['open', 'closed', 'open', 'closed']);
    });
  });

  group('lifecycle', () {
    testWidgets('disposes cleanly with no running animations', (tester) async {
      await _pumpOverlay(tester, const Size(360, 640));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(tester.takeException(), isNull);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpAndSettle();
    });
  });
}
