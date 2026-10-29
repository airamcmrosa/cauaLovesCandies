import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../style/palette.dart';

/// Animated game logo: pops in with an elastic scale, then breathes gently.
class TitleLogo extends StatefulWidget {
  const TitleLogo({super.key});

  static final _log = Logger('TitleLogo');

  static const String assetPath =
      'assets/images/ui/logo_caua_loves_candies.webp';
  static const String fallbackText = 'Cauã Loves Candies';

  /// Intro overshoot is clamped to this scale so the logo extent is bounded.
  static const double introPeakScale = 1.1;

  /// Upper bound of the painted logo scale (intro peak x pulse peak 1.03).
  static const double maxScale = introPeakScale * 1.03;

  @override
  State<TitleLogo> createState() => _TitleLogoState();
}

class _TitleLogoState extends State<TitleLogo> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  late final Animation<double> _introScale = CurvedAnimation(
    parent: _intro,
    curve: const _CappedElasticOut(),
  );
  late final Animation<double> _pulseScale = Tween<double>(
    begin: 0.97,
    end: 1.03,
  ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette();
    return ScaleTransition(
      scale: _introScale,
      child: ScaleTransition(
        scale: _pulseScale,
        child: Semantics(
          label: TitleLogo.fallbackText,
          child: Image.asset(
            TitleLogo.assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) {
              TitleLogo._log.warning('Failed to load logo', error, stack);
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  TitleLogo.fallbackText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: palette.brandBubblegumDark.color,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// [Curves.elasticOut] with the overshoot clamped to [TitleLogo.introPeakScale].
class _CappedElasticOut extends Curve {
  const _CappedElasticOut();

  @override
  double transformInternal(double t) {
    final v = Curves.elasticOut.transform(t);
    return v > TitleLogo.introPeakScale ? TitleLogo.introPeakScale : v;
  }
}
