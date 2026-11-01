import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/components/caua_player_component.dart';
import 'package:caua_loves_candies/game/components/item_spawner_component.dart';
import 'package:caua_loves_candies/game/item_sprites.dart';
import 'package:caua_loves_candies/game/managers/caua_reaction_controller.dart';
import 'package:caua_loves_candies/game/managers/caua_reaction_timings.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:caua_loves_candies/game/managers/mouth_state.dart';
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ui.Image baseImage;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final recorder = ui.PictureRecorder();
    ui.Canvas(
      recorder,
    ).drawRect(const ui.Rect.fromLTWH(0, 0, 1, 1), ui.Paint());
    baseImage = await recorder.endRecording().toImage(1, 1);
  });

  CauaCandiesGame buildGame() {
    final game = CauaCandiesGame();
    for (final name in [
      ...CauaPlayerComponent.allSpriteNames,
      ...CauaPlayerComponent.reactionSpriteNames,
      ...itemSpriteAssetList,
    ]) {
      game.images.add(name, baseImage.clone());
    }
    return game;
  }

  void down(CauaCandiesGame g, [int id = 1]) => g.onTapDown(
    TapDownEvent(id, g, TapDownDetails(globalPosition: const Offset(1, 1))),
  );
  void up(CauaCandiesGame g, [int id = 1]) =>
      g.onTapUp(TapUpEvent(id, g, TapUpDetails(kind: PointerDeviceKind.touch)));
  void cancel(CauaCandiesGame g, [int id = 1]) =>
      g.onTapCancel(TapCancelEvent(id));

  void ingest(CauaCandiesGame g, ItemType type) => g.world.children
      .whereType<ItemSpawnerComponent>()
      .single
      .onIngested!(type);

  final sweet = ItemType.ofCategory(ItemCategory.sweet).first;
  final hazard = ItemType.ofCategory(ItemCategory.hazard).first;

  void gameTest(String name, Future<void> Function(CauaCandiesGame) body) =>
      testWithGame<CauaCandiesGame>(name, buildGame, body);

  gameTest('ingesting a sweet chews and closes the mouth', (g) async {
    await g.ready();
    down(g);
    up(g);
    var notifications = 0;
    g.mouthController.state.addListener(() => notifications++);
    ingest(g, sweet);
    expect(g.reactionController.reaction.value, CauaReaction.chew);
    expect(g.mouthController.state.value, MouthState.closed);
    expect(notifications, 1);
  });

  gameTest('ingesting a hazard shows eca', (g) async {
    await g.ready();
    down(g);
    up(g);
    ingest(g, hazard);
    expect(g.reactionController.reaction.value, CauaReaction.eca);
  });

  gameTest('player shows the reaction sprite and returns to idle', (g) async {
    await g.ready();
    final player = g.world.children.whereType<CauaPlayerComponent>().single;
    final idle = player.sprite;
    down(g);
    up(g);
    ingest(g, sweet);
    expect(player.sprite, isNot(same(idle)));
    g.update(kChewTotal + 0.01);
    expect(g.reactionController.reaction.value, CauaReaction.none);
    expect(player.sprite!.image, same(idle!.image));
  });

  gameTest('tap during a reaction cancels it and toggles at once', (g) async {
    await g.ready();
    down(g);
    up(g);
    ingest(g, sweet);
    down(g);
    expect(g.reactionController.reaction.value, CauaReaction.none);
    expect(g.mouthController.state.value, MouthState.open);
  });

  gameTest('held finger: release after eating opens the mouth', (g) async {
    await g.ready();
    down(g);
    ingest(g, sweet);
    expect(g.mouthController.state.value, MouthState.closed);
    up(g);
    expect(g.mouthController.state.value, MouthState.open);
    expect(g.reactionController.reaction.value, CauaReaction.none);
  });

  gameTest('held finger: release also works after the reaction ended', (
    g,
  ) async {
    await g.ready();
    down(g);
    ingest(g, hazard);
    g.update(kEcaHold + 0.1);
    up(g);
    expect(g.mouthController.state.value, MouthState.open);
  });

  gameTest('release without ingestion does not toggle again', (g) async {
    await g.ready();
    down(g);
    up(g);
    expect(g.mouthController.state.value, MouthState.open);
  });

  gameTest('released finger before eating: release stays closed', (g) async {
    await g.ready();
    down(g);
    up(g);
    ingest(g, sweet);
    // A later tap-up of nothing changes nothing.
    up(g);
    expect(g.mouthController.state.value, MouthState.closed);
  });

  gameTest('tap cancel behaves like release only after ingestion', (g) async {
    await g.ready();
    down(g);
    cancel(g);
    expect(g.mouthController.state.value, MouthState.open);
    down(g);
    ingest(g, sweet);
    cancel(g);
    expect(g.mouthController.state.value, MouthState.open);
  });

  gameTest('second finger is ignored', (g) async {
    await g.ready();
    down(g);
    down(g, 2);
    expect(g.mouthController.state.value, MouthState.open);
    ingest(g, sweet);
    up(g, 2);
    expect(g.mouthController.state.value, MouthState.closed);
    up(g);
    expect(g.mouthController.state.value, MouthState.open);
  });

  gameTest('restart clears the reaction and pending release', (g) async {
    await g.ready();
    down(g);
    ingest(g, sweet);
    await g.restart();
    expect(g.reactionController.reaction.value, CauaReaction.none);
    up(g);
    expect(g.mouthController.state.value, MouthState.closed);
  });

  gameTest('game state change clears the reaction', (g) async {
    await g.ready();
    g.update(0.016);
    down(g);
    up(g);
    ingest(g, sweet);
    g.gameManager.state = g.gameManager.state == GameState.playing
        ? GameState.victory
        : GameState.playing;
    g.update(0.016);
    expect(g.reactionController.reaction.value, CauaReaction.none);
  });
}
