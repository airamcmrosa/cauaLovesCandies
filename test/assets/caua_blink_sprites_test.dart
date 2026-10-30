import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK-009 T2: the 9 blink sprites (3 mouth/win states x 3 eye states).
const _states = ['mouth_closed', 'mouth_open', 'win'];
const _eyes = ['open', 'half', 'shut'];

List<String> get _paths => [
  for (final s in _states)
    for (final e in _eyes) 'assets/images/caua/caua_${s}_eyes_$e.webp',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'all 9 blink sprites resolve via rootBundle and share dimensions',
    () async {
      await TestWidgetsFlutterBinding.instance.runAsync(() async {
        final sizes = <String>{};
        for (final p in _paths) {
          final data = await rootBundle.load(p);
          expect(data.lengthInBytes, greaterThan(0), reason: p);
          final codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          );
          final img = (await codec.getNextFrame()).image;
          sizes.add('${img.width}x${img.height}');
          img.dispose();
          codec.dispose();
        }
        expect(sizes, hasLength(1), reason: 'dimensions differ: $sizes');
      });
    },
  );

  test('9 blink sprites combined are under 3.5 MB', () {
    final total = _paths.fold<int>(0, (s, p) => s + File(p).lengthSync());
    expect(total, lessThan((3.5 * 1024 * 1024).toInt()));
  });
}
