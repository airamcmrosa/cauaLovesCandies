import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/caua_game_screen.dart';
import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:caua_loves_candies/ui/game_hud.dart';
import 'package:caua_loves_candies/ui/phase_banner_overlay.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CauaGameScreen()));
  }

  // GameWidget only shows overlays once the game finished loading real assets,
  // which fake-async widget tests cannot await. The screen's registered
  // builders are mounted directly against the screen's own game instead.
  Future<CauaCandiesGame> mountOverlays(WidgetTester tester) async {
    await pumpScreen(tester);
    final widget = tester.widget<GameWidget<CauaCandiesGame>>(
      find.byType(GameWidget<CauaCandiesGame>),
    );
    // Own game: replacing the screen tree disposes the screen's game manager.
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
              for (final name in ['hud', 'phaseBanner'])
                widget.overlayBuilderMap![name]!(context, game),
            ],
          ),
        ),
      ),
    );
    return game;
  }

  final banner2 = kPhases[1].bannerText!;

  group('CauaGameScreen phaseBanner overlay', () {
    testWidgets('registers and activates phaseBanner alongside hud', (
      tester,
    ) async {
      await pumpScreen(tester);
      final widget = tester.widget<GameWidget<CauaCandiesGame>>(
        find.byType(GameWidget<CauaCandiesGame>),
      );
      expect(widget.overlayBuilderMap, contains('hud'));
      expect(widget.overlayBuilderMap, contains('phaseBanner'));
      expect(widget.initialActiveOverlays, containsAll(['hud', 'phaseBanner']));
    });

    testWidgets('builds PhaseBannerOverlay and GameHud in the tree', (
      tester,
    ) async {
      await mountOverlays(tester);
      expect(find.byType(GameHud), findsOneWidget);
      expect(find.byType(PhaseBannerOverlay), findsOneWidget);
    });

    testWidgets('banner shows on phaseChanged 2 and hides on restart', (
      tester,
    ) async {
      final game = await mountOverlays(tester);
      final gm = game.gameManager;
      expect(find.text(banner2), findsNothing);

      gm.phaseChanged.value = 2;
      await tester.pump();
      expect(find.text(banner2), findsOneWidget);
      var opacity = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(PhaseBannerOverlay),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 1);

      // Reset hides immediately (opacity target 0) without waiting 1500 ms.
      gm.reset();
      await tester.pump();
      opacity = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(PhaseBannerOverlay),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(opacity.opacity, 0);
      expect(gm.currentPhase.value, 1);
      expect(gm.currentSpeedMultiplier, kPhases[0].speedMultiplier);
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
