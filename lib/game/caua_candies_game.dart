import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show Color;

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import 'components/caua_player_component.dart';
import 'components/conveyor_belt_component.dart';
import 'components/food_item_component.dart';
import 'components/item_spawner_component.dart';
import 'components/particle_celebration_component.dart';
import 'item_sprites.dart';
import 'projection.dart';
import 'managers/blink_controller.dart';
import 'managers/caua_reaction_controller.dart';
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
/// and the [BlinkController] it creates and disposes them in [onRemove]; callers must not dispose them.
class CauaCandiesGame extends FlameGame with TapCallbacks {
  CauaCandiesGame({
    MouthController? mouthController,
    GameManager? gameManager,
    AudioController? audio,
    Random? random,
  }) : _mouthController = mouthController ?? MouthController(),
       _gameManager = gameManager ?? GameManager(),
       _blinkController = BlinkController(random: random),
       _reactionController = CauaReactionController(),
       _audio = audio,
       _random = random ?? Random(),
       super(
         camera: CameraComponent.withFixedResolution(width: 720, height: 1280),
       );

  /// Overlay keys registered by the host screen.
  static const String hudOverlayKey = 'hud';
  static const String phaseBannerOverlayKey = 'phaseBanner';
  static const String tutorialOverlayKey = 'tutorial';
  static const String victoryOverlayKey = 'victory';
  static const String gameOverOverlayKey = 'gameOver';

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
  final BlinkController _blinkController;
  final CauaReactionController _reactionController;
  final AudioController? _audio;
  final Random _random;
  CauaPlayerComponent? _player;

  // Pointer that owns the current touch (extra fingers are ignored).
  int? _activePointerId;

  // True when ingestion closed the mouth while the finger was still down:
  // the release then opens it again (TASK-011 release-after-eating rule).
  bool _releaseOpensMouth = false;
  GameState? _lastState;
  ScreenShake? _shake;
  ItemSpawnerComponent? _spawner;

  /// Mouth state owner, exposed for later tasks (read [MouthController.state]).
  MouthController get mouthController => _mouthController;

