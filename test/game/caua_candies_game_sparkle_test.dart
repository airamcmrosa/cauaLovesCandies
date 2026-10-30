import 'dart:ui' as ui;

import 'package:caua_loves_candies/game/caua_candies_game.dart';
import 'package:caua_loves_candies/game/components/caua_player_component.dart';
import 'package:caua_loves_candies/game/components/particle_celebration_component.dart';
import 'package:caua_loves_candies/game/item_sprites.dart';
import 'package:caua_loves_candies/game/projection.dart';
import 'package:caua_loves_candies/game/managers/game_manager.dart';
import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ui.Image baseImage;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      const ui.Rect.fromLTWH(0, 0, 1, 1),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    baseImage = await recorder.endRecording().toImage(1, 1);
  });

  CauaCandiesGame buildGame() {
    final game = CauaCandiesGame();
    for (final name in [
      CauaPlayerComponent.closedSpriteName,
      CauaPlayerComponent.openSpriteName,
      ...itemSpriteAssetList,
    ]) {
      game.images.add(name, baseImage.clone());
    }
    return game;
  }

  void gameTest(String name, Future<void> Function(CauaCandiesGame) body) =>
      testWithGame<CauaCandiesGame>(name, buildGame, body);

  List<ParticleCelebrationComponent> sparkles(CauaCandiesGame g) =>
      g.world.children.whereType<ParticleCelebrationComponent>().toList();

  group('spawnHitSparkle', () {
    for (final type in ItemType.values) {
      final isHazard = type.category == ItemCategory.hazard;
      gameTest(
        '${type.name} (${type.category.name}) '
        '${isHazard ? 'adds no sparkle' : 'adds one hitSparkle at priority 2000'}',
        (game) async {
          await game.ready();
          game.spawnHitSparkle(type);
          await game.ready();
          game.update(0);
          final list = sparkles(game);
          if (isHazard) {
            expect(list, isEmpty);
          } else {
            expect(list, hasLength(1));
            expect(list.single.preset, CelebrationPreset.hitSparkle);
            expect(list.single.priority, 2000);
            expect(CauaCandiesGame.sparklePriority, 2000);
            expect(list.single.origin.x, closeTo(Projection.xMouth, 1e-3));
            expect(list.single.origin.y, closeTo(Projection.yMouth, 1e-3));
            expect(
              list.single.activeCount,
              ParticleCelebrationComponent.hitSparkleCount,
            );
          }
        },
      );
    }
  });

  group('ingest flow through the spawner hook', () {
    // Drives the real spawner -> FoodItemComponent -> hook path and counts
    // sparkles seen against ingested items by category.
    Future<({int sparkles, int hazards, int good, int deflected})> run(
      CauaCandiesGame game, {
      required bool open,
    }) async {
      await game.ready();
      if (open) game.mouthController.toggle();
      var seen = <ParticleCelebrationComponent>{};
      var hazards = 0;
      var good = 0;
      final gm = game.gameManager;
      var lastHp = gm.hp.value;
      var lastScore = gm.score.value;
      for (var i = 0; i < 600 && gm.state == GameState.playing; i++) {
        game.update(0.05);
        await game.ready();
        seen.addAll(sparkles(game));
        if (gm.hp.value < lastHp) hazards++;
        if (gm.score.value > lastScore) good++;
        lastHp = gm.hp.value;
        lastScore = gm.score.value;
        if (gm.level > 1) break;
      }
      return (
        sparkles: seen.length,
        hazards: hazards,
        good: good,
        deflected: 0,
      );
    }

    gameTest('open mouth: one sparkle per sweet/fruit, none for hazards', (
      game,
    ) async {
      final r = await run(game, open: true);
      expect(r.good, greaterThan(0));
      expect(r.sparkles, r.good);
    });

    gameTest('closed mouth: deflections spawn no sparkles', (game) async {
      final r = await run(game, open: false);
      expect(r.good, 0);
      expect(r.hazards, 0);
      expect(r.sparkles, 0);
    });
  });

  group('restart', () {
    gameTest('clears live sparkles', (game) async {
      await game.ready();
      game.spawnHitSparkle(ItemType.donut);
      game.spawnHitSparkle(ItemType.banana);
      await game.ready();
      game.update(0);
      expect(sparkles(game), hasLength(2));
      await game.restart();
      await game.ready();
      game.update(0);
      expect(sparkles(game), isEmpty);
    });

    gameTest('restart removes victory and sparkles together', (game) async {
      await game.ready();
      game.world.add(ParticleCelebrationComponent());
      game.spawnHitSparkle(ItemType.donut);
      await game.ready();
      game.update(0);
      expect(sparkles(game), hasLength(2));
      await game.restart();
      await game.ready();
      game.update(0);
      expect(sparkles(game), isEmpty);
    });

    gameTest('10 victory add + restart cycles leave no leftovers', (
      game,
    ) async {
      await game.ready();
      for (var i = 0; i < 10; i++) {
        game.world.add(ParticleCelebrationComponent());
        await game.ready();
        game.update(0);
        expect(sparkles(game), hasLength(1));
        await game.restart();
        await game.ready();
        game.update(0);
        expect(sparkles(game), isEmpty);
      }
    });
  });
}
