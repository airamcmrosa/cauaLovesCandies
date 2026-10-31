import 'package:flutter/material.dart';

import 'end_card.dart';

/// Final victory card: congratulation message and a big restart button.
/// Presentational (no game logic); confetti is drawn by the game world.
class VictoryOverlay extends StatelessWidget {
  const VictoryOverlay({required this.onPlayAgain, super.key});

  /// Exact US05 message.
  static const String message =
      'Parabéns, você ajudou o Cauã a comer todos os doces! '
      'Feliz Aniversário, Cauã!';

  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) =>
      EndCard(body: message, onPlayAgain: onPlayAgain);
}
