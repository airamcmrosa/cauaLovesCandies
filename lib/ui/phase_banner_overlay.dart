import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../game/managers/phase_config.dart';
import '../style/palette.dart';

/// Presentational banner shown briefly when a new phase starts.
///
/// Listens to [phaseChanged] (1-based phase number, null on reset) and shows
/// `phases[n - 1].bannerText` for [showDuration], then fades out. A null value
/// hides any visible banner immediately. Wrapped in [IgnorePointer]: it never
/// consumes taps and never pauses the game.
class PhaseBannerOverlay extends StatefulWidget {
  const PhaseBannerOverlay({
    required this.phaseChanged,
    this.phases = kPhases,
    this.showDuration = const Duration(milliseconds: 1500),
    super.key,
  });

  final ValueListenable<int?> phaseChanged;

  /// Source of banner text (`bannerText`); index 0 is Phase 1.
  final List<PhaseConfig> phases;

  /// How long the banner stays fully visible before fading out.
  final Duration showDuration;

  @override
  State<PhaseBannerOverlay> createState() => _PhaseBannerOverlayState();
}

class _PhaseBannerOverlayState extends State<PhaseBannerOverlay> {
  static const Duration _fadeDuration = Duration(milliseconds: 250);

  static final Palette _palette = Palette();

  // Cached style: large, high contrast (ink on a cream pill).
  static final TextStyle _textStyle = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w900,
    height: 1.1,
    color: _palette.ink.color,
  );

  Timer? _hideTimer;
  String? _text;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.phaseChanged.addListener(_onPhaseChanged);
  }

  @override
  void didUpdateWidget(PhaseBannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phaseChanged != widget.phaseChanged) {
      oldWidget.phaseChanged.removeListener(_onPhaseChanged);
      widget.phaseChanged.addListener(_onPhaseChanged);
      _hide();
    }
  }

  @override
  void dispose() {
    widget.phaseChanged.removeListener(_onPhaseChanged);
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onPhaseChanged() {
    final phase = widget.phaseChanged.value;
    if (phase == null) {
      _hide();
      return;
    }
    if (phase < 1 || phase > widget.phases.length) return;
    final text = widget.phases[phase - 1].bannerText;
    if (text == null) return;

    _hideTimer?.cancel();
    _hideTimer = Timer(widget.showDuration, _hide);
    setState(() {
      _text = text;
      _visible = true;
    });
  }

  void _hide() {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (!_visible || !mounted) return;
    setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: _fadeDuration,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _palette.bgCream.color,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Text(
                _text ?? '',
                textAlign: TextAlign.center,
                style: _textStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
