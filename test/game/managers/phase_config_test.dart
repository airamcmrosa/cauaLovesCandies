import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kPhases', () {
    test('has 3 phases', () {
      expect(kPhases.length, 3);
    });

    test('speed multipliers are 1.0, 1.35, 1.65', () {
      const expected = [1.0, 1.35, 1.65];
      for (var i = 0; i < expected.length; i++) {
        expect(kPhases[i].speedMultiplier, closeTo(expected[i], 1e-9));
      }
    });

    test('speed is strictly increasing', () {
      for (var i = 1; i < kPhases.length; i++) {
        expect(
          kPhases[i].speedMultiplier,
          greaterThan(kPhases[i - 1].speedMultiplier),
        );
      }
    });

    test('weights per phase match 70/20/10, 50/30/20, 30/40/30', () {
      const expected = [
        [70, 20, 10],
        [50, 30, 20],
        [30, 40, 30],
      ];
      for (var i = 0; i < expected.length; i++) {
        final w = kPhases[i].weights;
        expect(
          [w.sweets, w.fruits, w.hazards],
          expected[i],
          reason: 'P${i + 1}',
        );
      }
    });

    test('each phase weights sum to 100', () {
      for (final p in kPhases) {
        expect(p.weights.total, 100);
      }
    });

    test('CategoryWeights.of maps categories to fields', () {
      final w = kPhases[0].weights;
      expect(w.of(ItemCategory.sweet), w.sweets);
      expect(w.of(ItemCategory.fruit), w.fruits);
      expect(w.of(ItemCategory.hazard), w.hazards);
    });
  });
}
