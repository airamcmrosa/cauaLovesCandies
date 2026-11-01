import 'package:flutter/material.dart';

import 'end_card.dart';

/// Friendly, non-punitive game-over card with a big restart button.
/// Presentational (no game logic).
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({required this.onPlayAgain, super.key});

  static const String title = 'Tente de Novo!';
  static const String message = 'Quase lá! O Cauã ainda quer mais doces.';

  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) =>
      EndCard(title: title, body: message, onPlayAgain: onPlayAgain);
}
