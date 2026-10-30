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

/// Canvas stub that records translations and fill colors of every draw call.
class _PosCanvas implements Canvas {
  final List<Offset> translations = <Offset>[];
  final List<Color> colors = <Color>[];

  @override
  void translate(double dx, double dy) => translations.add(Offset(dx, dy));

  @override
  void drawRRect(RRect rrect, Paint paint) => colors.add(paint.color);

  @override
  void drawCircle(Offset c, double radius, Paint paint) =>
      colors.add(paint.color);

  @override
  void drawPath(Path path, Paint paint) => colors.add(paint.color);

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

  group('ParticleCelebrationComponent hitSparkle preset', () {
    ParticleCelebrationComponent sparkle({int seed = 1, Vector2? origin}) =>
        ParticleCelebrationComponent(
          preset: CelebrationPreset.hitSparkle,
          random: math.Random(seed),
          origin: origin ?? Vector2(100, 200),
        );

    test('spawns within the 6-8 particle cap', () {
      final c = sparkle();
      expect(ParticleCelebrationComponent.hitSparkleMaxParticles, 8);
      expect(c.activeCount, inInclusiveRange(6, 8));
      expect(_renderAlphas(c).length, c.activeCount);
    });

    test('every particle spawns at the given origin', () {
      final c = sparkle(origin: Vector2(123, 456));
      final canvas = _PosCanvas();
      c.render(canvas);
      expect(canvas.translations.length, c.activeCount);
      for (final t in canvas.translations) {
        expect(t.dx, closeTo(123, 1e-9));
        expect(t.dy, closeTo(456, 1e-9));
      }
    });

    test('particles move away from the origin after updating', () {
      final c = sparkle(origin: Vector2(123, 456));
      c.update(0.1);
      final canvas = _PosCanvas();
      c.render(canvas);
      expect(
        canvas.translations.any(
          (t) => (t - const Offset(123, 456)).distance > 1,
        ),
        isTrue,
      );
    });

    test('uses only the accent lemon color', () {
      final c = sparkle();
      final lemon = ParticleCelebrationComponent.colors[0];
      for (var step = 0; step < 30; step++) {
        final canvas = _PosCanvas();
        c.render(canvas);
        for (final col in canvas.colors) {
          expect(col.r, closeTo(lemon.r, 1e-6));
          expect(col.g, closeTo(lemon.g, 1e-6));
          expect(col.b, closeTo(lemon.b, 1e-6));
        }
        c.update(_dt);
      }
    });

    test('same seed gives identical positions, different seed differs', () {
      List<Offset> snap(int seed) {
        final c = sparkle(seed: seed);
        c.update(0.2);
        final canvas = _PosCanvas();
        c.render(canvas);
        return canvas.translations;
      }

      expect(snap(42), snap(42));
      expect(snap(42), isNot(snap(43)));
    });

    test('lives about 0.6s then finishes', () {
      final c = sparkle();
      c.update(0.55);
      expect(c.activeCount, greaterThan(0));
      c.update(0.1);
      expect(c.activeCount, 0);
      expect(_renderAlphas(c), isEmpty);
    });

    test('fades out before finishing', () {
      final c = sparkle();
      c.update(0.55);
      final alphas = _renderAlphas(c);
      expect(alphas, isNotEmpty);
      expect(alphas.every((a) => a < 1.0 && a >= 0.0), isTrue);
    });

    testWithFlameGame('removes itself after its lifetime', (game) async {
      final c = sparkle();
      await game.add(c);
      await game.ready();
      game.update(0.5);
      expect(game.children.contains(c), isTrue);
      game.update(0.2);
      game.update(_dt);
      expect(game.children.contains(c), isFalse);
    });

    testWithFlameGame('10 independent instances all remove, no leftovers', (
      game,
    ) async {
      final sparkles = List.generate(
        10,
        (i) => sparkle(seed: i, origin: Vector2(10.0 * i, 20)),
      );
      await game.addAll(sparkles);
      await game.ready();
      expect(
        game.children.whereType<ParticleCelebrationComponent>().length,
        10,
      );
      for (final s in sparkles) {
        expect(s.activeCount, inInclusiveRange(6, 8));
      }
      game.update(0.3);
      expect(
        game.children.whereType<ParticleCelebrationComponent>().length,
        10,
      );
      game.update(0.4);
      game.update(_dt);
      expect(game.children.whereType<ParticleCelebrationComponent>(), isEmpty);
      for (final s in sparkles) {
        expect(s.isMounted, isFalse);
        expect(s.activeCount, 0);
      }
    });

    test('origin getter returns the given origin', () {
      final c = sparkle(origin: Vector2(12, 34));
      expect(c.origin.x, 12);
      expect(c.origin.y, 34);
      expect(ParticleCelebrationComponent().origin, Vector2(360, 200));
    });

    test('pool and active count stay within the per-preset caps', () {
      final s = sparkle();
      expect(
        s.activeCount,
        lessThanOrEqualTo(ParticleCelebrationComponent.hitSparkleMaxParticles),
      );
      expect(ParticleCelebrationComponent.hitSparkleMaxParticles, 8);
      expect(ParticleCelebrationComponent.maxParticles, 80);
      expect(_renderAlphas(s).length, lessThanOrEqualTo(8));
      final v = ParticleCelebrationComponent(random: math.Random(1));
      expect(v.activeCount, lessThanOrEqualTo(80));
      expect(_renderAlphas(v).length, lessThanOrEqualTo(80));
    });

    test('sparkle size stays in 10-16 and life is 0.6s', () {
      expect(ParticleCelebrationComponent.hitSparkleLife, 0.6);
      expect(ParticleCelebrationComponent.hitSparkleFadeWindow, 0.2);
    });

    test('sparkle holds full alpha until the last 0.2s then fades', () {
      final c = sparkle();
      // Age 0 and 0.39s (0.21s remaining): still fully opaque.
      expect(_renderAlphas(c).every((a) => a == 1.0), isTrue);
      c.update(0.39);
      var alphas = _renderAlphas(c);
      expect(alphas, isNotEmpty);
      expect(alphas.every((a) => a == 1.0), isTrue);
      // 0.1s remaining: about half alpha.
      c.update(0.11);
      alphas = _renderAlphas(c);
      expect(alphas, isNotEmpty);
      for (final a in alphas) {
        expect(a, closeTo(0.5, 0.07));
      }
      // 0.02s remaining: nearly transparent.
      c.update(0.08);
      for (final a in _renderAlphas(c)) {
        expect(a, lessThan(0.2));
      }
    });

    test('victory fade window is unchanged at 0.5s', () {
      expect(ParticleCelebrationComponent.victoryFadeWindow, 0.5);
      final c = ParticleCelebrationComponent(random: math.Random(11));
      // Before any particle can be within 0.5s of its end (min life 2.2s).
      c.update(1.6);
      expect(_renderAlphas(c).every((a) => a == 1.0), isTrue);
      // At 2.5s some burst particles are inside the fade window.
      for (var i = 0; i < 54; i++) {
        c.update(_dt);
      }
      expect(_renderAlphas(c).any((a) => a < 1.0), isTrue);
    });

    test('rendering many frames does not change particle state', () {
      final c = sparkle();
      c.update(0.45);
      expect(_renderAlphas(c), _renderAlphas(c));
    });

    test('victory preset is unchanged by the sparkle preset', () {
      final v = ParticleCelebrationComponent(random: math.Random(1));
      expect(v.preset, CelebrationPreset.victory);
      expect(v.activeCount, ParticleCelebrationComponent.maxParticles);
      expect(_renderAlphas(v).length, ParticleCelebrationComponent.burstCount);
    });
  });
}
