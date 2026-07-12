import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';

class PublicRecipeDetail {
  const PublicRecipeDetail({
    required this.recipe,
    required this.ingredients,
    required this.steps,
    this.nutrition,
    this.photoDisplayUrl,
    required this.authorName,
    required this.avgScore,
    required this.ratingCount,
    this.myRating,
    this.sourceLang = 'es',
  });

  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final NutritionInfo? nutrition;
  final String? photoDisplayUrl;
  final String authorName;
  final double avgScore;
  final int ratingCount;
  final int? myRating;
  final String sourceLang;

  PublicRecipeDetail copyWith({
    Recipe? recipe,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    NutritionInfo? nutrition,
    String? photoDisplayUrl,
    String? authorName,
    double? avgScore,
    int? ratingCount,
    int? myRating,
    String? sourceLang,
  }) {
    return PublicRecipeDetail(
      recipe: recipe ?? this.recipe,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      nutrition: nutrition ?? this.nutrition,
      photoDisplayUrl: photoDisplayUrl ?? this.photoDisplayUrl,
      authorName: authorName ?? this.authorName,
      avgScore: avgScore ?? this.avgScore,
      ratingCount: ratingCount ?? this.ratingCount,
      myRating: myRating ?? this.myRating,
      sourceLang: sourceLang ?? this.sourceLang,
    );
  }
}
