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

    test('weights per phase match 70/20/10, 50/30/20, 25/30/45', () {
      const expected = [
        [70, 20, 10],
        [50, 30, 20],
        [25, 30, 45],
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

    test('hazards weight strictly increases across phases (10 < 20 < 45)', () {
      final h = kPhases.map((p) => p.weights.hazards).toList();
      expect(h, [10, 20, 45]);
      expect(h[0], lessThan(h[1]));
      expect(h[1], lessThan(h[2]));
    });

    test('each phase weights sum to 100', () {
      for (final p in kPhases) {
        expect(p.weights.total, 100);
      }
    });

    test('target scores are 10, 20, 30 and strictly increasing', () {
      expect(kPhases.map((p) => p.targetScore).toList(), [10, 20, 30]);
      for (var i = 1; i < kPhases.length; i++) {
        expect(kPhases[i].targetScore, greaterThan(kPhases[i - 1].targetScore));
      }
    });

    test('banner text is null for phase 1 and set for phases 2 and 3', () {
      expect(kPhases[0].bannerText, isNull);
      expect(kPhases[1].bannerText, 'Fase 2 - Mais Rápido!');
      expect(kPhases[2].bannerText, 'Fase 3 - Super Rápido!');
      expect(kPhases[1].bannerText, isNotEmpty);
      expect(kPhases[2].bannerText, isNotEmpty);
    });

    test('bannerText defaults to null when omitted', () {
      const c = PhaseConfig(
        speedMultiplier: 1.0,
        targetScore: 1,
        weights: CategoryWeights(sweets: 1, fruits: 1, hazards: 1),
      );
      expect(c.bannerText, isNull);
    });

    test('CategoryWeights.of maps categories to fields', () {
      final w = kPhases[0].weights;
      expect(w.of(ItemCategory.sweet), w.sweets);
      expect(w.of(ItemCategory.fruit), w.fruits);
      expect(w.of(ItemCategory.hazard), w.hazards);
    });
  });
}
