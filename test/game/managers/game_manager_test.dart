import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameManager gm;
  late int scoreNotes;
  late int hpNotes;

  setUp(() {
    gm = GameManager();
    scoreNotes = 0;
    hpNotes = 0;
    gm.score.addListener(() => scoreNotes++);
    gm.hp.addListener(() => hpNotes++);
  });

  group('initial state', () {
    test('score 0, hp maxHp (3), level 1, tutorial', () {
      expect(gm.score.value, 0);
      expect(gm.hp.value, GameManager.maxHp);
      expect(GameManager.maxHp, 3);
      expect(gm.level, 1);
      expect(gm.state, GameState.tutorial);
    });
  });

  group('dismissTutorial', () {
    test('moves tutorial to playing', () {
      gm.dismissTutorial();
      expect(gm.state, GameState.playing);
    });

    test('second call is a no-op', () {
      gm.dismissTutorial();
      gm.dismissTutorial();
      expect(gm.state, GameState.playing);
    });

    test('does not touch score, hp or level', () {
      gm.dismissTutorial();
      expect(gm.score.value, 0);
      expect(gm.hp.value, GameManager.maxHp);
      expect(gm.level, 1);
      expect(scoreNotes, 0);
      expect(hpNotes, 0);
    });
  });

  group('addScore', () {
    test('accumulates and notifies once per call', () {
      gm.addScore(2);
      gm.addScore(1);
      expect(gm.score.value, 3);
      expect(scoreNotes, 2);
    });

    test('zero and negative are ignored without notification', () {
      gm.addScore(0);
      gm.addScore(-5);
      expect(gm.score.value, 0);
      expect(scoreNotes, 0);
    });
  });

  group('onIngested', () {
    test('sweet gives +2 and keeps hp', () {
      gm.onIngested(ItemType.lollipop);
      expect(gm.score.value, 2);
      expect(gm.hp.value, 3);
      expect(scoreNotes, 1);
      expect(hpNotes, 0);
    });

    test('fruit gives +1 and keeps hp', () {
      gm.onIngested(ItemType.strawberry);
      expect(gm.score.value, 1);
      expect(gm.hp.value, 3);
    });

    test('hazard costs 1 hp and leaves score unchanged', () {
      gm.onIngested(ItemType.broccoli);
      expect(gm.hp.value, 2);
      expect(gm.score.value, 0);
      expect(hpNotes, 1);
      expect(scoreNotes, 0);
    });

    for (final item in ItemType.values) {
      test('${item.name} applies its catalog effect', () {
        gm.onIngested(item);
        expect(gm.score.value, item.points);
        expect(gm.hp.value, GameManager.maxHp + item.hpDelta);
        expect(scoreNotes, item.points > 0 ? 1 : 0);
        expect(hpNotes, item.hpDelta < 0 ? 1 : 0);
      });
    }
  });

  group('loseHp', () {
    test('never goes below 0 and does not notify at 0', () {
      for (var i = 0; i < 3; i++) {
        gm.loseHp();
      }
      expect(gm.hp.value, 0);
      expect(hpNotes, 3);
      gm.loseHp();
      gm.onIngested(ItemType.onion);
      expect(gm.hp.value, 0);
      expect(hpNotes, 3);
    });
  });

  group('reset', () {
    test('restores score, hp, level, state and notifies changed ones', () {
      gm.addScore(5);
      gm.loseHp();
      gm.level = 2;
      scoreNotes = 0;
      hpNotes = 0;
      gm.reset();
      expect(gm.score.value, 0);
      expect(gm.hp.value, 3);
      expect(gm.level, 1);
      expect(gm.state, GameState.playing);
      expect(scoreNotes, 1);
      expect(hpNotes, 1);
    });

    test('returns to playing from tutorial and after dismiss', () {
      gm.reset();
      expect(gm.state, GameState.playing);
      gm.dismissTutorial();
      gm.reset();
      expect(gm.state, GameState.playing);
    });

    test('does not notify unchanged notifiers', () {
      gm.addScore(4);
      scoreNotes = 0;
      hpNotes = 0;
      gm.reset();
      expect(scoreNotes, 1);
      expect(hpNotes, 0);
    });
  });

  group('phase', () {
    test('returns kPhases[level - 1]', () {
      for (var level = 1; level <= kPhases.length; level++) {
        gm.level = level;
        expect(gm.phase, same(kPhases[level - 1]));
      }
    });
  });

  group('dispose', () {
    test('does not throw and disposes notifiers', () {
      final other = GameManager();
      expect(other.dispose, returnsNormally);
      expect(() => other.score.addListener(() {}), throwsFlutterError);
      expect(() => other.hp.addListener(() {}), throwsFlutterError);
    });
  });

  group('timeScale', () {
    test('equals kTutorialTimeScale during the tutorial', () {
      final m = GameManager();
      addTearDown(m.dispose);
      expect(m.state, GameState.tutorial);
      expect(m.timeScale, kTutorialTimeScale);
      expect(m.timeScale, 0.0);
    });

    test('is 1.0 once playing', () {
      final m = GameManager()..dismissTutorial();
      addTearDown(m.dispose);
      expect(m.timeScale, 1.0);
    });

    test('is 1.0 after reset', () {
      final m = GameManager()..reset();
      addTearDown(m.dispose);
      expect(m.timeScale, 1.0);
    });

    test('is 0 in victory so the belt and items freeze', () {
      final m = GameManager()..dismissTutorial();
      addTearDown(m.dispose);
      m.addScore(kPhases.last.targetScore);
      expect(m.state, GameState.victory);
      expect(m.timeScale, 0.0);
    });
  });
}
