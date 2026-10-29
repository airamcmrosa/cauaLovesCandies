import 'package:caua_loves_candies/game/managers/item_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItemType catalog', () {
    test('has 16 items', () {
      expect(ItemType.values.length, 16);
    });

    test('ofCategory returns the right counts', () {
      expect(ItemType.ofCategory(ItemCategory.sweet).length, 7);
      expect(ItemType.ofCategory(ItemCategory.fruit).length, 5);
      expect(ItemType.ofCategory(ItemCategory.hazard).length, 4);
    });

    test('ofCategory only returns items of that category', () {
      for (final c in ItemCategory.values) {
        expect(ItemType.ofCategory(c).every((t) => t.category == c), isTrue);
      }
    });

    test('ofCategory partitions the whole catalog', () {
      final all = [
        for (final c in ItemCategory.values) ...ItemType.ofCategory(c),
      ];
      expect(all.toSet(), ItemType.values.toSet());
      expect(all.length, ItemType.values.length);
    });

    test('sweets give +2 points and 0 hp', () {
      for (final t in ItemType.ofCategory(ItemCategory.sweet)) {
        expect(t.points, 2, reason: t.name);
        expect(t.hpDelta, 0, reason: t.name);
      }
    });

    test('fruits give +1 point and 0 hp', () {
      for (final t in ItemType.ofCategory(ItemCategory.fruit)) {
        expect(t.points, 1, reason: t.name);
        expect(t.hpDelta, 0, reason: t.name);
      }
    });

    test('hazards give 0 points and -1 hp', () {
      for (final t in ItemType.ofCategory(ItemCategory.hazard)) {
        expect(t.points, 0, reason: t.name);
        expect(t.hpDelta, -1, reason: t.name);
      }
    });

    test('names and labels are unique and non-empty', () {
      final names = ItemType.values.map((t) => t.name).toSet();
      final labels = ItemType.values.map((t) => t.label).toSet();
      expect(names.length, ItemType.values.length);
      expect(labels.length, ItemType.values.length);
      expect(ItemType.values.every((t) => t.label.isNotEmpty), isTrue);
    });
  });
}
