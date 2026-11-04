import 'dart:async';
import 'dart:developer' as developer;

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import 'app_lifecycle/app_lifecycle.dart';
import 'audio/audio_controller.dart';
import 'player_progress/player_progress.dart';
import 'router.dart';
import 'settings/settings.dart';
import 'style/palette.dart';
import 'ui/error_reporter.dart';

/// Routes every `package:logging` record to the terminal (`flutter run`),
/// the browser console (web) and the DevTools "Logging" tab.
///
/// Without a listener on [Logger.root] the app's `Logger`s print nothing.
void _setUpLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  // Native player state ("player status: ...") from audioplayers, debug only.
  if (kDebugMode) AudioLogger.logLevel = AudioLogLevel.info;
  Logger.root.onRecord.listen((record) {
    final line =
        '${record.level.name}: ${record.loggerName}: ${record.message}';
    debugPrint(line);
    if (record.error != null) debugPrint('  error: ${record.error}');
    if (record.stackTrace != null) debugPrint('${record.stackTrace}');
    developer.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  });
}

void main() {
  _setUpLogging();
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    ErrorReporter.instance.install();
    await Flame.device.setPortraitUpOnly();
    await Flame.device.fullScreen();
    runApp(ErrorGate(reporter: ErrorReporter.instance, child: const MyGame()));
  }, (e, s) => ErrorReporter.instance.report(e, s));
}

class MyGame extends StatelessWidget {
  const MyGame({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          Provider(create: (context) => Palette()),
          ChangeNotifierProvider(create: (context) => PlayerProgress()),
          Provider(create: (context) => SettingsController()),
          // Set up audio.
          ProxyProvider2<
            SettingsController,
            AppLifecycleStateNotifier,
            AudioController
          >(
            // Ensures that music starts immediately.
            lazy: false,
            create: (context) => AudioController(),
            update: (context, settings, lifecycleNotifier, audio) {
              audio!.attachDependencies(lifecycleNotifier, settings);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
          ),
        ],
        child: Builder(
          builder: (context) {
            final palette = context.watch<Palette>();

            return MaterialApp.router(
              title: 'Cauã Loves Candies',
              theme: flutterNesTheme().copyWith(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: palette.seed.color,
                  surface: palette.backgroundMain.color,
                ),
                textTheme: GoogleFonts.pressStart2pTextTheme().apply(
                  bodyColor: palette.text.color,
                  displayColor: palette.text.color,
                ),
              ),
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
