import 'dart:math' as math;

import 'package:caua_loves_candies/game/screen_shake.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CameraComponent camera;
  late ScreenShake shake;
  final base = Vector2(100, 50);

  setUp(() {
    camera = CameraComponent();
    camera.viewfinder.position = base.clone();
    shake = ScreenShake(camera: camera);
  });

  test('is idle and leaves the camera alone before trigger', () {
    expect(shake.isShaking, isFalse);
    shake.update(0.1);
    expect(camera.viewfinder.position, base);
  });

  test('trigger moves the offset within the peak and then restores', () {
    shake.trigger();
    expect(shake.isShaking, isTrue);
    var moved = false;
    for (var i = 0; i < 17; i++) {
      shake.update(0.01);
      final d = camera.viewfinder.position - base;
      expect(d.x.abs(), lessThanOrEqualTo(ScreenShake.amplitude + 1e-9));
      expect(d.y.abs(), lessThanOrEqualTo(ScreenShake.amplitude * 0.5 + 1e-9));
      if (d.length > 1e-6) moved = true;
    }
    expect(moved, isTrue);
    expect(shake.isShaking, isTrue);

    shake.update(ScreenShake.duration);
    expect(shake.isShaking, isFalse);
    expect(camera.viewfinder.position.x, closeTo(base.x, 1e-9));
    expect(camera.viewfinder.position.y, closeTo(base.y, 1e-9));
  });

  test('offset decays toward the end', () {
    shake.trigger();
    shake.update(0.299);
    final d = (camera.viewfinder.position - base).length;
    expect(d, lessThan(math.max(1.0, ScreenShake.amplitude * 0.1)));
  });

  test('retrigger mid-shake keeps the original base', () {
    shake.trigger();
    shake.update(0.05);
    shake.trigger();
    shake.update(ScreenShake.duration);
    expect(camera.viewfinder.position.x, closeTo(base.x, 1e-9));
    expect(camera.viewfinder.position.y, closeTo(base.y, 1e-9));
  });
}
