import 'package:caua_loves_candies/game/managers/caua_reaction_controller.dart';
import 'package:caua_loves_candies/game/managers/caua_reaction_timings.dart';
import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CauaReactionController c;
  setUp(() => c = CauaReactionController());
  tearDown(() => c.dispose());

  test('timings are derived from the single source of truth', () {
    expect(kChewTotal, closeTo(0.60, 1e-9));
    expect(kEcaHold, 0.60);
    expect(kMinArrivalGap, closeTo(0.80, 1e-9));
  });

  test('starts idle', () {
    expect(c.reaction.value, CauaReaction.none);
    expect(c.isActive, isFalse);
  });

  test('chew emits steps 0, 1, 2 in order and ends at kChewTotal', () {
    c.start(ItemCategory.sweet);
    final steps = <int>[c.step.value];
    c.step.addListener(() => steps.add(c.step.value));
    expect(c.reaction.value, CauaReaction.chew);
    c.tick(kChewStep + 0.001);
    expect(c.step.value, 1);
    c.tick(kChewStep);
    expect(c.step.value, 2);
    c.tick(kChewTotal - kChewStep * 2 - 0.001 - 0.01);
    expect(c.reaction.value, CauaReaction.chew);
    c.tick(0.02);
    expect(c.reaction.value, CauaReaction.none);
    expect(steps.take(3), [0, 1, 2]);
  });

  test('fruit also chews; a long dt never skips a step', () {
    c.start(ItemCategory.fruit);
    final steps = <int>[];
    c.step.addListener(() => steps.add(c.step.value));
    c.tick(kChewStep * 2 + 0.01);
    expect(steps, [1, 2]);
    expect(c.reaction.value, CauaReaction.chew);
    c.tick(10);
    expect(c.reaction.value, CauaReaction.none);
  });

  test('eca holds for kEcaHold then returns to none', () {
    c.start(ItemCategory.hazard);
    expect(c.reaction.value, CauaReaction.eca);
    c.tick(kEcaHold - 0.01);
    expect(c.reaction.value, CauaReaction.eca);
    c.tick(0.02);
    expect(c.reaction.value, CauaReaction.none);
  });

  test('cancel and reset clear the reaction', () {
    c.start(ItemCategory.hazard);
    c.cancel();
    expect(c.reaction.value, CauaReaction.none);
    c.start(ItemCategory.sweet);
    c.tick(kChewStep * 2.5);
    c.reset();
    expect(c.reaction.value, CauaReaction.none);
    expect(c.step.value, 0);
  });

  test('tick is a no-op when idle or dt <= 0', () {
    c.tick(5);
    c.tick(-1);
    expect(c.reaction.value, CauaReaction.none);
    c.start(ItemCategory.sweet);
    c.tick(0);
    expect(c.step.value, 0);
  });

  test('restarting mid-chew starts from step 0', () {
    c.start(ItemCategory.sweet);
    c.tick(kChewStep * 2.2);
    c.start(ItemCategory.sweet);
    expect(c.step.value, 0);
  });
}
