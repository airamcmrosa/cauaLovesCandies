import 'dart:ui' as ui;

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logging/logging.dart';

/// Decorative candies falling along the left and right edges of the title
/// screen (US01). Purely visual: ignores pointers and reuses the sprites that
/// the asset preloader already put in `Flame.images`.
///
/// Candies live in two edge lanes, each [laneFraction] of the width, so they
/// stay outside the centered content column. One ticker drives a single
/// painter; nothing is rebuilt or allocated per frame.
class FallingCandies extends StatefulWidget {
  const FallingCandies({super.key});

  /// Width of each edge lane as a fraction of the available width.
  static const double laneFraction = 0.12;

  /// Normal candy size (px) before the 30% reduction.
  static const double baseSize = 56;

  /// Final drawn size: 70% of [baseSize].
  static const double drawSize = baseSize * 0.7;

  static const List<String> spriteKeys = [
    'items/candy_cotton.webp',
    'items/candy_cupcake.webp',
    'items/candy_wrapped.webp',
    'items/lollipop.webp',
  ];

  @override
  State<FallingCandies> createState() => _FallingCandiesState();
}

class _FallingCandiesState extends State<FallingCandies>
    with SingleTickerProviderStateMixin {
  static final _log = Logger('FallingCandies');

  final ValueNotifier<double> _seconds = ValueNotifier<double>(0);
  late final Ticker _ticker = createTicker(_onTick);
  late final List<ui.Image> _sprites = _resolveSprites();
  late final List<_Candy> _candies = _buildCandies(_sprites.length);
  double _base = 0;

  List<ui.Image> _resolveSprites() {
    final result = <ui.Image>[];
    for (final key in FallingCandies.spriteKeys) {
      try {
        result.add(Flame.images.fromCache(key));
      } on Object catch (e) {
        _log.info('Candy sprite $key not in cache, skipping: $e');
      }
    }
    return result;
  }

  // 3 candies per side with staggered phases, speeds (px/s) and sprites.
  static List<_Candy> _buildCandies(int spriteCount) {
    if (spriteCount == 0) return const [];
    const speeds = [70.0, 95.0, 82.0, 105.0, 76.0, 90.0];
    const phases = [0.0, 0.34, 0.67, 0.17, 0.5, 0.84];
    return List<_Candy>.generate(
      6,
      (i) => _Candy(
        leftSide: i < 3,
        sprite: (i * 3 + (i < 3 ? 0 : 1)) % spriteCount,
        speed: speeds[i],
        phase: phases[i],
      ),
      growable: false,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      if (_ticker.isActive) {
        _ticker.stop();
        _base = _seconds.value; // Freeze in place, no jump.
      }
    } else if (!_ticker.isActive && _candies.isNotEmpty) {
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    _seconds.value = _base + elapsed.inMicroseconds / 1e6;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_candies.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _CandyPainter(_seconds, _sprites, _candies),
        ),
      ),
    );
  }
}

class _Candy {
  const _Candy({
    required this.leftSide,
    required this.sprite,
    required this.speed,
    required this.phase,
  });

  final bool leftSide;
  final int sprite;
  final double speed;
  final double phase;
}

class _CandyPainter extends CustomPainter {
  _CandyPainter(this._seconds, this._sprites, this._candies)
    : super(repaint: _seconds);

  final ValueNotifier<double> _seconds;
  final List<ui.Image> _sprites;
  final List<_Candy> _candies;
  final Paint _paint = Paint()..filterQuality = FilterQuality.medium;

  @override
  void paint(Canvas canvas, Size size) {
    const s = FallingCandies.drawSize;
    final lane = size.width * FallingCandies.laneFraction;
    final span = size.height + 2 * s;
    final t = _seconds.value;
    for (final c in _candies) {
      final y = ((c.phase * span + t * c.speed) % span) - s;
      final cx = c.leftSide ? lane / 2 : size.width - lane / 2;
      final image = _sprites[c.sprite];
      canvas
        ..save()
        ..translate(cx - s / 2, y)
        ..scale(s / image.width, s / image.height)
        ..drawImage(image, Offset.zero, _paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_CandyPainter old) =>
      old._sprites != _sprites || old._candies != _candies;
}
