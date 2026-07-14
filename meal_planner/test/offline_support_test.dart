import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/core/sync/recipe_form_data_codec.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';

void main() {
  group('isOfflineFromConnectivity', () {
    test('returns true when connectivity list is empty', () {
      expect(isOfflineFromConnectivity([]), isTrue);
    });

    test('returns false when wifi is available', () {
      expect(
        isOfflineFromConnectivity([ConnectivityResult.wifi]),
        isFalse,
      );
    });
  });

  group('RecipeFormDataCodec', () {
    test('round-trips recipe form data', () {
      final form = RecipeFormData(
        title: 'Tortilla',
        servings: 2,
        tags: ['entrante'],
        tips: 'Servir caliente',
        ingredients: [
          IngredientFormItem(name: 'Huevo', quantity: 3, unit: 'unidad'),
        ],
        steps: [StepFormItem(description: 'Batir y freír')],
      );

      final restored = RecipeFormDataCodec.fromJson(
        RecipeFormDataCodec.toJson(form),
      );

      expect(restored.title, 'Tortilla');
      expect(restored.servings, 2);
      expect(restored.tags, ['entrante']);
      expect(restored.tips, 'Servir caliente');
    });

    test('defaults missing ingredient unit to unidad', () {
      final json = RecipeFormDataCodec.toJson(
        RecipeFormData(
          title: 'Ensalada',
          ingredients: [
            IngredientFormItem(name: 'Lechuga', quantity: 1, unit: 'unidad'),
          ],
          steps: [StepFormItem(description: 'Mezclar')],
        ),
      );

      final ingredients = json['ingredients'] as List<dynamic>;
      final ingredient = Map<String, dynamic>.from(
        ingredients.first as Map<dynamic, dynamic>,
      );
      ingredient.remove('unit');

      final restored = RecipeFormDataCodec.fromJson(json);

      expect(restored.ingredients.single.unit, 'unidad');
    });
  });
}
