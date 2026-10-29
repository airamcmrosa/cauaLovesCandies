List<String> soundTypeToFilename(SfxType type) => switch (type) {
  SfxType.damage => const ['damage1.mp3', 'damage2.mp3'],
  SfxType.score => const ['score1.mp3', 'score2.mp3'],
  SfxType.fruit => const ['score2.mp3'],
  SfxType.hmm => const ['hmm.mp3'],
  SfxType.eurk => const ['eurk.mp3'],
  SfxType.buttonTap => const [
    'click1.mp3',
    'click2.mp3',
    'click3.mp3',
    'click4.mp3',
  ],
};

/// Allows control over loudness of different SFX types.
double soundTypeToVolume(SfxType type) {
  switch (type) {
    case SfxType.score:
    case SfxType.fruit:
    case SfxType.damage:
      return 0.4;
    // Short product-owner voice clips: full volume, like UI taps, so the
    // reaction is clearly audible over the music.
    case SfxType.hmm:
    case SfxType.eurk:
    case SfxType.buttonTap:
      return 1.0;
  }
}

enum SfxType { score, fruit, damage, hmm, eurk, buttonTap }

/// Asset path relative to the `assets/` prefix of `AudioCache`. Voice clips
/// (hmm, eurk) live in `assets/audio/`, every other SFX in `assets/sfx/`.
String sfxAssetPath(SfxType type, String filename) => switch (type) {
  SfxType.hmm || SfxType.eurk => 'audio/$filename',
  SfxType.score ||
  SfxType.fruit ||
  SfxType.damage ||
  SfxType.buttonTap => 'sfx/$filename',
};
