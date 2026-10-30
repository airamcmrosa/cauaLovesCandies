import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/components/conveyor_belt_component.dart';
import 'package:caua_loves_candies/game/components/food_item_component.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:caua_loves_candies/game/managers/mouth_controller.dart';
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

  test('item on the belt takes the new multiplier with no z jump', () async {
    final gm = GameManager()..dismissTutorial();
    final mouth = MouthController();
    final game = FlameGame();
    addTearDown(() {
      gm.dispose();
      mouth.dispose();
    });
    final item = FoodItemComponent(
      type: ItemType.values.first,
      gameManager: gm,
      mouthController: mouth,
      sprite: sprite,
    );
    await game.ensureAdd(item);

    const dt = 0.1;
    item.update(dt);
    final z1 = item.z;
    expect(z1, closeTo(ConveyorBeltComponent.baseSpeed * 1.2 * dt, 1e-9));

    gm.addScore(10); // phase 2 -> 1.44
    item.update(dt);
    final z2 = item.z;
    expect(z2 - z1, closeTo(ConveyorBeltComponent.baseSpeed * 1.44 * dt, 1e-9));

    gm.addScore(10); // phase 3 -> 1.728
    item.update(dt);
    expect(
      item.z - z2,
      closeTo(ConveyorBeltComponent.baseSpeed * 1.728 * dt, 1e-9),
    );
  });
}
