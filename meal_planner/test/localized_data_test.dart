import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/locale/localized_data.dart';

void main() {
  group('normalizeCategoryKey', () {
    test('defaults empty values to vegetables', () {
      expect(normalizeCategoryKey(null), defaultIngredientCategoryKey);
      expect(normalizeCategoryKey(''), defaultIngredientCategoryKey);
    });

    test('keeps known keys', () {
      expect(normalizeCategoryKey('meat_fish'), 'meat_fish');
    });

    test('maps legacy Spanish labels', () {
      expect(normalizeCategoryKey('Verduras'), 'vegetables');
      expect(normalizeCategoryKey('Carnes y pescados'), 'meat_fish');
      expect(normalizeCategoryKey('Panadería'), 'baking');
    });

    test('falls back to other for unknown labels', () {
      expect(normalizeCategoryKey('Cosas raras'), 'other');
    });
  });

  group('normalizeTagKey', () {
    test('keeps canonical keys', () {
      expect(normalizeTagKey('dessert'), 'dessert');
      expect(normalizeTagKey('kid_friendly'), 'kid_friendly');
    });

    test('maps legacy Spanish labels', () {
      expect(normalizeTagKey('postre'), 'dessert');
      expect(normalizeTagKey('sin gluten'), 'gluten_free');
      expect(normalizeTagKey('para niños'), 'kid_friendly');
    });

    test('returns unknown tags unchanged', () {
      expect(normalizeTagKey('casera'), 'casera');
    });
  });
}
