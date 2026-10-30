import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../style/palette.dart';
import '../ui/game_hud.dart';
import '../ui/phase_banner_overlay.dart';

import 'caua_candies_game.dart';

/// Minimal host screen for [CauaCandiesGame] (manual verification path).
///
/// Owns the game instance so it is created once, not on every rebuild.
class CauaGameScreen extends StatefulWidget {
  const CauaGameScreen({super.key});

  @override
  State<CauaGameScreen> createState() => _CauaGameScreenState();
}

/// Minimum logical size of the playfield (9:16, half the virtual size).
///
/// Below this the playfield is scaled down to fit instead of scrolling: a
/// one-tap kids arcade must always show the whole playfield, and the game
/// scales via its fixed-resolution camera.
const double kMinGameWidth = 360;
const double kMinGameHeight = 640;

/// Largest 9:16 size fitting [available], centered by the caller.
///
/// Never smaller than the 360x640 minimum (callers scale that down to fit
/// when the parent is smaller). Non-finite axes fall back to the minimum.
Size computeGameSize(Size available) {
  const ratio = CauaCandiesGame.virtualWidth / CauaCandiesGame.virtualHeight;
  final w = available.width.isFinite ? available.width : kMinGameWidth;
  final h = available.height.isFinite ? available.height : kMinGameHeight;
  var width = w;
  var height = w / ratio;
  if (height > h) {
    height = h;
    width = h * ratio;
  }
  if (width < kMinGameWidth || height < kMinGameHeight) {
    return const Size(kMinGameWidth, kMinGameHeight);
  }
  return Size(width, height);
}

class _CauaGameScreenState extends State<CauaGameScreen> {
  CauaCandiesGame? _gameInstance;

  CauaCandiesGame get _game => _gameInstance ??= CauaCandiesGame(
    // Tolerant lookup: null when no provider is in the tree.
    audio: Provider.of<AudioController?>(context, listen: false),
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette?>();
    final skyColor = (palette ?? Palette()).bgSky.color;
    return Scaffold(
      body: ColoredBox(
        key: const Key('game parent'),
        color: skyColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg/stage1_sky.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    ColoredBox(color: skyColor),
              ),
            ),
            SizedBox.expand(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = computeGameSize(constraints.biggest);
                        // FittedBox scales the container down when the parent is
                        // smaller than the minimum; the GameWidget always gets
                        // finite, large constraints.
                        return Center(
                          child: FittedBox(
                            child: SizedBox(
                              key: const Key('game container'),
                              width: size.width,
                              height: size.height,
                              child: ClipRect(
                                child: GameWidget<CauaCandiesGame>(
                                  game: _game,
                                  overlayBuilderMap: {
                                    'hud': (context, game) =>
                                        GameHud(gameManager: game.gameManager),
                                    'phaseBanner': (context, game) =>
                                        PhaseBannerOverlay(
                                          phaseChanged:
                                              game.gameManager.phaseChanged,
                                        ),
                                  },
                                  initialActiveOverlays: const [
                                    'hud',
                                    'phaseBanner',
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        iconSize: 40,
                        tooltip: 'Back',
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => GoRouter.of(context).go('/'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
