import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Locks the TASK-017 Caua frame normalization: canvas, alpha, weight,
/// opaque bbox anchor, per-group size, skin/hair/shirt color and no dark halo.

const _dir = 'assets/images/caua';

const _expected = <String>[
  'caua_chew_eyes_half',
  'caua_chew_eyes_open',
  'caua_chew_eyes_shut',
  'caua_eca',
  'caua_mouth_closed_eyes_half',
  'caua_mouth_closed_eyes_open',
  'caua_mouth_closed_eyes_shut',
  'caua_mouth_open_eyes_half',
  'caua_mouth_open_eyes_open',
  'caua_mouth_open_eyes_shut',
  'caua_win_eyes_half',
  'caua_win_eyes_open',
  'caua_win_eyes_shut',
];

// The 10 older frames used as the color reference.
const _refNames = <String>[
  'caua_chew_eyes_half',
  'caua_chew_eyes_shut',
  'caua_eca',
  'caua_mouth_closed_eyes_open',
  'caua_mouth_closed_eyes_shut',
  'caua_mouth_open_eyes_half',
  'caua_mouth_open_eyes_shut',
  'caua_win_eyes_half',
  'caua_win_eyes_open',
  'caua_win_eyes_shut',
];

bool _isWin(String n) => n.startsWith('caua_win_');

class _Frame {
  _Frame(this.w, this.h, this.rgba);
  final int w;
  final int h;
  final Uint8List rgba;
  int r(int x, int y) => rgba[(y * w + x) * 4];
  int g(int x, int y) => rgba[(y * w + x) * 4 + 1];
  int b(int x, int y) => rgba[(y * w + x) * 4 + 2];
  int a(int x, int y) => rgba[(y * w + x) * 4 + 3];
}

class _Metrics {
  late int x0, y0, x1, y1;
  double get bboxCx => (x0 + x1) / 2;
  int get bboxW => x1 - x0 + 1;
  int get bboxH => y1 - y0 + 1;
  late List<double> skinRgb;
  late List<double> hairRgb;
  late List<double> shirtRgb;
  late List<double> haloMean;
  late int semiCount;
}

Future<_Frame> _decode(String name) async {
  final bytes = await File('$_dir/$name.webp').readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final fi = await codec.getNextFrame();
  final img = fi.image;
  final bd = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  final f = _Frame(
    img.width,
    img.height,
    bd!.buffer.asUint8List(bd.offsetInBytes, bd.lengthInBytes),
  );
  img.dispose();
  codec.dispose();
  return f;
}

double _median(List<int> v) {
  final s = [...v]..sort();
  final n = s.length;
  return n.isOdd ? s[n ~/ 2].toDouble() : (s[n ~/ 2 - 1] + s[n ~/ 2]) / 2;
}

