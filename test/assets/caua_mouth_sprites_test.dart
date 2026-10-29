import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const closedPath = 'assets/images/caua/caua_mouth_closed_eyes_open.webp';
  const openPath = 'assets/images/caua/caua_mouth_open_eyes_open.webp';
  const maxBytes = 60 * 1024;

  group('Caua mouth sprites', () {
    for (final path in [closedPath, openPath]) {
      group(path, () {
        test('exists', () {
          expect(File(path).existsSync(), isTrue);
        });

        test('is a valid WebP (RIFF....WEBP header)', () {
          final Uint8List b = File(path).readAsBytesSync();
          expect(b.length, greaterThanOrEqualTo(12));
          expect(String.fromCharCodes(b.sublist(0, 4)), 'RIFF');
          expect(String.fromCharCodes(b.sublist(8, 12)), 'WEBP');
        });

        test('is under 60 KB', () {
          expect(File(path).lengthSync(), lessThan(maxBytes));
        });
      });
    }

    test('open and closed sprites differ', () {
      final a = File(closedPath).readAsBytesSync();
      final b = File(openPath).readAsBytesSync();
      expect(a, isNot(equals(b)));
    });

    test('pubspec.yaml declares the assets/images/caua/ directory', () {
      final lines = File(
        'pubspec.yaml',
      ).readAsLinesSync().map((l) => l.trim()).toList();
      expect(lines, contains('- assets/images/caua/'));
    });
  });
}
