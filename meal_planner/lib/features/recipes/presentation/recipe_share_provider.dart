import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/recipes/data/recipe_share_repository.dart';
import 'package:meal_planner/features/recipes/domain/recipe_detail.dart';

final recipeShareRepositoryProvider = Provider<RecipeShareRepository>((ref) {
  return RecipeShareRepository();
});

/// Full recipe payload for a private share token, fetched via the
/// token-gated `get_shared_recipe` RPC. Used by the recipe detail screen
/// when opened from a private share link (`?shared=<token>`).
final sharedRecipeDetailProvider =
    FutureProvider.family<RecipeDetail, String>((ref, token) async {
  return ref.read(recipeShareRepositoryProvider).fetchSharedRecipe(token);
});
