import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';

import '../app_lifecycle/app_lifecycle.dart';
import '../settings/settings.dart';
import 'songs.dart';
import 'sounds.dart';

/// Allows playing music and sound. A facade to `package:audioplayers`.
class AudioController {
  static final _log = Logger('AudioController');

  final AudioPlayer _musicPlayer;

  /// This is a list of [AudioPlayer] instances which are rotated to play
  /// sound effects.
  final List<AudioPlayer> _sfxPlayers;

  int _currentSfxPlayer = 0;

  final Queue<Song> _playlist;

  final Random _random = Random();

  SettingsController? _settings;

  /// True once the attached settings finished loading (or failed and fell back
  /// to defaults). Music never starts before this, so a saved "off" is honored.
  bool _settingsReady = false;

  /// Guards against concurrent [_startOrResumeMusic] runs.
  bool _startingMusic = false;

  /// Set when a start is requested while one is in flight; the in-flight run
  /// re-evaluates the desired state when it ends instead of dropping it.
  bool _startPending = false;

  bool _disposed = false;

  StreamSubscription<void>? _completeSubscription;

  ValueNotifier<AppLifecycleState>? _lifecycleNotifier;

  /// Creates an instance that plays music and sound.
  ///
  /// Use [polyphony] to configure the number of sound effects (SFX) that can
  /// play at the same time. A [polyphony] of `1` will always only play one
  /// sound (a new sound will stop the previous one). See discussion
  /// of [_sfxPlayers] to learn why this is the case.
  ///
  /// Background music does not count into the [polyphony] limit. Music will
  /// never be overridden by sound effects because that would be silly.
  AudioController({int polyphony = 2})
    : assert(polyphony >= 1),
      _musicPlayer = AudioPlayer(playerId: 'musicPlayer'),
      _sfxPlayers = Iterable.generate(
        polyphony,
        (i) => AudioPlayer(playerId: 'sfxPlayer#$i'),
      ).toList(growable: false),
      _playlist = Queue.of(List<Song>.of(songs)..shuffle()) {
    _completeSubscription = _musicPlayer.onPlayerComplete.listen(
      _handleSongFinished,
    );
    unawaited(_preloadSfx());
  }

  /// Makes sure the audio controller is listening to changes
  /// of both the app lifecycle (e.g. suspended app) and to changes
  /// of settings (e.g. muted sound).
  void attachDependencies(
    AppLifecycleStateNotifier lifecycleNotifier,
    SettingsController settingsController,
  ) {
    _attachLifecycleNotifier(lifecycleNotifier);
    _attachSettings(settingsController);
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _settings?.audioOn.removeListener(_audioOnHandler);
    _settings = null;
    _settingsReady = false;
    _lifecycleNotifier?.removeListener(_handleAppLifecycle);
    _lifecycleNotifier = null;
    unawaited(_completeSubscription?.cancel());
    _completeSubscription = null;
    _stopAllSound();
    _musicPlayer.dispose();
    for (final player in _sfxPlayers) {
      player.dispose();
    }
  }

  /// Idempotent retry hook for the first user tap.
  ///
  /// Music tries to start as soon as settings attach (on every platform), but
  /// browsers may block that initial autoplay. Call this from a tap handler:
  /// if settings allow music and it is not currently playing, it is started or
  /// resumed. It never silences music and is safe to call repeatedly.
  Future<void> unlockAndStartMusic() async {
    final settings = _settings;
    _log.info(
      'unlockAndStartMusic: audioOn=${settings?.audioOn.value}, '
      'playerState=${_musicPlayer.state}',
    );
    if (settings == null || !settings.audioOn.value) {
      return;
    }
    if (_musicPlayer.state == PlayerState.playing) {
      return;
    }
    await _startOrResumeMusic();
  }

  /// Plays a single sound effect, defined by [type].
  ///
  /// The controller ignores this call when the attached settings'
  /// [SettingsController.audioOn] is `false` (single sound flag for music
  /// and SFX).
  void playSfx(SfxType type) {
    final audioOn = _settings?.audioOn.value ?? false;
    if (!audioOn) {
      _log.fine(() => 'Ignoring playing sound ($type) because audio is muted.');
      return;
    }
    _log.fine(() => 'Playing sound: $type');
    final options = soundTypeToFilename(type);
    final filename = options[_random.nextInt(options.length)];
    _log.fine(() => '- Chosen filename: $filename');

    final currentPlayer = _sfxPlayers[_currentSfxPlayer];
    unawaited(
      currentPlayer
          .play(
            AssetSource(sfxAssetPath(type, filename)),
            volume: soundTypeToVolume(type),
          )
          .then<void>(
            (_) => _log.info('SFX started: ${sfxAssetPath(type, filename)}'),
            onError: (Object e, StackTrace st) => _log.warning(
              'Could not play SFX ${sfxAssetPath(type, filename)}',
              e,
              st,
            ),
          ),
    );
    _currentSfxPlayer = (_currentSfxPlayer + 1) % _sfxPlayers.length;
  }

