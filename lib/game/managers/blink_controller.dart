import 'dart:math';

import 'package:flutter/foundation.dart';

/// Eye state used by Cauã's idle blink animation.
enum EyeState { open, half, shut }

/// Drives Cauã's idle blink purely from elapsed time.
///
/// Sequence: open -> half -> shut -> half -> open, one step every
/// [stepSeconds], after a random gap of [minGapSeconds]..[maxGapSeconds].
class BlinkController {
  BlinkController({Random? random}) : _random = random ?? Random() {
    _armGap();
  }

  /// Duration of each blink frame, in seconds (70 ms).
  static const double stepSeconds = 0.07;

  /// Minimum idle gap between blinks, in seconds.
  static const double minGapSeconds = 2.5;

  /// Maximum idle gap between blinks, in seconds.
  static const double maxGapSeconds = 5.0;

  // Frames emitted after the initial open state, in order.
  static const List<EyeState> _sequence = <EyeState>[
    EyeState.half,
    EyeState.shut,
    EyeState.half,
    EyeState.open,
  ];

  final Random _random;
  final ValueNotifier<EyeState> _state = ValueNotifier<EyeState>(EyeState.open);

  double _timer = 0;
  // Index of the next frame in [_sequence]; -1 while waiting for a blink.
  int _nextStep = -1;

  /// Current eye state, observable by components.
  ValueListenable<EyeState> get state => _state;

  /// Advances the blink timeline. Large [dt] values catch up step by step
  /// without skipping any frame.
  void tick(double dt) {
    if (dt <= 0) return;
    _timer -= dt;
    while (_timer <= 0) {
      if (_nextStep < 0) _nextStep = 0;
      _state.value = _sequence[_nextStep];
      if (_nextStep == _sequence.length - 1) {
        _nextStep = -1;
        _timer += _randomGap();
      } else {
        _nextStep++;
        _timer += stepSeconds;
      }
    }
  }

  /// Returns to open eyes and re-arms a fresh random gap.
  void reset() {
    _state.value = EyeState.open;
    _armGap();
  }

  void _armGap() {
    _nextStep = -1;
    _timer = _randomGap();
  }

  double _randomGap() =>
      minGapSeconds + _random.nextDouble() * (maxGapSeconds - minGapSeconds);

  void dispose() {
    _state.dispose();
  }
}
