/// Pure pseudo-3D projection math for items on the conveyor belt.
///
/// Items track a normalized depth `z` in [0, 1]: 0 is the near plane (bottom
/// of the screen), 1 is the belt end at Cauã's shoulder on the horizon. See architecture
/// section 2.
library;

/// Result of evaluating an item against the decision boundary.
enum ItemOutcome {
  /// The item has not reached the decision boundary yet.
  undecided,

  /// The item reached the mouth while it was open.
  ingest,

  /// The item reached the mouth while it was closed.
  deflect,
}

/// Projection constants in the 720x1280 virtual resolution.
abstract final class Projection {
  /// Scale at the near plane (z = 0).
  static const double scaleBottom = 1.0;

  /// Scale at the horizon (z = 1).
  static const double scaleHorizon = 0.25;

  /// Y of the near plane (z = 0).
  static const double yBottom = 1180.0;

  /// Y of the horizon / belt far end (z = 1), at Cauã's shoulder line.
  static const double yHorizon = 480.0;

  /// X where items spawn at the near plane (horizontal center).
  static const double xSpawn = 360.0;

  /// X of Cauã's mouth at the horizon (horizontal center).
  static const double xMouth = 360.0;

  /// Cauã's sprite is a square of this size (sprite is 512x512).
  ///
  /// Single source of truth; `CauaCandiesGame.playerSize` aliases it.
  static const double playerSize = 240.0;

  /// Shoulder line (top of the shirt) as a fraction of the sprite height,
  /// measured on the 512px webp: y~410 / 512 = 0.80.
  static const double shoulderFraction = 0.80;

  /// Mouth center as a fraction of the sprite height (y~325 / 512 = 0.635).
  static const double mouthFraction = 0.635;

  /// Center Y of Cauã so his shoulder line sits on [yHorizon]:
  /// 480 - (0.80 - 0.5) * 240 = 408.
  static const double playerCenterY =
      yHorizon - (shoulderFraction - 0.5) * playerSize;

  /// Y of Cauã's mouth center, target of the ingest tween.
  ///
  /// The shoulder line is on [yHorizon], so the mouth sits
  /// (0.80 - 0.635) * 240 above it: 480 - 39.6 = 440.4.
  static const double yMouth =
      yHorizon - (shoulderFraction - mouthFraction) * playerSize;

  /// Depth at which the mouth decision is evaluated.
  static const double decisionZ = 0.95;
}

/// Screen scale for depth [z].
double scaleAt(double z) =>
    Projection.scaleBottom +
    (Projection.scaleHorizon - Projection.scaleBottom) * z;

/// Screen Y for depth [z].
double yAt(double z) =>
    Projection.yBottom + (Projection.yHorizon - Projection.yBottom) * z;

/// Screen X for depth [z].
double xAt(double z) =>
    Projection.xSpawn + (Projection.xMouth - Projection.xSpawn) * z;

/// Decides what happens to an item at depth [z] given the mouth state.
ItemOutcome decideOutcome(double z, {required bool mouthOpen}) {
  if (z < Projection.decisionZ) return ItemOutcome.undecided;
  return mouthOpen ? ItemOutcome.ingest : ItemOutcome.deflect;
}
