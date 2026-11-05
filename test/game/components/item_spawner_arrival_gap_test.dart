import 'dart:math';
import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/components/food_item_component.dart';
import 'package:caua_loves_candies/game/components/item_spawner_component.dart';
import 'package:caua_loves_candies/game/managers/caua_reaction_timings.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/mouth_controller.dart';
import 'package:caua_loves_candies/game/managers/phase_config.dart';
import 'package:caua_loves_candies/game/projection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Sprite sprite;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawRect(const ui.Rect.fromLTWH(0, 0, 2, 2), ui.Paint());
    sprite = Sprite(await recorder.endRecording().toImage(2, 2));
  });

  /// Runs a fixed-dt simulation and returns decision times of every item.
  Future<List<double>> simulate(
    FlameGame game, {
    required int startPhase,
    int? switchToPhaseAt,
    required double dt,
    double seconds = 60,
  }) async {
    final gm = GameManager()..dismissTutorial();
    gm.level = startPhase;
    final mouth = MouthController();
    final spawner = ItemSpawnerComponent(
      gameManager: gm,
      mouthController: mouth,
      random: Random(3),
      spriteFor: (_) => sprite,
    );
    await game.world.ensureAdd(spawner);
    final seen = <FoodItemComponent>{};
    final arrivals = <double>[];
    var t = 0.0;
    var switched = false;
    while (t < seconds) {
      if (!switched && switchToPhaseAt != null && t >= 20) {
        gm.level = switchToPhaseAt;
        switched = true;
      }
      // Drive components explicitly (as the sibling spawner tests do).
      spawner.update(dt);
      for (final item in game.world.children.whereType<FoodItemComponent>()) {
        item.update(dt);
      }
      game.update(0);
      await game.ready();
      t += dt;
      for (final item
          in game.world.children.whereType<FoodItemComponent>().toList()) {
        if (item.outcome != ItemOutcome.undecided && seen.add(item)) {
          arrivals.add(t);
        }
      }
    }
    gm.dispose();
    mouth.dispose();
    return arrivals;
  }

  void expectGaps(List<double> arrivals, double dt) {
    expect(arrivals.length, greaterThan(10));
    for (var i = 1; i < arrivals.length; i++) {
      expect(
        arrivals[i] - arrivals[i - 1],
        greaterThanOrEqualTo(kMinArrivalGap - 1e-9),
        reason: 'pair $i dt=$dt',
      );
    }
  }

  for (final phase in [1, 2, 3]) {
    for (final dt in [1 / 60, 1 / 30]) {
      testWithGame<FlameGame>(
        'phase $phase dt=$dt keeps arrivals >= kMinArrivalGap',
        FlameGame.new,
        (game) async =>
            expectGaps(await simulate(game, startPhase: phase, dt: dt), dt),
      );
    }
  }

  testWithGame<FlameGame>(
    'forced phase change 1 -> 3 keeps arrivals >= kMinArrivalGap',
    FlameGame.new,
    (game) async => expectGaps(
      await simulate(game, startPhase: 1, switchToPhaseAt: 3, dt: 1 / 60),
      1 / 60,
    ),
  );

  test('spawn spacing covers the fastest phase plus margin', () {
    expect(
      ItemSpawnerComponent.spawnIntervalSeconds / kPhases.last.speedMultiplier,
      greaterThanOrEqualTo(kMinArrivalGap + kArrivalGapMargin - 1e-9),
    );
  });
}
