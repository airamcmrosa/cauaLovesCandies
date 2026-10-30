import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../game/managers/asset_preloader.dart';
import '../style/palette.dart';
import 'bobbing_avatar.dart';
import 'falling_candies.dart';
import 'play_button.dart';
import 'title_loading_indicator.dart';
import 'title_logo.dart';

/// Presentational title screen (US01). All behavior is injected.
///
/// The full screen (logo, avatar, JOGAR) is shown only on [PreloadDone]; while
/// idle/loading a plain spinner is shown, and on [PreloadFailed] a simple
/// asset-free error layout with a disabled JOGAR and a retry control (shown
/// only when [onRetry] is non-null). The first pointer-down anywhere (any
/// state) calls [onFirstTap] exactly once (audio unlock/retry hook).
class TitleScreen extends StatefulWidget {
  const TitleScreen({
    super.key,
    required this.preloadState,
    required this.onPlay,
    required this.onFirstTap,
    this.onRetry,
    required this.soundOn,
    required this.onToggleSound,
  });

  final ValueListenable<PreloadState> preloadState;
  final VoidCallback onPlay;
  final VoidCallback onFirstTap;
  final VoidCallback? onRetry;
  final ValueListenable<bool> soundOn;
  final VoidCallback onToggleSound;

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  static final _log = Logger('TitleScreen');

  bool _firstTapDone = false;

  void _handlePointerDown(PointerDownEvent _) {
    if (_firstTapDone) return;
    _firstTapDone = true;
    widget.onFirstTap();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette();
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      child: Scaffold(
        backgroundColor: palette.backgroundMain.color,
        body: ValueListenableBuilder<PreloadState>(
          valueListenable: widget.preloadState,
          builder: (context, state, _) => switch (state) {
            PreloadDone() => _buildReady(palette),
            PreloadFailed() => _buildFailed(palette),
            PreloadIdle() || PreloadLoading() => Center(
              child: CircularProgressIndicator(
                color: palette.brandBubblegumDark.color,
              ),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildFailed(Palette palette) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TitleLogo.fallbackText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: palette.brandBubblegumDark.color,
                ),
              ),
              const SizedBox(height: 32),
              const PlayButton(onPressed: null),
              const SizedBox(height: 8),
              TitleLoadingIndicator(onRetry: widget.onRetry),
              const SizedBox(height: 16),
              _SoundToggle(
                soundOn: widget.soundOn,
                onToggle: widget.onToggleSound,
                color: palette.ink.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Horizontal inset for the logo so that, scaled by [TitleLogo.maxScale],
  /// it stays at least 4 px clear of each candy lane.
  static double _logoInset(double screenWidth) {
    final lane = screenWidth * FallingCandies.laneFraction;
    final maxLogoWidth = (screenWidth - 2 * (lane + 4)) / TitleLogo.maxScale;
    final columnWidth = math.min(480.0, screenWidth) - 48;
    return math.max(0, (columnWidth - maxLogoWidth) / 2);
  }

  Widget _buildReady(Palette palette) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/bg/menu_bg.webp',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
            _log.warning('Failed to load menu background', error, stack);
            return const SizedBox.shrink();
          },
        ),
        const FallingCandies(),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final avatarSize = math.min(
                constraints.maxWidth * 0.6,
                constraints.maxHeight * 0.3,
              );
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Padding(
                            // Keeps the logo's max painted extent (incl. scale
                            // overshoot) clear of the candy lanes.
                            padding: EdgeInsets.symmetric(
                              horizontal: _logoInset(constraints.maxWidth),
                            ),
                            child: const TitleLogo(),
                          ),
                        ),
                        BobbingAvatar(size: avatarSize),
                        const SizedBox(height: 16),
                        PlayButton(onPressed: widget.onPlay),
                        const SizedBox(height: 24),
                        _SoundToggle(
                          soundOn: widget.soundOn,
                          onToggle: widget.onToggleSound,
                          color: palette.ink.color,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Single speaker toggle controlling music and SFX together.
class _SoundToggle extends StatelessWidget {
  const _SoundToggle({
    required this.soundOn,
    required this.onToggle,
    required this.color,
  });

  final ValueListenable<bool> soundOn;
  final VoidCallback onToggle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: soundOn,
      builder: (context, on, _) {
        final label = on ? 'Som ligado' : 'Som desligado';
        return Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: IconButton(
            iconSize: 36,
            constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
            tooltip: label,
            onPressed: onToggle,
            icon: Icon(on ? Icons.volume_up : Icons.volume_off, color: color),
          ),
        );
      },
    );
  }
}
