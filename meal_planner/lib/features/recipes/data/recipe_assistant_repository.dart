import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/recipes/domain/recipe_assistant_mapper.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const recipeAssistantNotRecipeRequestKey = 'recipeAssistantNotRecipeRequest';
const recipeAssistantRateLimitedKey = 'recipeAssistantRateLimited';
const recipeAssistantDailyLimitKey = 'recipeAssistantDailyLimitReached';
const recipeAssistantTooFastKey = 'recipeAssistantTooFast';
const recipeAssistantServiceAtCapacityKey = 'recipeAssistantServiceAtCapacity';
const recipeAssistantFailedKey = 'recipeAssistantFailed';
const recipeAssistantOfflineKey = 'recipeAssistantOffline';
const recipeAssistantNotConfiguredKey = 'recipeAssistantNotConfigured';
const recipeAssistantTimeoutKey = 'recipeAssistantTimeout';
const recipeAssistantPromptTooLongKey = 'recipeAssistantPromptTooLong';
const recipeAssistantMissingInputKey = 'recipeAssistantMissingInput';
const recipeAssistantImageTooLargeKey = 'recipeAssistantImageTooLarge';
const recipeAssistantInvalidImageKey = 'recipeAssistantInvalidImage';

/// Maximum characters allowed in the recipe assistant prompt.
const maxRecipeAssistantPromptLength = 3000;

/// Max raw image bytes after client-side pick/compress (~1 MB).
const maxRecipeAssistantImageBytes = 1024 * 1024;

/// Maximum photos the recipe assistant accepts in one request.
const maxRecipeAssistantImages = 4;

const _allowedImageMimeTypes = {'image/jpeg', 'image/png', 'image/webp'};

/// Client timeouts aligned with the Edge Function budget (~240s total).
const _recipeGenerationTimeout = Duration(seconds: 210);
const _nutritionGenerationTimeout = Duration(seconds: 200);

/// A single photo attached to a recipe-assistant prompt.
class RecipeAssistantImageInput {
  const RecipeAssistantImageInput({
    required this.bytes,
    required this.mimeType,
  });

  final Uint8List bytes;
  final String mimeType;
}

/// Input from the recipe assistant prompt sheet (text and/or up to 4 images).
class RecipeAssistantPromptInput {
  const RecipeAssistantPromptInput({this.prompt = '', this.images = const []});

  final String prompt;
  final List<RecipeAssistantImageInput> images;

  bool get hasText => prompt.trim().isNotEmpty;
  bool get hasImage => images.isNotEmpty;
  bool get hasContent => hasText || hasImage;
}

class GeneratedRecipeResult {
  const GeneratedRecipeResult({
    required this.formData,
    required this.sourceLang,
  });

  final RecipeFormData formData;
  final String sourceLang;
}

/// Validates prompt/image before calling the edge function.
/// Returns an error localization key, or `null` if valid.
String? validateRecipeAssistantInput(RecipeAssistantPromptInput input) {
  final trimmed = input.prompt.trim();
  if (trimmed.isEmpty && !input.hasImage) {
    return recipeAssistantMissingInputKey;
  }
  if (trimmed.length > maxRecipeAssistantPromptLength) {
    return recipeAssistantPromptTooLongKey;
  }
  if (!input.hasImage) return null;

  if (input.images.length > maxRecipeAssistantImages) {
    return recipeAssistantInvalidImageKey;
  }

  for (final image in input.images) {
    final mime = image.mimeType.toLowerCase().trim();
    if (!_allowedImageMimeTypes.contains(mime) || image.bytes.isEmpty) {
      return recipeAssistantInvalidImageKey;
    }
    if (image.bytes.length > maxRecipeAssistantImageBytes) {
      return recipeAssistantImageTooLargeKey;
    }
  }
  return null;
}

/// Builds the JSON body for `generate_recipe` (testable without network).
Map<String, dynamic> buildGenerateRecipeBody(RecipeAssistantPromptInput input) {
  final body = <String, dynamic>{
    'mode': 'generate_recipe',
    'prompt': input.prompt.trim(),
  };
  if (input.hasImage) {
    body['images'] = [
      for (final image in input.images)
        {
          'imageBase64': base64Encode(image.bytes),
          'imageMimeType': image.mimeType.toLowerCase().trim(),
        },
    ];
  }
  return body;
}

