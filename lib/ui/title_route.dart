import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game/managers/asset_preloader.dart';
import '../settings/settings.dart';
import 'title_screen.dart';

/// Route wrapper that owns the [AssetPreloader] and wires [TitleScreen].
class TitleRoute extends StatefulWidget {
  const TitleRoute({super.key});

  @override
  State<TitleRoute> createState() => _TitleRouteState();
}

class _TitleRouteState extends State<TitleRoute> {
  // Shares the global Flame image cache with the game.
  late final AssetPreloader _preloader = AssetPreloader(images: Flame.images);

  @override
  void initState() {
    super.initState();
    _preloader.preload();
  }

  @override
  void dispose() {
    _preloader.dispose();
    super.dispose();
  }

  void _onPlay() {
    if (_preloader.state.value is! PreloadDone) return;
    context.read<AudioController>().playSfx(SfxType.buttonTap);
    GoRouter.of(context).go('/caua');
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsController>();
    return TitleScreen(
      preloadState: _preloader.state,
      onPlay: _onPlay,
      onFirstTap: () => context.read<AudioController>().unlockAndStartMusic(),
      onRetry: _preloader.preload,
      soundOn: settings.audioOn,
      onToggleSound: settings.toggleAudioOn,
    );
  }
}
