import 'package:flame/components.dart';

import '../managers/blink_controller.dart';
import '../managers/caua_reaction_controller.dart';
import '../managers/caua_reaction_timings.dart';
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
    CauaReactionController? reactionController,
    super.position,
    super.size,
    super.anchor,
    super.priority,
  }) : _mouthController = mouthController,
       _blinkController = blinkController,
       _reactionController = reactionController;

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

  /// Reaction sprites: chew frames in step order, then eca.
  static const List<String> reactionSpriteNames = <String>[
    'caua/caua_chew_eyes_open.webp',
    'caua/caua_chew_eyes_half.webp',
    'caua/caua_chew_eyes_shut.webp',
    'caua/caua_eca.webp',
  ];

  final MouthController _mouthController;
  final BlinkController? _blinkController;
  final CauaReactionController? _reactionController;

  // Built once in onLoad: chew frames (kChewSteps) then eca.
  late final List<Sprite> _reactionTable;

  bool _blinkEnabled = true;

  /// Whether the blink controller is ticked. Disabling forces open eyes and
  /// re-arms the gap, so re-enabling never blinks within 2.5 s.
  bool get blinkEnabled => _blinkEnabled;
  set blinkEnabled(bool value) {
    if (_blinkEnabled == value) return;
    _blinkEnabled = value;
    if (!value && _listening) _blinkController?.reset();
  }

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
    // Missing reaction art falls back to the idle closed face.
    final idle = table[CauaPose.mouthClosed.index * eyeCount];
    _reactionTable = <Sprite>[
      for (final name in reactionSpriteNames) _tryLoad(name) ?? idle,
    ];
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
    _reactionController?.reaction.addListener(_refresh);
    _reactionController?.step.addListener(_refresh);
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
    _reactionController?.reaction.removeListener(_refresh);
    _reactionController?.step.removeListener(_refresh);
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_listening && _blinkEnabled) _blinkController?.tick(dt);
  }

  void _refresh() {
    // A forced pose (win) beats reactions; reactions beat idle and blink.
    if (_poseOverride == null) {
      final reaction = _reactionController?.reaction.value;
      if (reaction == CauaReaction.chew) {
        sprite =
            _reactionTable[_reactionController!.step.value.clamp(
              0,
              kChewSteps - 1,
            )];
        return;
      }
      if (reaction == CauaReaction.eca) {
        sprite = _reactionTable[kChewSteps];
        return;
      }
    }
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
