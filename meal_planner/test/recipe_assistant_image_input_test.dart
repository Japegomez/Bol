import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/recipes/data/recipe_assistant_repository.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';

RecipeAssistantImageInput _jpeg(List<int> bytes) {
  return RecipeAssistantImageInput(
    bytes: Uint8List.fromList(bytes),
    mimeType: 'image/jpeg',
  );
}

void main() {
  group('validateRecipeAssistantInput', () {
    test('rejects empty prompt without image', () {
      expect(
        validateRecipeAssistantInput(const RecipeAssistantPromptInput()),
        equals(recipeAssistantMissingInputKey),
      );
      expect(
        validateRecipeAssistantInput(
          const RecipeAssistantPromptInput(prompt: '   '),
        ),
        equals(recipeAssistantMissingInputKey),
      );
    });

    test('rejects prompt longer than max', () {
      final long = 'a' * (maxRecipeAssistantPromptLength + 1);
      expect(
        validateRecipeAssistantInput(RecipeAssistantPromptInput(prompt: long)),
        equals(recipeAssistantPromptTooLongKey),
      );
    });

    test('accepts text-only prompt', () {
      expect(
        validateRecipeAssistantInput(
          const RecipeAssistantPromptInput(prompt: 'tortilla de patatas'),
        ),
        isNull,
      );
    });

    test('accepts image-only with allowed mime', () {
      expect(
        validateRecipeAssistantInput(
          RecipeAssistantPromptInput(
            images: [
              _jpeg([1, 2, 3]),
            ],
          ),
        ),
        isNull,
      );
    });

    test('rejects image with empty bytes', () {
      expect(
        validateRecipeAssistantInput(
          RecipeAssistantPromptInput(
            images: [
              RecipeAssistantImageInput(
                bytes: Uint8List(0),
                mimeType: 'image/jpeg',
              ),
            ],
          ),
        ),
        equals(recipeAssistantInvalidImageKey),
      );
    });

    test('accepts multiple images up to the max', () {
      expect(
        validateRecipeAssistantInput(
          RecipeAssistantPromptInput(
            images: [
              _jpeg([1]),
              _jpeg([2]),
              _jpeg([3]),
              _jpeg([4]),
            ],
          ),
        ),
        isNull,
      );
    });

    test('rejects more images than the max', () {
      expect(
        validateRecipeAssistantInput(
          RecipeAssistantPromptInput(
            images: [
              _jpeg([1]),
              _jpeg([2]),
              _jpeg([3]),
              _jpeg([4]),
              _jpeg([5]),
            ],
          ),
        ),
        equals(recipeAssistantInvalidImageKey),
      );
    });

    test('rejects invalid mime type', () {
      expect(
        validateRecipeAssistantInput(
          RecipeAssistantPromptInput(
            images: [
              RecipeAssistantImageInput(
                bytes: Uint8List.fromList([1, 2, 3]),
                mimeType: 'image/gif',
              ),
            ],
          ),
        ),
        equals(recipeAssistantInvalidImageKey),
      );
    });

    test('rejects image larger than max bytes', () {
      expect(
        validateRecipeAssistantInput(
          RecipeAssistantPromptInput(
            images: [
              RecipeAssistantImageInput(
                bytes: Uint8List(maxRecipeAssistantImageBytes + 1),
                mimeType: 'image/png',
              ),
            ],
          ),
        ),
        equals(recipeAssistantImageTooLargeKey),
      );
    });
  });

  group('buildGenerateRecipeBody', () {
    test('includes prompt only for text input', () {
      final body = buildGenerateRecipeBody(
        const RecipeAssistantPromptInput(prompt: '  pasta  '),
      );
      expect(body['mode'], equals('generate_recipe'));
      expect(body['prompt'], equals('pasta'));
      expect(body.containsKey('images'), isFalse);
      expect(body.containsKey('imageBase64'), isFalse);
      expect(body.containsKey('imageMimeType'), isFalse);
    });

    test('includes images array when photos are present', () {
      final first = Uint8List.fromList([10, 20, 30]);
      final second = Uint8List.fromList([40, 50]);
      final body = buildGenerateRecipeBody(
        RecipeAssistantPromptInput(
          prompt: 'versión vegana',
          images: [
            RecipeAssistantImageInput(bytes: first, mimeType: 'image/jpeg'),
            RecipeAssistantImageInput(bytes: second, mimeType: 'image/png'),
          ],
        ),
      );
      expect(body['prompt'], equals('versión vegana'));
      expect(body['images'], [
        {'imageBase64': base64Encode(first), 'imageMimeType': 'image/jpeg'},
        {'imageBase64': base64Encode(second), 'imageMimeType': 'image/png'},
      ]);
    });
  });

  group('mapRecipeAssistantFunctionError image codes', () {
    test('maps missing_input', () {
      expect(
        mapRecipeAssistantFunctionError(400, {'error': 'missing_input'}),
        equals(recipeAssistantMissingInputKey),
      );
    });

    test('maps legacy missing_prompt to missing_input', () {
      expect(
        mapRecipeAssistantFunctionError(400, {'error': 'missing_prompt'}),
        equals(recipeAssistantMissingInputKey),
      );
    });

    test('maps image_too_large', () {
      expect(
        mapRecipeAssistantFunctionError(400, {'error': 'image_too_large'}),
        equals(recipeAssistantImageTooLargeKey),
      );
    });

    test('maps invalid_image', () {
      expect(
        mapRecipeAssistantFunctionError(400, {'error': 'invalid_image'}),
        equals(recipeAssistantInvalidImageKey),
      );
    });

    test('maps too_many_images to invalid_image', () {
      expect(
        mapRecipeAssistantFunctionError(400, {'error': 'too_many_images'}),
        equals(recipeAssistantInvalidImageKey),
      );
    });
  });

  group('buildGenerateTagsBody', () {
    test('includes recipe context and omits empty optional fields', () {
      final body = buildGenerateTagsBody(
        title: '  Tortilla  ',
        servings: 4,
        ingredients: [
          IngredientFormItem(name: 'Patata', quantity: 4, unit: 'unidad'),
          IngredientFormItem(name: '  '),
        ],
        steps: [StepFormItem(description: '   ')],
        tips: '  ',
        existingTags: ['unknown_tag'],
      );

      expect(body['mode'], equals('generate_tags'));
      expect(body['title'], equals('Tortilla'));
      expect(body['servings'], equals(4));
      expect(body['ingredients'], hasLength(1));
      expect(body['steps'], isEmpty);
      expect(body.containsKey('prepTime'), isFalse);
      expect(body.containsKey('cookTime'), isFalse);
      expect(body.containsKey('tips'), isFalse);
      expect(body.containsKey('existingTags'), isFalse);
    });

    test('includes times, tips, steps, and known existing tags', () {
      final body = buildGenerateTagsBody(
        title: 'Pasta',
        servings: 2,
        ingredients: [
          IngredientFormItem(name: 'Espagueti', quantity: 200, unit: 'g'),
        ],
        steps: [StepFormItem(description: 'Hervir')],
        prepTime: 10,
        cookTime: 12,
        tips: 'Sal al agua',
        existingTags: ['main_course', 'casera'],
      );

      expect(body['prepTime'], 10);
      expect(body['cookTime'], 12);
      expect(body['tips'], 'Sal al agua');
      expect(body['existingTags'], ['main_course']);
      expect(body['steps'], [
        {'description': 'Hervir', 'isOptional': false},
      ]);
    });
  });
}