  /// Enables the [AudioController] to listen to [AppLifecycleState] events,
  /// and therefore do things like stopping playback when the game
  /// goes into the background.
  void _attachLifecycleNotifier(AppLifecycleStateNotifier lifecycleNotifier) {
    _lifecycleNotifier?.removeListener(_handleAppLifecycle);

    lifecycleNotifier.addListener(_handleAppLifecycle);
    _lifecycleNotifier = lifecycleNotifier;
  }

  /// Enables the [AudioController] to track changes to settings.
  /// Namely, when [SettingsController.audioOn] (the single flag controlling
  /// music and SFX) changes, the audio controller will act accordingly.
  void _attachSettings(SettingsController settingsController) {
    if (_settings == settingsController) {
      // Already attached to this instance. Nothing to do.
      return;
    }

    // Remove handlers from the old settings controller if present
    final oldSettings = _settings;
    if (oldSettings != null) {
      oldSettings.audioOn.removeListener(_audioOnHandler);
    }

    _settings = settingsController;

    // Add handlers to the new settings controller
    settingsController.audioOn.addListener(_audioOnHandler);

    // Only decide after the persisted audioOn value has been loaded, so a
    // saved "off" never produces sound.
    _settingsReady = false;
    unawaited(_awaitSettingsThenStart(settingsController));
  }

  Future<void> _awaitSettingsThenStart(SettingsController settings) async {
    try {
      await settings.loaded;
    } catch (e, st) {
      _log.warning('Settings failed to load; using current defaults', e, st);
    }
    if (_settings != settings) {
      return;
    }
    _settingsReady = true;
    if (settings.audioOn.value) {
      await _startOrResumeMusic();
    }
  }

  void _audioOnHandler() {
    _log.fine('audioOn changed to ${_settings!.audioOn.value}');
    if (_settings!.audioOn.value) {
      // All sound just got un-muted. Audio is on.
      _startOrResumeMusic();
    } else {
      // All sound just got muted. Audio is off.
      _stopAllSound();
    }
  }

  void _handleAppLifecycle() {
    switch (_lifecycleNotifier!.value) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _stopAllSound();
      case AppLifecycleState.resumed:
        if (_settings!.audioOn.value) {
          _startOrResumeMusic();
        }
      case AppLifecycleState.inactive:
        // No need to react to this state change.
        break;
    }
  }

  void _handleSongFinished(void _) {
    if (_disposed || !(_settings?.audioOn.value ?? false)) {
      _log.info('Song finished while muted or disposed; not restarting.');
      return;
    }
    _log.info('Last song finished playing.');
    // Move the song that just finished playing to the end of the playlist.
    _playlist.addLast(_playlist.removeFirst());
    // Play the song at the beginning of the playlist.
    _playCurrentSongInPlaylist();
  }

  Future<void> _playCurrentSongInPlaylist() async {
    final path = 'music/${_playlist.first.filename}';
    _log.info(
      'Playing $path now (cache prefix: ${AudioCache.instance.prefix})',
    );
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource(path));
      _log.info('Music started: $path, state=${_musicPlayer.state}');
    } catch (e, st) {
      _log.warning('Could not play song $path (autoplay blocked?)', e, st);
    }
  }

  /// Preloads all sound effects.
  Future<void> _preloadSfx() async {
    _log.info('Preloading sound effects');
    // This assumes there is only a limited number of sound effects in the game.
    // If there are hundreds of long sound effect files, it's better
    // to be more selective when preloading.
    try {
      await AudioCache.instance.loadAll(
        SfxType.values
            .expand(
              (type) => soundTypeToFilename(
                type,
              ).map((filename) => sfxAssetPath(type, filename)),
            )
            .toList(),
      );
    } catch (e, st) {
      _log.warning('Could not preload sound effects', e, st);
    }
  }

  Future<void> _startOrResumeMusic() async {
    if (_disposed || !_settingsReady) {
      return;
    }
    if (_startingMusic) {
      _startPending = true;
      return;
    }
    _startingMusic = true;
    try {
      do {
        _startPending = false;
        await _doStartOrResumeMusic();
        if (_disposed) {
          return;
        }
        if (!(_settings?.audioOn.value ?? false)) {
          // Muted while the start was in flight: never leave music playing.
          await _musicPlayer.pause();
          return;
        }
      } while (_startPending);
    } finally {
      _startingMusic = false;
    }
  }

  Future<void> _doStartOrResumeMusic() async {
    final state = _musicPlayer.state;
    if (_musicPlayer.source == null ||
        state == PlayerState.stopped ||
        state == PlayerState.completed ||
        state == PlayerState.disposed) {
      _log.info('Starting the current song in playlist.');
      await _playCurrentSongInPlaylist();
      return;
    }

    _log.info('Resuming paused music.');
    try {
      await _musicPlayer.resume();
    } catch (e) {
      // Resuming may fail (e.g. autoplay blocked); retry from scratch.
      _log.warning('Error resuming music', e);
      await _playCurrentSongInPlaylist();
    }
  }

  void _stopAllSound() {
    _log.info('Stopping all sound');
    _musicPlayer.pause();
    for (final player in _sfxPlayers) {
      player.stop();
    }
  }
}