class RecipeAssistantRepository {
  Future<GeneratedRecipeResult> generateRecipe(
    RecipeAssistantPromptInput input,
  ) async {
    await _ensureOnline();

    final validationError = validateRecipeAssistantInput(input);
    if (validationError != null) {
      throw Exception(validationError);
    }

    final data = await _invoke(
      body: buildGenerateRecipeBody(input),
      timeout: _recipeGenerationTimeout,
    );

    final recipeMap = data['recipe'];
    if (recipeMap is! Map) {
      throw Exception(recipeAssistantFailedKey);
    }

    final recipeJson = Map<String, dynamic>.from(recipeMap);
    return GeneratedRecipeResult(
      formData: recipeFromAssistantJson(recipeJson),
      sourceLang: detectedLangFromAssistantJson(recipeJson),
    );
  }

  Future<NutritionFormData> generateNutrition({
    required String title,
    required int servings,
    required List<IngredientFormItem> ingredients,
    NutritionFormData? existingNutrition,
  }) async {
    await _ensureOnline();

    final validIngredients = ingredients
        .where((item) => item.name.trim().isNotEmpty)
        .toList();
    if (validIngredients.isEmpty) {
      throw Exception(recipeAssistantFailedKey);
    }

    final existingPayload = existingNutrition?.toAssistantPayload();

    final data = await _invoke(
      body: {
        'mode': 'generate_nutrition',
        'title': title.trim(),
        'servings': servings,
        'ingredients': validIngredients
            .map(
              (item) => {
                'name': item.name.trim(),
                'quantity': item.isToTaste ? null : item.quantity,
                'unit': item.isToTaste ? null : item.effectiveUnit,
                'category': item.category,
                'isOptional': item.isOptional,
                'isToTaste': item.isToTaste,
              },
            )
            .toList(),
        'existingNutrition': ?existingPayload,
      },
      timeout: _nutritionGenerationTimeout,
    );

    final nutritionMap = data['nutrition'];
    if (nutritionMap is! Map) {
      throw Exception(recipeAssistantFailedKey);
    }

    return nutritionFromAssistantJson(Map<String, dynamic>.from(nutritionMap));
  }

  /// Invokes the edge function and normalizes both transport and application
  /// errors into the localized keys used by the UI.
  ///
  /// Note: `functions_client` throws [FunctionException] on any non-2xx
  /// response, so the specific error codes returned by the function body are
  /// read from [FunctionException.details].
  Future<Map<String, dynamic>> _invoke({
    required Map<String, dynamic> body,
    required Duration timeout,
  }) async {
    try {
      final response = await supabase.functions
          .invoke('recipe-assistant', body: body)
          .timeout(timeout);

      final data = response.data;
      if (data is! Map) {
        throw Exception(recipeAssistantFailedKey);
      }
      return Map<String, dynamic>.from(data);
    } on TimeoutException {
      throw Exception(recipeAssistantTimeoutKey);
    } on FunctionException catch (e) {
      throw Exception(mapRecipeAssistantFunctionError(e.status, e.details));
    }
  }

  Future<void> _ensureOnline() async {
    if (!await NetworkStatus.isOnline) {
      throw Exception(recipeAssistantOfflineKey);
    }
  }
}

/// Maps edge-function HTTP status / error payload to UI localization keys.
String mapRecipeAssistantFunctionError(int status, dynamic details) {
  final errorCode = details is Map ? details['error']?.toString() : null;

  if (status == 422 || errorCode == 'not_a_recipe_request') {
    return recipeAssistantNotRecipeRequestKey;
  }
  if (errorCode == 'prompt_too_long') {
    return recipeAssistantPromptTooLongKey;
  }
  if (errorCode == 'missing_input' || errorCode == 'missing_prompt') {
    return recipeAssistantMissingInputKey;
  }
  if (errorCode == 'image_too_large') {
    return recipeAssistantImageTooLargeKey;
  }
  if (errorCode == 'invalid_image' || errorCode == 'too_many_images') {
    return recipeAssistantInvalidImageKey;
  }
  if (errorCode == 'too_fast') {
    return recipeAssistantTooFastKey;
  }
  if (errorCode == 'daily_limit_reached') {
    return recipeAssistantDailyLimitKey;
  }
  if (errorCode == 'service_at_capacity' || errorCode == 'quota_check_failed') {
    return recipeAssistantServiceAtCapacityKey;
  }
  if (status == 429 || errorCode == 'rate_limited') {
    return recipeAssistantRateLimitedKey;
  }
  if (status == 503 || errorCode == 'not_configured') {
    return recipeAssistantNotConfiguredKey;
  }
  return recipeAssistantFailedKey;
}

final recipeAssistantRepositoryProvider = Provider<RecipeAssistantRepository>((
  ref,
) {
  return RecipeAssistantRepository();
});

class RecipeAssistantDraft {
  const RecipeAssistantDraft({
    required this.formData,
    required this.sourceLang,
  });

  final RecipeFormData formData;
  final String sourceLang;
}

final recipeAssistantDraftProvider = StateProvider<RecipeAssistantDraft?>(
  (ref) => null,
);
