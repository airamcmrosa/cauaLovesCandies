import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/caua_game_screen.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ratio = 9 / 16;

  group('computeGameSize', () {
    test('virtual size has a 9:16 ratio', () {
      expect(
        CauaCandiesGame.virtualWidth / CauaCandiesGame.virtualHeight,
        closeTo(ratio, 1e-9),
      );
    });

    final cases = <String, (Size, Size)>{
      'exact minimum': (const Size(360, 640), const Size(360, 640)),
      'exact 9:16 larger': (const Size(720, 1280), const Size(720, 1280)),
      'wide viewport is height bound': (
        const Size(1280, 720),
        const Size(405, 720),
      ),
      'tall viewport is width bound': (
        const Size(412, 915),
        const Size(412, 412 / ratio),
      ),
      'full hd landscape': (const Size(1920, 1080), const Size(607.5, 1080)),
    };
    cases.forEach((name, c) {
      test('largest 9:16 that fits: $name', () {
        final result = computeGameSize(c.$1);
        expect(result.width, closeTo(c.$2.width, 1e-6));
        expect(result.height, closeTo(c.$2.height, 1e-6));
        expect(result.width / result.height, closeTo(ratio, 1e-9));
        expect(result.width, lessThanOrEqualTo(c.$1.width + 1e-6));
        expect(result.height, lessThanOrEqualTo(c.$1.height + 1e-6));
      });
    });

    for (final s in const [
      Size(200, 300),
      Size(359, 640),
      Size(360, 639),
      Size(100, 2000),
      Size(2000, 100),
    ]) {
      test('below minimum returns 360x640 for $s', () {
        expect(computeGameSize(s), const Size(kMinGameWidth, kMinGameHeight));
      });
    }

    test('non-finite axes fall back to the minimum', () {
      expect(
        computeGameSize(const Size(double.infinity, double.infinity)),
        const Size(360, 640),
      );
    });
  });

  group('CauaGameScreen layout', () {
    late WidgetTester t;

    tearDown(() {
      t.view.resetPhysicalSize();
      t.view.resetDevicePixelRatio();
    });

    final viewports = <Size>[
      const Size(360, 640),
      const Size(412, 915),
      const Size(1280, 720),
      const Size(1920, 1080),
      const Size(200, 300),
    ];

    for (final vp in viewports) {
      testWidgets('viewport ${vp.width.toInt()}x${vp.height.toInt()}', (
        tester,
      ) async {
        t = tester;
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = vp;

        await tester.pumpWidget(const MaterialApp(home: CauaGameScreen()));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);

        final parent = find.byKey(const Key('game parent'));
        final container = find.byKey(const Key('game container'));

        // Parent fills the whole viewport.
        expect(tester.getSize(parent), vp);
        expect(tester.getTopLeft(parent), Offset.zero);

        // On-screen (transformed) rect of the container.
        final tl = tester.getTopLeft(container);
        final br = tester.getBottomRight(container);
        final shown = Size(br.dx - tl.dx, br.dy - tl.dy);

        // Ratio 9:16 on screen.
        expect(shown.width / shown.height, closeTo(ratio, 0.005));

        // Fits inside the parent.
        expect(tl.dx, greaterThanOrEqualTo(-0.01));
        expect(tl.dy, greaterThanOrEqualTo(-0.01));
        expect(br.dx, lessThanOrEqualTo(vp.width + 0.01));
        expect(br.dy, lessThanOrEqualTo(vp.height + 0.01));

        // Centered.
        expect((tl.dx + br.dx) / 2, closeTo(vp.width / 2, 0.01));
        expect((tl.dy + br.dy) / 2, closeTo(vp.height / 2, 0.01));

        // Layout size of the container and the game widget.
        final expected = computeGameSize(vp);
        final layout = tester.getSize(container);
        expect(layout.width, closeTo(expected.width, 0.01));
        expect(layout.height, closeTo(expected.height, 0.01));
        expect(layout.width, greaterThanOrEqualTo(kMinGameWidth));
        expect(layout.height, greaterThanOrEqualTo(kMinGameHeight));

        final gameSize = tester.getSize(
          find.byType(GameWidget<CauaCandiesGame>),
        );
        expect(gameSize.width, closeTo(layout.width, 0.01));
        expect(gameSize.height, closeTo(layout.height, 0.01));
        expect(gameSize.isEmpty, isFalse);

        final fitsWithoutScaling =
            vp.width >= kMinGameWidth && vp.height >= kMinGameHeight;
        if (fitsWithoutScaling) {
          // Not scaled: on-screen size equals layout size.
          expect(shown.width, closeTo(layout.width, 0.01));
          expect(shown.height, closeTo(layout.height, 0.01));
          // Largest fit touches the limiting axis.
          final touches =
              (shown.width - vp.width).abs() < 0.01 ||
              (shown.height - vp.height).abs() < 0.01;
          expect(touches, isTrue);
        } else {
          // Scaled down to fit, touching the limiting axis.
          expect(shown.width, lessThan(layout.width));
          final touches =
              (shown.width - vp.width).abs() < 0.01 ||
              (shown.height - vp.height).abs() < 0.01;
          expect(touches, isTrue);
        }
      });
    }
  });
}
