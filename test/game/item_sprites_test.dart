import 'dart:io';

import 'package:caua_loves_candies/audio/audio_controller.dart';
import 'package:caua_loves_candies/audio/sounds.dart';
import 'package:caua_loves_candies/game/item_sprites.dart';
import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAudio extends Fake implements AudioController {
  final List<SfxType> played = [];

  @override
  void playSfx(SfxType type) => played.add(type);
}

void main() {
  group('itemSpriteAssets', () {
    test('has an entry for every ItemType (16 types)', () {
      expect(ItemType.values.length, 16);
      for (final type in ItemType.values) {
        expect(itemSpriteAssets.containsKey(type), isTrue, reason: '$type');
      }
    });

    test('itemSpriteAssetList equals the unique values of the map', () {
      expect(itemSpriteAssetList.toSet(), itemSpriteAssets.values.toSet());
      expect(
        itemSpriteAssetList.length,
        itemSpriteAssetList.toSet().length,
        reason: 'no duplicates',
      );
      expect(itemSpriteAssetList.length, 9);
    });

    test('every listed asset exists on disk under assets/images/', () {
      for (final key in itemSpriteAssetList) {
        expect(File('assets/images/$key').existsSync(), isTrue, reason: key);
      }
    });

    test('hazards only reuse hazard art', () {
      for (final type in ItemType.values.where(
        (t) => t.category == ItemCategory.hazard,
      )) {
        expect(itemSpriteAssets[type], startsWith('items/bad_'));
      }
    });
  });

  group('sfxForItem', () {
    for (final type in ItemType.values) {
      test('${type.name} maps by category', () {
        final expected = switch (type.category) {
          ItemCategory.sweet => SfxType.score,
          ItemCategory.fruit => SfxType.fruit,
          ItemCategory.hazard => SfxType.damage,
        };
        expect(sfxForItem(type), expected);
      });
    }
  });

  group('ingestHook', () {
    test('plays one SFX per item and fires onHazard for hazards only', () {
      for (final type in ItemType.values) {
        final audio = _RecordingAudio();
        var hazards = 0;
        ingestHook(audio, onHazard: () => hazards++)(type);
        expect(audio.played, [sfxForItem(type)], reason: type.name);
        expect(
          hazards,
          type.category == ItemCategory.hazard ? 1 : 0,
          reason: type.name,
        );
      }
    });

    test('works without an onHazard callback', () {
      final audio = _RecordingAudio();
      ingestHook(audio)(ItemType.soap);
      expect(audio.played, [SfxType.damage]);
    });
  });
}
