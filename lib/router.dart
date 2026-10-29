import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'game/caua_game_screen.dart';
import 'main_menu/main_menu_screen.dart';
import 'settings/settings_screen.dart';

/// The router describes the game's navigational hierarchy, from the main
/// screen to the game and settings screens.
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainMenuScreen(key: Key('main menu')),
      routes: [
        GoRoute(
          path: 'caua',
          builder: (context, state) =>
              const CauaGameScreen(key: Key('caua game')),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) =>
              const SettingsScreen(key: Key('settings')),
        ),
      ],
    ),
  ],
);
