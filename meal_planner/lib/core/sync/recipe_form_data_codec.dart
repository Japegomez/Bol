import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';

/// Serialize/deserialize [RecipeFormData] for the pending-operations queue.
abstract final class RecipeFormDataCodec {
  static Map<String, dynamic> toJson(RecipeFormData form) {
    return {
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
    final nutritionJson = json['nutrition'] as Map<String, dynamic>? ?? {};
    return RecipeFormData(
      title: json['title'] as String? ?? '',
      servings: json['servings'] as int? ?? 4,
      prepTime: json['prepTime'] as int?,
      cookTime: json['cookTime'] as int?,
      tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      tips: json['tips'] as String? ?? '',
      existingPhotoPath: json['existingPhotoPath'] as String?,
      removePhoto: json['removePhoto'] as bool? ?? false,
      isPublic: json['isPublic'] as bool? ?? false,
      forkedFromId: json['forkedFromId'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map(
            (raw) {
              final i = Map<String, dynamic>.from(raw as Map);
              return IngredientFormItem(
                name: i['name'] as String? ?? '',
                quantity: i['quantity'] as num?,
                unit: i['unit'] as String?,
                category: i['category'] as String? ?? 'Carnes y pescados',
                customUnit: i['customUnit'] as String? ?? '',
                useCustomUnit: i['useCustomUnit'] as bool? ?? false,
                isOptional: i['isOptional'] as bool? ?? false,
                isIncluded: i['isIncluded'] as bool? ?? true,
                isToTaste: i['isToTaste'] as bool? ?? false,
              );
            },
          )
          .toList(),
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map(
            (raw) {
              final s = Map<String, dynamic>.from(raw as Map);
              return StepFormItem(
                description: s['description'] as String? ?? '',
                isOptional: s['isOptional'] as bool? ?? false,
              );
            },
          )
          .toList(),
      nutrition: NutritionFormData(
        calories: nutritionJson['calories'] as num?,
        protein: nutritionJson['protein'] as num?,
        carbohydrates: nutritionJson['carbohydrates'] as num?,
        fat: nutritionJson['fat'] as num?,
        fiber: nutritionJson['fiber'] as num?,
      ),
    );
  }
}