_Metrics _measure(_Frame f) {
  final m = _Metrics();
  bool op(int x, int y) => f.a(x, y) > 128;
  var x0 = f.w, x1 = -1, y0 = f.h, y1 = -1;
  for (var y = 0; y < f.h; y++) {
    for (var x = 0; x < f.w; x++) {
      if (op(x, y)) {
        if (x < x0) x0 = x;
        if (x > x1) x1 = x;
        if (y < y0) y0 = y;
        if (y > y1) y1 = y;
      }
    }
  }
  m
    ..x0 = x0
    ..x1 = x1
    ..y0 = y0
    ..y1 = y1;

  bool blue(int x, int y) =>
      op(x, y) && f.b(x, y) > f.r(x, y) + 40 && f.b(x, y) > 180;

  // Shirt: first row with >= 40 blue pixels; mean color of all blue pixels.
  var shirtTop = -1;
  var sr = 0, sg = 0, sb = 0, sn = 0;
  for (var y = 0; y < f.h; y++) {
    var cnt = 0;
    for (var x = 0; x < f.w; x++) {
      if (blue(x, y)) {
        cnt++;
        sr += f.r(x, y);
        sg += f.g(x, y);
        sb += f.b(x, y);
        sn++;
      }
    }
    if (shirtTop < 0 && cnt >= 40) shirtTop = y;
  }
  expect(shirtTop, greaterThan(y0), reason: 'shirt must be detected');
  m.shirtRgb = [sr / sn, sg / sn, sb / sn];

  final headH = shirtTop - y0;
  // Head width over the top 70% of head height.
  var hx0 = f.w, hx1 = -1;
  for (var y = y0; y < y0 + (0.7 * headH).toInt(); y++) {
    for (var x = 0; x < f.w; x++) {
      if (op(x, y)) {
        if (x < hx0) hx0 = x;
        if (x > hx1) hx1 = x;
      }
    }
  }
  final headW = hx1 - hx0 + 1;
  final hcx = (hx0 + hx1) / 2;

  // Skin band.
  final ya = y0 + (0.55 * headH).toInt();
  final yb = y0 + (0.75 * headH).toInt();
  final xa = (hcx - 0.12 * headW).toInt();
  final xb = (hcx + 0.12 * headW).toInt();
  final px = <List<int>>[];
  for (var y = ya; y < yb; y++) {
    for (var x = xa; x < xb; x++) {
      final r = f.r(x, y), g = f.g(x, y), b = f.b(x, y);
      if (op(x, y) &&
          r > 170 &&
          r > g + 15 &&
          g > b + 15 &&
          g > 110 &&
          r - g < 70) {
        px.add([r, g, b]);
      }
    }
  }
  expect(px, isNotEmpty, reason: 'skin pixels must be found');
  final med = [
    for (var c = 0; c < 3; c++) _median([for (final p in px) p[c]]),
  ];
  final kept = px
      .where(
        (p) =>
            (p[0] - med[0]).abs() +
                (p[1] - med[1]).abs() +
                (p[2] - med[2]).abs() <
            40,
      )
      .toList();
  m.skinRgb = [
    for (var c = 0; c < 3; c++)
      kept.fold<int>(0, (s, p) => s + p[c]) / kept.length,
  ];

  // Hair: dark brown pixels in the top region of the head.
  final hy0 = y0 + (0.05 * headH).toInt();
  final hy1 = y0 + (0.25 * headH).toInt();
  final hxa = (hcx - 0.25 * headW).toInt();
  final hxb = (hcx + 0.25 * headW).toInt();
  var hr = 0, hg = 0, hb = 0, hn = 0;
  for (var y = hy0; y < hy1; y++) {
    for (var x = hxa; x < hxb; x++) {
      final r = f.r(x, y), b = f.b(x, y);
      if (r > b + 25 && r < 170 && r > 60) {
        hr += r;
        hg += f.g(x, y);
        hb += b;
        hn++;
      }
    }
  }
  expect(hn, greaterThan(0), reason: 'hair pixels must be found');
  m.hairRgb = [hr / hn, hg / hn, hb / hn];

  // Halo: partial-alpha pixels. The decoder may return premultiplied RGB,
  // so un-premultiply before averaging. Very low alpha pixels
  // lose color precision in that round trip, so only alpha >= 64 is judged.
  var pr = 0, pg = 0, pb = 0, pn = 0;
  for (var y = 0; y < f.h; y++) {
    for (var x = 0; x < f.w; x++) {
      final a = f.a(x, y);
      if (a >= 64 && a < 250) {
        pr += math.min(255, f.r(x, y) * 255 ~/ a);
        pg += math.min(255, f.g(x, y) * 255 ~/ a);
        pb += math.min(255, f.b(x, y) * 255 ~/ a);
        pn++;
      }
    }
  }
  m.semiCount = pn;
  m.haloMean = pn == 0 ? [255, 255, 255] : [pr / pn, pg / pn, pb / pn];
  return m;
}

List<double> _lab(List<double> rgb) {
  double lin(double c) {
    c /= 255;
    return c > 0.04045
        ? math.pow((c + 0.055) / 1.055, 2.4).toDouble()
        : c / 12.92;
  }

  final r = lin(rgb[0]), g = lin(rgb[1]), b = lin(rgb[2]);
  final x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047;
  final y = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  final z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883;
  double f(double t) =>
      t > 0.008856 ? math.pow(t, 1 / 3).toDouble() : 7.787 * t + 16 / 116;
  return [116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z))];
}

