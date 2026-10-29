/// Pure pseudo-3D projection math for items on the conveyor belt.
///
/// Items track a normalized depth `z` in [0, 1]: 0 is the near plane (bottom
/// of the screen), 1 is Cauã's mouth on the horizon. See architecture
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

  /// Y of the horizon / mouth (z = 1).
  static const double yHorizon = 400.0;

  /// X where items spawn at the near plane (horizontal center).
  static const double xSpawn = 360.0;

  /// X of Cauã's mouth at the horizon (horizontal center).
  static const double xMouth = 360.0;

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
