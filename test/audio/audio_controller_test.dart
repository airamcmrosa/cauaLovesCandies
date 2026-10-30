import 'dart:async';
import 'dart:io';

import 'package:caua_loves_candies/app_lifecycle/app_lifecycle.dart';
import 'package:caua_loves_candies/audio/audio_controller.dart';
import 'package:caua_loves_candies/audio/sounds.dart';
import 'package:caua_loves_candies/settings/persistence/settings_persistence.dart';
import 'package:caua_loves_candies/settings/settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryPersistence implements SettingsPersistence {
  bool audioOn = true;
  bool musicOn = true;
  bool soundsOn = true;
  String name = 'Player';

  /// When set, getAudioOn waits for it (simulates a slow persisted load).
  Completer<void>? gate;

  /// When true, getAudioOn throws (simulates a failing load).
  bool failLoad = false;

  @override
  Future<bool> getAudioOn({required bool defaultValue}) async {
    await gate?.future;
    if (failLoad) throw StateError('load failed');
    return audioOn;
  }

  @override
  Future<bool> getMusicOn({required bool defaultValue}) async => musicOn;
  @override
  Future<bool> getSoundsOn({required bool defaultValue}) async => soundsOn;
  @override
  Future<String> getPlayerName() async => name;
  @override
  Future<void> saveAudioOn(bool value) async => audioOn = value;
  @override
  Future<void> saveMusicOn(bool value) async => musicOn = value;
  @override
  Future<void> saveSoundsOn(bool value) async => soundsOn = value;
  @override
  Future<void> savePlayerName(String value) async => name = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const audioChannel = MethodChannel('xyz.luan/audioplayers');
  const globalChannel = MethodChannel('xyz.luan/audioplayers.global');
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');

  late Directory tempDir;
  late List<String> calls;
  late List<String> sfxCalls;
  late bool failResume;
  Completer<void>? resumeGate;
  late Map<String, MockStreamHandlerEventSink> preparedSinks;
  late AudioController controller;
  late SettingsController settings;
  late AppLifecycleStateNotifier lifecycle;

  // Calls on the music player only (SFX players are never touched here).
  int count(String method) => calls.where((c) => c == method).length;

  // Pause/resume calls only (ignores position polling and similar noise).
  List<String> playbackCalls() =>
      calls.where((c) => c == 'pause' || c == 'resume').toList();

  // Waits until no new platform call arrives for a quiet window (real async
  // file IO is involved when the asset is first copied to the cache).
  Future<void> settle() async {
    var last = -1;
    var quiet = 0;
    while (quiet < 8) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      if (calls.length == last) {
        quiet++;
      } else {
        quiet = 0;
        last = calls.length;
      }
    }
  }

  Future<SettingsController> makeSettings({bool audio = true}) async {
    final store = _MemoryPersistence()..audioOn = audio;
    final s = SettingsController(store: store);
    await settle();
    return s;
  }

  Future<void> attach(SettingsController s) async {
    controller.attachDependencies(lifecycle, s);
    await settle();
  }

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('audio_controller_test');
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    calls = [];
    sfxCalls = [];
    preparedSinks = {};
    failResume = false;
    resumeGate = null;
    messenger.setMockMethodCallHandler(audioChannel, (call) async {
      if (call.arguments is Map &&
          (call.arguments as Map)['playerId'] == 'musicPlayer') {
        final blocked = call.method == 'resume' && failResume;
        calls.add(blocked ? 'resumeBlocked' : call.method);
      }
      final pid = call.arguments is Map
          ? (call.arguments as Map)['playerId'] as String?
          : null;
      if (pid != null && pid.startsWith('sfxPlayer')) {
        sfxCalls.add(call.method);
      }
      if (call.method == 'setSourceUrl') {
        Future<void>.delayed(Duration.zero, () {
          preparedSinks[pid ?? 'musicPlayer']?.success({
            'event': 'audio.onPrepared',
            'value': true,
          });
        });
      }
      if (call.method == 'resume' && pid == 'musicPlayer') {
        await resumeGate?.future;
      }
      if (call.method == 'resume' && failResume) {
        throw PlatformException(code: 'blocked', message: 'autoplay blocked');
      }
      return null;
    });
    messenger.setMockMethodCallHandler(globalChannel, (_) async => null);
    messenger.setMockMethodCallHandler(pathChannel, (call) async {
      return tempDir.path;
    });
    // Event channels (one per player): report "prepared" as soon as the
    // controller subscribes, like a real platform does after a source is set.
    for (final id in ['musicPlayer', 'sfxPlayer#0', 'sfxPlayer#1']) {
      messenger.setMockStreamHandler(
        EventChannel('xyz.luan/audioplayers/events/$id'),
        MockStreamHandler.inline(
          onListen: (args, sink) {
            preparedSinks[id] = sink;
          },
        ),
      );
    }
    lifecycle = ValueNotifier(AppLifecycleState.resumed);
    controller = AudioController();
    await settle();
    calls.clear();
  });

  tearDown(() async {
    controller.dispose();
    await settle();
  });

  group('start on settings attach (all platforms)', () {
    test('tries to start music when audioOn is true', () async {
      settings = await makeSettings();
      await attach(settings);
      expect(count('setSourceUrl'), 1);
      expect(count('resume'), 1);
    });

    test('does not start when audioOn is false', () async {
      settings = await makeSettings(audio: false);
      await attach(settings);
      expect(count('setSourceUrl'), 0);
      expect(count('resume'), 0);
    });

    test('attaching the same settings twice does not restart music', () async {
      settings = await makeSettings();
      await attach(settings);
      await attach(settings);
      expect(count('setSourceUrl'), 1);
    });

    test('does not throw when autoplay is blocked on attach', () async {
      failResume = true;
      settings = await makeSettings();
      await attach(settings);
      expect(count('setSourceUrl'), 1);
      expect(count('resume'), 0);
    });
  });

  group('attach waits for settings.loaded', () {
    test('does not start music before the load completes', () async {
      final store = _MemoryPersistence()..gate = Completer<void>();
      settings = SettingsController(store: store);
      await attach(settings);
      expect(count('setSourceUrl'), 0);
      expect(count('resume'), 0);

      store.gate!.complete();
      await settle();
      expect(count('setSourceUrl'), 1);
      expect(count('resume'), 1);
    });

    test('persisted off never plays, even with early unlock/resume', () async {
      final store = _MemoryPersistence()
        ..audioOn = false
        ..gate = Completer<void>();
      settings = SettingsController(store: store);
      await attach(settings);

      // Before load: default audioOn is still true.
      await controller.unlockAndStartMusic();
      lifecycle.value = AppLifecycleState.paused;
      lifecycle.value = AppLifecycleState.resumed;
      await settle();

      store.gate!.complete();
      await settle();
      expect(settings.audioOn.value, isFalse);

      // After load.
      await controller.unlockAndStartMusic();
      lifecycle.value = AppLifecycleState.paused;
      lifecycle.value = AppLifecycleState.resumed;
      await settle();

      expect(count('setSourceUrl'), 0);
      expect(count('resume'), 0);
    });

    test('a failing load does not raise an unhandled error', () async {
      final store = _MemoryPersistence()..failLoad = true;
      settings = SettingsController(store: store);
      await expectLater(settings.loaded, throwsStateError);
      await attach(settings);
      await expectLater(controller.unlockAndStartMusic(), completes);
    });
  });

  group('dispose', () {
    test('removes the listener so toggling causes no player calls', () async {
      settings = await makeSettings();
      await attach(settings);
      controller.dispose();
      await settle();
      calls.clear();
      sfxCalls.clear();

      settings.toggleAudioOn();
      settings.toggleAudioOn();
      await settle();
      expect(calls, isEmpty);
      expect(sfxCalls, isEmpty);

      // Fresh controller so tearDown can dispose without a double dispose.
      controller = AudioController();
      await settle();
    });
  });

  group('dispose hardening (OBS-022)', () {
    test('double dispose is safe', () async {
      settings = await makeSettings();
      await attach(settings);
      controller.dispose();
      expect(() => controller.dispose(), returnsNormally);
      await settle();
    });

    test('no player calls after dispose', () async {
      settings = await makeSettings();
      await attach(settings);
      controller.dispose();
      await settle();
      calls.clear();
      sfxCalls.clear();

      settings.toggleAudioOn();
      settings.toggleAudioOn();
      lifecycle.value = AppLifecycleState.paused;
      lifecycle.value = AppLifecycleState.resumed;
      await controller.unlockAndStartMusic();
      await settle();
      expect(calls, isEmpty);
      expect(sfxCalls, isEmpty);
    });

    test('dispose with an in-flight start leaves no unhandled error', () async {
      resumeGate = Completer<void>();
      settings = await makeSettings();
      await attach(settings);
      expect(count('resume'), 1);

      controller.dispose();
      resumeGate!.complete();
      await settle();
      // Reaching here without an uncaught async error fails nothing.
    });
  });

  group('start during in-flight start (OBS-033)', () {
    test('mute during in-flight start ends paused', () async {
      resumeGate = Completer<void>();
      settings = await makeSettings();
      await attach(settings);
      settings.toggleAudioOn();
      await settle();
      calls.clear();

      resumeGate!.complete();
      await settle();
      expect(playbackCalls().last, 'pause');
    });

    test('mute then unmute during in-flight start ends playing', () async {
      resumeGate = Completer<void>();
      settings = await makeSettings();
      await attach(settings);
      settings.toggleAudioOn();
      settings.toggleAudioOn();
      await settle();
      calls.clear();

      resumeGate!.complete();
      await settle();
      expect(count('resume'), greaterThanOrEqualTo(1));
      expect(playbackCalls().last, 'resume');
    });

    test('unlockAndStartMusic during in-flight start is not lost', () async {
      resumeGate = Completer<void>();
      settings = await makeSettings();
      await attach(settings);
      expect(count('resume'), 1);

      final unlock = controller.unlockAndStartMusic();
      resumeGate!.complete();
      await unlock;
      await settle();
      expect(count('resume'), 2);
    });

    test('blocked play does not loop forever', () async {
      failResume = true;
      resumeGate = Completer<void>();
      settings = await makeSettings();
      await attach(settings);

      final unlock = controller.unlockAndStartMusic();
      resumeGate!.complete();
      await unlock;
      await settle();
      final after = count('setSourceUrl');
      expect(after, lessThanOrEqualTo(2));

      await settle();
      expect(count('setSourceUrl'), after);
    });
  });

  group('song finished (OBS-034)', () {
    void emitComplete() =>
        preparedSinks['musicPlayer']!.success({'event': 'audio.onComplete'});

    test('restarts music while audio is enabled', () async {
      settings = await makeSettings();
      await attach(settings);
      calls.clear();
      emitComplete();
      await settle();
      expect(count('setSourceUrl'), 1);
      expect(count('resume'), 1);
    });

    test('does not restart music while muted', () async {
      settings = await makeSettings();
      await attach(settings);
      settings.toggleAudioOn();
      await settle();
      calls.clear();
      emitComplete();
      await settle();
      expect(count('setSourceUrl'), 0);
      expect(count('resume'), 0);
    });

    test('does nothing after dispose', () async {
      settings = await makeSettings();
      await attach(settings);
      final sink = preparedSinks['musicPlayer']!;
      controller.dispose();
      await settle();
      calls.clear();
      try {
        sink.success({'event': 'audio.onComplete'});
      } catch (_) {}
      await settle();
      expect(calls, isEmpty);
    });
  });

  group('toggles', () {
    test('audioOn off pauses and on resumes music', () async {
      settings = await makeSettings();
      await attach(settings);
      calls.clear();

      settings.toggleAudioOn();
      await settle();
      expect(count('pause'), greaterThanOrEqualTo(1));

      calls.clear();
      settings.toggleAudioOn();
      await settle();
      expect(count('resume'), 1);
    });
  });

  group('playSfx (OBS-031)', () {
    test('is muted when audioOn is false', () async {
      settings = await makeSettings(audio: false);
      await attach(settings);
      controller.playSfx(SfxType.score);
      controller.playSfx(SfxType.damage);
      controller.playSfx(SfxType.buttonTap);
      await settle();
      expect(
        sfxCalls.where((c) => c == 'resume' || c == 'setSourceUrl'),
        isEmpty,
      );
    });

    test('is muted when no settings are attached', () async {
      controller.playSfx(SfxType.score);
      await settle();
      expect(
        sfxCalls.where((c) => c == 'resume' || c == 'setSourceUrl'),
        isEmpty,
      );
    });

    test('is audible when audioOn is true', () async {
      settings = await makeSettings();
      await attach(settings);
      sfxCalls.clear();
      controller.playSfx(SfxType.score);
      await settle();
      expect(sfxCalls, contains('setSourceUrl'));
      expect(sfxCalls, contains('resume'));
    });

    test('toggling audioOn off then on mutes then restores SFX', () async {
      settings = await makeSettings();
      await attach(settings);
      settings.toggleAudioOn();
      await settle();
      sfxCalls.clear();
      controller.playSfx(SfxType.buttonTap);
      await settle();
      expect(sfxCalls.where((c) => c == 'resume'), isEmpty);

      settings.toggleAudioOn();
      await settle();
      sfxCalls.clear();
      controller.playSfx(SfxType.buttonTap);
      await settle();
      expect(sfxCalls, contains('resume'));
    });
  });

  group('settings defaults', () {
    test('audioOn defaults to true before and after load', () async {
      final s = SettingsController(store: _MemoryPersistence());
      expect(s.audioOn.value, isTrue);
      await settle();
      expect(s.audioOn.value, isTrue);
    });

    test('audioOn false is restored from persistence', () async {
      final s = await makeSettings(audio: false);
      expect(s.audioOn.value, isFalse);
    });
  });

  group('unlockAndStartMusic', () {
    test('is a no-op before settings are attached', () async {
      await controller.unlockAndStartMusic();
      expect(calls, isEmpty);
    });

    test('is a no-op when audio is off', () async {
      final muted = await makeSettings(audio: false);
      await attach(muted);
      await controller.unlockAndStartMusic();
      expect(count('setSourceUrl'), 0);
      expect(count('resume'), 0);
    });

    test('starts music when blocked autoplay left it stopped', () async {
      failResume = true;
      settings = await makeSettings();
      await attach(settings);
      expect(count('resume'), 0);

      failResume = false;
      await controller.unlockAndStartMusic();
      await settle();
      expect(count('resume'), 1);
    });

    test('is idempotent and never silences playing music', () async {
      settings = await makeSettings();
      await attach(settings);
      calls.clear();

      await controller.unlockAndStartMusic();
      await controller.unlockAndStartMusic();
      await controller.unlockAndStartMusic();
      await settle();
      expect(calls, isEmpty);
    });

    test('resumes music paused by a lifecycle change', () async {
      settings = await makeSettings();
      await attach(settings);
      lifecycle.value = AppLifecycleState.paused;
      await settle();
      calls.clear();

      await controller.unlockAndStartMusic();
      await settle();
      expect(count('resume'), 1);
      expect(count('pause'), 0);
    });

    test('does not throw when play fails repeatedly', () async {
      failResume = true;
      settings = await makeSettings();
      await attach(settings);
      await expectLater(controller.unlockAndStartMusic(), completes);
      await expectLater(controller.unlockAndStartMusic(), completes);
    });
  });

  group('lifecycle', () {
    for (final state in [
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.detached,
    ]) {
      test('$state pauses music', () async {
        settings = await makeSettings();
        await attach(settings);
        calls.clear();
        lifecycle.value = state;
        await settle();
        expect(count('pause'), greaterThanOrEqualTo(1));
      });
    }

    test('inactive does not touch music', () async {
      settings = await makeSettings();
      await attach(settings);
      calls.clear();
      lifecycle.value = AppLifecycleState.inactive;
      await settle();
      expect(calls, isEmpty);
    });

    test('resumed restarts music when allowed', () async {
      settings = await makeSettings();
      await attach(settings);
      lifecycle.value = AppLifecycleState.paused;
      await settle();
      calls.clear();
      lifecycle.value = AppLifecycleState.resumed;
      await settle();
      expect(count('resume'), 1);
    });
  });
}
