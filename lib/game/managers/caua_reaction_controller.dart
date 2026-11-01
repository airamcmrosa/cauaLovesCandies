import 'package:flutter/foundation.dart';

import 'caua_reaction_timings.dart';
import 'item_type.dart';

/// Which reaction face Cauã is showing.
enum CauaReaction { none, chew, eca }

/// Drives Cauã's reaction (chew or "eca") purely from elapsed time.
///
/// Chew steps through frames 0, 1, 2 every [kChewStep] and holds the last
/// frame during [kReactionRecover]; eca holds for [kEcaHold]. No timers.
class CauaReactionController {
  final ValueNotifier<CauaReaction> _reaction = ValueNotifier<CauaReaction>(
    CauaReaction.none,
  );
  final ValueNotifier<int> _step = ValueNotifier<int>(0);

  double _elapsed = 0;

  /// Current reaction, observable by components.
  ValueListenable<CauaReaction> get reaction => _reaction;

  /// Chew frame index (0..2); always 0 outside a chew.
  ValueListenable<int> get step => _step;

  /// Whether a reaction is playing.
  bool get isActive => _reaction.value != CauaReaction.none;

  /// Starts the reaction for an ingested [category]: hazard -> eca, others ->
  /// chew. Restarts from the beginning if one is already playing.
  void start(ItemCategory category) {
    _elapsed = 0;
    _step.value = 0;
    _reaction.value = category == ItemCategory.hazard
        ? CauaReaction.eca
        : CauaReaction.chew;
  }

  /// Advances the reaction. Long [dt] values emit every chew step in order.
  void tick(double dt) {
    if (dt <= 0 || !isActive) return;
    _elapsed += dt;
    if (_reaction.value == CauaReaction.eca) {
      if (_elapsed >= kEcaHold) _clear();
      return;
    }
    final target = (_elapsed / kChewStep).floor().clamp(0, kChewSteps - 1);
    while (_step.value < target) {
      _step.value++;
    }
    if (_elapsed >= kChewTotal) _clear();
  }

  /// Stops the current reaction immediately (back to idle).
  void cancel() => _clear();

  /// Returns to the initial idle state.
  void reset() => _clear();

  void _clear() {
    _elapsed = 0;
    _step.value = 0;
    _reaction.value = CauaReaction.none;
  }

  void dispose() {
    _reaction.dispose();
    _step.dispose();
  }
}
