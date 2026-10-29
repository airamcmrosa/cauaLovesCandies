import 'package:flutter/foundation.dart';

import 'mouth_state.dart';

/// Owns Cauã's mouth state. A single tap toggles it between closed and open.
class MouthController {
  final ValueNotifier<MouthState> _state = ValueNotifier<MouthState>(
    MouthState.closed,
  );

  /// Current mouth state, observable by components and overlays.
  ValueListenable<MouthState> get state => _state;

  /// Whether the mouth is currently open.
  bool get isOpen => _state.value == MouthState.open;

  /// Flips the mouth state. Notifies listeners exactly once per call.
  void toggle() {
    _state.value = isOpen ? MouthState.closed : MouthState.open;
  }

  /// Returns the mouth to its default closed state.
  void reset() {
    _state.value = MouthState.closed;
  }

  void dispose() {
    _state.dispose();
  }
}
