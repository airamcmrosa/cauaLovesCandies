import 'package:caua_loves_candies/game/managers/asset_preloader.dart';
import 'package:caua_loves_candies/ui/title_logo.dart';
import 'package:caua_loves_candies/ui/title_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ValueNotifier<PreloadState> state;
  late int plays;
  late int firstTaps;
  late int retries;

  setUp(() {
    state = ValueNotifier<PreloadState>(const PreloadIdle());
    plays = 0;
    firstTaps = 0;
    retries = 0;
  });

  tearDown(() => state.dispose());

  Future<void> pumpScreen(
    WidgetTester tester, {
    bool withRetry = true,
    bool withSettings = false,
    Size size = const Size(360, 640),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: TitleScreen(
          preloadState: state,
          onPlay: () => plays++,
          onFirstTap: () => firstTaps++,
          onRetry: withRetry ? () => retries++ : null,
          onSettings: withSettings ? () {} : null,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  Finder jogar() => find.text('JOGAR');

  group('Idle and Loading', () {
    for (final s in <PreloadState>[
      const PreloadIdle(),
      const PreloadLoading(0.5),
    ]) {
      testWidgets('${s.runtimeType} shows only a spinner', (tester) async {
        state.value = s;
        await pumpScreen(tester);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(jogar(), findsNothing);
        expect(find.byType(TitleLogo), findsNothing);
        expect(find.text(TitleLogo.fallbackText), findsNothing);
      });
    }
  });

  group('Done', () {
    testWidgets('shows full screen with enabled JOGAR; tap calls onPlay once', (
      tester,
    ) async {
      state.value = const PreloadDone();
      await pumpScreen(tester);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(TitleLogo), findsOneWidget);
      final button = find.ancestor(
        of: jogar(),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      expect(tester.widget<ButtonStyleButton>(button).enabled, isTrue);
      await tester.tap(jogar());
      await tester.pump(const Duration(milliseconds: 100));
      expect(plays, 1);
    });

    testWidgets('settings tooltip shown only when onSettings given', (
      tester,
    ) async {
      state.value = const PreloadDone();
      await pumpScreen(tester, withSettings: true);
      expect(find.byTooltip('Configurações'), findsOneWidget);
    });

    testWidgets('no settings control when onSettings null', (tester) async {
      state.value = const PreloadDone();
      await pumpScreen(tester);
      expect(find.byTooltip('Configurações'), findsNothing);
    });

    for (final size in const [Size(360, 640), Size(412, 915)]) {
      testWidgets('JOGAR is >= 64 high at $size without overflow', (
        tester,
      ) async {
        state.value = const PreloadDone();
        await pumpScreen(tester, size: size, withSettings: true);
        final button = find.ancestor(
          of: jogar(),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        );
        expect(tester.getSize(button).height, greaterThanOrEqualTo(64));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Failed', () {
    testWidgets('shows retry, disabled JOGAR; retry calls onRetry', (
      tester,
    ) async {
      state.value = const PreloadFailed('boom');
      await pumpScreen(tester);
      final button = find.ancestor(
        of: jogar(),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      expect(tester.widget<ButtonStyleButton>(button).enabled, isFalse);
      await tester.tap(jogar(), warnIfMissed: false);
      await tester.pump();
      expect(plays, 0);
      expect(find.text('Tentar de novo'), findsOneWidget);
      await tester.tap(find.text('Tentar de novo'));
      await tester.pump();
      expect(retries, 1);
      expect(plays, 0);
    });

    testWidgets('retry hidden when onRetry is null', (tester) async {
      state.value = const PreloadFailed('boom');
      await pumpScreen(tester, withRetry: false);
      expect(find.text('Tentar de novo'), findsNothing);
    });
  });

  group('behavior', () {
    testWidgets('onFirstTap fires exactly once across multiple taps', (
      tester,
    ) async {
      state.value = const PreloadDone();
      await pumpScreen(tester);
      await tester.tap(jogar());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(jogar());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(const Offset(5, 5));
      await tester.pump(const Duration(milliseconds: 50));
      expect(firstTaps, 1);
      expect(plays, 2);
    });

    testWidgets('onFirstTap also fires from the loading state', (tester) async {
      state.value = const PreloadLoading(0.2);
      await pumpScreen(tester);
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      expect(firstTaps, 1);
    });

    testWidgets('Loading -> Done swaps spinner for full screen', (
      tester,
    ) async {
      state.value = const PreloadLoading(0.5);
      await pumpScreen(tester);
      expect(jogar(), findsNothing);
      state.value = const PreloadDone();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(jogar(), findsOneWidget);
      expect(find.byType(TitleLogo), findsOneWidget);
    });
  });
}
