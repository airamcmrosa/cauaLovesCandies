import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameManager gm;

  setUp(() => gm = GameManager());
  tearDown(() => gm.dispose());

  test('currentSpeedMultiplier tracks the phase (1.2, 1.44, 1.728)', () {
    expect(gm.currentSpeedMultiplier, closeTo(1.2, 1e-9));
    gm.addScore(10);
    expect(gm.currentSpeedMultiplier, closeTo(1.44, 1e-9));
    gm.addScore(10);
    expect(gm.currentSpeedMultiplier, closeTo(1.728, 1e-9));
  });

  test('stays at phase 1 value just below the first threshold', () {
    gm.addScore(9);
    expect(gm.currentSpeedMultiplier, closeTo(1.2, 1e-9));
  });

  test('reset returns the multiplier to the phase 1 value', () {
    gm.addScore(20);
    gm.reset();
    expect(gm.currentSpeedMultiplier, closeTo(1.2, 1e-9));
  });
}
