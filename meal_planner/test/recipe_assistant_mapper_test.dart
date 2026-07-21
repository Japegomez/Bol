import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/recipes/domain/recipe_assistant_mapper.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';

void main() {
  group('recipeFromAssistantJson', () {
    test('maps a complete recipe with valid units and categories', () {
      final form = recipeFromAssistantJson({
        'title': 'Tortilla de patatas',
        'servings': 4,
        'prepTime': 10,
        'cookTime': 25,
        'detectedLang': 'es',
        'tips': 'Dejar reposar antes de servir',
        'tags': ['main_course', 'vegetarian', 'unknown_tag'],
        'ingredients': [
          {
            'name': 'Patata',
            'quantity': 4,
            'unit': 'unidad',
            'category': 'vegetables',
            'isOptional': false,
            'isToTaste': false,
          },
          {
            'name': 'Sal',
            'quantity': null,
            'unit': null,
            'category': 'spices',
            'isOptional': false,
            'isToTaste': true,
          },
        ],
        'steps': [
          {
            'description': 'Freír las patatas',
            'isOptional': false,
          },
        ],
        'nutrition': {
          'calories': 320,
          'protein': 12,
          'carbohydrates': 28,
          'fat': 18,
          'fiber': 3,
        },
      });

      expect(form.title, 'Tortilla de patatas');
      expect(form.servings, 4);
      expect(form.prepTime, 10);
      expect(form.cookTime, 25);
      expect(form.tips, 'Dejar reposar antes de servir');
      expect(form.tags, ['main_course', 'vegetarian']);
      expect(form.ingredients, hasLength(2));
      expect(form.ingredients.first.unit, 'unidad');
      expect(form.ingredients.first.category, 'vegetables');
      expect(form.ingredients.last.isToTaste, isTrue);
      expect(form.steps.single.description, 'Freír las patatas');
      expect(form.nutrition.calories, 320);
      expect(form.nutrition.fiber, 3);
      expect(detectedLangFromAssistantJson({'detectedLang': 'es'}), 'es');
    });

    test('preserves consumed water ingredients', () {
      final form = recipeFromAssistantJson({
        'title': 'Pasta',
        'servings': 2,
        'detectedLang': 'es',
        'tags': <String>[],
        'ingredients': [
          {
            'name': 'espaguetis',
            'quantity': 200,
            'unit': 'g',
            'category': 'grains',
            'isOptional': false,
            'isToTaste': false,
          },
          {
            'name': 'agua',
            'quantity': 2,
            'unit': 'l',
            'category': 'beverages',
            'isOptional': false,
            'isToTaste': false,
          },
          {
            'name': 'agua de coco',
            'quantity': 200,
            'unit': 'ml',
            'category': 'beverages',
            'isOptional': false,
            'isToTaste': false,
          },
        ],
        'steps': [
          {
            'description': 'Hervir la pasta en agua con sal',
            'isOptional': false,
          },
        ],
        'nutrition': <String, dynamic>{},
      });

      expect(form.ingredients, hasLength(3));
      expect(form.ingredients[0].name, 'Espaguetis');
      expect(form.ingredients[1].name, 'Agua');
      expect(form.ingredients[2].name, 'Agua de coco');
    });

    test('drops water for boiling entries', () {
      final form = recipeFromAssistantJson({
        'title': 'Pasta',
        'servings': 2,
        'detectedLang': 'es',
        'tags': <String>[],
        'ingredients': [
          {
            'name': 'espaguetis',
            'quantity': 200,
            'unit': 'g',
            'category': 'grains',
            'isOptional': false,
            'isToTaste': false,
          },
          {
            'name': 'agua para hervir',
            'quantity': 2,
            'unit': 'l',
            'category': 'beverages',
            'isOptional': false,
            'isToTaste': false,
          },
        ],
        'steps': [
          {
            'description': 'Hervir la pasta en agua con sal',
            'isOptional': false,
          },
        ],
        'nutrition': <String, dynamic>{},
      });

      expect(form.ingredients, hasLength(1));
      expect(form.ingredients.first.name, 'Espaguetis');
    });

    test('capitalizes ingredient names without singularization', () {
      final form = recipeFromAssistantJson({
        'title': 'Tortilla',
        'servings': 2,
        'detectedLang': 'es',
        'tags': <String>[],
        'ingredients': [
          {
            'name': 'patatas',
            'quantity': 4,
            'unit': 'unidad',
            'category': 'vegetables',
            'isOptional': false,
            'isToTaste': false,
          },
          {
            'name': 'ajos',
            'quantity': 2,
            'unit': 'diente',
            'category': 'vegetables',
            'isOptional': false,
            'isToTaste': false,
          },
          {
            'name': 'plátanos',
            'quantity': 2,
            'unit': 'unidad',
            'category': 'fruits',
            'isOptional': false,
            'isToTaste': false,
          },
        ],
        'steps': [
          {
            'description': 'Mezclar',
            'isOptional': false,
          },
        ],
        'nutrition': <String, dynamic>{},
      });

      expect(form.ingredients.map((item) => item.name).toList(), [
        'Patatas',
        'Ajos',
        'Plátanos',
      ]);
    });

    test('falls back for invalid unit and category', () {
      final form = recipeFromAssistantJson({
        'title': 'Custom dish',
        'servings': 2,
        'prepTime': null,
        'cookTime': null,
        'detectedLang': 'en-US',
        'tips': null,
        'tags': <String>[],
        'ingredients': [
          {
            'name': 'Mystery spice',
            'quantity': 1,
            'unit': 'dash',
            'category': 'unknown_category',
            'isOptional': true,
            'isToTaste': false,
          },
        ],
        'steps': [
          {
            'description': 'Mix everything',
            'isOptional': false,
          },
        ],
        'nutrition': {
          'calories': null,
          'protein': 5,
          'carbohydrates': null,
          'fat': null,
          'fiber': null,
        },
      });

      final ingredient = form.ingredients.single;
      expect(ingredient.useCustomUnit, isTrue);
      expect(ingredient.customUnit, 'dash');
      expect(ingredient.category, 'other');
      expect(form.nutrition.protein, 5);
      expect(detectedLangFromAssistantJson({'detectedLang': 'en-US'}), 'en');
    });

    test('returns defaults for empty payload fragments', () {
      final form = recipeFromAssistantJson({
        'title': '',
        'servings': 0,
        'tags': 'invalid',
        'ingredients': 'invalid',
        'steps': null,
        'nutrition': <String, dynamic>{},
      });

      expect(form.servings, 4);
      expect(form.ingredients.single, isA<IngredientFormItem>());
      expect(form.steps.single, isA<StepFormItem>());
      expect(form.nutrition.hasAnyValue, isFalse);
    });
  });

  group('nutritionFromAssistantJson', () {
    test('maps partial nutrition values as non-negative integers', () {
      final nutrition = nutritionFromAssistantJson({
        'calories': '210',
        'protein': 8.5,
        'carbohydrates': null,
        'fat': 10,
        'fiber': '2,5',
      });

      expect(nutrition.calories, 210);
      expect(nutrition.protein, 9);
      expect(nutrition.carbohydrates, isNull);
      expect(nutrition.fat, 10);
      expect(nutrition.fiber, 3);
      expect(nutrition.hasAnyValue, isTrue);
    });

    test('rejects negative nutrition values', () {
      final nutrition = nutritionFromAssistantJson({
        'calories': -1,
        'protein': 4,
      });

      expect(nutrition.calories, isNull);
      expect(nutrition.protein, 4);
    });
  });
}
