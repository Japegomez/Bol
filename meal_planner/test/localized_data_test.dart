import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

void main() {
  group('normalizeCategoryKey', () {
    test('defaults empty values to vegetables', () {
      expect(normalizeCategoryKey(null), defaultIngredientCategoryKey);
      expect(normalizeCategoryKey(''), defaultIngredientCategoryKey);
    });

    test('keeps known keys', () {
      expect(normalizeCategoryKey('meat_fish'), 'meat_fish');
    });

    test('maps legacy Spanish labels', () {
      expect(normalizeCategoryKey('Verduras'), 'vegetables');
      expect(normalizeCategoryKey('Carnes y pescados'), 'meat_fish');
      expect(normalizeCategoryKey('Panadería'), 'baking');
    });

    test('falls back to other for unknown labels', () {
      expect(normalizeCategoryKey('Cosas raras'), 'other');
    });
  });

  group('normalizeTagKey', () {
    test('keeps canonical keys', () {
      expect(normalizeTagKey('dessert'), 'dessert');
      expect(normalizeTagKey('kid_friendly'), 'kid_friendly');
    });

    test('maps legacy Spanish labels', () {
      expect(normalizeTagKey('postre'), 'dessert');
      expect(normalizeTagKey('sin gluten'), 'gluten_free');
      expect(normalizeTagKey('para niños'), 'kid_friendly');
      expect(normalizeTagKey('sin cacahuetes'), 'peanut_free');
      expect(normalizeTagKey('desayuno'), 'breakfast');
      expect(normalizeTagKey('aperitivo'), 'appetizer');
      expect(normalizeTagKey('tentempié'), 'appetizer');
    });

    test('returns unknown tags unchanged', () {
      expect(normalizeTagKey('casera'), 'casera');
    });
  });

  group('sortedRecipeTags', () {
    test('orders suggested tags like the form chips and keeps custom last', () {
      expect(
        sortedRecipeTags(['casera', 'quick', 'vegetarian', 'main_course']),
        ['main_course', 'vegetarian', 'quick', 'casera'],
      );
    });

    test('deduplicates and normalizes legacy labels', () {
      expect(sortedRecipeTags(['rápida', 'quick', 'postre']), [
        'dessert',
        'quick',
      ]);
    });
  });

  group('allergenTagKeys', () {
    test('are a subset of suggestedRecipeTagKeys', () {
      for (final allergen in allergenTagKeys) {
        expect(
          suggestedRecipeTagKeys.contains(allergen),
          isTrue,
          reason: '$allergen should be a suggested tag',
        );
      }
    });

    test('contains the 10 expected allergen keys', () {
      expect(allergenTagKeys, [
        'gluten_free',
        'lactose_free',
        'dairy_free',
        'egg_free',
        'nut_free',
        'peanut_free',
        'soy_free',
        'fish_free',
        'shellfish_free',
        'sugar_free',
      ]);
    });
  });

  group('allergen dialog messages', () {
    final l10n = lookupAppLocalizations(const Locale('es'));

    test('conflict messages name each allergen', () {
      expect(allergenConflictMessages(l10n, ['egg_free', 'gluten_free']), [
        'No se puede adaptar la receta para evitar: huevo.',
        'No se puede adaptar la receta para evitar: gluten.',
      ]);
    });

    test('conflict falls back when keys are empty', () {
      expect(allergenConflictMessages(l10n, const []), [
        l10n.recipeAssistantAllergenConflict,
      ]);
    });

    test('adjustment notes name each allergen', () {
      expect(allergenAdjustmentMessages(l10n, ['peanut_free']), [
        'Se ha modificado la receta para evitar el alérgeno o la intolerancia: cacahuetes.',
      ]);
    });

    test('substance labels omit the sin prefix', () {
      expect(allergenSubstanceLabel(l10n, 'egg_free'), 'huevo');
      expect(allergenSubstanceLabel(l10n, 'gluten_free'), 'gluten');
    });

    test('inferAdjustedAllergens recovers keys from Adaptado title', () {
      expect(
        inferAdjustedAllergens(
          adjustedAllergens: const [],
          allergenAdjustments: const [],
          userAllergens: const ['peanut_free'],
          title: 'Pad Thai Adaptado',
        ),
        ['peanut_free'],
      );
    });

    test('inferAdjustedAllergens stays empty without adaptation signal', () {
      expect(
        inferAdjustedAllergens(
          adjustedAllergens: const [],
          allergenAdjustments: const [],
          userAllergens: const ['peanut_free'],
          title: 'Ensalada de tomate',
        ),
        isEmpty,
      );
    });

    test('inferAdjustedAllergens ignores generic allergy-friendly titles', () {
      expect(
        inferAdjustedAllergens(
          adjustedAllergens: const [],
          allergenAdjustments: const [],
          userAllergens: const ['peanut_free'],
          title: 'Allergy-friendly salad',
        ),
        isEmpty,
      );
    });

    test('normalizeAllergenKeys drops unknowns and duplicates', () {
      expect(
        normalizeAllergenKeys(['egg_free', 'nope', 'egg_free', 'gluten_free']),
        ['egg_free', 'gluten_free'],
      );
    });
  });

  group('legacy mediterranean tag', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    test('keeps mediterranean as an untranslated custom label', () {
      expect(normalizeTagKey('mediterranean'), 'mediterranean');
      expect(localizedTagLabel(l10n, 'mediterranean'), 'mediterranean');
      expect(
        sortedRecipeTags(['mediterranean', 'main_course']),
        ['main_course', 'mediterranean'],
      );
    });
  });
}
