import 'package:flutter/material.dart';

import '../style/palette.dart';

/// Big, high-contrast restart button shared by the end-state overlays.
///
/// Full width of its parent and at least [minHeight] logical px tall so a
/// 6-year-old can hit it. Presentational: it only calls [onPressed].
class PlayAgainButton extends StatelessWidget {
  const PlayAgainButton({required this.onPressed, super.key});

  /// Label shared by the victory and game-over screens.
  static const String label = 'JOGAR NOVAMENTE';

  /// Minimum touch target height.
  static const double minHeight = 72;

  final VoidCallback onPressed;

  static final Palette _palette = Palette();
  static final TextStyle _style = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: _palette.ink.color,
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: _palette.accentLemon.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(36),
          side: BorderSide(color: _palette.ink.color, width: 4),
        ),
        child: InkWell(
          key: const Key('play again button'),
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: minHeight,
              minWidth: double.infinity,
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: _style),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
