import 'dart:async';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:caua_loves_candies/game/managers/asset_preloader.dart';
import 'package:flame/cache.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUiImage extends Fake implements ui.Image {}

class _FakeImages extends Fake implements Images {
  _FakeImages({this.missing = const {}, this.gate});

  final Set<String> missing;
  final Completer<void>? gate;
  final List<String> loaded = [];

  @override
  Future<ui.Image> load(String fileName, {String? key, String? package}) async {
    await gate?.future;
    if (missing.contains(fileName)) {
      throw Exception('missing image $fileName');
    }
    loaded.add(fileName);
    return _FakeUiImage();
  }
}

class _FakeAudioCache extends Fake implements AudioCache {
  _FakeAudioCache({this.missing = const {}});

  final Set<String> missing;
  final List<String> loaded = [];

  @override
  Future<Uri> load(String fileName) async {
    if (missing.contains(fileName)) {
      throw Exception('missing audio $fileName');
    }
    loaded.add(fileName);
    return Uri.parse('file:///$fileName');
  }
}

void main() {
  const images = ['a.webp', 'b.webp'];
  const audio = ['x.mp3', 'y.mp3'];

  AssetPreloader build({
    required _FakeImages fi,
    required _FakeAudioCache fa,
  }) => AssetPreloader(
    imagePaths: images,
    audioPaths: audio,
    images: fi,
    audioCache: fa,
  );

  List<PreloadState> record(AssetPreloader p) {
    final out = <PreloadState>[];
    p.state.addListener(() => out.add(p.state.value));
    return out;
  }

  group('AssetPreloader', () {
    test('starts idle', () {
      final p = build(fi: _FakeImages(), fa: _FakeAudioCache());
      expect(p.state.value, isA<PreloadIdle>());
      p.dispose();
    });

    test('emits loading with rising progress then done', () async {
      final fi = _FakeImages();
      final fa = _FakeAudioCache();
      final p = build(fi: fi, fa: fa);
      final seen = record(p);

      await p.preload();

      expect(seen.last, isA<PreloadDone>());
      final progress = seen
          .whereType<PreloadLoading>()
          .map((s) => s.progress)
          .toList();
      expect(progress.first, 0);
      expect(progress.last, closeTo(1.0, 1e-9));
      expect(progress, orderedEquals([...progress]..sort()));
      expect(progress.length, 5);
      expect(fi.loaded, images);
      expect(fa.loaded, audio);
      p.dispose();
    });

    test('missing image yields PreloadFailed without throwing', () async {
      final p = build(
        fi: _FakeImages(missing: {'b.webp'}),
        fa: _FakeAudioCache(),
      );
      await expectLater(p.preload(), completes);
      final s = p.state.value;
      expect(s, isA<PreloadFailed>());
      expect((s as PreloadFailed).error, isA<Exception>());
      p.dispose();
    });

    test('missing audio yields PreloadFailed without throwing', () async {
      final p = build(
        fi: _FakeImages(),
        fa: _FakeAudioCache(missing: {'y.mp3'}),
      );
      await expectLater(p.preload(), completes);
      expect(p.state.value, isA<PreloadFailed>());
      p.dispose();
    });

    test('preload is a no-op after done', () async {
      final fi = _FakeImages();
      final p = build(fi: fi, fa: _FakeAudioCache());
      await p.preload();
      final seen = record(p);
      await p.preload();
      expect(seen, isEmpty);
      expect(fi.loaded.length, images.length);
      expect(p.state.value, isA<PreloadDone>());
      p.dispose();
    });

    test('preload is a no-op while loading', () async {
      final gate = Completer<void>();
      final fi = _FakeImages(gate: gate);
      final p = build(fi: fi, fa: _FakeAudioCache());
      final first = p.preload();
      await Future<void>.delayed(Duration.zero);
      expect(p.state.value, isA<PreloadLoading>());

      await p.preload();
      gate.complete();
      await first;

      expect(fi.loaded, images);
      expect(p.state.value, isA<PreloadDone>());
      p.dispose();
    });

    test('retry after failure can reach done', () async {
      final missing = <String>{'a.webp'};
      final fi = _FakeImages(missing: missing);
      final p = build(fi: fi, fa: _FakeAudioCache());
      await p.preload();
      expect(p.state.value, isA<PreloadFailed>());

      missing.clear();
      await p.preload();
      expect(p.state.value, isA<PreloadDone>());
      p.dispose();
    });

    test('no emission and no throw after dispose', () async {
      final gate = Completer<void>();
      final p = build(
        fi: _FakeImages(gate: gate),
        fa: _FakeAudioCache(),
      );
      final running = p.preload();
      await Future<void>.delayed(Duration.zero);
      p.dispose();
      gate.complete();
      await expectLater(running, completes);
    });

    test('preload after dispose does nothing', () async {
      final fi = _FakeImages();
      final p = build(fi: fi, fa: _FakeAudioCache());
      p.dispose();
      await expectLater(p.preload(), completes);
      expect(fi.loaded, isEmpty);
    });
  });
}
