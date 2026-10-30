import 'package:flutter/material.dart';

import '../style/palette.dart';

/// Large high-contrast "JOGAR" button. Disabled when [onPressed] is null.
class PlayButton extends StatelessWidget {
  const PlayButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  static const String label = 'JOGAR';
  static const double minHeight = 72;

  @override
  Widget build(BuildContext context) {
    final palette = Palette();
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, minHeight: minHeight),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(240, minHeight),
          backgroundColor: palette.brandBubblegumDark.color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: palette.inkSoft.color.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(minHeight / 2),
          ),
          textStyle: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        child: const Text(label),
      ),
    );
  }
}
