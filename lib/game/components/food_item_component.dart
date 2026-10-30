import 'package:flame/components.dart';

import '../managers/game_manager.dart';
import '../managers/item_type.dart';
import '../managers/mouth_controller.dart';
import '../projection.dart';
import 'conveyor_belt_component.dart';

/// Called with the item type when an item is ingested or deflected.
typedef FoodItemCallback = void Function(ItemType type);

/// A single item riding the conveyor belt toward Cauã's mouth.
///
/// Advances its depth `z` linearly at the belt speed, projects it with the
/// pure functions in `projection.dart`, and at the decision boundary asks
/// `decideOutcome` using [MouthController.isOpen]. It owns no score or HP:
/// ingestion is reported to [GameManager.onIngested]. Deflection is penalty
/// free; the item slides sideways and removes itself.
class FoodItemComponent extends SpriteComponent {
  FoodItemComponent({
    required this.type,
    required GameManager gameManager,
    required MouthController mouthController,
    required Sprite sprite,
    this.onIngested,
    this.onDeflected,
    this.deflectRight = true,
  }) : _gameManager = gameManager,
       _mouthController = mouthController,
       super(
         sprite: sprite,
         size: Vector2.all(baseSize),
         anchor: Anchor.center,
       );

  /// Item size at the near plane (scale 1.0), in virtual pixels.
  static const double baseSize = 160.0;

  /// Lateral deflection speed in virtual pixels per second.
  static const double deflectSpeed = 900.0;

  /// Lateral distance after which a deflected item is removed.
  static const double deflectDistance = 500.0;

  /// Duration in seconds of the visual ingest tween toward the mouth.
  static const double ingestTweenDuration = 0.15;

  /// Scale reached at the end of the ingest tween (just before removal).
  static const double ingestEndScale = 0.0;

  /// Priority range: nearer items (low z) draw in front.
  static const int _priorityRange = 1000;

  final ItemType type;
  final GameManager _gameManager;
  final MouthController _mouthController;

  /// Hook fired once on ingest (after the manager is updated). T7 plugs SFX
  /// here; for hazards (`type.category == ItemCategory.hazard`) also the
  /// screen shake.
  final FoodItemCallback? onIngested;

  /// Hook fired once when the item is deflected by a closed mouth.
  final FoodItemCallback? onDeflected;

  /// Whether a deflected item slides to the right (true) or left (false).
  final bool deflectRight;

  double _z = 0.0;
  double _lateral = 0.0;
  double _ingestT = 0.0;
  double _ingestStartX = 0.0;
  double _ingestStartY = 0.0;
  double _ingestStartScale = 0.0;
  ItemOutcome _outcome = ItemOutcome.undecided;

  /// Current depth in [0, 1+].
  double get z => _z;

  /// Decision already taken (undecided until the boundary is reached).
  ItemOutcome get outcome => _outcome;

  @override
  Future<void> onLoad() async {
    _project();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_outcome == ItemOutcome.ingest) {
      _updateIngestTween(dt);
      return;
    }
    final speed =
        ConveyorBeltComponent.baseSpeed * _gameManager.currentSpeedMultiplier;
    // Freeze depth once deflected so the item slides the full distance.
    if (_outcome != ItemOutcome.deflect) {
      _z += speed * dt * _gameManager.timeScale;
    }

    if (_outcome == ItemOutcome.undecided) {
      final outcome = decideOutcome(_z, mouthOpen: _mouthController.isOpen);
      if (outcome != ItemOutcome.undecided) {
        _outcome = outcome;
        if (outcome == ItemOutcome.ingest) {
          _gameManager.onIngested(type);
          onIngested?.call(type);
          // Freeze z at the decision z and start the visual tween from the
          // current projected pose.
          _z = Projection.decisionZ;
          _ingestStartX = xAt(_z);
          _ingestStartY = yAt(_z);
          _ingestStartScale = scaleAt(_z);
          return;
        }
        onDeflected?.call(type);
      }
    }

    if (_outcome == ItemOutcome.deflect) {
      _lateral += deflectSpeed * dt;
      if (_lateral >= deflectDistance) {
        removeFromParent();
        return;
      }
    }

    if (_z > 1.0) {
      removeFromParent();
      return;
    }
    _project();
  }

  /// Dt-driven shrink toward the mouth; fires nothing, then removes itself.
  void _updateIngestTween(double dt) {
    _ingestT += dt;
    final t = (_ingestT / ingestTweenDuration).clamp(0.0, 1.0);
    final s = _ingestStartScale + (ingestEndScale - _ingestStartScale) * t;
    scale.setValues(s, s);
    position.setValues(
      _ingestStartX + (Projection.xMouth - _ingestStartX) * t,
      _ingestStartY + (Projection.yMouth - _ingestStartY) * t,
    );
    if (t >= 1.0) removeFromParent();
  }

  void _project() {
    final s = scaleAt(_z);
    scale.setValues(s, s);
    final offset = deflectRight ? _lateral : -_lateral;
    position.setValues(xAt(_z) + offset, yAt(_z));
    priority = ((1.0 - _z) * _priorityRange).round();
  }
}
