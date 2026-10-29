List<String> soundTypeToFilename(SfxType type) => switch (type) {
  SfxType.damage => const ['damage1.mp3', 'damage2.mp3'],
  SfxType.score => const ['score1.mp3', 'score2.mp3'],
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
    case SfxType.damage:
      return 0.4;
    case SfxType.buttonTap:
      return 1.0;
  }
}

enum SfxType { score, damage, buttonTap }
