import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameManager gm;
  late List<bool> signals;

  void attach() {
    signals = [];
    gm.finalTargetReached.addListener(
      () => signals.add(gm.finalTargetReached.value),
    );
  }

  setUp(() {
    gm = GameManager();
    attach();
  });

  tearDown(() => gm.dispose());

  test('starts playing with no final target signal', () {
    expect(gm.state, GameState.playing);
    expect(gm.finalTargetReached.value, isFalse);
  });

  test('score 29 stays playing without signal', () {
    gm.addScore(29);
    expect(gm.state, GameState.playing);
    expect(gm.finalTargetReached.value, isFalse);
    expect(signals, isEmpty);
    expect(gm.currentPhase.value, 3);
  });

  test('score 30 enters victory with exactly one signal', () {
    gm.addScore(29);
    gm.addScore(1);
    expect(gm.state, GameState.victory);
    expect(gm.finalTargetReached.value, isTrue);
    expect(signals, [true]);
  });

  test('further addScore after victory does not re-fire', () {
    gm.addScore(30);
    gm.addScore(2);
    gm.addScore(5);
    expect(signals, [true]);
    expect(gm.state, GameState.victory);
    expect(gm.currentPhase.value, 3);
  });

  test('jump 0 to 35 reaches phase 3 and victory with one signal', () {
    final phases = <int?>[];
    gm.phaseChanged.addListener(() => phases.add(gm.phaseChanged.value));
    gm.addScore(35);
    expect(gm.currentPhase.value, 3);
    expect(phases, [2, 3]);
    expect(gm.state, GameState.victory);
    expect(signals, [true]);
  });

  test('phase never exceeds phases.length', () {
    gm.addScore(500);
    expect(gm.currentPhase.value, kPhases.length);
    expect(gm.phase, same(kPhases.last));
    gm.addScore(100);
    expect(gm.currentPhase.value, kPhases.length);
  });

  test('reset clears signal and state without firing', () {
    gm.addScore(30);
    signals.clear();
    gm.reset();
    expect(gm.finalTargetReached.value, isFalse);
    expect(gm.state, GameState.playing);
    expect(gm.currentPhase.value, 1);
    expect(gm.score.value, 0);
    // Listener ran for the true -> false change; no true signal is emitted.
    expect(signals.contains(true), isFalse);
  });

  test('victory can be reached again after reset', () {
    gm.addScore(30);
    gm.reset();
    signals.clear();
    gm.addScore(30);
    expect(gm.state, GameState.victory);
    expect(signals, [true]);
  });

  test('injected 2-phase config reaches victory at its last target', () {
    gm.dispose();
    gm = GameManager(
      phases: [
        for (final t in [4, 7])
          PhaseConfig(
            speedMultiplier: 1.0,
            targetScore: t,
            weights: kPhases.first.weights,
          ),
      ],
    );
    attach();
    gm.addScore(6);
    expect(gm.state, GameState.playing);
    expect(gm.currentPhase.value, 2);
    expect(signals, isEmpty);
    gm.addScore(1);
    expect(gm.state, GameState.victory);
    expect(gm.currentPhase.value, 2);
    expect(signals, [true]);
  });
}