double _dE76(List<double> a, List<double> b) {
  final la = _lab(a), lb = _lab(b);
  return math.sqrt(
    math.pow(la[0] - lb[0], 2) +
        math.pow(la[1] - lb[1], 2) +
        math.pow(la[2] - lb[2], 2),
  );
}

List<double> _meanRgb(Iterable<List<double>> v) {
  final l = v.toList();
  return [
    for (var c = 0; c < 3; c++)
      l.fold<double>(0, (s, e) => s + e[c]) / l.length,
  ];
}

void main() {
  final frames = <String, _Frame>{};
  final metrics = <String, _Metrics>{};
  late List<double> refSkin, refHair, refShirt;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await TestWidgetsFlutterBinding.instance.runAsync(() async {
      for (final n in _expected) {
        frames[n] = await _decode(n);
        metrics[n] = _measure(frames[n]!);
      }
    });
    refSkin = _meanRgb(_refNames.map((n) => metrics[n]!.skinRgb));
    refHair = _meanRgb(_refNames.map((n) => metrics[n]!.hairRgb));
    refShirt = _meanRgb(_refNames.map((n) => metrics[n]!.shirtRgb));
  });

  test('directory contains exactly the 13 expected webp frames', () {
    final names =
        Directory(_dir)
            .listSync()
            .whereType<File>()
            .map((f) => f.uri.pathSegments.last)
            .where((n) => n.endsWith('.webp'))
            .map((n) => n.substring(0, n.length - 5))
            .toList()
          ..sort();
    expect(names, [..._expected]..sort());
    expect(_expected.length, 13);
  });

  for (final name in _expected) {
    group(name, () {
      test('is 512x512 with real alpha and <= 30 KB', () {
        final f = frames[name]!;
        expect(f.w, 512);
        expect(f.h, 512);
        var transparent = 0, opaque = 0;
        for (var i = 3; i < f.rgba.length; i += 4) {
          if (f.rgba[i] == 0) transparent++;
          if (f.rgba[i] == 255) opaque++;
        }
        expect(transparent, greaterThan(0), reason: 'has transparent pixels');
        expect(opaque, greaterThan(0), reason: 'has opaque pixels');
        expect(
          File('$_dir/$name.webp').lengthSync(),
          lessThanOrEqualTo(30 * 1024),
        );
      });

      test('opaque bbox is anchored at top 26, bottom 486, center x 255.5', () {
        final m = metrics[name]!;
        expect(m.y0, closeTo(26, 2));
        expect(m.y1, closeTo(486, 2));
        expect(m.bboxCx, closeTo(255.5, 2));
      });

      test('bbox size matches its group', () {
        final m = metrics[name]!;
        expect(m.bboxH, closeTo(461, 4));
        if (_isWin(name)) {
          expect(m.bboxW, closeTo(456, 4));
        } else {
          expect(m.bboxW, closeTo(386, 4));
        }
      });

      test('skin tone is within dE76 <= 5 of the reference mean', () {
        expect(_dE76(metrics[name]!.skinRgb, refSkin), lessThanOrEqualTo(5.0));
      });

      test('hair and shirt mean are within +-8 per channel of reference', () {
        final m = metrics[name]!;
        for (var c = 0; c < 3; c++) {
          expect(m.hairRgb[c], closeTo(refHair[c], 8), reason: 'hair ch $c');
          expect(m.shirtRgb[c], closeTo(refShirt[c], 8), reason: 'shirt ch $c');
        }
      });

      test('partial-alpha pixels have no dark halo (mean RGB >= 240)', () {
        final m = metrics[name]!;
        expect(m.semiCount, greaterThan(0));
        for (var c = 0; c < 3; c++) {
          expect(m.haloMean[c], greaterThanOrEqualTo(240));
        }
      });
    });
  }
}
