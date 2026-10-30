import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Lifecycle of an [AssetPreloader] run.
sealed class PreloadState {
  const PreloadState();
}

/// Nothing has been requested yet.
final class PreloadIdle extends PreloadState {
  const PreloadIdle();
}

/// Loading is in progress; [progress] is in the range 0..1.
final class PreloadLoading extends PreloadState {
  const PreloadLoading(this.progress);

  final double progress;
}

/// Every asset was loaded successfully.
final class PreloadDone extends PreloadState {
  const PreloadDone();
}

/// At least one asset failed to load (e.g. missing file).
final class PreloadFailed extends PreloadState {
  const PreloadFailed(this.error);

  final Object error;
}

/// Preloads images and audio so the game starts without hitches.
///
/// Image paths are relative to the Flame `Images` prefix (`assets/images/`).
/// Audio paths are relative to the `AudioCache` prefix (`assets/`), matching
/// `AudioController` (e.g. `sfx/click1.mp3`).
class AssetPreloader {
  AssetPreloader({
    this.imagePaths = defaultImagePaths,
    this.audioPaths = defaultAudioPaths,
    Images? images,
    AudioCache? audioCache,
  }) : images = images ?? Images(),
       audioCache = audioCache ?? AudioCache.instance;

  static final _log = Logger('AssetPreloader');

  /// Product image manifest (relative to `assets/images/`).
  static const List<String> defaultImagePaths = [
    'bg/menu_bg.webp',
    'bg/stage1_sky.webp',
    'bg/stage2_sky.webp',
    'bg/stage3_sky.webp',
    'caua/caua_chew_eyes_half.webp',
    'caua/caua_chew_eyes_open.webp',
    'caua/caua_chew_eyes_shut.webp',
    'caua/caua_eca.webp',
    'caua/caua_mouth_closed_eyes_half.webp',
    'caua/caua_mouth_closed_eyes_open.webp',
    'caua/caua_mouth_closed_eyes_shut.webp',
    'caua/caua_mouth_open_eyes_half.webp',
    'caua/caua_mouth_open_eyes_open.webp',
    'caua/caua_mouth_open_eyes_shut.webp',
    'caua/caua_win_eyes_half.webp',
    'caua/caua_win_eyes_open.webp',
    'caua/caua_win_eyes_shut.webp',
    'game/belt_tile.webp',
    'items/bad_onion.webp',
    'items/bad_soap.webp',
    'items/bad_sock.webp',
    'items/candy_cotton.webp',
    'items/candy_cupcake.webp',
    'items/candy_wrapped.webp',
    'items/fruit_grape.webp',
    'items/fruit_strawberry.webp',
    'items/lollipop.webp',
    'ui/heart_empty.webp',
    'ui/heart_full.webp',
    'ui/icon_check.webp',
    'ui/icon_cross.webp',
    'ui/logo_caua_loves_candies.webp',
    'ui/tap_hand.webp',
  ];

  /// Product audio manifest (relative to `assets/`).
  static const List<String> defaultAudioPaths = [
    'music/tropical_fantasy.mp3',
    'sfx/click1.mp3',
    'sfx/click2.mp3',
    'sfx/click3.mp3',
    'sfx/click4.mp3',
    'sfx/damage1.mp3',
    'sfx/damage2.mp3',
    'sfx/score1.mp3',
    'sfx/score2.mp3',
  ];

  final List<String> imagePaths;
  final List<String> audioPaths;
  final Images images;
  final AudioCache audioCache;

  final ValueNotifier<PreloadState> _state = ValueNotifier<PreloadState>(
    const PreloadIdle(),
  );

  bool _disposed = false;

  /// Current preload state.
  ValueListenable<PreloadState> get state => _state;

  /// Loads all assets. Never throws; failures end in [PreloadFailed].
  /// Calling again after [PreloadDone] is a no-op; after failure it retries.
  Future<void> preload() async {
    final current = _state.value;
    if (_disposed || current is PreloadLoading || current is PreloadDone) {
      return;
    }
    final total = imagePaths.length + audioPaths.length;
    var loaded = 0;
    _emit(const PreloadLoading(0));
    try {
      for (final path in imagePaths) {
        await images.load(path);
        loaded++;
        _emit(PreloadLoading(loaded / total));
      }
      for (final path in audioPaths) {
        await audioCache.load(path);
        loaded++;
        _emit(PreloadLoading(loaded / total));
      }
      _log.info('Preloaded $total assets');
      _emit(const PreloadDone());
    } on Object catch (e, st) {
      _log.severe('Asset preload failed after $loaded/$total assets', e, st);
      _emit(PreloadFailed(e));
    }
  }

  void _emit(PreloadState value) {
    if (!_disposed) {
      _state.value = value;
    }
  }

  void dispose() {
    _disposed = true;
    _state.dispose();
  }
}
