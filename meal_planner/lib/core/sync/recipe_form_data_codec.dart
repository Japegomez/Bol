import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';

/// Serialize/deserialize [RecipeFormData] for the pending-operations queue.
abstract final class RecipeFormDataCodec {
  static const int _currentVersion = 1;

  static Map<String, dynamic> toJson(RecipeFormData form) {
    return {
      'version': _currentVersion,
      'title': form.title,
      'servings': form.servings,
      'prepTime': form.prepTime,
      'cookTime': form.cookTime,
      'tags': form.tags,
      'tips': form.tips,
      'existingPhotoPath': form.existingPhotoPath,
      'removePhoto': form.removePhoto,
      'isPublic': form.isPublic,
      'forkedFromId': form.forkedFromId,
      'ingredients': form.ingredients
          .map(
            (i) => {
              'name': i.name,
              'quantity': i.quantity,
              'unit': i.unit,
              'category': i.category,
              'customUnit': i.customUnit,
              'useCustomUnit': i.useCustomUnit,
              'isOptional': i.isOptional,
              'isIncluded': i.isIncluded,
              'isToTaste': i.isToTaste,
            },
          )
          .toList(),
      'steps': form.steps
          .map(
            (s) => {
              'description': s.description,
              'isOptional': s.isOptional,
            },
          )
          .toList(),
      'nutrition': {
        'calories': form.nutrition.calories,
        'protein': form.nutrition.protein,
        'carbohydrates': form.nutrition.carbohydrates,
        'fat': form.nutrition.fat,
        'fiber': form.nutrition.fiber,
      },
    };
  }

  static RecipeFormData fromJson(Map<String, dynamic> json) {
    // Validate version
    final version = json['version'] as int?;
    if (version == null || version != _currentVersion) {
      throw FormatException(
        'Incompatible recipe form data version: $version (expected $_currentVersion)',
      );
    }

    // Validate required fields
    final title = json['title'];
    if (title == null || title is! String || title.trim().isEmpty) {
      throw const FormatException(
        'Recipe title is required and must be non-empty',
      );
    }

    final servings = json['servings'];
    if (servings == null || servings is! int || servings < 1) {
      throw const FormatException('Recipe servings must be a positive integer');
    }

    // Validate ingredients structure
    final ingredientsJson = json['ingredients'];
    if (ingredientsJson is! List) {
      throw const FormatException('Recipe ingredients must be a list');
    }

    // Validate steps structure
    final stepsJson = json['steps'];
    if (stepsJson is! List) {
      throw const FormatException('Recipe steps must be a list');
    }

    final rawNutrition = json['nutrition'];
    Map<String, dynamic> nutritionMap = {};
    if (rawNutrition != null) {
      if (rawNutrition is! Map) {
        throw const FormatException('Recipe nutrition must be a map');
      }
      nutritionMap = Map<String, dynamic>.from(rawNutrition);
    }

    return RecipeFormData(
      title: title,
      servings: servings,
      prepTime: json['prepTime'] as int?,
      cookTime: json['cookTime'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      tips: json['tips'] as String? ?? '',
      existingPhotoPath: json['existingPhotoPath'] as String?,
      removePhoto: json['removePhoto'] as bool? ?? false,
      isPublic: json['isPublic'] as bool? ?? false,
      forkedFromId: json['forkedFromId'] as String?,
      ingredients: ingredientsJson
          .map(
            (raw) {
              if (raw is! Map) {
                throw const FormatException('Each ingredient must be a map');
              }
              final i = Map<String, dynamic>.from(raw);
              final name = i['name'];
              if (name == null || name is! String || name.trim().isEmpty) {
                throw const FormatException('Ingredient name is required');
              }
              final isToTaste = i['isToTaste'] as bool? ?? false;
              final useCustomUnit = i['useCustomUnit'] as bool? ?? false;
              return IngredientFormItem(
                name: name,
                quantity: i['quantity'] as num?,
                unit: isToTaste || useCustomUnit
                    ? i['unit'] as String?
                    : (i['unit'] as String?) ?? defaultIngredientUnit,
                category: normalizeCategoryKey(i['category'] as String?),
                customUnit: i['customUnit'] as String? ?? '',
                useCustomUnit: useCustomUnit,
                isOptional: i['isOptional'] as bool? ?? false,
                isIncluded: i['isIncluded'] as bool? ?? true,
                isToTaste: isToTaste,
              );
            },
          )
          .toList(),
      steps: stepsJson
          .map(
            (raw) {
              if (raw is! Map) {
                throw const FormatException('Each step must be a map');
              }
              final s = Map<String, dynamic>.from(raw);
              final description = s['description'];
              if (description == null ||
                  description is! String ||
                  description.trim().isEmpty) {
                throw const FormatException('Step description is required');
              }
              return StepFormItem(
                description: description,
                isOptional: s['isOptional'] as bool? ?? false,
              );
            },
          )
          .toList(),
      nutrition: NutritionFormData(
        calories: nutritionMap['calories'] as num?,
        protein: nutritionMap['protein'] as num?,
        carbohydrates: nutritionMap['carbohydrates'] as num?,
        fat: nutritionMap['fat'] as num?,
        fiber: nutritionMap['fiber'] as num?,
      ),
    );
  }
}
