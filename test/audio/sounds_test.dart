import 'dart:io';

import 'package:caua_loves_candies/audio/sounds.dart';
import 'package:flutter_test/flutter_test.dart';

const _voiceTypes = {SfxType.hmm, SfxType.eurk};

void main() {
  group('sounds manifest', () {
    test('SfxType contains hmm and eurk alongside existing types', () {
      expect(
        SfxType.values,
        containsAll([
          SfxType.score,
          SfxType.fruit,
          SfxType.damage,
          SfxType.hmm,
          SfxType.eurk,
          SfxType.buttonTap,
        ]),
      );
      expect(SfxType.values.length, 6);
    });

    test('SfxType.fruit has filenames that exist in assets/sfx', () {
      final files = soundTypeToFilename(SfxType.fruit);
      expect(files, isNotEmpty);
      for (final f in files) {
        expect(File('assets/sfx/$f').existsSync(), isTrue, reason: f);
      }
    });

    test('every SfxType file exists under its resolved asset directory', () {
      for (final type in SfxType.values) {
        final files = soundTypeToFilename(type);
        expect(files, isNotEmpty, reason: '$type');
        for (final f in files) {
          expect(
            File('assets/${sfxAssetPath(type, f)}').existsSync(),
            isTrue,
            reason: '$type $f',
          );
        }
        final v = soundTypeToVolume(type);
        expect(v, greaterThan(0), reason: '$type');
        expect(v, lessThanOrEqualTo(1.0), reason: '$type');
      }
    });

    test('hmm and eurk map to their single files at volume 1.0', () {
      expect(soundTypeToFilename(SfxType.hmm), ['hmm.mp3']);
      expect(soundTypeToFilename(SfxType.eurk), ['eurk.mp3']);
      expect(soundTypeToVolume(SfxType.hmm), 1.0);
      expect(soundTypeToVolume(SfxType.eurk), 1.0);
      expect(File('assets/audio/hmm.mp3').existsSync(), isTrue);
      expect(File('assets/audio/eurk.mp3').existsSync(), isTrue);
    });

    test('existing type mappings are unchanged and files remain in sfx', () {
      expect(soundTypeToFilename(SfxType.damage), [
        'damage1.mp3',
        'damage2.mp3',
      ]);
      expect(soundTypeToFilename(SfxType.score), ['score1.mp3', 'score2.mp3']);
      expect(soundTypeToFilename(SfxType.fruit), ['score2.mp3']);
      expect(soundTypeToFilename(SfxType.buttonTap), [
        'click1.mp3',
        'click2.mp3',
        'click3.mp3',
        'click4.mp3',
      ]);
      expect(soundTypeToVolume(SfxType.score), 0.4);
      expect(soundTypeToVolume(SfxType.fruit), 0.4);
      expect(soundTypeToVolume(SfxType.damage), 0.4);
      expect(soundTypeToVolume(SfxType.buttonTap), 1.0);
      for (final f in [
        'damage1.mp3',
        'damage2.mp3',
        'score1.mp3',
        'score2.mp3',
        'click1.mp3',
        'click2.mp3',
        'click3.mp3',
        'click4.mp3',
      ]) {
        expect(File('assets/sfx/$f').existsSync(), isTrue, reason: f);
      }
    });

    test('fruit volume matches score volume', () {
      expect(
        soundTypeToVolume(SfxType.fruit),
        soundTypeToVolume(SfxType.score),
      );
    });
  });

  group('sfxAssetPath', () {
    test('voice clips resolve to audio/, others to sfx/', () {
      expect(sfxAssetPath(SfxType.hmm, 'hmm.mp3'), 'audio/hmm.mp3');
      expect(sfxAssetPath(SfxType.eurk, 'eurk.mp3'), 'audio/eurk.mp3');
      for (final type in SfxType.values.where(
        (t) => !_voiceTypes.contains(t),
      )) {
        expect(sfxAssetPath(type, 'x.mp3'), 'sfx/x.mp3', reason: '$type');
      }
    });

    test('preload path list over SfxType.values covers every file', () {
      // Mirrors AudioController._preloadSfx, which is private and needs
      // audio plugins to construct.
      final paths = SfxType.values
          .expand((t) => soundTypeToFilename(t).map((f) => sfxAssetPath(t, f)))
          .toSet();
      expect(paths, containsAll(['audio/hmm.mp3', 'audio/eurk.mp3']));
      for (final p in paths) {
        expect(File('assets/$p').existsSync(), isTrue, reason: p);
      }
    });

    test('AudioController source preloads and plays via sfxAssetPath', () {
      final src = File('lib/audio/audio_controller.dart').readAsStringSync();
      expect(src, contains('sfxAssetPath(type, filename)'));
      expect(src, contains('SfxType.values'));
    });
  });

  group('pubspec', () {
    test('declares assets/audio/ as an asset directory', () {
      final lines = File(
        'pubspec.yaml',
      ).readAsLinesSync().map((l) => l.trim()).toList();
      expect(lines, contains('- assets/audio/'));
    });
  });
}
