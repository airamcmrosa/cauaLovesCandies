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
  late int toggles;
  late ValueNotifier<bool> soundOn;

  setUp(() {
    state = ValueNotifier<PreloadState>(const PreloadIdle());
    plays = 0;
    firstTaps = 0;
    retries = 0;
    toggles = 0;
    soundOn = ValueNotifier<bool>(true);
  });

  tearDown(() {
    state.dispose();
    soundOn.dispose();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    bool withRetry = true,
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
          soundOn: soundOn,
          onToggleSound: () => toggles++,
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
        expect(find.byType(IconButton), findsNothing);
        expect(find.byIcon(Icons.volume_up), findsNothing);
        expect(find.byIcon(Icons.volume_off), findsNothing);
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

    testWidgets('speaker toggle shows icon and tooltip for soundOn', (
      tester,
    ) async {
      state.value = const PreloadDone();
      await pumpScreen(tester);
      expect(find.byTooltip('Som ligado'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byTooltip('Som desligado'), findsNothing);

      soundOn.value = false;
      await tester.pump();
      expect(find.byTooltip('Som desligado'), findsOneWidget);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
      expect(find.byTooltip('Som ligado'), findsNothing);
    });

    testWidgets('speaker toggle exposes button semantics label', (
      tester,
    ) async {
      state.value = const PreloadDone();
      await pumpScreen(tester);
      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Som ligado'), findsOneWidget);
      soundOn.value = false;
      await tester.pump();
      expect(find.bySemanticsLabel('Som desligado'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('tapping the speaker calls onToggleSound once, not onPlay', (
      tester,
    ) async {
      state.value = const PreloadDone();
      await pumpScreen(tester);
      await tester.tap(find.byTooltip('Som ligado'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(toggles, 1);
      expect(plays, 0);
    });

    for (final size in const [Size(360, 640), Size(412, 915)]) {
      testWidgets('JOGAR is >= 64 high at $size without overflow', (
        tester,
      ) async {
        state.value = const PreloadDone();
        await pumpScreen(tester, size: size);
        final button = find.ancestor(
          of: jogar(),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        );
        expect(tester.getSize(button).height, greaterThanOrEqualTo(64));
        final toggleSize = tester.getSize(find.byType(IconButton));
        expect(toggleSize.width, greaterThanOrEqualTo(56));
        expect(toggleSize.height, greaterThanOrEqualTo(56));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Failed', () {
    testWidgets('speaker toggle present and calls onToggleSound', (
      tester,
    ) async {
      state.value = const PreloadFailed('boom');
      await pumpScreen(tester);
      expect(find.byTooltip('Som ligado'), findsOneWidget);
      final size = tester.getSize(find.byType(IconButton));
      expect(size.width, greaterThanOrEqualTo(56));
      expect(size.height, greaterThanOrEqualTo(56));
      await tester.tap(find.byTooltip('Som ligado'));
      await tester.pump();
      expect(toggles, 1);
      expect(plays, 0);
    });

    testWidgets('Failed layout has no overflow at small and large sizes', (
      tester,
    ) async {
      state.value = const PreloadFailed('boom');
      await pumpScreen(tester, size: const Size(360, 640));
      expect(tester.takeException(), isNull);
      await pumpScreen(tester, size: const Size(412, 915));
      expect(tester.takeException(), isNull);
    });

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
