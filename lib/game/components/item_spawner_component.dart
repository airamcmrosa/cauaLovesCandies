import 'dart:math';

import 'package:flame/components.dart';

import '../managers/game_manager.dart';
import '../managers/item_type.dart';
import '../managers/mouth_controller.dart';
import '../managers/phase_config.dart';
import 'food_item_component.dart';

/// Resolves the sprite for an item type (mapping lives in T7/T9).
typedef ItemSpriteLookup = Sprite Function(ItemType type);

/// Picks a category by the phase weights, then a uniform type within it.
///
/// Pure and deterministic for a seeded [random].
ItemType pickItemType(Random random, PhaseConfig phase) {
  final weights = phase.weights;
  var roll = random.nextInt(weights.total);
  var category = ItemCategory.hazard;
  for (final candidate in ItemCategory.values) {
    final weight = weights.of(candidate);
    if (roll < weight) {
      category = candidate;
      break;
    }
    roll -= weight;
  }
  final types = _typesByCategory[category]!;
  return types[random.nextInt(types.length)];
}

// Built once; every category has at least one type in the catalog.
final Map<ItemCategory, List<ItemType>> _typesByCategory = {
  for (final c in ItemCategory.values) c: ItemType.ofCategory(c),
};

/// Spawns [FoodItemComponent]s at z = 0 on a fixed interval while playing.
///
/// Items remove themselves when ingested, deflected or past z > 1, so no
/// pooling is needed. Not owned score/HP logic: it only reads the manager.
class ItemSpawnerComponent extends Component {
  ItemSpawnerComponent({
    required GameManager gameManager,
    required MouthController mouthController,
    required Random random,
    required ItemSpriteLookup spriteFor,
    this.onIngested,
    this.onDeflected,
  }) : _gameManager = gameManager,
       _mouthController = mouthController,
       _random = random,
       _spriteFor = spriteFor;

  /// Seconds between spawns at Phase 1 speed (single place to tune).
  static const double spawnIntervalSeconds = 1.4;

  final GameManager _gameManager;
  final MouthController _mouthController;
  final Random _random;
  final ItemSpriteLookup _spriteFor;
  final FoodItemCallback? onIngested;
  final FoodItemCallback? onDeflected;

  double _elapsed = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (_gameManager.state != GameState.playing) return;
    // Keep the gap in belt distance constant across phases.
    _elapsed += dt * _gameManager.currentSpeedMultiplier;
    if (_elapsed < spawnIntervalSeconds) return;
    _elapsed -= spawnIntervalSeconds;
    _spawn();
  }

  void _spawn() {
    final type = pickItemType(_random, _gameManager.phase);
    parent?.add(
      FoodItemComponent(
        type: type,
        gameManager: _gameManager,
        mouthController: _mouthController,
        sprite: _spriteFor(type),
        onIngested: onIngested,
        onDeflected: onDeflected,
        deflectRight: _random.nextBool(),
      ),
    );
  }
}
