import 'package:flame/components.dart';

import '../managers/mouth_controller.dart';
import '../managers/mouth_state.dart';

/// Renders Cauã and swaps between the closed and open mouth sprites whenever
/// [MouthController.state] changes. It owns no game rules, only the visual.
class CauaPlayerComponent extends SpriteComponent with HasGameReference {
  CauaPlayerComponent({
    required MouthController mouthController,
    super.position,
    super.size,
    super.anchor,
    super.priority,
  }) : _mouthController = mouthController;

  /// Expected file names inside the game's images cache.
  static const String closedSpriteName = 'caua_mouth_closed.webp';
  static const String openSpriteName = 'caua_mouth_open.webp';

  final MouthController _mouthController;

  late final Sprite _closedSprite;
  late final Sprite _openSprite;

  @override
  Future<void> onLoad() async {
    _closedSprite = Sprite(game.images.fromCache(closedSpriteName));
    _openSprite = Sprite(game.images.fromCache(openSpriteName));
    sprite = _spriteFor(_mouthController.state.value);
  }

  @override
  void onMount() {
    super.onMount();
    _mouthController.state.addListener(_onMouthChanged);
    // Resync in case the state changed before mounting.
    sprite = _spriteFor(_mouthController.state.value);
  }

  @override
  void onRemove() {
    _mouthController.state.removeListener(_onMouthChanged);
    super.onRemove();
  }

  void _onMouthChanged() {
    sprite = _spriteFor(_mouthController.state.value);
  }

  Sprite _spriteFor(MouthState state) => switch (state) {
    MouthState.closed => _closedSprite,
    MouthState.open => _openSprite,
  };
}
