import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';

void main() {
  group('IngredientFormItem.effectiveUnit', () {
    test('uses the predefined unit by default', () {
      final item = IngredientFormItem(unit: 'g');
      expect(item.effectiveUnit, 'g');
    });

    test('uses a trimmed custom unit when enabled', () {
      final item = IngredientFormItem(
        unit: 'g',
        useCustomUnit: true,
        customUnit: '  ramita  ',
      );
      expect(item.effectiveUnit, 'ramita');
    });

    test('returns null when custom unit is blank', () {
      final item = IngredientFormItem(useCustomUnit: true, customUnit: '   ');
      expect(item.effectiveUnit, isNull);
    });
  });

  group('RecipeFormData.validate', () {
    test('requires a title, a required ingredient and a required step', () {
      final empty = RecipeFormData();
      expect(empty.validate(), 'El nombre es obligatorio');

      empty.title = 'Tortilla';
      expect(empty.validate(), 'Añade al menos un ingrediente no opcional');

      empty.ingredients.first
        ..name = 'Huevo'
        ..isOptional = true;
      expect(empty.validate(), 'Añade al menos un ingrediente no opcional');

      empty.ingredients.first.isOptional = false;
      expect(
        empty.validate(),
        'Añade al menos un paso de elaboración no opcional',
      );

      empty.steps.first.description = 'Batir';
      expect(empty.validate(), isNull);
    });

    test('cannot publish a forked recipe', () {
      expect(RecipeFormData().canPublish, isTrue);
      expect(RecipeFormData(forkedFromId: 'other').canPublish, isFalse);
    });
  });
}
