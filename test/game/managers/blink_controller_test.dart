import 'dart:math';

import 'package:caua_loves_candies/game/managers/blink_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scripted Random returning queued doubles from nextDouble().
class _FakeRandom implements Random {
  _FakeRandom(this.values);
  final List<double> values;
  int _i = 0;

  @override
  double nextDouble() => values[_i++ % values.length];

  @override
  bool nextBool() => false;

  @override
  int nextInt(int max) => 0;
}

void main() {
  const step = BlinkController.stepSeconds;
  const expected = <EyeState>[
    EyeState.half,
    EyeState.shut,
    EyeState.half,
    EyeState.open,
  ];

  late BlinkController controller;
  late List<EyeState> emitted;

  void listen(BlinkController c) {
    emitted = <EyeState>[];
    c.state.addListener(() => emitted.add(c.state.value));
  }

  tearDown(() => controller.dispose());

  group('BlinkController', () {
    test('starts open and does not blink before the minimum gap', () {
      controller = BlinkController(random: _FakeRandom([0.0]));
      listen(controller);
      expect(controller.state.value, EyeState.open);
      controller.tick(BlinkController.minGapSeconds - 0.01);
      expect(controller.state.value, EyeState.open);
      expect(emitted, isEmpty);
    });

    test('emits the exact sequence once per interval with a fixed seed', () {
      controller = BlinkController(random: Random(42));
      listen(controller);
      // Tiny dt steps over 40 s; every blink must be the exact 4 changes.
      for (var i = 0; i < 4000; i++) {
        controller.tick(0.01);
      }
      expect(emitted.length, greaterThanOrEqualTo(4));
      expect(emitted.length % 4, anyOf(0, 1, 2, 3));
      final full = emitted.length - emitted.length % 4;
      for (var i = 0; i < full; i++) {
        expect(emitted[i], expected[i % 4], reason: 'index $i');
      }
    });

    test('steps advance every 70 ms after the gap elapses', () {
      controller = BlinkController(random: _FakeRandom([0.0]));
      listen(controller);
      controller.tick(BlinkController.minGapSeconds + 0.001);
      expect(controller.state.value, EyeState.half);
      controller.tick(step);
      expect(controller.state.value, EyeState.shut);
      controller.tick(step);
      expect(controller.state.value, EyeState.half);
      controller.tick(step);
      expect(controller.state.value, EyeState.open);
      expect(emitted, expected);
    });

    test('gap is within 2.5 to 5 s for min and max random draws', () {
      for (final draw in [0.0, 0.999999]) {
        final c = BlinkController(random: _FakeRandom([draw]));
        final gap =
            BlinkController.minGapSeconds +
            draw *
                (BlinkController.maxGapSeconds - BlinkController.minGapSeconds);
        c.tick(gap - 0.01);
        expect(c.state.value, EyeState.open, reason: 'draw $draw before gap');
        c.tick(0.02);
        expect(c.state.value, EyeState.half, reason: 'draw $draw after gap');
        expect(gap, inInclusiveRange(2.5, 5.0));
        c.dispose();
      }
      controller = BlinkController(random: _FakeRandom([0.0]));
    });

    test('measured gaps between blinks stay within bounds for seed 7', () {
      controller = BlinkController(random: Random(7));
      var t = 0.0;
      var last = 0.0;
      final gaps = <double>[];
      controller.state.addListener(() {
        // Blink end (open) to next blink start (half) is the gap.
        if (controller.state.value == EyeState.open) last = t;
        if (controller.state.value == EyeState.half && last > 0) {
          gaps.add(t - last);
        }
      });
      for (var i = 0; i < 20000; i++) {
        t += 0.005;
        controller.tick(0.005);
      }
      expect(gaps, isNotEmpty);
      for (final g in gaps) {
        // Gap measured from blink end; 4 steps already elapsed inside the
        // timer is not counted, so allow one tick of quantization.
        expect(g, greaterThanOrEqualTo(2.5 - 0.006));
        expect(g, lessThanOrEqualTo(5.0 + 0.006));
      }
    });

    test('long dt catches up without skipping any step', () {
      controller = BlinkController(random: _FakeRandom([0.0]));
      listen(controller);
      // One huge dt covering several blinks, delivered in one call.
      controller.tick(60);
      expect(emitted, isNotEmpty);
      for (var i = 0; i < emitted.length; i++) {
        expect(emitted[i], expected[i % 4], reason: 'index $i');
      }
    });

    test('long dt that ends mid blink leaves a consistent next step', () {
      controller = BlinkController(random: _FakeRandom([0.0]));
      listen(controller);
      controller.tick(BlinkController.minGapSeconds + step * 1.5);
      expect(emitted, [EyeState.half, EyeState.shut]);
      controller.tick(step * 2);
      expect(emitted, [
        EyeState.half,
        EyeState.shut,
        EyeState.half,
        EyeState.open,
      ]);
    });

    test('non-positive dt is ignored', () {
      controller = BlinkController(random: _FakeRandom([0.0]));
      listen(controller);
      controller.tick(0);
      controller.tick(-5);
      expect(emitted, isEmpty);
      expect(controller.state.value, EyeState.open);
    });

    test('reset returns to open and re-arms a fresh gap', () {
      controller = BlinkController(random: _FakeRandom([0.0]));
      controller.tick(BlinkController.minGapSeconds + 0.001);
      expect(controller.state.value, EyeState.half);
      controller.reset();
      expect(controller.state.value, EyeState.open);
      listen(controller);
      controller.tick(BlinkController.minGapSeconds - 0.01);
      expect(controller.state.value, EyeState.open);
      expect(emitted, isEmpty);
      controller.tick(0.02);
      expect(controller.state.value, EyeState.half);
    });

    test('dispose disposes the notifier', () {
      controller = BlinkController(random: _FakeRandom([0.0]));
      final c = BlinkController(random: _FakeRandom([0.0]));
      c.dispose();
      expect(() => c.state.addListener(() {}), throwsFlutterError);
    });
  });
}
