import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/recipes/data/recipe_translation_repository.dart';
import 'package:meal_planner/features/recipes/domain/recipe_translation_payload.dart';
import 'package:meal_planner/features/social/domain/public_recipe_detail.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';

final publicRecipeDisplayProvider =
    FutureProvider.family<PublicRecipeDisplayState, String>((
      ref,
      recipeId,
    ) async {
      final detail = await ref.watch(
        publicRecipeDetailProvider(recipeId).future,
      );
      final targetLang = ref.watch(currentLanguageCodeProvider);
      final sourceLang = detail.sourceLang;

      if (sourceLang == targetLang) {
        return PublicRecipeDisplayState(
          detail: detail,
          isTranslated: false,
          showTranslation: false,
        );
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
          return PublicRecipeDisplayState(
            detail: detail,
            isTranslated: false,
            showTranslation: false,
          );
        }

        return PublicRecipeDisplayState(
          detail: _applyTranslation(detail, translation),
          isTranslated: true,
          showTranslation: true,
          translation: translation,
          originalDetail: detail,
        );
      } catch (_) {
        return PublicRecipeDisplayState(
          detail: detail,
          isTranslated: false,
          showTranslation: false,
          translationFailed: true,
        );
      }
    });

class PublicRecipeDisplayState {
  const PublicRecipeDisplayState({
    required this.detail,
    required this.isTranslated,
    required this.showTranslation,
    this.translation,
    this.originalDetail,
    this.translationFailed = false,
  });

  final PublicRecipeDetail detail;
  final bool isTranslated;
  final bool showTranslation;
  final RecipeTranslationPayload? translation;
  final PublicRecipeDetail? originalDetail;
  final bool translationFailed;

  PublicRecipeDisplayState withShowOriginal(bool showOriginal) {
    if (!isTranslated || originalDetail == null || translation == null) {
      return this;
    }
    if (showOriginal) {
      return PublicRecipeDisplayState(
        detail: originalDetail!,
        isTranslated: true,
        showTranslation: false,
        translation: translation,
        originalDetail: originalDetail,
      );
    }
    return PublicRecipeDisplayState(
      detail: _applyTranslation(originalDetail!, translation!),
      isTranslated: true,
      showTranslation: true,
      translation: translation,
      originalDetail: originalDetail,
    );
  }
}

PublicRecipeDetail _applyTranslation(
  PublicRecipeDetail detail,
  RecipeTranslationPayload translation,
) {
  final translatedIngredientById = {
    for (final ingredient in translation.ingredients) ingredient.id: ingredient,
  };
  final translatedStepById = {
    for (final step in translation.steps) step.id: step,
  };

  // Only free-text fields come from the machine translation. Units, categories
  // and tags are stable keys localized on the client, so we keep the originals.
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
