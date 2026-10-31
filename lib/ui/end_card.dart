import 'package:flutter/material.dart';

import '../style/palette.dart';
import 'play_again_button.dart';

/// Bottom card shared by the end-state overlays: optional [title], a [body]
/// and the big restart button. Anchored to the bottom so the confetti and
/// Cauã stay visible above it. Presentational only.
class EndCard extends StatelessWidget {
  const EndCard({
    required this.body,
    required this.onPlayAgain,
    this.title,
    super.key,
  });

  final String? title;
  final String body;
  final VoidCallback onPlayAgain;

  static final Palette _palette = Palette();
  static final TextStyle _titleStyle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    color: _palette.brandBubblegumDark.color,
  );
  static final TextStyle _bodyStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: _palette.ink.color,
  );

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _palette.bgCream.color,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _palette.ink.color, width: 4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: _titleStyle,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(body, textAlign: TextAlign.center, style: _bodyStyle),
                  const SizedBox(height: 16),
                  PlayAgainButton(onPressed: onPlayAgain),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