  /// Chew / eca reaction owner, exposed for tests.
  CauaReactionController get reactionController => _reactionController;

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
      ...CauaPlayerComponent.allSpriteNames,
      ...CauaPlayerComponent.reactionSpriteNames,
      ...itemSpriteAssetList,
    ]);
    await world.add(ConveyorBeltComponent(gameManager: _gameManager));
    final player = CauaPlayerComponent(
      mouthController: _mouthController,
      blinkController: _blinkController,
      reactionController: _reactionController,
      position: Vector2(virtualWidth / 2, playerCenterY),
      size: Vector2.all(playerSize),
      anchor: Anchor.center,
      priority: playerPriority,
    );
    _player = player;
    await world.add(player);
    final shake = ScreenShake(camera: camera);
    _shake = shake;
    await world.add(shake);
    await _addSpawner();
    _gameManager.stateNotifier.addListener(_onGameStateChanged);
  }

  /// Draw priority of the victory confetti: above everything in the world.
  static const int victoryPriority = 3000;

  /// Reacts to end states exactly once per transition (the notifier only
  /// fires on a change): victory adds confetti, plays the jingle and shows
  /// the victory card; lost shows the game-over card; playing hides both.
  void _onGameStateChanged() {
    switch (_gameManager.state) {
      case GameState.victory:
        world.add(
          ParticleCelebrationComponent(
            random: _random,
            origin: Vector2(Projection.xMouth, Projection.yMouth),
            priority: victoryPriority,
          ),
        );
        _audio?.playSfx(SfxType.victory);
        overlays.add(victoryOverlayKey);
      case GameState.lost:
        overlays.add(gameOverOverlayKey);
      case GameState.playing:
      case GameState.tutorial:
        overlays
          ..remove(victoryOverlayKey)
          ..remove(gameOverOverlayKey);
    }
  }

  Future<void> _addSpawner() async {
    final audio = _audio;
    final FoodItemCallback baseHook = audio != null
        ? ingestHook(audio, onHazard: _triggerShake)
        : _hazardShakeOnly;
    final spawner = ItemSpawnerComponent(
      gameManager: _gameManager,
      mouthController: _mouthController,
      random: _random,
      spriteFor: buildItemSpriteLookup(images),
      onIngested: (type) {
        baseHook(type);
        spawnHitSparkle(type);
        _reactToIngestion(type);
      },
    );
    _spawner = spawner;
    await world.add(spawner);
  }

  /// Ingestion outcome: Cauã reacts and his mouth closes (the chewing face
  /// has a closed mouth). A finger still down opens it again on release.
  void _reactToIngestion(ItemType type) {
    _reactionController.start(type.category);
    _mouthController.close();
    _releaseOpensMouth = _activePointerId != null;
  }

  void _triggerShake() => _shake?.trigger();

  /// Draw priority of sparkles: above items (0..1000), Cauã and the belt.
  static const int sparklePriority = 2000;

  /// Spawns a [CelebrationPreset.hitSparkle] at Cauã's mouth for sweets and
  /// fruits. Hazards spawn nothing.
  void spawnHitSparkle(ItemType type) {
    if (type.category == ItemCategory.hazard) return;
    world.add(
      ParticleCelebrationComponent(
        preset: CelebrationPreset.hitSparkle,
        random: _random,
        origin: Vector2(Projection.xMouth, Projection.yMouth),
        priority: sparklePriority,
      ),
    );
  }

  void _hazardShakeOnly(ItemType type) {
    if (type.category == ItemCategory.hazard) _triggerShake();
  }

  /// Resets the session: clears items, resets the manager and recreates the
  /// spawner (fresh spawn timer).
  Future<void> restart() async {
    // Reset returns to playing: never leave a stale tutorial overlay behind.
    overlays
      ..remove(tutorialOverlayKey)
      ..remove(victoryOverlayKey)
      ..remove(gameOverOverlayKey);
    _audio?.stopSfx();
    _mouthController.reset();
    _blinkController.reset();
    _reactionController.reset();
    _releaseOpensMouth = false;
    // Safe before onLoad: nothing to clear, onLoad builds the initial state.
    if (_shake == null) {
      _gameManager.reset();
      return;
    }
    _spawner?.removeFromParent();
    world.children.whereType<FoodItemComponent>().toList().forEach(
      (c) => c.removeFromParent(),
    );
    world.children.whereType<ParticleCelebrationComponent>().toList().forEach(
      (c) => c.removeFromParent(),
    );
    _gameManager.reset();
    await _addSpawner();
  }

  @override
  void update(double dt) {
    // Blink only while playing (no allocation: plain field comparison).
    final state = _gameManager.state;
    // Caua blinks in every state except game over (no sleepy eyes on the
    // "Tente de Novo!" card).
    _player?.blinkEnabled = state != GameState.lost;
    // Any game-state change (tutorial, victory, lost, ...) clears the reaction.
    if (state != _lastState) {
      _lastState = state;
      _reactionController.cancel();
      _releaseOpensMouth = false;
    }
    _reactionController.tick(dt);
    super.update(dt);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Input is paused while an end-state card is shown.
    final state = _gameManager.state;
    if (state == GameState.victory || state == GameState.lost) return;
    // Extra simultaneous touches (a different pointer) are ignored. A repeat
    // down from the owner pointer (its up was lost) is a normal tap.
    final active = _activePointerId;
    if (active != null && active != event.pointerId) return;
    _activePointerId = event.pointerId;
    _releaseOpensMouth = false;
    // Input always wins: cancel any reaction and toggle in the same frame.
    _reactionController.cancel();
    _mouthController.toggle();
  }

  @override
  void onTapUp(TapUpEvent event) => _release(event.pointerId);

  @override
  void onTapCancel(TapCancelEvent event) => _release(event.pointerId);

  void _release(int pointerId) {
    if (pointerId != _activePointerId) return;
    _activePointerId = null;
    if (!_releaseOpensMouth) return;
    _releaseOpensMouth = false;
    _reactionController.cancel();
    _mouthController.open();
  }

  @override
  void onRemove() {
    _gameManager.stateNotifier.removeListener(_onGameStateChanged);
    _gameManager.dispose();
    _mouthController.dispose();
    super.onRemove();
    // Children (and their listeners) are gone after super; the game owns
    // the blink controller and disposes it last.
    _blinkController.dispose();
    _reactionController.dispose();
  }
}
