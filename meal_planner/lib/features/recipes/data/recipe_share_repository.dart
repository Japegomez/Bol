import 'package:meal_planner/core/config/share_urls.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/recipes/domain/recipe_detail.dart';

class RecipeShareLink {
  const RecipeShareLink({
    required this.token,
    required this.expiresAt,
    required this.url,
  });

  final String token;
  final DateTime expiresAt;
  final String url;
}

class RecipeShareRepository {
  Future<RecipeShareLink> getOrCreatePrivateShareLink(String recipeId) async {
    final data = await supabase.rpc<dynamic>(
      'get_or_create_recipe_share_link',
      params: {'p_recipe_id': recipeId},
    );

    final map = data is Map
        ? Map<String, dynamic>.from(data)
        : Map<String, dynamic>.from((data as List).first as Map);
    final token = map['token'] as String;
    return RecipeShareLink(
      token: token,
      expiresAt: DateTime.parse(map['expires_at'] as String),
      url: ShareUrls.privateLink(token),
    );
  }

  Future<String> resolvePrivateShareToken(String token) async {
    final recipeId = await supabase.rpc<dynamic>(
      'resolve_recipe_share',
      params: {'p_token': token},
    );
    return recipeId.toString();
  }

  /// Revokes (deletes) all active private share links for a recipe. Only the
  /// owner can call this (enforced by the recipe_share_links_delete_owner
  /// RLS policy). After this, existing share URLs stop resolving.
  ///
  /// Throws [StateError] when no link was deleted (none existed or RLS denied).
  Future<void> revokePrivateShareLinks(String recipeId) async {
    final deleted = await supabase
        .from('recipe_share_links')
        .delete()
        .eq('recipe_id', recipeId)
        .select('id');
    if (deleted.isEmpty) {
      throw StateError('no_active_share_link');
    }
  }

  /// Fetches the full recipe payload for a private share token via the
  /// token-gated `get_shared_recipe` RPC. The recipe content is not readable
  /// through table selects (RLS), so the token is the only access path.
  Future<RecipeDetail> fetchSharedRecipe(String token) async {
    final data = await supabase.rpc<dynamic>(
      'get_shared_recipe',
      params: {'p_token': token},
    );
    final map = data is Map
        ? Map<String, dynamic>.from(data)
        : Map<String, dynamic>.from((data as List).first as Map);

    final recipeMap = Map<String, dynamic>.from(map['recipe'] as Map);
    final recipe = Recipe.converterSingle(recipeMap);
    final ingredients = Ingredient.converter(
      (map['ingredients'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
    final steps = RecipeStep.converter(
      (map['steps'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
    final nutritionRaw = map['nutrition'];
    final nutrition = nutritionRaw == null
        ? null
        : NutritionInfo.converterSingle(
            Map<String, dynamic>.from(nutritionRaw as Map),
          );
    final forkedFromId = recipeMap['forked_from_id']?.toString();
    final sourceLang = recipeMap['source_lang']?.toString() ?? 'es';

    return RecipeDetail(
      recipe: recipe,
      ingredients: ingredients,
      steps: steps,
      nutrition: nutrition,
      // Shared-recipe photos are not readable via storage RLS after the C2
      // fix; display without a photo. Restore later via a token-gated
      // signing endpoint.
      photoDisplayUrl: null,
      forkedFromId: (forkedFromId == null || forkedFromId.isEmpty) ? null : forkedFromId,
      sourceLang: sourceLang,
    );
  }

  String publicShareUrl(String recipeId) => ShareUrls.publicLink(recipeId);
}
