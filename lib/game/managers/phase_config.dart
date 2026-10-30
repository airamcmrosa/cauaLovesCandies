/// Const phase table: speed multiplier, target score, banner text and spawn
/// composition per phase.
library;

import 'item_type.dart';

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
  const PhaseConfig({
    required this.speedMultiplier,
    required this.targetScore,
    required this.weights,
    this.bannerText,
  });

  /// Belt speed multiplier relative to the base belt speed.
  final double speedMultiplier;

  /// Cumulative total score that completes this phase.
  final int targetScore;

  /// Spawn composition (sweets/fruits/hazards).
  final CategoryWeights weights;

  /// Banner shown when entering this phase; null when none (Phase 1).
  final String? bannerText;
}

/// Geometric growth ratio of the belt speed per phase (1.2^phase).
const double kPhaseSpeedRatio = 1.2;

/// Phase table; index 0 is Phase 1.
const List<PhaseConfig> kPhases = [
  PhaseConfig(
    speedMultiplier: kPhaseSpeedRatio,
    targetScore: 10,
    weights: CategoryWeights(sweets: 70, fruits: 20, hazards: 10),
  ),
  PhaseConfig(
    speedMultiplier: kPhaseSpeedRatio * kPhaseSpeedRatio,
    targetScore: 20,
    bannerText: 'Fase 2 - Mais Rápido!',
    weights: CategoryWeights(sweets: 50, fruits: 30, hazards: 20),
  ),
  // Final challenge composition, weighted toward forbidden items (45%).
  PhaseConfig(
    speedMultiplier: kPhaseSpeedRatio * kPhaseSpeedRatio * kPhaseSpeedRatio,
    targetScore: 30,
    bannerText: 'Fase 3 - Super Rápido!',
    weights: CategoryWeights(sweets: 25, fruits: 30, hazards: 45),
  ),
];
