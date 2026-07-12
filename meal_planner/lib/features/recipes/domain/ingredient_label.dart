import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

/// Locale for formatting units/connectors when showing recipe content.
///
/// When the user toggles "view original", units and connectors must follow the
/// recipe [sourceLang], not the app UI language.
String recipeContentLocaleName({
  required String sourceLang,
  required String appLocale,
  required bool isTranslated,
  required bool showingOriginal,
}) {
  if (!isTranslated) return appLocale;
  return showingOriginal ? sourceLang : appLocale;
}

String _toTasteForLocale(String localeName) {
  return lookupAppLocalizations(Locale(localeName)).toTaste.toLowerCase();
}
String _formatQuantity(num quantity, {bool round = false}) {
  final value = round ? quantity.round() : quantity;
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toString();
}

String formatIngredientDisplay(
  AppLocalizations l10n, {
  required String name,
  num? quantity,
  String? unit,
  bool isToTaste = false,
  bool roundQuantity = false,
  String? contentLocaleName,
}) {
  final localeName = contentLocaleName ?? l10n.localeName;
  final displayName = name.toLowerCase();

  if (isToTaste) {
    return '$displayName ${_toTasteForLocale(localeName)}';
  }

  final formattedUnit = localizedUnitForLocale(localeName, unit, quantity);
  final hasQuantity = quantity != null;
  final hasUnit = formattedUnit.isNotEmpty;

  final connector = ingredientNameConnector(localeName);
  final connectorPart = connector.isEmpty ? '' : '$connector ';
  if (hasQuantity && hasUnit && isAbbreviatedUnit(unit)) {
    return '${_formatQuantity(quantity, round: roundQuantity)}$formattedUnit '
        '$connectorPart$displayName';
  }

  if (hasQuantity && hasUnit) {
    return '${_formatQuantity(quantity, round: roundQuantity)} $formattedUnit '
        '$connectorPart$displayName';
  }

  if (hasQuantity) {
    return '${_formatQuantity(quantity, round: roundQuantity)} $displayName';
  }

  return name;
}

String formatIngredientLabel(
  AppLocalizations l10n,
  Ingredient ingredient, {
  String? contentLocaleName,
}) {
  return formatIngredientDisplay(
    l10n,
    name: ingredient.name,
    quantity: ingredient.quantity,
    unit: ingredient.unit,
    isToTaste: ingredient.isToTaste,
    contentLocaleName: contentLocaleName,
  );
}
String formatShoppingItemLabel(
  AppLocalizations l10n, {
  required String name,
  num? quantity,
  String? unit,
}) {
  return formatIngredientDisplay(
    l10n,
    name: name,
    quantity: quantity,
    unit: unit,
    roundQuantity: true,
  );
}
