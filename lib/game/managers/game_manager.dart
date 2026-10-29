/// Domain state for a play session: score, HP, level and game state.
///
/// Plain Dart (only `ValueNotifier` from foundation). Components report
/// ingested items; they never own score or HP.
library;

import 'package:flutter/foundation.dart';

import 'item_type.dart';
import 'phase_config.dart';

/// High-level game state. Only `playing` exists for now.
enum GameState { playing }

class GameManager {
  GameManager();

  /// Maximum (and starting) HP.
  static const int maxHp = 3;

  /// Starting level (1-based).
  static const int initialLevel = 1;

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> hp = ValueNotifier<int>(maxHp);

  /// Current level (1-based). Does not advance here.
  int level = initialLevel;

  GameState state = GameState.playing;

  /// Config of the current level.
  PhaseConfig get phase => kPhases[level - 1];

  /// Adds [points] to the score; non-positive values are ignored.
  void addScore(int points) {
    if (points <= 0) return;
    score.value += points;
  }

  /// Removes 1 HP, clamped at 0 (no notification when already 0).
  void loseHp() {
    if (hp.value <= 0) return;
    hp.value -= 1;
  }

  /// Applies the effect of an ingested [item] (points and/or HP loss).
  void onIngested(ItemType item) {
    addScore(item.points);
    if (item.hpDelta < 0) loseHp();
  }

  /// Restores the initial session state.
  void reset() {
    score.value = 0;
    hp.value = maxHp;
    level = initialLevel;
    state = GameState.playing;
  }

  void dispose() {
    score.dispose();
    hp.dispose();
  }
}
