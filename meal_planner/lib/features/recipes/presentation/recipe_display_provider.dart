import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/recipes/data/recipe_translation_repository.dart';
import 'package:meal_planner/features/recipes/domain/recipe_detail.dart';
import 'package:meal_planner/features/recipes/domain/recipe_translation_payload.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';

/// Machine-translated view of an own recipe detail, mirroring the public-recipe
/// translation flow: auto-translate to the app language with a "view original"
/// toggle.
final recipeDisplayProvider = FutureProvider.family<RecipeDisplayState, String>(
  (ref, recipeId) async {
    final detail = await ref.watch(recipeDetailProvider(recipeId).future);
    final targetLang = ref.watch(currentLanguageCodeProvider);
    final sourceLang = detail.sourceLang;

    if (sourceLang == targetLang) {
      return RecipeDisplayState(detail: detail, isTranslated: false);
    }

    try {
      final translation = await ref
          .read(recipeTranslationRepositoryProvider)
          .fetchTranslation(
            recipeId: detail.recipe.id,
            targetLang: targetLang,
            sourceLang: sourceLang,
          );

      if (translation == null) {
        return RecipeDisplayState(detail: detail, isTranslated: false);
      }

      return RecipeDisplayState(
        detail: _applyTranslation(detail, translation),
        isTranslated: true,
        showTranslation: true,
        translation: translation,
        originalDetail: detail,
      );
    } catch (_) {
      return RecipeDisplayState(
        detail: detail,
        isTranslated: false,
        translationFailed: true,
      );
    }
  },
);

class RecipeDisplayState {
  const RecipeDisplayState({
    required this.detail,
    required this.isTranslated,
    this.showTranslation = false,
    this.translation,
    this.originalDetail,
    this.translationFailed = false,
  });

  final RecipeDetail detail;
  final bool isTranslated;
  final bool showTranslation;
  final RecipeTranslationPayload? translation;
  final RecipeDetail? originalDetail;
  final bool translationFailed;

  RecipeDisplayState withShowOriginal(bool showOriginal) {
    if (!isTranslated || originalDetail == null || translation == null) {
      return this;
    }
    if (showOriginal) {
      return RecipeDisplayState(
        detail: originalDetail!,
        isTranslated: true,
        showTranslation: false,
        translation: translation,
        originalDetail: originalDetail,
      );
    }
    return RecipeDisplayState(
      detail: _applyTranslation(originalDetail!, translation!),
      isTranslated: true,
      showTranslation: true,
      translation: translation,
      originalDetail: originalDetail,
    );
  }
}

RecipeDetail _applyTranslation(
  RecipeDetail detail,
  RecipeTranslationPayload translation,
) {
  final translatedIngredientById = {
    for (final ingredient in translation.ingredients) ingredient.id: ingredient,
  };
  final translatedStepById = {
    for (final step in translation.steps) step.id: step,
  };

  // Only free-text fields are translated. Units, categories and tags are stable
  // keys localized on the client, so the originals are kept.
  // Iterate over originals to preserve order and retain untranslated items.
  final translatedIngredients = detail.ingredients.map((original) {
    final translated = translatedIngredientById[original.id];
    if (translated == null) return original;
    return original.copyWith(name: translated.name);
  }).toList();

  final translatedSteps = detail.steps.map((original) {
    final translated = translatedStepById[original.id];
    if (translated == null) return original;
    return original.copyWith(description: translated.description);
  }).toList();

  return detail.copyWith(
    recipe: detail.recipe.copyWith(
      title: translation.title,
      tips: translation.tips,
    ),
    ingredients: translatedIngredients,
    steps: translatedSteps,
  );
}
