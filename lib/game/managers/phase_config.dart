/// Const phase table: speed multiplier and spawn composition per phase.
///
/// Target score and banner text belong to TASK-004, not here.
library;

import 'item_type.dart';

/// Time scale applied to belt, spawner and items while the tutorial shows.
/// 0.0 means fully paused; play resumes at 1.0 on dismissal.
const double kTutorialTimeScale = 0.0;

/// Relative spawn weights per category (not required to sum to 100).
class CategoryWeights {
  const CategoryWeights({
    required this.sweets,
    required this.fruits,
    required this.hazards,
  });

  final int sweets;
  final int fruits;
  final int hazards;

  int get total => sweets + fruits + hazards;

  /// Weight for [category].
  int of(ItemCategory category) => switch (category) {
    ItemCategory.sweet => sweets,
    ItemCategory.fruit => fruits,
    ItemCategory.hazard => hazards,
  };
}

/// Configuration of a single phase.
class PhaseConfig {
  const PhaseConfig({required this.speedMultiplier, required this.weights});

  /// Belt speed multiplier relative to Phase 1.
  final double speedMultiplier;

  /// Spawn composition (sweets/fruits/hazards).
  final CategoryWeights weights;
}

/// Phase table; index 0 is Phase 1.
const List<PhaseConfig> kPhases = [
  PhaseConfig(
    speedMultiplier: 1.0,
    weights: CategoryWeights(sweets: 70, fruits: 20, hazards: 10),
  ),
  PhaseConfig(
    speedMultiplier: 1.35,
    weights: CategoryWeights(sweets: 50, fruits: 30, hazards: 20),
  ),
  // Final challenge composition, weighted toward forbidden items (45%).
  PhaseConfig(
    speedMultiplier: 1.65,
    weights: CategoryWeights(sweets: 25, fruits: 30, hazards: 45),
  ),
];
