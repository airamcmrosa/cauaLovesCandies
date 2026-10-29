import 'dart:math' as math;

import 'package:flame/components.dart';

/// Short decaying camera shake (architecture section 2), used on hazard
/// ingestion. Add once to the game/world, then call [trigger]. Uses a
/// deterministic sine offset, so there are no per-frame allocations.
class ScreenShake extends Component {
  ScreenShake({required CameraComponent camera}) : _camera = camera;

  /// Shake length in seconds.
  static const double duration = 0.3;

  /// Peak offset in virtual pixels.
  static const double amplitude = 14.0;

  /// Oscillation frequency in Hz.
  static const double frequency = 28.0;

  final CameraComponent _camera;
  final Vector2 _base = Vector2.zero();
  final Vector2 _scratch = Vector2.zero();
  double _elapsed = duration;

  bool get isShaking => _elapsed < duration;

  /// Starts (or restarts) the shake.
  void trigger() {
    if (!isShaking) _base.setFrom(_camera.viewfinder.position);
    _elapsed = 0;
  }

  @override
  void update(double dt) {
    if (!isShaking) return;
    _elapsed += dt;
    if (_elapsed >= duration) {
      _camera.viewfinder.position = _base;
      return;
    }
    final decay = 1.0 - _elapsed / duration;
    final phase = _elapsed * frequency * 2 * math.pi;
    _scratch.setValues(
      _base.x + math.sin(phase) * amplitude * decay,
      _base.y + math.cos(phase * 0.7) * amplitude * decay * 0.5,
    );
    // The getter returns a copy in Flame 1.38, so assign via the setter.
    _camera.viewfinder.position = _scratch;
  }

  @override
  void onRemove() {
    if (isShaking) {
      _elapsed = duration;
      _camera.viewfinder.position = _base;
    }
    super.onRemove();
  }
}
