import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';

class RecipeDetail {
  const RecipeDetail({
    required this.recipe,
    required this.ingredients,
    required this.steps,
    this.nutrition,
    this.photoDisplayUrl,
    this.forkedFromId,
    this.sourceLang = 'es',
  });

  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final NutritionInfo? nutrition;
  final String? photoDisplayUrl;
  final String? forkedFromId;
  final String sourceLang;

  bool get isForked => forkedFromId != null;

  RecipeDetail copyWith({
    Recipe? recipe,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    NutritionInfo? nutrition,
    String? photoDisplayUrl,
    String? forkedFromId,
    String? sourceLang,
  }) {
    return RecipeDetail(
      recipe: recipe ?? this.recipe,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      nutrition: nutrition ?? this.nutrition,
      photoDisplayUrl: photoDisplayUrl ?? this.photoDisplayUrl,
      forkedFromId: forkedFromId ?? this.forkedFromId,
      sourceLang: sourceLang ?? this.sourceLang,
    );
  }
}
