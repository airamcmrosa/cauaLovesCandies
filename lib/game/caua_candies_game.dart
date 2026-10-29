import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show Color;

import 'components/caua_player_component.dart';
import 'managers/mouth_controller.dart';

/// Product game: Cauã at the end of the conveyor belt, one global tap toggles
/// his mouth. Runs in a fixed 720x1280 (9:16) virtual resolution.
///
/// The game itself is the [TapCallbacks] target, so a tap anywhere on screen
/// (including the letterbox bars) toggles the mouth. It reacts on tap down
/// for minimal latency.
class CauaCandiesGame extends FlameGame with TapCallbacks {
  CauaCandiesGame({MouthController? mouthController})
    : _mouthController = mouthController ?? MouthController(),
      super(
        camera: CameraComponent.withFixedResolution(width: 720, height: 1280),
      );

  static const double virtualWidth = 720;
  static const double virtualHeight = 1280;

  /// Cauã is a square 480x480 (sprite is 512x512), centered horizontally and
  /// placed in the lower-middle area (horizon head position) of the 9:16 space.
  static const double playerSize = 480;
  static const double playerCenterY = 800;

  final MouthController _mouthController;

  /// Mouth state owner, exposed for later tasks (read [MouthController.state]).
  MouthController get mouthController => _mouthController;

  /// Candy Pastel `bg-cream` (#FFF5E6), the base game background.
  @override
  Color backgroundColor() => const Color(0xFFFFF5E6);

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      CauaPlayerComponent.closedSpriteName,
      CauaPlayerComponent.openSpriteName,
    ]);
    world.add(
      CauaPlayerComponent(
        mouthController: _mouthController,
        position: Vector2(virtualWidth / 2, playerCenterY),
        size: Vector2.all(playerSize),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _mouthController.toggle();
  }

  @override
  void onRemove() {
    _mouthController.dispose();
    super.onRemove();
  }
}
