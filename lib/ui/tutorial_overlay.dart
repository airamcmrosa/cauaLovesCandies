import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../style/palette.dart';

/// Presentational, text-free "how to play" overlay.
///
/// A single looping [AnimationController] drives both the finger tap (press
/// scale + ripple) and the Caua mouth open/closed swap, so the mouth always
/// changes on the same tick as the press. Below it, a check row (sweet + fruit
/// are good) and an X row (a bad item is forbidden). Holds no game logic.
class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({
    required this.onDismiss,
    required this.onRemoved,
    super.key,
  });

  /// Fired once, immediately on the first tap (before the fade starts).
  final VoidCallback onDismiss;

  /// Fired once when the fade-out completes; the owner removes the overlay.
  final VoidCallback onRemoved;

  /// Fade-out duration after the dismissing tap.
  static const Duration fadeDuration = Duration(milliseconds: 250);

  /// One loop = two taps (open, then close). Two full open/close cycles
  /// are therefore shown within 3 s.
  static const Duration loopDuration = Duration(milliseconds: 1500);

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  static const String _handAsset = 'assets/images/ui/tap_hand.webp';
  static const String _checkAsset = 'assets/images/ui/icon_check.webp';
  static const String _crossAsset = 'assets/images/ui/icon_cross.webp';
  static const String _mouthOpenAsset =
      'assets/images/caua/caua_mouth_open_eyes_open.webp';
  static const String _mouthClosedAsset =
      'assets/images/caua/caua_mouth_closed_eyes_open.webp';
  static const String _sweetAsset = 'assets/images/items/candy_wrapped.webp';
  static const String _fruitAsset = 'assets/images/items/fruit_strawberry.webp';
  static const String _badAsset = 'assets/images/items/bad_onion.webp';

  static const double _mouthSize = 160;
  static const double _handSize = 110;
  static const double _itemSize = 88;
  static const double _badgeSize = 64;
  static const double _rippleSize = 120;

  static final Palette _palette = Palette();
  static final Color _scrimColor = _palette.ink.color.withValues(alpha: 0.78);
  static final Color _rippleColor = _palette.bgCream.color;
  static final Color _rowColor = _palette.bgCream.color.withValues(alpha: 0.92);

  // Taps per loop; the mouth toggles on each one.
  static const int _tapsPerLoop = 2;
  // Fraction of a tap segment during which the finger is pressed.
  static const double _pressSpan = 0.35;

  late final AnimationController _controller;
  late final AnimationController _fade;
  bool _dismissed = false;

  // Static subtrees built once and passed as AnimatedBuilder children.
  late final Widget _ripple = DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: _rippleColor, width: 6),
    ),
    child: const SizedBox.square(dimension: _rippleSize),
  );
  late final Widget _hand = Image.asset(
    _handAsset,
    width: _handSize,
    height: _handSize,
    gaplessPlayback: true,
    errorBuilder: _handFallback,
  );

  late final Widget _mouthOpen = Image.asset(
    _mouthOpenAsset,
    width: _mouthSize,
    height: _mouthSize,
    gaplessPlayback: true,
  );
  late final Widget _mouthClosed = Image.asset(
    _mouthClosedAsset,
    width: _mouthSize,
    height: _mouthSize,
    gaplessPlayback: true,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TutorialOverlay.loopDuration,
    )..repeat();
    _fade = AnimationController(
      vsync: this,
      duration: TutorialOverlay.fadeDuration,
      value: 1,
    )..addStatusListener(_onFadeStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Warm the image cache so the first mouth swap does not flicker.
    for (final asset in const [_mouthClosedAsset, _mouthOpenAsset]) {
      precacheImage(AssetImage(asset), context, onError: (_, _) {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fade.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (_dismissed) return;
    _dismissed = true;
    widget.onDismiss();
    _fade.reverse();
  }

  void _onFadeStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _controller.stop();
      widget.onRemoved();
    }
  }

  static Widget _handFallback(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) => Icon(Icons.touch_app, size: _handSize, color: _rippleColor);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      child: FadeTransition(
        opacity: _fade,
        child: ColoredBox(
          color: _scrimColor,
          child: SafeArea(
            child: Center(
              // Scales the fixed-size layout down on small screens: no overflow.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 340,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: _buildTapDemo,
                          child: _hand,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _FeedbackRow(
                        color: _rowColor,
                        badgeAsset: _checkAsset,
                        badgeSize: _badgeSize,
                        itemAssets: const [_sweetAsset, _fruitAsset],
                        itemSize: _itemSize,
                      ),
                      const SizedBox(height: 20),
                      _FeedbackRow(
                        color: _rowColor,
                        badgeAsset: _crossAsset,
                        badgeSize: _badgeSize,
                        itemAssets: const [_badAsset],
                        itemSize: _itemSize,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapDemo(BuildContext context, Widget? hand) {
    final double t = _controller.value;
    // Position inside the current tap segment, in [0, 1).
    final double segment = (t * _tapsPerLoop) % 1.0;
    // First tap of the loop opens the mouth, the second closes it.
    final bool open = t < 1 / _tapsPerLoop;
    final double press = segment < _pressSpan
        ? math.sin(math.pi * segment / _pressSpan)
        : 0.0;
    final double rippleT = (segment / 0.6).clamp(0.0, 1.0);

    return SizedBox(
      width: 340,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: 10, child: open ? _mouthOpen : _mouthClosed),
          Positioned(
            right: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: segment < 0.6 ? 1 - rippleT : 0,
                  child: Transform.scale(
                    scale: 0.4 + 0.9 * rippleT,
                    child: _ripple,
                  ),
                ),
                Transform.scale(scale: 1 - 0.18 * press, child: hand),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackRow extends StatelessWidget {
  const _FeedbackRow({
    required this.color,
    required this.badgeAsset,
    required this.badgeSize,
    required this.itemAssets,
    required this.itemSize,
  });

  final Color color;
  final String badgeAsset;
  final double badgeSize;
  final List<String> itemAssets;
  final double itemSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final asset in itemAssets)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image.asset(
                  asset,
                  width: itemSize,
                  height: itemSize,
                  gaplessPlayback: true,
                ),
              ),
            Image.asset(
              badgeAsset,
              width: badgeSize,
              height: badgeSize,
              gaplessPlayback: true,
            ),
          ],
        ),
      ),
    );
  }
}
