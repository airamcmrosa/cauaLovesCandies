import 'package:caua_loves_candies/game/components/conveyor_belt_component.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameManager gm;
  late ConveyorBeltComponent belt;

  setUp(() {
    gm = GameManager()..dismissTutorial();
    belt = ConveyorBeltComponent(gameManager: gm);
  });

  group('speed per level', () {
    for (var level = 1; level <= kPhases.length; level++) {
      test('level $level uses baseSpeed * phase multiplier', () {
        gm.level = level;
        expect(
          belt.speed,
          closeTo(
            ConveyorBeltComponent.baseSpeed *
                kPhases[level - 1].speedMultiplier,
            1e-12,
          ),
        );
      });
    }

    test('speeds are strictly increasing across levels', () {
      final speeds = <double>[];
      for (var level = 1; level <= kPhases.length; level++) {
        gm.level = level;
        speeds.add(belt.speed);
      }
      expect(speeds[0], lessThan(speeds[1]));
      expect(speeds[1], lessThan(speeds[2]));
    });

    test('speed is constant within a level regardless of updates', () {
      final before = belt.speed;
      belt.update(0.5);
      belt.update(0.016);
      expect(belt.speed, before);
    });
  });

  group('stripe phase', () {
    test('starts at zero', () {
      expect(belt.phase, 0.0);
    });

    test('advances linearly with dt', () {
      belt.update(0.01);
      final one = belt.phase;
      belt.update(0.01);
      expect(belt.phase, closeTo(one * 2, 1e-12));
      expect(
        one,
        closeTo(belt.speed * 0.01 * ConveyorBeltComponent.stripeCount, 1e-12),
      );
    });

    test('zero dt does not move the stripes', () {
      belt.update(0);
      expect(belt.phase, 0.0);
    });

    test('wraps into [0, 1)', () {
      for (var i = 0; i < 500; i++) {
        belt.update(0.037);
        expect(belt.phase, inInclusiveRange(0.0, 1.0));
        expect(belt.phase, lessThan(1.0));
      }
    });

    test('wraps after one full period', () {
      final period = 1.0 / (belt.speed * ConveyorBeltComponent.stripeCount);
      belt.update(period * 1.25);
      expect(belt.phase, closeTo(0.25, 1e-9));
    });

    test('higher level scrolls proportionally faster', () {
      final slow = ConveyorBeltComponent(gameManager: gm)..update(0.01);
      gm.level = 3;
      final fast = ConveyorBeltComponent(gameManager: gm)..update(0.01);
      expect(
        fast.phase / slow.phase,
        closeTo(kPhases[2].speedMultiplier / kPhases[0].speedMultiplier, 1e-9),
      );
    });
  });

  group('frame-rate independence', () {
    for (var level = 1; level <= kPhases.length; level++) {
      test('1 x 1s equals 60 x 1/60s at level $level', () {
        gm.level = level;
        final a = ConveyorBeltComponent(gameManager: gm)..update(1.0);
        final b = ConveyorBeltComponent(gameManager: gm);
        for (var i = 0; i < 60; i++) {
          b.update(1 / 60);
        }
        expect(b.phase, closeTo(a.phase, 1e-9));
      });
    }
  });

  group('tutorial gating', () {
    setUp(() => gm.state = GameState.tutorial);

    test('stripe phase does not scroll while in the tutorial', () {
      expect(gm.state, GameState.tutorial);
      for (var i = 0; i < 100; i++) {
        belt.update(0.1);
      }
      expect(belt.phase, 0.0);
    });

    test('scrolls at full phase 1 speed right after dismissTutorial', () {
      gm.dismissTutorial();
      belt.update(0.01);
      expect(
        belt.phase,
        closeTo(
          ConveyorBeltComponent.baseSpeed *
              kPhases[0].speedMultiplier *
              0.01 *
              ConveyorBeltComponent.stripeCount,
          1e-9,
        ),
      );
    });
  });
}
