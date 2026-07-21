import 'dart:async';

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

/// Client timeouts aligned with the Edge Function budget (~240s total).
const _recipeGenerationTimeout = Duration(seconds: 210);
const _nutritionGenerationTimeout = Duration(seconds: 200);

class GeneratedRecipeResult {
  const GeneratedRecipeResult({
    required this.formData,
    required this.sourceLang,
  });

  final RecipeFormData formData;
  final String sourceLang;
}

class RecipeAssistantRepository {
  Future<GeneratedRecipeResult> generateRecipe(String prompt) async {
    await _ensureOnline();

    final data = await _invoke(
      body: {
        'mode': 'generate_recipe',
        'prompt': prompt.trim(),
      },
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

    return nutritionFromAssistantJson(
      Map<String, dynamic>.from(nutritionMap),
    );
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

final recipeAssistantRepositoryProvider =
    Provider<RecipeAssistantRepository>((ref) {
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

final recipeAssistantDraftProvider =
    StateProvider<RecipeAssistantDraft?>((ref) => null);
