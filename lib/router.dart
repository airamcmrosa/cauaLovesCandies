import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'game/caua_game_screen.dart';
import 'ui/title_route.dart';

/// The router describes the game's navigational hierarchy, from the main
/// screen to the game screen.
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TitleRoute(key: Key('title')),
      routes: [
        GoRoute(
          path: 'caua',
          builder: (context, state) =>
              const CauaGameScreen(key: Key('caua game')),
        ),
      ],
    ),
  ],
);
