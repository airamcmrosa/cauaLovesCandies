import 'package:flutter/material.dart';

import '../style/palette.dart';

/// Retry affordance shown on the title screen when preload failed.
/// Renders an empty slot when [onRetry] is null.
class TitleLoadingIndicator extends StatelessWidget {
  const TitleLoadingIndicator({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final color = Palette().ink.color;
    final retry = onRetry;
    if (retry == null) return const SizedBox(height: 40);
    return SizedBox(
      height: 40,
      child: TextButton.icon(
        onPressed: retry,
        icon: Icon(Icons.refresh, color: color),
        label: Text(
          'Tentar de novo',
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
