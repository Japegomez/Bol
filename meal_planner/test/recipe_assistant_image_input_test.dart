import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/recipes/data/recipe_assistant_repository.dart';

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
            imageBytes: Uint8List.fromList([1, 2, 3]),
            imageMimeType: 'image/jpeg',
          ),
        ),
        isNull,
      );
    });

    test('rejects invalid mime type', () {
      expect(
        validateRecipeAssistantInput(
          RecipeAssistantPromptInput(
            imageBytes: Uint8List.fromList([1, 2, 3]),
            imageMimeType: 'image/gif',
          ),
        ),
        equals(recipeAssistantInvalidImageKey),
      );
    });

    test('rejects image larger than max bytes', () {
      expect(
        validateRecipeAssistantInput(
          RecipeAssistantPromptInput(
            imageBytes: Uint8List(maxRecipeAssistantImageBytes + 1),
            imageMimeType: 'image/png',
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
      expect(body.containsKey('imageBase64'), isFalse);
      expect(body.containsKey('imageMimeType'), isFalse);
    });

    test('includes base64 image fields when image present', () {
      final bytes = Uint8List.fromList([10, 20, 30]);
      final body = buildGenerateRecipeBody(
        RecipeAssistantPromptInput(
          prompt: 'versión vegana',
          imageBytes: bytes,
          imageMimeType: 'image/jpeg',
        ),
      );
      expect(body['prompt'], equals('versión vegana'));
      expect(body['imageBase64'], equals(base64Encode(bytes)));
      expect(body['imageMimeType'], equals('image/jpeg'));
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
  });
}
