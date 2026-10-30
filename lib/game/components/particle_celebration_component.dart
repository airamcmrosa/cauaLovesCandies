import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Celebration presets rendered by [ParticleCelebrationComponent].
enum CelebrationPreset {
  /// Full-screen multicolor burst followed by light falling rain.
  victory,

  /// Small sparkle on a successful ingest (implemented in a later task).
  hitSparkle,
}

enum _Shape { roundedRect, circle, star }

class _Particle {
  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double angle = 0;
  double spin = 0;
  double size = 0;
  double age = 0;
  double life = 0;
  double delay = 0;
  _Shape shape = _Shape.circle;
  int paintIndex = 0;
  bool alive = false;
}

/// Pure particle celebration on a fixed pool (no per-frame allocations).
///
/// Owns no game rules; the caller adds it to the world and it removes itself
/// when every particle has faded out.
class ParticleCelebrationComponent extends PositionComponent {
  ParticleCelebrationComponent({
    this.preset = CelebrationPreset.victory,
    math.Random? random,
    Vector2? origin,
    super.priority = 100,
  }) : _random = random ?? math.Random(),
       _origin = origin ?? Vector2(360, 200) {
    _fill();
  }

  /// Hard particle cap (burst + rain).
  static const int maxParticles = 80;

  /// Particles in the initial burst; the rest fall as rain.
  static const int burstCount = 56;

  static const double gravity = 900.0;
  static const double worldWidth = 720.0;
  static const double worldHeight = 1280.0;

  /// Palette from docs/product/design/color-palette.md.
  static const List<Color> colors = <Color>[
    Color(0xFFFFE98A),
    Color(0xFFFF8FC0),
    Color(0xFF7CC8FF),
    Color(0xFFA8F0D1),
    Color(0xFFB79CFF),
    Color(0xFFFFB36B),
  ];

  final CelebrationPreset preset;
  final math.Random _random;
  final Vector2 _origin;

  final List<_Particle> _pool = List<_Particle>.generate(
    maxParticles,
    (_) => _Particle(),
    growable: false,
  );
  final List<Paint> _paints = List<Paint>.generate(
    colors.length,
    (i) => Paint()
      ..color = colors[i]
      ..style = PaintingStyle.fill,
    growable: false,
  );
  final RRect _rrect = RRect.fromLTRBR(
    -1,
    -1,
    1,
    1,
    const Radius.circular(0.3),
  );

  /// Unit rounded 5-point star (outer radius 1), scaled on the canvas.
  static final Path _starPath = _buildStarPath();

  int _active = 0;

  /// Number of particles still alive or waiting to spawn.
  int get activeCount => _active;

  static Path _buildStarPath() {
    const points = 5;
    const inner = 0.5;
    final path = Path();
    final verts = <Offset>[];
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? 1.0 : inner;
      final a = -math.pi / 2 + i * math.pi / points;
      verts.add(Offset(r * math.cos(a), r * math.sin(a)));
    }
    // Round corners by quadratic curves through edge midpoints.
    final n = verts.length;
    Offset mid(Offset a, Offset b) =>
        Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final start = mid(verts[n - 1], verts[0]);
    path.moveTo(start.dx, start.dy);
    for (var i = 0; i < n; i++) {
      final m = mid(verts[i], verts[(i + 1) % n]);
      path.quadraticBezierTo(verts[i].dx, verts[i].dy, m.dx, m.dy);
    }
    path.close();
    return path;
  }

  void _fill() {
    for (var i = 0; i < maxParticles; i++) {
      final p = _pool[i];
      final burst = i < burstCount;
      p
        ..alive = true
        ..age = 0
        ..shape = _Shape.values[_random.nextInt(_Shape.values.length)]
        ..paintIndex = _random.nextInt(colors.length)
        ..angle = _random.nextDouble() * math.pi * 2
        ..spin = (_random.nextDouble() - 0.5) * 10
        ..size = 10 + _random.nextDouble() * 12;
      if (burst) {
        final dir = -math.pi / 2 + (_random.nextDouble() - 0.5) * math.pi * 1.4;
        final speed = 350 + _random.nextDouble() * 550;
        p
          ..delay = 0
          ..x = _origin.x
          ..y = _origin.y
          ..vx = math.cos(dir) * speed
          ..vy = math.sin(dir) * speed
          ..life = 2.2 + _random.nextDouble() * 0.8;
      } else {
        p
          ..delay = 0.6 + _random.nextDouble() * 1.6
          ..x = _random.nextDouble() * worldWidth
          ..y = -20
          ..vx = (_random.nextDouble() - 0.5) * 80
          ..vy = 120 + _random.nextDouble() * 120
          ..life = 2.6 + _random.nextDouble() * 0.8;
      }
    }
    _active = maxParticles;
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (var i = 0; i < maxParticles; i++) {
      final p = _pool[i];
      if (!p.alive) continue;
      if (p.delay > 0) {
        p.delay -= dt;
        continue;
      }
      p.age += dt;
      if (p.age >= p.life || p.y > worldHeight + 40) {
        p.alive = false;
        _active--;
        continue;
      }
      p.vy += gravity * dt;
      // Light air drag keeps the rain gentle.
      final drag = 1 - 0.8 * dt;
      p.vx *= drag;
      if (p.vy > 420) p.vy = 420;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.angle += p.spin * dt;
    }
    if (_active <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < maxParticles; i++) {
      final p = _pool[i];
      if (!p.alive || p.delay > 0) continue;
      final remaining = p.life - p.age;
      final alpha = remaining < 0.5 ? remaining / 0.5 : 1.0;
      final paint = _paints[p.paintIndex]
        ..color = colors[p.paintIndex].withValues(alpha: alpha);
      canvas
        ..save()
        ..translate(p.x, p.y)
        ..rotate(p.angle)
        ..scale(p.size, p.size);
      switch (p.shape) {
        case _Shape.roundedRect:
          canvas.drawRRect(_rrect, paint);
        case _Shape.circle:
          canvas.drawCircle(Offset.zero, 0.8, paint);
        case _Shape.star:
          canvas.drawPath(_starPath, paint);
      }
      canvas.restore();
    }
  }
}
