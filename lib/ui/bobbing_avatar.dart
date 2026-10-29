import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// Cauã avatar that bobs up and down and toggles its mouth each cycle.
class BobbingAvatar extends StatefulWidget {
  const BobbingAvatar({super.key, required this.size});

  final double size;

  static final _log = Logger('BobbingAvatar');

  static const String _closed =
      'assets/images/caua/caua_mouth_closed_eyes_open.webp';
  static const String _open =
      'assets/images/caua/caua_mouth_open_eyes_open.webp';

  @override
  State<BobbingAvatar> createState() => _BobbingAvatarState();
}

class _BobbingAvatarState extends State<BobbingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _curve,
          builder: (context, _) {
            final t = _curve.value;
            return Transform.translate(
              offset: Offset(0, -size * 0.06 * t),
              child: Image.asset(
                t > 0.5 ? BobbingAvatar._open : BobbingAvatar._closed,
                width: size,
                height: size,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (context, error, stack) {
                  BobbingAvatar._log.warning(
                    'Failed to load avatar image',
                    error,
                    stack,
                  );
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
