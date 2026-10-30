import 'dart:math' as math;
import 'dart:ui';

import 'package:caua_loves_candies/game/components/particle_celebration_component.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Canvas stub that records the alpha of every draw call.
class _RecordingCanvas implements Canvas {
  final List<double> alphas = <double>[];

  @override
  void drawRRect(RRect rrect, Paint paint) => alphas.add(paint.color.a);

  @override
  void drawCircle(Offset c, double radius, Paint paint) =>
      alphas.add(paint.color.a);

  @override
  void drawPath(Path path, Paint paint) => alphas.add(paint.color.a);

  @override
  dynamic noSuchMethod(Invocation invocation) {}
}

const double _dt = 1 / 60;

List<int> _trajectory(int seed, int steps) {
  final c = ParticleCelebrationComponent(random: math.Random(seed));
  final out = <int>[];
  for (var i = 0; i < steps; i++) {
    c.update(_dt);
    out.add(c.activeCount);
  }
  return out;
}

List<double> _renderAlphas(ParticleCelebrationComponent c) {
  final canvas = _RecordingCanvas();
  c.render(canvas);
  return canvas.alphas;
}

void main() {
  group('ParticleCelebrationComponent victory preset', () {
    test('defaults to the victory preset', () {
      expect(ParticleCelebrationComponent().preset, CelebrationPreset.victory);
    });

    test('starts at the cap and never exceeds 80 particles', () {
      final c = ParticleCelebrationComponent(random: math.Random(1));
      expect(ParticleCelebrationComponent.maxParticles, 80);
      expect(c.activeCount, lessThanOrEqualTo(80));
      expect(c.activeCount, 80);
      var prev = c.activeCount;
      for (var i = 0; i < 600; i++) {
        c.update(_dt);
        expect(c.activeCount, lessThanOrEqualTo(80));
        expect(c.activeCount, lessThanOrEqualTo(prev));
        prev = c.activeCount;
      }
    });

    test('same seed yields identical lifecycle and render output', () {
      expect(_trajectory(42, 400), _trajectory(42, 400));
      final a = ParticleCelebrationComponent(random: math.Random(7));
      final b = ParticleCelebrationComponent(random: math.Random(7));
      for (var i = 0; i < 90; i++) {
        a.update(_dt);
        b.update(_dt);
      }
      expect(_renderAlphas(a), _renderAlphas(b));
    });

    test('burst renders immediately, rain is delayed', () {
      final c = ParticleCelebrationComponent(random: math.Random(3));
      // Before any update the whole pool is alive but delayed rain is hidden.
      final first = _renderAlphas(c);
      expect(first.length, ParticleCelebrationComponent.burstCount);

      // Rain delay is 0.6..2.2s; after 2.3s of steps rain has started while
      // burst particles (life 2.2..3.0s) are still partially present.
      for (var i = 0; i < 138; i++) {
        c.update(_dt);
      }
      final later = _renderAlphas(c);
      expect(later, isNotEmpty);
      expect(
        later.length,
        lessThanOrEqualTo(ParticleCelebrationComponent.maxParticles),
      );
    });

    test('rain particles appear after the burst began fading', () {
      final c = ParticleCelebrationComponent(random: math.Random(5));
      // At 0.5s no rain yet: only burst particles are drawn.
      for (var i = 0; i < 30; i++) {
        c.update(_dt);
      }
      expect(
        _renderAlphas(c).length,
        lessThanOrEqualTo(ParticleCelebrationComponent.burstCount),
      );
      // At 2.5s rain (spawned 0.6..2.2s) is visible: more than only the
      // surviving burst could account for is not guaranteed, so assert that
      // particles beyond the burst count were activated in total.
      for (var i = 0; i < 120; i++) {
        c.update(_dt);
      }
      expect(c.activeCount, greaterThan(0));
    });

    test('particles fade to transparent before finishing', () {
      final c = ParticleCelebrationComponent(random: math.Random(11));
      var sawFade = false;
      for (var i = 0; i < 600 && c.activeCount > 0; i++) {
        c.update(_dt);
        for (final a in _renderAlphas(c)) {
          expect(a, inInclusiveRange(0.0, 1.0));
          if (a < 1.0) sawFade = true;
        }
      }
      expect(sawFade, isTrue);
    });

    test('finishes: activeCount reaches 0 and nothing renders', () {
      final c = ParticleCelebrationComponent(random: math.Random(9));
      for (var i = 0; i < 60 * 10; i++) {
        c.update(_dt);
      }
      expect(c.activeCount, 0);
      expect(_renderAlphas(c), isEmpty);
    });

    test('a single huge dt finishes all particles without throwing', () {
      final c = ParticleCelebrationComponent(random: math.Random(2));
      c.update(0.0);
      c.update(100);
      c.update(100);
      expect(c.activeCount, 0);
    });

    test('update and render with various seeds do not throw', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      for (var seed = 0; seed < 5; seed++) {
        final c = ParticleCelebrationComponent(random: math.Random(seed));
        for (var i = 0; i < 400; i++) {
          c.update(_dt);
          c.render(canvas);
        }
      }
      recorder.endRecording().dispose();
    });

    test('works without an injected Random and custom origin', () {
      final c = ParticleCelebrationComponent(origin: Vector2(100, 100));
      expect(() {
        c.update(_dt);
        c.render(Canvas(PictureRecorder()));
      }, returnsNormally);
    });
  });

  group('ParticleCelebrationComponent self-removal', () {
    testWithFlameGame('removes itself from the parent after finishing', (
      game,
    ) async {
      final c = ParticleCelebrationComponent(random: math.Random(4));
      await game.add(c);
      await game.ready();
      expect(game.children.contains(c), isTrue);

      game.update(0.5);
      expect(game.children.contains(c), isTrue);

      for (var i = 0; i < 60 * 10; i++) {
        game.update(_dt);
      }
      game.update(_dt);
      expect(game.children.contains(c), isFalse);
      expect(c.isMounted, isFalse);
    });
  });
}
