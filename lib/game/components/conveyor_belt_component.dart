import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import '../../style/palette.dart';
import '../managers/game_manager.dart';
import '../managers/phase_config.dart';
import '../projection.dart';

/// Renders the trapezoidal conveyor lane from the near plane to the horizon
/// with stripes that scroll toward the horizon at the current phase speed.
///
/// Geometry is derived from [Projection] via `yAt`/`xAt`/`scaleAt`, so the
/// stripes converge to the horizon. It owns no game rules; it only reads the
/// phase multiplier from [GameManager.level] and [kPhases].
class ConveyorBeltComponent extends PositionComponent {
  ConveyorBeltComponent({
    required GameManager gameManager,
    Palette? palette,
    super.priority = -10,
  }) : _gameManager = gameManager,
       _basePaint = Paint()
         ..color = (palette ?? Palette()).beltBase.color
         ..style = PaintingStyle.fill,
       _stripePaint = Paint()
         ..color = (palette ?? Palette()).beltStripe.color
         ..style = PaintingStyle.fill;

  /// Belt scroll speed in depth units (z) per second at Phase 1 (1.0x).
  /// Shared with item movement so items ride the belt without slipping.
  static const double baseSpeed = 0.25;

  /// Half width of the lane at the near plane, in virtual pixels.
  static const double halfWidthBottom = 330.0;

  /// Number of stripes along the lane.
  static const int stripeCount = 10;

  /// Stripe length as a fraction of the stripe period.
  static const double stripeDutyCycle = 0.5;

  final GameManager _gameManager;
  final Paint _basePaint;
  final Paint _stripePaint;
  final Path _lanePath = Path();
  final Path _stripePath = Path();

  /// Scroll offset in stripe periods, in [0, 1).
  double _phase = 0.0;

  /// Scroll offset in stripe periods, exposed for tests.
  @visibleForTesting
  double get phase => _phase;

  /// Current belt speed in z per second.
  double get speed =>
      baseSpeed * kPhases[_gameManager.level - 1].speedMultiplier;

  @override
  Future<void> onLoad() async {
    // Static lane trapezoid, built once.
    const double halfTop = halfWidthBottom * Projection.scaleHorizon;
    _lanePath
      ..moveTo(xAt(0) - halfWidthBottom, yAt(0))
      ..lineTo(xAt(0) + halfWidthBottom, yAt(0))
      ..lineTo(xAt(1) + halfTop, yAt(1))
      ..lineTo(xAt(1) - halfTop, yAt(1))
      ..close();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Linear, frame-rate independent scroll toward the horizon.
    _phase = (_phase + speed * dt * stripeCount) % 1.0;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(_lanePath, _basePaint);
    for (var i = 0; i < stripeCount; i++) {
      final z0 = (i + _phase) / stripeCount;
      var z1 = z0 + stripeDutyCycle / stripeCount;
      if (z1 > 1.0) z1 = 1.0;
      if (z0 >= z1) continue;
      final h0 = halfWidthBottom * scaleAt(z0);
      final h1 = halfWidthBottom * scaleAt(z1);
      _stripePath
        ..reset()
        ..moveTo(xAt(z0) - h0, yAt(z0))
        ..lineTo(xAt(z0) + h0, yAt(z0))
        ..lineTo(xAt(z1) + h1, yAt(z1))
        ..lineTo(xAt(z1) - h1, yAt(z1))
        ..close();
      canvas.drawPath(_stripePath, _stripePaint);
    }
  }
}
