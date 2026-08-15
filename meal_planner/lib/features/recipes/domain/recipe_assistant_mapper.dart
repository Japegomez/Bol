import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';

NutritionFormData nutritionFromAssistantJson(Map<String, dynamic> json) {
  return NutritionFormData(
    calories: _parseNonNegativeInt(json['calories']),
    protein: _parseNonNegativeInt(json['protein']),
    carbohydrates: _parseNonNegativeInt(json['carbohydrates']),
    fat: _parseNonNegativeInt(json['fat']),
    fiber: _parseNonNegativeInt(json['fiber']),
  );
}

RecipeFormData recipeFromAssistantJson(Map<String, dynamic> json) {
  final ingredients = _mapIngredients(json['ingredients']);
  final steps = _mapSteps(json['steps']);
  final tags = tagsFromAssistantJson(json['tags']);

  return RecipeFormData(
    title: (json['title'] as String? ?? '').trim(),
    servings: _parseServings(json['servings']),
    prepTime: _parseOptionalInt(json['prepTime']),
    cookTime: _parseOptionalInt(json['cookTime']),
    tags: tags,
    ingredients: ingredients.isEmpty ? [IngredientFormItem()] : ingredients,
    steps: steps.isEmpty ? [StepFormItem()] : steps,
    nutrition: nutritionFromAssistantJson(
      Map<String, dynamic>.from(json['nutrition'] as Map? ?? const {}),
    ),
    tips: (json['tips'] as String? ?? '').trim(),
  );
}

String detectedLangFromAssistantJson(Map<String, dynamic> json) {
  final lang = (json['detectedLang'] as String? ?? '').trim().toLowerCase();
  if (lang.isEmpty) return 'es';
  return lang.split('-').first;
}

List<IngredientFormItem> _mapIngredients(dynamic raw) {
  if (raw is! List) return [];

  return raw
      .whereType<Map<String, dynamic>>()
      .map((map) {
        final name = _formatIngredientName(map['name'] as String? ?? '');
        if (name.isEmpty || _isCookingWaterIngredient(name)) return null;

        final isToTaste = map['isToTaste'] == true;
        final rawUnit = map['unit'] as String?;
        final normalizedUnit = normalizeUnit(rawUnit);
        final useCustomUnit =
            normalizedUnit != null && !predefinedUnits.contains(normalizedUnit);

        return IngredientFormItem(
          name: name,
          quantity: isToTaste ? null : _parseNum(map['quantity']),
          unit: useCustomUnit ? defaultIngredientUnit : normalizedUnit,
          category: normalizeCategoryKey(map['category'] as String?),
          customUnit: useCustomUnit ? normalizedUnit : '',
          useCustomUnit: useCustomUnit,
          isOptional: map['isOptional'] == true,
          isToTaste: isToTaste,
        );
      })
      .whereType<IngredientFormItem>()
      .toList();
}

String _formatIngredientName(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

bool _isCookingWaterIngredient(String name) {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) return false;

  final cookingWaterPatterns = <RegExp>[
    RegExp(
      r'^agua\s+(para|de)\s+(cocer|hervir|ebullir|coccion|cocción|bano|baño|vapor)',
    ),
    RegExp(r'^aigua\s+(per|de)\s+(coure|bullir|vapor)'),
    RegExp(r'^auga\s+(para|de)\s+(cocer|fervir|vapor)'),
    RegExp(r'^ura\s+(egiteko|fermintzeko)'),
    RegExp(r'^água\s+para\s+(cozer|ferver|vapor)'),
    RegExp(r'^water\s+for\s+(boiling|cooking|blanching|steaming)'),
    RegExp(r'^agua\s+hirviendo'),
    RegExp(r'^boiling\s+water'),
  ];

  return cookingWaterPatterns.any((pattern) => pattern.hasMatch(normalized));
}

List<StepFormItem> _mapSteps(dynamic raw) {
  if (raw is! List) return [];

  return raw
      .whereType<Map<String, dynamic>>()
      .map((map) {
        final description = (map['description'] as String? ?? '').trim();
        if (description.isEmpty) return null;
        return StepFormItem(
          description: description,
          isOptional: map['isOptional'] == true,
        );
      })
      .whereType<StepFormItem>()
      .toList();
}

List<String> tagsFromAssistantJson(dynamic raw) {
  if (raw is! List) return [];

  final tags = <String>[];
  for (final entry in raw) {
    if (entry is! String) continue;
    final normalized = normalizeTagKey(entry.trim());
    if (normalized.isEmpty) continue;
    if (suggestedRecipeTagKeys.contains(normalized) &&
        !tags.contains(normalized)) {
      tags.add(normalized);
    }
  }
  return sortedRecipeTags(tags);
}

/// Replaces suggested chips with the assistant result and keeps custom tags.
List<String> mergeAssistantTags({
  required Iterable<String> currentTags,
  required Iterable<String> assistantTags,
}) {
  final suggested = tagsFromAssistantJson(assistantTags.toList());
  final merged = [...suggested];
  for (final entry in currentTags) {
    final normalized = normalizeTagKey(entry.trim());
    if (normalized.isEmpty || suggestedRecipeTagKeys.contains(normalized)) {
      continue;
    }
    if (!merged.contains(normalized)) {
      merged.add(normalized);
    }
  }
  return sortedRecipeTags(merged);
}

int _parseServings(dynamic value) {
  if (value is int && value >= 1) return value;
  if (value is num && value >= 1) return value.round();
  return 4;
}

int? _parseOptionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int && value >= 0) return value;
  if (value is num && value >= 0) return value.round();
  return null;
}

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value.replaceAll(',', '.'));
  return null;
}

/// Nutrition values are whole numbers only (round half away from zero via round).
int? _parseNonNegativeInt(dynamic value) {
  final parsed = _parseNum(value);
  if (parsed == null || parsed < 0) return null;
  return parsed.round();
}
