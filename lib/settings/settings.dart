// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'persistence/local_storage_settings_persistence.dart';
import 'persistence/settings_persistence.dart';

/// An class that holds settings like [audioOn] or [playerName],
/// and saves them to an injected persistence store.
class SettingsController {
  static final _log = Logger('SettingsController');

  /// The persistence store that is used to save settings.
  final SettingsPersistence _store;

  /// Whether or not the audio is on at all. This overrides both music
  /// and sounds (sfx).
  ///
  /// This is an important feature especially on mobile, where players
  /// expect to be able to quickly mute all the audio. Having this as
  /// a separate flag (as opposed to some kind of {off, sound, everything}
  /// enum) keeps a single, simple mute switch for music and sfx.
  ValueNotifier<bool> audioOn = ValueNotifier(true);

  /// The player's name. Used for things like high score lists.
  ValueNotifier<String> playerName = ValueNotifier('Player');

  /// Completes once persisted values have been loaded into the notifiers.
  late final Future<void> loaded;

  /// Creates a new instance of [SettingsController] backed by [store].
  ///
  /// By default, settings are persisted using [LocalStorageSettingsPersistence]
  /// (i.e. NSUserDefaults on iOS, SharedPreferences on Android or
  /// local storage on the web).
  SettingsController({SettingsPersistence? store})
    : _store = store ?? LocalStorageSettingsPersistence() {
    loaded = _loadStateFromPersistence();
  }

  void setPlayerName(String name) {
    playerName.value = name;
    _store.savePlayerName(playerName.value);
  }

  void toggleAudioOn() {
    audioOn.value = !audioOn.value;
    _store.saveAudioOn(audioOn.value);
  }

  /// Asynchronously loads values from the injected persistence store.
  Future<void> _loadStateFromPersistence() async {
    final loadedValues = await Future.wait([
      _store
          .getAudioOn(defaultValue: true)
          .then((value) => audioOn.value = value),
      _store.getPlayerName().then((value) => playerName.value = value),
    ]);

    _log.fine(() => 'Loaded settings: $loadedValues');
  }
}
