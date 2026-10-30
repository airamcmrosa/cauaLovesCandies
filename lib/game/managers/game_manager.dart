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
  GameManager({List<PhaseConfig> phases = kPhases}) : _phases = phases;

  /// Maximum (and starting) HP.
  static const int maxHp = 3;

  /// Starting level (1-based).
  static const int initialLevel = 1;

  final List<PhaseConfig> _phases;

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> hp = ValueNotifier<int>(maxHp);

  /// Current phase (1-based).
  final ValueNotifier<int> currentPhase = ValueNotifier<int>(initialLevel);

  /// New phase number, notified exactly once per advance. Null (and silent)
  /// at start and after [reset].
  final ValueNotifier<int?> phaseChanged = ValueNotifier<int?>(null);

  /// Current level (1-based); compatible view of [currentPhase].
  int get level => currentPhase.value;

  /// Compatibility setter (sets the phase without firing [phaseChanged]).
  set level(int value) => currentPhase.value = value;

  GameState state = GameState.playing;

  /// Config of the current phase.
  PhaseConfig get phase => _phases[currentPhase.value - 1];

  /// Belt speed multiplier of the active phase.
  double get currentSpeedMultiplier => phase.speedMultiplier;

  /// Adds [points] to the score; non-positive values are ignored.
  void addScore(int points) {
    if (points <= 0) return;
    score.value += points;
    advanceIfTargetReached();
  }

  /// Advances one phase at a time while the cumulative score reaches the
  /// current phase target. Never advances past the last configured phase.
  void advanceIfTargetReached() {
    while (currentPhase.value < _phases.length &&
        score.value >= _phases[currentPhase.value - 1].targetScore) {
      currentPhase.value += 1;
      phaseChanged.value = currentPhase.value;
    }
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
    currentPhase.value = initialLevel;
    phaseChanged.value = null;
    state = GameState.playing;
  }

  void dispose() {
    currentPhase.dispose();
    phaseChanged.dispose();
    score.dispose();
    hp.dispose();
  }
}
