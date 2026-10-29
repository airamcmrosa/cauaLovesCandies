import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/managers/asset_preloader.dart';
import 'package:caua_loves_candies/ui/falling_candies.dart';
import 'package:caua_loves_candies/ui/title_logo.dart';
import 'package:caua_loves_candies/ui/title_screen.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ui.Image> _tinyImage() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, 4, 4),
    ui.Paint()..color = const Color(0xFFFF00FF),
  );
  return recorder.endRecording().toImage(4, 4);
}

void main() {
  tearDown(() {
    Flame.images.clearCache();
  });

  Future<void> prefill(WidgetTester tester) async {
    await tester.runAsync(() async {
      for (final key in FallingCandies.spriteKeys) {
        Flame.images.add(key, await _tinyImage());
      }
    });
  }

  Future<void> pumpCandies(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FallingCandies())),
    );
  }

  Finder candyPaint() => find.descendant(
    of: find.byType(FallingCandies),
    matching: find.byType(CustomPaint),
  );

  group('missing cache keys', () {
    testWidgets('renders nothing and does not throw when none resolve', (
      tester,
    ) async {
      await pumpCandies(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      expect(candyPaint(), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('ignores a missing key and renders with the rest', (
      tester,
    ) async {
      await tester.runAsync(() async {
        Flame.images.add(FallingCandies.spriteKeys.first, await _tinyImage());
      });
      await pumpCandies(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(candyPaint(), findsOneWidget);
    });
  });

  group('painting path', () {
    testWidgets('paints with prefilled sprites, ignores pointers', (
      tester,
    ) async {
      await prefill(tester);
      await pumpCandies(tester);
      await tester.pump(const Duration(milliseconds: 700));
      expect(tester.takeException(), isNull);
      expect(candyPaint(), findsOneWidget);
      expect(
        find.ancestor(of: candyPaint(), matching: find.byType(IgnorePointer)),
        findsWidgets,
      );
    });
  });

  group('ticker lifecycle', () {
    testWidgets('ticks while animations are enabled', (tester) async {
      await prefill(tester);
      await pumpCandies(tester);
      expect(tester.binding.transientCallbackCount, greaterThan(0));
    });

    testWidgets('disposing leaves no active ticker or error', (tester) async {
      await prefill(tester);
      await pumpCandies(tester);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('reduce motion stops ticker; clearing it resumes', (
      tester,
    ) async {
      await prefill(tester);
      final features = tester.platformDispatcher;
      addTearDown(features.clearAccessibilityFeaturesTestValue);
      features.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      await pumpCandies(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.transientCallbackCount, 0);
      expect(candyPaint(), findsOneWidget);

      features.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('enabling reduce motion at runtime stops the ticker', (
      tester,
    ) async {
      await prefill(tester);
      final features = tester.platformDispatcher;
      addTearDown(features.clearAccessibilityFeaturesTestValue);
      await pumpCandies(tester);
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      features.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.transientCallbackCount, 0);
    });
  });

  group('in TitleScreen', () {
    late ValueNotifier<PreloadState> state;
    late ValueNotifier<bool> soundOn;
    late int plays;
    late int toggles;

    setUp(() {
      state = ValueNotifier<PreloadState>(const PreloadIdle());
      soundOn = ValueNotifier<bool>(true);
      plays = 0;
      toggles = 0;
    });

    tearDown(() {
      state.dispose();
      soundOn.dispose();
    });

    Future<void> pumpScreen(
      WidgetTester tester, {
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
            onFirstTap: () {},
            onRetry: () {},
            soundOn: soundOn,
            onToggleSound: () => toggles++,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('present in Done layout', (tester) async {
      await prefill(tester);
      state.value = const PreloadDone();
      await pumpScreen(tester);
      expect(find.byType(FallingCandies), findsOneWidget);
      expect(candyPaint(), findsOneWidget);
    });

    for (final s in <PreloadState>[
      const PreloadIdle(),
      const PreloadLoading(0.5),
      const PreloadFailed('boom'),
    ]) {
      testWidgets('absent in ${s.runtimeType} layout', (tester) async {
        await prefill(tester);
        state.value = s;
        await pumpScreen(tester);
        expect(find.byType(FallingCandies), findsNothing);
      });
    }

    testWidgets('taps on JOGAR and toggle work with candies mounted', (
      tester,
    ) async {
      await prefill(tester);
      state.value = const PreloadDone();
      await pumpScreen(tester);
      await tester.tap(find.text('JOGAR'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byTooltip('Som ligado'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(plays, 1);
      expect(toggles, 1);
    });

    testWidgets('Done without cached sprites mounts without error', (
      tester,
    ) async {
      state.value = const PreloadDone();
      await pumpScreen(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('JOGAR'), findsOneWidget);
    });

    for (final w in const [320.0, 360.0, 412.0]) {
      testWidgets('logo max painted extent clears candy lanes at $w', (
        tester,
      ) async {
        await prefill(tester);
        state.value = const PreloadDone();
        await pumpScreen(tester, size: Size(w, 800));
        final rect = tester.getRect(find.byType(TitleLogo));
        final half = rect.width / 2 * TitleLogo.maxScale;
        final left = rect.center.dx - half;
        final right = rect.center.dx + half;
        final lane = w * FallingCandies.laneFraction;
        expect(left, greaterThanOrEqualTo(lane));
        expect(right, lessThanOrEqualTo(w - lane));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
