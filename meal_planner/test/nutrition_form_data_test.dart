import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';

void main() {
  group('NutritionFormData.normalizeNutritionValue', () {
    test('rounds decimals to nearest int', () {
      expect(NutritionFormData.normalizeNutritionValue(12.4), 12);
      expect(NutritionFormData.normalizeNutritionValue(12.5), 13);
    });

    test('rejects negatives', () {
      expect(NutritionFormData.normalizeNutritionValue(-1), isNull);
      expect(NutritionFormData.normalizeNutritionValue(-0.1), isNull);
    });

    test('rejects non-finite values', () {
      expect(NutritionFormData.normalizeNutritionValue(double.nan), isNull);
      expect(
        NutritionFormData.normalizeNutritionValue(double.infinity),
        isNull,
      );
      expect(
        NutritionFormData.normalizeNutritionValue(double.negativeInfinity),
        isNull,
      );
    });

    test('keeps null and zero', () {
      expect(NutritionFormData.normalizeNutritionValue(null), isNull);
      expect(NutritionFormData.normalizeNutritionValue(0), 0);
    });

    test('constructor normalizes legacy num fields', () {
      final data = NutritionFormData(
        calories: 100.6,
        protein: -3,
        carbohydrates: double.nan,
        fat: 2,
      );
      expect(data.calories, 101);
      expect(data.protein, isNull);
      expect(data.carbohydrates, isNull);
      expect(data.fat, 2);
    });
  });
}
