import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';

NutritionFormData nutritionFromAssistantJson(Map<String, dynamic> json) {
  return NutritionFormData(
    calories: _parseNum(json['calories']),
    protein: _parseNum(json['protein']),
    carbohydrates: _parseNum(json['carbohydrates']),
    fat: _parseNum(json['fat']),
    fiber: _parseNum(json['fiber']),
  );
}

RecipeFormData recipeFromAssistantJson(Map<String, dynamic> json) {
  final ingredients = _mapIngredients(json['ingredients']);
  final steps = _mapSteps(json['steps']);
  final tags = _mapTags(json['tags']);

  return RecipeFormData(
    title: (json['title'] as String? ?? '').trim(),
    servings: _parseServings(json['servings']),
    prepTime: _parseOptionalInt(json['prepTime']),
    cookTime: _parseOptionalInt(json['cookTime']),
    tags: tags,
    ingredients: ingredients.isEmpty ? [IngredientFormItem()] : ingredients,
    steps: steps.isEmpty ? [StepFormItem()] : steps,
    nutrition: nutritionFromAssistantJson(
      Map<String, dynamic>.from(
        json['nutrition'] as Map? ?? const {},
      ),
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
        final useCustomUnit = normalizedUnit != null &&
            !predefinedUnits.contains(normalizedUnit);

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
  final singular = _toSingularIngredientName(trimmed);
  return singular[0].toUpperCase() + singular.substring(1);
}

String _toSingularIngredientName(String name) {
  return name
      .split(RegExp(r'\s+'))
      .map(_singularizeWord)
      .join(' ');
}

String _singularizeWord(String word) {
  if (word.length <= 2) return word;

  final lower = word.toLowerCase();
  const irregular = {
    'nueces': 'nuez',
    'peces': 'pez',
  };
  final irregularSingular = irregular[lower];
  if (irregularSingular != null) {
    return _preserveWordCase(word, irregularSingular);
  }

  if (lower.endsWith('ies') && word.length > 4) {
    return _preserveWordCase(word, '${word.substring(0, word.length - 3)}y');
  }
  if (lower.endsWith('oes') && word.length > 4) {
    return word.substring(0, word.length - 2);
  }
  if (lower.endsWith('as') && word.length > 3) {
    return word.substring(0, word.length - 1);
  }
  if (lower.endsWith('os') && word.length > 3) {
    return word.substring(0, word.length - 1);
  }
  if (lower.endsWith('es') &&
      word.length > 3 &&
      !lower.endsWith('ces') &&
      !lower.endsWith('ses')) {
    return word.substring(0, word.length - 1);
  }
  if (lower.endsWith('s') &&
      !lower.endsWith('ss') &&
      !lower.endsWith('us') &&
      word.length > 3) {
    return word.substring(0, word.length - 1);
  }

  return word;
}

String _preserveWordCase(String original, String replacement) {
  if (original.isEmpty || replacement.isEmpty) return replacement;
  if (original[0] == original[0].toUpperCase()) {
    return replacement[0].toUpperCase() + replacement.substring(1);
  }
  return replacement;
}

bool _isCookingWaterIngredient(String name) {
  final normalized = name.trim().toLowerCase();
  if (normalized.isEmpty) return false;

  const plainWater = {'agua', 'water', 'aigua', 'auga', 'ura', 'água'};
  if (plainWater.contains(normalized)) return true;

  final cookingWaterPatterns = <RegExp>[
    RegExp(r'^agua\s+(para|de)\s+(cocer|hervir|ebullir|coccion|cocción|bano|baño|vapor)'),
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

List<String> _mapTags(dynamic raw) {
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
  return tags;
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
