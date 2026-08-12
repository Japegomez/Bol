import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/features/recipes/domain/ingredient_label.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  group('recipeContentLocaleName', () {
    test('uses app locale when not translated', () {
      expect(
        recipeContentLocaleName(
          sourceLang: 'en',
          appLocale: 'es',
          isTranslated: false,
          showingOriginal: true,
        ),
        'es',
      );
    });

    test('uses source language when showing original of a translation', () {
      expect(
        recipeContentLocaleName(
          sourceLang: 'en',
          appLocale: 'es',
          isTranslated: true,
          showingOriginal: true,
        ),
        'en',
      );
    });

    test('uses app locale when showing the translation', () {
      expect(
        recipeContentLocaleName(
          sourceLang: 'en',
          appLocale: 'es',
          isTranslated: true,
          showingOriginal: false,
        ),
        'es',
      );
    });
  });

  group('formatIngredientDisplay', () {
    test('formats to-taste ingredients', () {
      expect(
        formatIngredientDisplay(l10n, name: 'Sal', isToTaste: true),
        'sal al gusto',
      );
    });

    test('joins abbreviated units without a space before the unit', () {
      expect(
        formatIngredientDisplay(l10n, name: 'Harina', quantity: 200, unit: 'g'),
        '200g de harina',
      );
    });

    test('joins word units with a space', () {
      expect(
        formatIngredientDisplay(
          l10n,
          name: 'Huevo',
          quantity: 2,
          unit: 'unidad',
        ),
        '2 unidades de huevo',
      );
    });

    test('omits unit when missing', () {
      expect(
        formatIngredientDisplay(l10n, name: 'Perejil', quantity: 1),
        '1 perejil',
      );
    });

    test('returns the name when there is no quantity', () {
      expect(formatIngredientDisplay(l10n, name: 'Agua'), 'agua');
    });

    test('rounds shopping quantities', () {
      expect(
        formatShoppingItemLabel(l10n, name: 'Harina', quantity: 1.6, unit: 'g'),
        '2g de harina',
      );
    });
  });

  group('formatIngredientLabel', () {
    test('delegates to display formatting', () {
      const ingredient = Ingredient(
        id: '1',
        recipeId: 'r1',
        name: 'Tomate',
        quantity: 3,
        unit: 'unidad',
        position: 0,
      );
      expect(formatIngredientLabel(l10n, ingredient), '3 unidades de tomate');
    });
  });
}
