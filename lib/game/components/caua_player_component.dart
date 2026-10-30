import 'package:flame/components.dart';

import '../managers/blink_controller.dart';
import '../managers/mouth_controller.dart';
import '../managers/mouth_state.dart';
import 'caua_pose.dart';

/// Renders Cauã and swaps sprites whenever [MouthController.state] or the
/// optional [BlinkController.state] changes. It owns no game rules.
///
/// Ownership: the [BlinkController] is owned and disposed by the game, never
/// by this component. The component only listens and ticks it, and stops both
/// as soon as it is removed.
class CauaPlayerComponent extends SpriteComponent with HasGameReference {
  CauaPlayerComponent({
    required MouthController mouthController,
    BlinkController? blinkController,
    super.position,
    super.size,
    super.anchor,
    super.priority,
  }) : _mouthController = mouthController,
       _blinkController = blinkController;

  /// Expected file names inside the game's images cache.
  static const String closedSpriteName =
      'caua/caua_mouth_closed_eyes_open.webp';
  static const String openSpriteName = 'caua/caua_mouth_open_eyes_open.webp';

  /// Every sprite file the component can show, indexed by
  /// `pose.index * 3 + eye.index` (open, half, shut), for preloading.
  static const List<String> allSpriteNames = <String>[
    'caua/caua_mouth_closed_eyes_open.webp',
    'caua/caua_mouth_closed_eyes_half.webp',
    'caua/caua_mouth_closed_eyes_shut.webp',
    'caua/caua_mouth_open_eyes_open.webp',
    'caua/caua_mouth_open_eyes_half.webp',
    'caua/caua_mouth_open_eyes_shut.webp',
    'caua/caua_win_eyes_open.webp',
    'caua/caua_win_eyes_half.webp',
    'caua/caua_win_eyes_shut.webp',
  ];

  final MouthController _mouthController;
  final BlinkController? _blinkController;

  /// Whether the blink controller is ticked. T4 wires this to the game state.
  bool blinkEnabled = true;

  // Sprite table indexed by `pose.index * 3 + eye.index`, built once.
  late final List<Sprite> _table;

  CauaPose? _poseOverride;
  bool _listening = false;

  /// Forces a pose (e.g. [CauaPose.win]); null restores mouth-driven poses.
  set poseOverride(CauaPose? value) {
    if (_poseOverride == value) return;
    _poseOverride = value;
    _refresh();
  }

  @override
  Future<void> onLoad() async {
    final eyeCount = EyeState.values.length;
    final table = <Sprite>[];
    for (final pose in CauaPose.values) {
      final frames = List<Sprite?>.generate(
        eyeCount,
        (i) => _tryLoad(allSpriteNames[pose.index * eyeCount + i]),
      );
      final open = frames[EyeState.open.index];
      final half = frames[EyeState.half.index];
      // Fallback: nearest eye state of the same pose (half <-> open).
      final base = open ?? half;
      if (base == null) {
        throw StateError('No Cauã sprite loaded for pose ${pose.name}');
      }
      table
        ..add(open ?? base)
        ..add(half ?? base)
        ..add(frames[EyeState.shut.index] ?? half ?? base);
    }
    _table = table;
    _refresh();
  }

  Sprite? _tryLoad(String name) {
    try {
      return Sprite(game.images.fromCache(name));
    } on Object {
      return null;
    }
  }

  @override
  void onMount() {
    super.onMount();
    _mouthController.state.addListener(_refresh);
    _blinkController?.state.addListener(_refresh);
    _listening = true;
    // Resync in case a state changed before mounting.
    _refresh();
  }

  @override
  void onRemove() {
    // Listeners first; after this the component never touches the blink
    // controller again (the game may dispose it right after).
    _listening = false;
    _mouthController.state.removeListener(_refresh);
    _blinkController?.state.removeListener(_refresh);
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_listening && blinkEnabled) _blinkController?.tick(dt);
  }

  void _refresh() {
    final pose =
        _poseOverride ??
        switch (_mouthController.state.value) {
          MouthState.closed => CauaPose.mouthClosed,
          MouthState.open => CauaPose.mouthOpen,
        };
    final eye = _blinkController?.state.value ?? EyeState.open;
    sprite = _table[pose.index * EyeState.values.length + eye.index];
  }
}
