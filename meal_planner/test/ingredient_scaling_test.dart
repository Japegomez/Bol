import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/planner/domain/ingredient_scaling.dart';

void main() {
  group('servingsScale', () {
    test('is 1 when chosen servings match the recipe', () {
      expect(servingsScale(chosenServings: 4, recipeServings: 4), 1);
    });

    test('halves when planning half the recipe yield', () {
      expect(servingsScale(chosenServings: 2, recipeServings: 4), 0.5);
    });

    test('doubles when planning twice the recipe yield', () {
      expect(servingsScale(chosenServings: 8, recipeServings: 4), 2);
    });

    test('returns 0 when recipe servings are invalid', () {
      expect(servingsScale(chosenServings: 2, recipeServings: 0), 0);
    });
  });

  group('scaleIngredientQuantity', () {
    test('returns null for to-taste / missing quantity', () {
      expect(scaleIngredientQuantity(null, 2), isNull);
    });

    test('scales and rounds to nearest integer', () {
      // Recipe: 4 servings, 100 g → plan 2 servings → 50 g
      final scale = servingsScale(chosenServings: 2, recipeServings: 4);
      expect(scaleIngredientQuantity(100, scale), 50);

      // Recipe: 3 servings, 100 g → plan 2 servings → 66.6… → 67
      final uneven = servingsScale(chosenServings: 2, recipeServings: 3);
      expect(scaleIngredientQuantity(100, uneven), 67);
    });

    test('keeps zero quantity as zero', () {
      expect(scaleIngredientQuantity(0, 2.5), 0);
    });

    test('scales fractional base quantities', () {
      final scale = servingsScale(chosenServings: 6, recipeServings: 2);
      expect(scaleIngredientQuantity(0.5, scale), 2);
    });
  });
}
