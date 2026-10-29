/// Item sprite and SFX manifest (TASK-003 T7). Single place for the
/// ItemType -> asset and ItemType -> SfxType mappings.
library;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import 'components/food_item_component.dart';
import 'components/item_spawner_component.dart';
import 'managers/item_type.dart';

/// Asset keys relative to `assets/images/` (the Flame `Images` prefix).
///
/// Only 9 art files exist for 16 item types, so types without dedicated art
/// reuse the nearest sprite of the same category (hazards stay hazards).
const Map<ItemType, String> itemSpriteAssets = {
  // Sweets.
  ItemType.lollipop: 'items/lollipop.webp',
  ItemType.donut: 'items/candy_cupcake.webp',
  ItemType.sprinkles: 'items/candy_cupcake.webp',
  ItemType.candy: 'items/candy_wrapped.webp',
  ItemType.cupcake: 'items/candy_cupcake.webp',
  ItemType.cottonCandy: 'items/candy_cotton.webp',
  ItemType.gum: 'items/candy_wrapped.webp',
  // Fruits.
  ItemType.strawberry: 'items/fruit_strawberry.webp',
  ItemType.banana: 'items/fruit_grape.webp',
  ItemType.watermelon: 'items/fruit_strawberry.webp',
  ItemType.grape: 'items/fruit_grape.webp',
  ItemType.orange: 'items/fruit_strawberry.webp',
  // Hazards.
  ItemType.broccoli: 'items/bad_onion.webp',
  ItemType.soap: 'items/bad_soap.webp',
  ItemType.dirtySock: 'items/bad_sock.webp',
  ItemType.onion: 'items/bad_onion.webp',
};

/// The 9 unique asset keys, for preloading (`images.loadAll`).
const List<String> itemSpriteAssetList = [
  'items/bad_onion.webp',
  'items/bad_soap.webp',
  'items/bad_sock.webp',
  'items/candy_cotton.webp',
  'items/candy_cupcake.webp',
  'items/candy_wrapped.webp',
  'items/fruit_grape.webp',
  'items/fruit_strawberry.webp',
  'items/lollipop.webp',
];

/// Builds an [ItemSpriteLookup] from a preloaded [Images] cache. The images
/// must already be loaded; sprites are created once and cached.
ItemSpriteLookup buildItemSpriteLookup(Images images) {
  final cache = <ItemType, Sprite>{
    for (final type in ItemType.values)
      type: Sprite(images.fromCache(itemSpriteAssets[type]!)),
  };
  return (type) => cache[type]!;
}

/// Product-owner reaction per category: "hmm" for good food (sweet, fruit),
/// "eurk" for hazards. The score/fruit/damage SfxTypes stay defined but are
/// no longer used on ingest.
SfxType sfxForItem(ItemType type) => switch (type.category) {
  ItemCategory.sweet || ItemCategory.fruit => SfxType.hmm,
  ItemCategory.hazard => SfxType.eurk,
};

/// Builds a `FoodItemComponent.onIngested` hook that plays the item SFX via
/// [AudioController.playSfx] (which already honors mute/sounds settings) and
/// optionally runs [onHazard] (e.g. `ScreenShake.trigger`) for hazards.
FoodItemCallback ingestHook(
  AudioController audio, {
  void Function()? onHazard,
}) {
  return (type) {
    audio.playSfx(sfxForItem(type));
    if (type.category == ItemCategory.hazard) onHazard?.call();
  };
}
