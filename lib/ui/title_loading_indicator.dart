import 'package:flutter/material.dart';

import '../game/managers/asset_preloader.dart';
import '../style/palette.dart';

/// Shows preload progress, or a retry affordance when preload failed.
/// Renders nothing once [PreloadDone].
class TitleLoadingIndicator extends StatelessWidget {
  const TitleLoadingIndicator({super.key, required this.state, this.onRetry});

  final PreloadState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = Palette();
    final color = palette.ink.color;
    switch (state) {
      case PreloadDone():
        return const SizedBox(height: 40);
      case PreloadFailed():
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
      case PreloadIdle():
      case PreloadLoading():
        final progress = switch (state) {
          PreloadLoading(:final progress) => progress,
          _ => null,
        };
        return SizedBox(
          height: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    color: palette.brandBubblegumDark.color,
                    backgroundColor: palette.bgCotton.color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Carregando...',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
    }
  }
}
