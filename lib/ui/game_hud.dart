import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../game/managers/game_manager.dart';
import '../style/palette.dart';

/// Presentational HUD: score counter and HP hearts at the top of the screen.
///
/// Listens to [GameManager.score] and [GameManager.hp]; holds no game logic.
/// Wrapped in [IgnorePointer] so taps reach the game area.
class GameHud extends StatelessWidget {
  const GameHud({required this.gameManager, super.key});

  final GameManager gameManager;

  static const String _heartFullAsset = 'assets/images/ui/heart_full.webp';
  static const String _heartEmptyAsset = 'assets/images/ui/heart_empty.webp';
  static const double _heartSize = 56;

  static final Palette _palette = Palette();

  // Cached style: large, high contrast (ink on a light pill).
  static final TextStyle _scoreStyle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    height: 1,
    color: _palette.ink.color,
  );

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ScorePill(score: gameManager.score, style: _scoreStyle),
              const Spacer(),
              _HpRow(hp: gameManager.hp),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score, required this.style});

  final ValueListenable<int> score;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: GameHud._palette.bgCream.color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ValueListenableBuilder<int>(
          valueListenable: score,
          builder: (context, value, _) => Text('$value', style: style),
        ),
      ),
    );
  }
}

class _HpRow extends StatelessWidget {
  const _HpRow({required this.hp});

  final ValueListenable<int> hp;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: hp,
      builder: (context, value, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < GameManager.maxHp; i++)
              _Heart(filled: i < value),
          ],
        );
      },
    );
  }
}

class _Heart extends StatelessWidget {
  const _Heart({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Image.asset(
        filled ? GameHud._heartFullAsset : GameHud._heartEmptyAsset,
        width: GameHud._heartSize,
        height: GameHud._heartSize,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => Icon(
          filled ? Icons.favorite : Icons.favorite_border,
          size: GameHud._heartSize,
          color: GameHud._palette.heart.color,
        ),
      ),
    );
  }
}
