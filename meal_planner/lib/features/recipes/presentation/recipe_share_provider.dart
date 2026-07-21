import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/recipes/data/recipe_share_repository.dart';

final recipeShareRepositoryProvider = Provider<RecipeShareRepository>((ref) {
  return RecipeShareRepository();
});
