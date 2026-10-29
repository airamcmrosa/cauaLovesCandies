import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show Color;

import '../audio/audio_controller.dart';
import 'components/caua_player_component.dart';
import 'components/conveyor_belt_component.dart';
import 'components/food_item_component.dart';
import 'components/item_spawner_component.dart';
import 'item_sprites.dart';
import 'projection.dart';
import 'managers/game_manager.dart';
import 'managers/item_type.dart';
import 'managers/mouth_controller.dart';
import 'screen_shake.dart';

/// Product game: Cauã at the end of the conveyor belt, one global tap toggles
/// his mouth. Runs in a fixed 720x1280 (9:16) virtual resolution.
///
/// The game itself is the [TapCallbacks] target, so a tap anywhere on screen
/// (including the letterbox bars) toggles the mouth. It reacts on tap down
/// for minimal latency.
///
/// Ownership: the game owns the injected [GameManager] and [MouthController]
/// and disposes them in [onRemove]; callers must not dispose them.
class CauaCandiesGame extends FlameGame with TapCallbacks {
  CauaCandiesGame({
    MouthController? mouthController,
    GameManager? gameManager,
    AudioController? audio,
    Random? random,
  }) : _mouthController = mouthController ?? MouthController(),
       _gameManager = gameManager ?? GameManager(),
       _audio = audio,
       _random = random ?? Random(),
       super(
         camera: CameraComponent.withFixedResolution(width: 720, height: 1280),
       );

  static const double virtualWidth = 720;
  static const double virtualHeight = 1280;

  /// Cauã is a square 240x240 (sprite is 512x512), centered horizontally and
  /// drawn BEHIND the belt, which ends at his shoulder line.
  static const double playerSize = Projection.playerSize;

  /// Shoulder line (top of the shirt) as a fraction of the sprite height,
  /// measured on the 512px webp: y~410 / 512 = 0.80. Mouth center is at
  /// y~325 / 512 = 0.635, the shirt base at y~500 / 512 = 0.975 and the
  /// horizontal center at x~255 / 512 = 0.50.
  static const double shoulderFraction = Projection.shoulderFraction;

  /// Center Y of Cauã so his shoulder line sits on the belt end
  /// (`Projection.yHorizon`).
  ///
  /// Derivation: the shoulder is (0.80 - 0.5) * 240 = 72 px below the sprite
  /// center, so centerY = 480 - 72 = 408 (head top ~288, shirt base ~528).
  /// The narrow belt end (165 px wide) covers his lower body. The mouth lands
  /// (0.80 - 0.635) * 240 = ~40 px above the belt end. The decision point is
  /// `yAt(decisionZ)` = 480 + 0.05 * 700 = 515, ~35 px below the belt end, so
  /// ingested items vanish ~75 px under the mouth center (geometric tension:
  /// yAt(0.95) is always below yHorizon).
  static const double playerCenterY = Projection.playerCenterY;

  /// Draw order: Cauã (-20) < belt (-10) < items (0..1000). Cauã is the
  /// lowest layer so the belt covers his body while his head stays free.
  static const int playerPriority = -20;

  final MouthController _mouthController;
  final GameManager _gameManager;
  final AudioController? _audio;
  final Random _random;
  ScreenShake? _shake;
  ItemSpawnerComponent? _spawner;

  /// Mouth state owner, exposed for later tasks (read [MouthController.state]).
  MouthController get mouthController => _mouthController;

  /// Score, HP and phase owner (read by the HUD overlay).
  GameManager get gameManager => _gameManager;

  /// Fully transparent so the sky art behind the game container shows through.
  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    // World is laid out in 0..720 x 0..1280: map world (0,0) to the viewport
    // top-left (the default anchor is the viewport center, which shifted it).
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    await images.loadAll([
      CauaPlayerComponent.closedSpriteName,
      CauaPlayerComponent.openSpriteName,
      ...itemSpriteAssetList,
    ]);
    await world.add(ConveyorBeltComponent(gameManager: _gameManager));
    await world.add(
      CauaPlayerComponent(
        mouthController: _mouthController,
        position: Vector2(virtualWidth / 2, playerCenterY),
        size: Vector2.all(playerSize),
        anchor: Anchor.center,
        priority: playerPriority,
      ),
    );
    final shake = ScreenShake(camera: camera);
    _shake = shake;
    await world.add(shake);
    await _addSpawner();
  }

  Future<void> _addSpawner() async {
    final audio = _audio;
    final spawner = ItemSpawnerComponent(
      gameManager: _gameManager,
      mouthController: _mouthController,
      random: _random,
      spriteFor: buildItemSpriteLookup(images),
      onIngested: audio != null
          ? ingestHook(audio, onHazard: _triggerShake)
          : _hazardShakeOnly,
    );
    _spawner = spawner;
    await world.add(spawner);
  }

  void _triggerShake() => _shake?.trigger();

  void _hazardShakeOnly(ItemType type) {
    if (type.category == ItemCategory.hazard) _triggerShake();
  }

  /// Resets the session: clears items, resets the manager and recreates the
  /// spawner (fresh spawn timer).
  Future<void> restart() async {
    // Safe before onLoad: nothing to clear, onLoad builds the initial state.
    if (_shake == null) {
      _gameManager.reset();
      return;
    }
    _spawner?.removeFromParent();
    world.children.whereType<FoodItemComponent>().toList().forEach(
      (c) => c.removeFromParent(),
    );
    _gameManager.reset();
    await _addSpawner();
  }

  @override
  void onTapDown(TapDownEvent event) {
    _mouthController.toggle();
  }

  @override
  void onRemove() {
    _gameManager.dispose();
    _mouthController.dispose();
    super.onRemove();
  }
}
