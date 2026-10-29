import 'dart:io';

import 'package:caua_loves_candies/app_lifecycle/app_lifecycle.dart';
import 'package:caua_loves_candies/audio/audio_controller.dart';
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

  @override
  Future<bool> getAudioOn({required bool defaultValue}) async => audioOn;
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
  late bool failResume;
  late Map<String, MockStreamHandlerEventSink> preparedSinks;
  late AudioController controller;
  late SettingsController settings;
  late AppLifecycleStateNotifier lifecycle;

  // Calls on the music player only (SFX players are never touched here).
  int count(String method) => calls.where((c) => c == method).length;

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

  Future<SettingsController> makeSettings({
    bool audio = true,
    bool music = true,
  }) async {
    final store = _MemoryPersistence()
      ..audioOn = audio
      ..musicOn = music;
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
    preparedSinks = {};
    failResume = false;
    messenger.setMockMethodCallHandler(audioChannel, (call) async {
      if (call.arguments is Map &&
          (call.arguments as Map)['playerId'] == 'musicPlayer') {
        final blocked = call.method == 'resume' && failResume;
        calls.add(blocked ? 'resumeBlocked' : call.method);
      }
      if (call.method == 'setSourceUrl') {
        Future<void>.delayed(Duration.zero, () {
          preparedSinks['musicPlayer']?.success({
            'event': 'audio.onPrepared',
            'value': true,
          });
        });
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
    test('tries to start music when audioOn and musicOn are true', () async {
      settings = await makeSettings();
      await attach(settings);
      expect(count('setSourceUrl'), 1);
      expect(count('resume'), 1);
    });

    test('does not start when musicOn is false', () async {
      settings = await makeSettings(music: false);
      await attach(settings);
      expect(count('setSourceUrl'), 0);
      expect(count('resume'), 0);
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

  group('toggles', () {
    test('musicOn off pauses and on resumes', () async {
      settings = await makeSettings();
      await attach(settings);
      calls.clear();

      settings.toggleMusicOn();
      await settle();
      expect(settings.musicOn.value, isFalse);
      expect(count('pause'), greaterThanOrEqualTo(1));

      calls.clear();
      settings.toggleMusicOn();
      await settle();
      expect(count('resume'), 1);
    });

    test('audioOn off pauses and on resumes when music is on', () async {
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

    test('audioOn on does not start music when musicOn is false', () async {
      settings = await makeSettings(audio: false, music: false);
      await attach(settings);
      settings.toggleAudioOn();
      await settle();
      expect(count('resume'), 0);
      expect(count('setSourceUrl'), 0);
    });

    test('musicOn on does not start music while audio is off', () async {
      settings = await makeSettings(audio: false, music: false);
      await attach(settings);
      settings.toggleMusicOn();
      await settle();
      expect(count('resume'), 0);
      expect(count('setSourceUrl'), 0);
    });
  });

  group('unlockAndStartMusic', () {
    test('is a no-op before settings are attached', () async {
      await controller.unlockAndStartMusic();
      expect(calls, isEmpty);
    });

    test('is a no-op when music is off or audio is off', () async {
      settings = await makeSettings(music: false);
      await attach(settings);
      await controller.unlockAndStartMusic();
      expect(count('setSourceUrl'), 0);
      expect(count('resume'), 0);

      controller.dispose();
      controller = AudioController();
      await settle();
      calls.clear();
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

    test('resumed does not restart music when musicOn is false', () async {
      settings = await makeSettings();
      await attach(settings);
      settings.toggleMusicOn();
      await settle();
      lifecycle.value = AppLifecycleState.paused;
      await settle();
      calls.clear();
      lifecycle.value = AppLifecycleState.resumed;
      await settle();
      expect(count('resume'), 0);
    });
  });
}
