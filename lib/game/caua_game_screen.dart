import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'caua_candies_game.dart';

/// Minimal host screen for [CauaCandiesGame] (manual verification path).
///
/// Owns the game instance so it is created once, not on every rebuild.
class CauaGameScreen extends StatefulWidget {
  const CauaGameScreen({super.key});

  @override
  State<CauaGameScreen> createState() => _CauaGameScreenState();
}

class _CauaGameScreenState extends State<CauaGameScreen> {
  late final CauaCandiesGame _game = CauaCandiesGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget<CauaCandiesGame>(game: _game)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                iconSize: 40,
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => GoRouter.of(context).go('/'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
