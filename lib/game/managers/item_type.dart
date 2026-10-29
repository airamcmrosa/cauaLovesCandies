/// Item catalog for the conveyor belt (US03 AC2).
///
/// Dart-only, const data. Points and HP deltas live here so no literals are
/// scattered across components or managers.
library;

/// Category of a conveyor item.
enum ItemCategory {
  /// Sweets: +2 points when ingested.
  sweet(points: 2, hpDelta: 0),

  /// Fruits: +1 point when ingested.
  fruit(points: 1, hpDelta: 0),

  /// Forbidden items: -1 HP when ingested.
  hazard(points: 0, hpDelta: -1);

  const ItemCategory({required this.points, required this.hpDelta});

  /// Points awarded when an item of this category is ingested.
  final int points;

  /// HP change applied when an item of this category is ingested.
  final int hpDelta;
}

/// Unified catalog of every item that can appear on the belt.
enum ItemType {
  // Sweets.
  lollipop(ItemCategory.sweet, 'Pirulito'),
  donut(ItemCategory.sweet, 'Rosquinha'),
  sprinkles(ItemCategory.sweet, 'Granulado'),
  candy(ItemCategory.sweet, 'Bala'),
  cupcake(ItemCategory.sweet, 'Cupcake'),
  cottonCandy(ItemCategory.sweet, 'Algodao-doce'),
  gum(ItemCategory.sweet, 'Chiclete'),

  // Fruits.
  strawberry(ItemCategory.fruit, 'Morango'),
  banana(ItemCategory.fruit, 'Banana'),
  watermelon(ItemCategory.fruit, 'Melancia'),
  grape(ItemCategory.fruit, 'Uva'),
  orange(ItemCategory.fruit, 'Laranja'),

  // Hazards.
  broccoli(ItemCategory.hazard, 'Brocolis'),
  soap(ItemCategory.hazard, 'Sabao'),
  dirtySock(ItemCategory.hazard, 'Meia suja'),
  onion(ItemCategory.hazard, 'Cebola');

  const ItemType(this.category, this.label);

  final ItemCategory category;

  /// Display name (pt-BR).
  final String label;

  int get points => category.points;

  int get hpDelta => category.hpDelta;

  /// All item types of [category], in catalog order.
  static List<ItemType> ofCategory(ItemCategory category) => [
    for (final type in values)
      if (type.category == category) type,
  ];
}
