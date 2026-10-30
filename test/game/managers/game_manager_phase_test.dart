import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameManager gm;
  late List<int?> events;

  setUp(() {
    gm = GameManager();
    events = [];
    gm.phaseChanged.addListener(() => events.add(gm.phaseChanged.value));
  });

  group('initial phase state', () {
    test('starts at phase 1 with no phaseChanged event', () {
      expect(gm.currentPhase.value, 1);
      expect(gm.level, 1);
      expect(gm.phaseChanged.value, isNull);
      expect(events, isEmpty);
    });
  });

  group('thresholds', () {
    final table = <List<int>>[
      // [score, expected phase]
      [9, 1],
      [10, 2],
      [19, 2],
      [20, 3],
      [29, 3],
      [30, 3],
    ];
    for (final row in table) {
      test('score ${row[0]} gives phase ${row[1]}', () {
        for (var i = 0; i < row[0]; i++) {
          gm.addScore(1);
        }
        expect(gm.currentPhase.value, row[1]);
        expect(gm.level, row[1]);
        expect(gm.phase, same(kPhases[row[1] - 1]));
      });
    }
  });

  group('phaseChanged events', () {
    test('fires exactly once per advance with the new phase', () {
      for (var i = 0; i < 30; i++) {
        gm.addScore(1);
      }
      expect(events, [2, 3]);
    });

    test('no event for scoring that does not cross a threshold', () {
      gm.addScore(5);
      gm.addScore(4);
      expect(events, isEmpty);
      gm.addScore(1);
      expect(events, [2]);
      gm.addScore(2);
      expect(events, [2]);
    });

    test('score jump 0 to 20 advances to phase 3, one event per step', () {
      gm.addScore(20);
      expect(gm.currentPhase.value, 3);
      expect(events, [2, 3]);
    });

    test('non-positive points do not advance', () {
      gm.addScore(0);
      gm.addScore(-5);
      expect(gm.currentPhase.value, 1);
      expect(events, isEmpty);
    });

    test('currentPhase notifies on each advance', () {
      var notes = 0;
      gm.currentPhase.addListener(() => notes++);
      gm.addScore(20);
      expect(notes, 2);
    });
  });

  group('cap at last phase', () {
    test('large score never exceeds phase 3', () {
      gm.addScore(1000);
      expect(gm.currentPhase.value, kPhases.length);
      expect(gm.phase, same(kPhases.last));
      expect(events, [2, 3]);
      gm.addScore(500);
      expect(gm.currentPhase.value, kPhases.length);
      expect(events, [2, 3]);
    });
  });

  group('reset', () {
    test('returns to phase 1 without firing and clears last event', () {
      gm.addScore(25);
      expect(gm.phaseChanged.value, 3);
      events.clear();
      gm.reset();
      expect(gm.currentPhase.value, 1);
      expect(gm.level, 1);
      expect(gm.phaseChanged.value, isNull);
      // Listener sees only the null reset, never a phase number.
      expect(events.whereType<int>(), isEmpty);
    });

    test('can advance again after reset', () {
      gm.addScore(10);
      gm.reset();
      events.clear();
      gm.addScore(10);
      expect(gm.currentPhase.value, 2);
      expect(events, [2]);
    });
  });

  group('level compat', () {
    test('setter sets phase without firing phaseChanged', () {
      gm.level = 2;
      expect(gm.currentPhase.value, 2);
      expect(gm.level, 2);
      expect(events, isEmpty);
    });
  });

  group('injected phases', () {
    const w = CategoryWeights(sweets: 1, fruits: 1, hazards: 1);
    final custom = [
      const PhaseConfig(speedMultiplier: 1.0, targetScore: 3, weights: w),
      const PhaseConfig(speedMultiplier: 2.0, targetScore: 5, weights: w),
    ];

    test('uses custom targets and caps at custom length', () {
      final g = GameManager(phases: custom);
      final ev = <int?>[];
      g.phaseChanged.addListener(() => ev.add(g.phaseChanged.value));
      g.addScore(2);
      expect(g.currentPhase.value, 1);
      g.addScore(1);
      expect(g.currentPhase.value, 2);
      expect(g.phase.speedMultiplier, 2.0);
      g.addScore(100);
      expect(g.currentPhase.value, 2);
      expect(ev, [2]);
      g.dispose();
    });
  });

  group('dispose', () {
    test('disposes phase notifiers', () {
      final g = GameManager();
      g.dispose();
      expect(() => g.currentPhase.addListener(() {}), throwsFlutterError);
      expect(() => g.phaseChanged.addListener(() {}), throwsFlutterError);
    });
  });
}
