import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/models/profile.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/social/domain/public_recipe_detail.dart';
import 'package:meal_planner/features/social/domain/public_recipe_summary.dart';

class SocialRepository {
  static const _photoBucket = 'recipe-photos';
  static const _avatarBucket = 'avatars';
  static const _signedUrlExpiry = 3600;
  static const _pageSize = 20;

  String get _userId {
    final id = supabase.auth.currentUser?.id;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  Future<List<PublicRecipeSummary>> fetchPublicRecipes({
    String? search,
    String? tag,
    String sort = 'recent',
    int page = 0,
  }) async {
    final data = await supabase.rpc<List<dynamic>>(
      'list_public_recipes',
      params: {
        'p_search': search?.trim().isEmpty ?? true ? null : search!.trim(),
        'p_tag': tag,
        'p_sort': sort,
        'p_limit': _pageSize,
        'p_offset': page * _pageSize,
      },
    );

    return data
        .map((row) => PublicRecipeSummary.fromJson(
              Map<String, dynamic>.from(row as Map),
            ))
        .toList();
  }

  Future<Set<String>> fetchPublicTags() async {
    final data = await supabase
        .from(Recipe.table_name)
        .select(Recipe.c_tags)
        .eq(Recipe.c_isPublic, true);

    final tags = <String>{};
    for (final row in List<Map<String, dynamic>>.from(data)) {
      final rowTags = row[Recipe.c_tags];
      if (rowTags is List) {
        tags.addAll(rowTags.map((e) => e.toString()));
      }
    }
    return tags;
  }

  Future<PublicRecipeDetail> fetchPublicRecipeDetail(String id) async {
    final recipeData = await supabase
        .from(Recipe.table_name)
        .select()
        .eq(Recipe.c_id, id)
        .eq(Recipe.c_isPublic, true)
        .maybeSingle();

    if (recipeData == null) {
      throw Exception('Receta pública no encontrada');
    }

    final recipe = Recipe.converterSingle(
      Map<String, dynamic>.from(recipeData),
    );

    final profileData = await supabase
        .from(Profile.table_name)
        .select(Profile.c_username)
        .eq(Profile.c_id, recipe.userId)
        .maybeSingle();

    final ingredientsData = await supabase
        .from(Ingredient.table_name)
        .select()
        .eq(Ingredient.c_recipeId, id)
        .order(Ingredient.c_position, ascending: true);

    final stepsData = await supabase
        .from(RecipeStep.table_name)
        .select()
        .eq(RecipeStep.c_recipeId, id)
        .order(RecipeStep.c_position, ascending: true);

    final nutritionData = await supabase
        .from(NutritionInfo.table_name)
        .select()
        .eq(NutritionInfo.c_recipeId, id)
        .maybeSingle();

    final ratingsData = await supabase
        .from('recipe_ratings')
        .select('score')
        .eq('recipe_id', id);

    final ratings = List<Map<String, dynamic>>.from(ratingsData);
    final avgScore = ratings.isEmpty
        ? 0.0
        : ratings.map((r) => r['score'] as int).reduce((a, b) => a + b) /
            ratings.length;

    int? myRating;
    if (recipe.userId != _userId) {
      final myRatingData = await supabase
          .from('recipe_ratings')
          .select('score')
          .eq('recipe_id', id)
          .eq('user_id', _userId)
          .maybeSingle();
      myRating = myRatingData?['score'] as int?;
    }

    final photoDisplayUrl = await resolvePhotoUrl(recipe.photoUrl);

    return PublicRecipeDetail(
      recipe: recipe,
      ingredients: Ingredient.converter(
        List<Map<String, dynamic>>.from(ingredientsData),
      ),
      steps: RecipeStep.converter(
        List<Map<String, dynamic>>.from(stepsData),
      ),
      nutrition: nutritionData != null
          ? NutritionInfo.converterSingle(
              Map<String, dynamic>.from(nutritionData),
            )
          : null,
      photoDisplayUrl: photoDisplayUrl,
      authorName: profileData?[Profile.c_username]?.toString() ?? 'Usuario',
      avgScore: avgScore,
      ratingCount: ratings.length,
      myRating: myRating,
    );
  }

  Future<String> forkRecipe(String publicRecipeId) async {
    final detail = await fetchPublicRecipeDetail(publicRecipeId);
    final source = detail.recipe;

    if (source.userId == _userId) {
      throw Exception('No puedes guardar tu propia receta en el recetario');
    }

    final recipeData = await supabase
        .from(Recipe.table_name)
        .insert({
          ...Recipe.insert(
            userId: _userId,
            title: source.title,
            servings: source.servings,
            prepTime: source.prepTime,
            cookTime: source.cookTime,
            tags: source.tags,
            isPublic: false,
            tips: source.tips,
          ),
          'forked_from_id': publicRecipeId,
        })
        .select()
        .single();

    final newId = recipeData['id'].toString();

    if (detail.ingredients.isNotEmpty) {
      await supabase.from(Ingredient.table_name).insert(
            detail.ingredients
                .asMap()
                .entries
                .map(
                  (entry) => Ingredient.insert(
                    recipeId: newId,
                    name: entry.value.name,
                    quantity: entry.value.quantity,
                    unit: entry.value.unit,
                    category: entry.value.category,
                    position: entry.key,
                    isOptional: entry.value.isOptional,
                    isIncluded: entry.value.isIncluded,
                    isToTaste: entry.value.isToTaste,
                  ),
                )
                .toList(),
          );
    }

    if (detail.steps.isNotEmpty) {
      await supabase.from(RecipeStep.table_name).insert(
            detail.steps
                .map(
                  (step) => RecipeStep.insert(
                    recipeId: newId,
                    position: step.position,
                    description: step.description,
                    isOptional: step.isOptional,
                  ),
                )
                .toList(),
          );
    }

    if (detail.nutrition != null) {
      final n = detail.nutrition!;
      await supabase.from(NutritionInfo.table_name).insert(
            NutritionInfo.insert(
              recipeId: newId,
              calories: n.calories,
              protein: n.protein,
              carbohydrates: n.carbohydrates,
              fat: n.fat,
              fiber: n.fiber,
            ),
          );
    }

    return newId;
  }

  Future<void> rateRecipe(String recipeId, int score) async {
    if (score < 1 || score > 5) {
      throw Exception('La puntuación debe estar entre 1 y 5');
    }

    await supabase.from('recipe_ratings').upsert(
      {
        'user_id': _userId,
        'recipe_id': recipeId,
        'score': score,
      },
      onConflict: 'user_id,recipe_id',
    );
  }

  Future<bool> isFollowing(String userId) async {
    final data = await supabase
        .from('follows')
        .select('follower_id')
        .eq('follower_id', _userId)
        .eq('following_id', userId)
        .maybeSingle();
    return data != null;
  }

  Future<void> followUser(String userId) async {
    if (userId == _userId) return;
    await supabase.from('follows').insert({
      'follower_id': _userId,
      'following_id': userId,
    });
  }

  Future<void> unfollowUser(String userId) async {
    await supabase
        .from('follows')
        .delete()
        .eq('follower_id', _userId)
        .eq('following_id', userId);
  }

  Future<List<PublicRecipeSummary>> fetchFeed({int page = 0}) async {
    final followsData = await supabase
        .from('follows')
        .select('following_id')
        .eq('follower_id', _userId);

    final followingIds = List<Map<String, dynamic>>.from(followsData)
        .map((row) => row['following_id'].toString())
        .toList();

    if (followingIds.isEmpty) return [];

    final recipesData = await supabase
        .from(Recipe.table_name)
        .select()
        .eq(Recipe.c_isPublic, true)
        .inFilter(Recipe.c_userId, followingIds)
        .order(Recipe.c_createdAt, ascending: false)
        .range(page * _pageSize, (page + 1) * _pageSize - 1);

    final recipes = Recipe.converter(List<Map<String, dynamic>>.from(recipesData));
    if (recipes.isEmpty) return [];

    final profilesData = await supabase
        .from(Profile.table_name)
        .select('${Profile.c_id}, ${Profile.c_username}')
        .inFilter(Profile.c_id, followingIds);

    final usernames = {
      for (final row in List<Map<String, dynamic>>.from(profilesData))
        row[Profile.c_id].toString(): row[Profile.c_username].toString(),
    };

    final summaries = <PublicRecipeSummary>[];
    for (final recipe in recipes) {

      final ratingsData = await supabase
          .from('recipe_ratings')
          .select('score')
          .eq('recipe_id', recipe.id);
      final ratings = List<Map<String, dynamic>>.from(ratingsData);
      final avgScore = ratings.isEmpty
          ? 0.0
          : ratings.map((r) => r['score'] as int).reduce((a, b) => a + b) /
              ratings.length;

      summaries.add(
        PublicRecipeSummary(
          id: recipe.id,
          userId: recipe.userId,
          title: recipe.title,
          photoUrl: recipe.photoUrl,
          servings: recipe.servings,
          tags: recipe.tags,
          createdAt: recipe.createdAt,
          authorName: usernames[recipe.userId] ?? 'Usuario',
          avgScore: avgScore,
          ratingCount: ratings.length,
        ),
      );
    }
    return summaries;
  }

  Future<PublicProfileData> fetchPublicProfile(String userId) async {
    final profileData = await supabase
        .from(Profile.table_name)
        .select()
        .eq(Profile.c_id, userId)
        .maybeSingle();

    if (profileData == null) {
      throw Exception('Perfil no encontrado');
    }

    final profile = Profile.fromJson(Map<String, dynamic>.from(profileData));
    final avatarUrl = await resolveAvatarUrl(profile.avatarUrl);

    final recipesData = await supabase
        .from(Recipe.table_name)
        .select()
        .eq(Recipe.c_userId, userId)
        .eq(Recipe.c_isPublic, true)
        .order(Recipe.c_createdAt, ascending: false);

    final recipes = Recipe.converter(List<Map<String, dynamic>>.from(recipesData));

    double totalScore = 0;
    int totalRatings = 0;
    final summaries = <PublicRecipeSummary>[];

    for (final recipe in recipes) {
      final ratingsData = await supabase
          .from('recipe_ratings')
          .select('score')
          .eq('recipe_id', recipe.id);
      final ratings = List<Map<String, dynamic>>.from(ratingsData);
      final avgScore = ratings.isEmpty
          ? 0.0
          : ratings.map((r) => r['score'] as int).reduce((a, b) => a + b) /
              ratings.length;

      totalScore += ratings.fold<double>(
        0,
        (sum, r) => sum + (r['score'] as int),
      );
      totalRatings += ratings.length;

      summaries.add(
        PublicRecipeSummary(
          id: recipe.id,
          userId: recipe.userId,
          title: recipe.title,
          photoUrl: recipe.photoUrl,
          servings: recipe.servings,
          tags: recipe.tags,
          createdAt: recipe.createdAt,
          authorName: profile.username,
          avgScore: avgScore,
          ratingCount: ratings.length,
        ),
      );
    }

    return PublicProfileData(
      userId: userId,
      username: profile.username,
      avatarUrl: avatarUrl,
      recipeCount: recipes.length,
      avgRating: totalRatings == 0 ? 0 : totalScore / totalRatings,
      recipes: summaries,
    );
  }

  Future<String?> resolvePhotoUrl(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return null;
    if (photoPath.startsWith('http')) return photoPath;

    return supabase.storage
        .from(_photoBucket)
        .createSignedUrl(photoPath, _signedUrlExpiry);
  }

  Future<String?> resolveAvatarUrl(String? avatarPath) async {
    if (avatarPath == null || avatarPath.isEmpty) return null;
    if (avatarPath.startsWith('http')) return avatarPath;

    return supabase.storage
        .from(_avatarBucket)
        .createSignedUrl(avatarPath, _signedUrlExpiry);
  }
}
