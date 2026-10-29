import 'dart:io';

import 'package:caua_loves_candies/audio/sounds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sounds manifest', () {
    test('SfxType.fruit has filenames that exist in assets/sfx', () {
      final files = soundTypeToFilename(SfxType.fruit);
      expect(files, isNotEmpty);
      for (final f in files) {
        expect(File('assets/sfx/$f').existsSync(), isTrue, reason: f);
      }
    });

    test('every SfxType has existing files and a sane volume', () {
      for (final type in SfxType.values) {
        final files = soundTypeToFilename(type);
        expect(files, isNotEmpty, reason: '$type');
        for (final f in files) {
          expect(File('assets/sfx/$f').existsSync(), isTrue, reason: f);
        }
        final v = soundTypeToVolume(type);
        expect(v, greaterThan(0), reason: '$type');
        expect(v, lessThanOrEqualTo(1.0), reason: '$type');
      }
    });

    test('fruit volume matches score volume', () {
      expect(
        soundTypeToVolume(SfxType.fruit),
        soundTypeToVolume(SfxType.score),
      );
    });
  });
}
