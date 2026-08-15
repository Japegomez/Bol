import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/core/local_db/local_cache_store.dart';
import 'package:meal_planner/core/local_db/local_db_provider.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/core/offline/offline_exceptions.dart';
import 'package:meal_planner/core/offline/supabase_error_utils.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/sync/pending_operation_types.dart';
import 'package:meal_planner/core/sync/recipe_form_data_codec.dart';
import 'package:meal_planner/features/recipes/data/recipe_assistant_repository.dart';
import 'package:meal_planner/features/recipes/domain/recipe_detail.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipesRepository {
  RecipesRepository(this._cache);

  static const _photoBucket = 'recipe-photos';
  static const _signedUrlExpiry = 3600;

  final LocalCacheStore _cache;

  String get _userId {
    final id = supabase.auth.currentUser?.id;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  Future<void> _guardOfflineMutation({
    String? householdId,
    required bool isOnline,
  }) async {
    if (householdId != null && !isOnline) {
      throw OfflineEditBlockedException();
    }
  }

  Future<void> _guardOfflinePhoto({
    required RecipeFormData form,
    required bool isOnline,
  }) async {
    if (form.pendingPhoto != null && !isOnline) {
      throw OfflinePhotoBlockedException();
    }
  }

  Future<List<Recipe>> fetchRecipes({
    String? search,
    Set<String>? tags,
    List<String>? memberUserIds,
  }) async {
    final ownerIds = (memberUserIds != null && memberUserIds.isNotEmpty)
        ? memberUserIds
        : <String>[_userId];

    if (await NetworkStatus.isOnline) {
      try {
        var query = supabase.from(Recipe.table_name).select();
        if (ownerIds.length == 1) {
          query = query.eq(Recipe.c_userId, ownerIds.first);
        } else {
          query = query.inFilter(Recipe.c_userId, ownerIds);
        }

        if (search != null && search.trim().isNotEmpty) {
          query = query.ilike(Recipe.c_title, '%${search.trim()}%');
        }
        if (tags != null && tags.isNotEmpty) {
          query = query.contains(Recipe.c_tags, tags.toList());
        }

        final data = await query.order(Recipe.c_createdAt, ascending: false);
        final recipes = Recipe.converter(List<Map<String, dynamic>>.from(data));
        await _cache.cacheRecipes(recipes);
        return recipes;
      } catch (error) {
        if (!shouldFallbackToCache(error)) rethrow;
        return _cache.getRecipes(userId: _userId, search: search, tags: tags);
      }
    }

    // Offline: household shared list is not cached; show own recipes only.
    return _cache.getRecipes(userId: _userId, search: search, tags: tags);
  }

  Future<Set<String>> fetchAllTags({List<String>? memberUserIds}) async {
    final recipes = await fetchRecipes(memberUserIds: memberUserIds);
    final tags = <String>{};
    for (final recipe in recipes) {
      tags.addAll(recipe.tags);
    }
    return tags;
  }

  Future<RecipeDetail> fetchRecipeDetail(String id) async {
    if (await NetworkStatus.isOnline) {
      try {
        final detail = await _fetchRecipeDetailRemote(id);
        // Only cache own recipes (share-link / foreign peeks must not pollute local DB).
        if (detail.recipe.userId == _userId) {
          await _cache.saveRecipeDetail(
            recipe: detail.recipe,
            ingredients: detail.ingredients,
            steps: detail.steps,
            nutrition: detail.nutrition,
            forkedFromId: detail.forkedFromId,
          );
        }
        return detail;
      } catch (error) {
        if (!shouldFallbackToCache(error)) rethrow;
        final cached = await _cache.getRecipeDetail(id, userId: _userId);
        if (cached != null) return cached;
        rethrow;
      }
    }

    final cached = await _cache.getRecipeDetail(id, userId: _userId);
    if (cached != null) return cached;
    throw Exception('Receta no encontrada');
  }

  Future<RecipeDetail> _fetchRecipeDetailRemote(String id) async {
    // No owner filter: RLS allows own, public, household, and active share-link reads.
    final recipeData = await supabase
        .from(Recipe.table_name)
        .select()
        .eq(Recipe.c_id, id)
        .maybeSingle();

    if (recipeData == null) {
      throw Exception('Receta no encontrada');
    }

    final recipe = Recipe.converterSingle(
      Map<String, dynamic>.from(recipeData),
    );
    final forkedFromId = recipeData['forked_from_id']?.toString();
    final sourceLang = recipeData['source_lang']?.toString() ?? 'es';

    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      supabase
          .from(Ingredient.table_name)
          .select()
          .eq(Ingredient.c_recipeId, id)
          .order(Ingredient.c_position, ascending: true),
      supabase
          .from(RecipeStep.table_name)
          .select()
          .eq(RecipeStep.c_recipeId, id)
          .order(RecipeStep.c_position, ascending: true),
      supabase
          .from(NutritionInfo.table_name)
          .select()
          .eq(NutritionInfo.c_recipeId, id)
          .maybeSingle(),
      resolvePhotoUrl(recipe.photoUrl),
    ]);

    final ingredientsData = results[0] as List<dynamic>;
    final stepsData = results[1] as List<dynamic>;
    final nutritionData = results[2] as Map<String, dynamic>?;
    final photoDisplayUrl = results[3] as String?;

    return RecipeDetail(
      recipe: recipe,
      ingredients: Ingredient.converter(
        List<Map<String, dynamic>>.from(ingredientsData),
      ),
      steps: RecipeStep.converter(List<Map<String, dynamic>>.from(stepsData)),
      nutrition: nutritionData != null
          ? NutritionInfo.converterSingle(
              Map<String, dynamic>.from(nutritionData),
            )
          : null,
      photoDisplayUrl: photoDisplayUrl,
      forkedFromId: forkedFromId,
      sourceLang: sourceLang,
    );
  }

  Future<String?> resolvePhotoUrl(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return null;
    if (photoPath.startsWith('http')) return photoPath;
    if (!await NetworkStatus.isOnline) return null;

    try {
      return await supabase.storage
          .from(_photoBucket)
          .createSignedUrl(photoPath, _signedUrlExpiry);
    } catch (_) {
      // Shared / household peeks may lack storage rights; load recipe without photo.
      return null;
    }
  }

  Future<String> createRecipe(
    RecipeFormData form, {
    String? householdId,
    String sourceLang = 'es',
  }) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);
    await _guardOfflinePhoto(form: form, isOnline: isOnline);

    if (isOnline) {
      try {
        final id = await createRecipeRemote(form, sourceLang: sourceLang);
        await _cacheRecipeDetailBestEffort(id);
        return id;
      } catch (error) {
        if (shouldFallbackToCache(error)) {
          // Revalidate constraints before falling back
          await _guardOfflineMutation(
            householdId: householdId,
            isOnline: false,
          );
          await _guardOfflinePhoto(form: form, isOnline: false);
          return _createRecipeOffline(form);
        }
        rethrow;
      }
    }

    return _createRecipeOffline(form);
  }

  Future<void> _cacheRecipeDetailBestEffort(String id) async {
    try {
      final detail = await _fetchRecipeDetailRemote(id);
      await _cache.saveRecipeDetail(
        recipe: detail.recipe,
        ingredients: detail.ingredients,
        steps: detail.steps,
        nutrition: detail.nutrition,
        forkedFromId: detail.forkedFromId,
      );
    } catch (_) {
      // Remote create succeeded; cache refresh is best-effort only.
    }
  }

  Future<String> createRecipeRemote(
    RecipeFormData form, {
    String? id,
    String sourceLang = 'es',
  }) async {
    final validationError = form.validate();
    if (validationError != null) throw Exception(validationError);

    final recipeData = await supabase
        .from(Recipe.table_name)
        .insert({
          ...Recipe.insert(
            id: id,
            userId: _userId,
            title: form.title.trim(),
            servings: form.servings,
            prepTime: form.prepTime,
            cookTime: form.cookTime,
            tags: sortedRecipeTags(form.tags),
            isPublic: form.isPublic,
            tips: form.tips.trim().isEmpty ? null : form.tips.trim(),
          ),
          'source_lang': sourceLang,
        })
        .select()
        .single();

    final recipeId = recipeData['id'].toString();
    await _syncChildren(recipeId, form);
    await _syncPhoto(recipeId, form);
    return recipeId;
  }

  Future<String> _createRecipeOffline(RecipeFormData form) async {
    final validationError = form.validate();
    if (validationError != null) throw Exception(validationError);

    final tempId = newLocalId();
    final now = DateTime.now();
    final built = _buildModelsFromForm(
      form: form,
      recipeId: tempId,
      userId: _userId,
      now: now,
    );

    await _cache.saveRecipeDetail(
      recipe: built.recipe,
      ingredients: built.ingredients,
      steps: built.steps,
      nutrition: built.nutrition,
      forkedFromId: form.forkedFromId,
    );

    await _cache.enqueueOperation(
      entityType: PendingEntity.recipe,
      opType: PendingOp.create,
      payload: {'tempId': tempId, 'form': RecipeFormDataCodec.toJson(form)},
    );

    return tempId;
  }

  Future<void> setRecipeVisibility(
    String id,
    bool isPublic, {
    String? householdId,
  }) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);
    await _validateRecipeCanBePublished(id, isPublic);

    if (isOnline) {
      try {
        await setRecipeVisibilityRemote(id, isPublic);
        await _syncCachedRecipeVisibility(id, isPublic);
        return;
      } catch (error) {
        if (shouldFallbackToCache(error)) {
          // Revalidate household constraint before falling back
          await _guardOfflineMutation(
            householdId: householdId,
            isOnline: false,
          );
          await _setRecipeVisibilityOffline(id, isPublic);
          return;
        }
        rethrow;
      }
    }

    await _setRecipeVisibilityOffline(id, isPublic);
  }

  Future<void> _validateRecipeCanBePublished(String id, bool isPublic) async {
    if (!isPublic) return;

    if (await NetworkStatus.isOnline) {
      final recipeData = await supabase
          .from(Recipe.table_name)
          .select('forked_from_id')
          .eq(Recipe.c_id, id)
          .eq(Recipe.c_userId, _userId)
          .maybeSingle();

      if (recipeData?['forked_from_id'] != null) {
        throw Exception(
          'Las recetas guardadas de otros usuarios no se pueden publicar',
        );
      }
      return;
    }

    final detail = await _cache.getRecipeDetail(id, userId: _userId);
    if (detail?.forkedFromId != null) {
      throw Exception(
        'Las recetas guardadas de otros usuarios no se pueden publicar',
      );
    }
  }

  Future<void> setRecipeVisibilityRemote(String id, bool isPublic) async {
    await _validateRecipeCanBePublished(id, isPublic);

    await supabase
        .from(Recipe.table_name)
        .update(Recipe.update(isPublic: isPublic))
        .eq(Recipe.c_id, id)
        .eq(Recipe.c_userId, _userId);
  }

  Future<void> _syncCachedRecipeVisibility(String id, bool isPublic) async {
    final detail = await _cache.getRecipeDetail(id, userId: _userId);
    if (detail == null) return;

    await _cache.saveRecipeDetail(
      recipe: detail.recipe.copyWith(
        isPublic: isPublic,
        updatedAt: DateTime.now(),
      ),
      ingredients: detail.ingredients,
      steps: detail.steps,
      nutrition: detail.nutrition,
      forkedFromId: detail.forkedFromId,
    );
  }

  Future<void> _setRecipeVisibilityOffline(String id, bool isPublic) async {
    final detail = await _cache.getRecipeDetail(id, userId: _userId);
    if (detail == null) throw Exception('Receta no encontrada');

    await _cache.saveRecipeDetail(
      recipe: detail.recipe.copyWith(
        isPublic: isPublic,
        updatedAt: DateTime.now(),
      ),
      ingredients: detail.ingredients,
      steps: detail.steps,
      nutrition: detail.nutrition,
      forkedFromId: detail.forkedFromId,
    );

    await _cache.enqueueOperation(
      entityType: PendingEntity.recipe,
      opType: PendingOp.setVisibility,
      payload: {'recipeId': id, 'isPublic': isPublic},
    );
  }

  Future<void> updateIngredientIncluded({
    required String ingredientId,
    required String recipeId,
    required bool isIncluded,
    String? householdId,
  }) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);

    if (isOnline) {
      await updateIngredientIncludedRemote(
        ingredientId: ingredientId,
        recipeId: recipeId,
        isIncluded: isIncluded,
      );
    } else {
      await _cache.enqueueOperation(
        entityType: PendingEntity.recipe,
        opType: PendingOp.setIngredientIncluded,
        payload: {
          'ingredientId': ingredientId,
          'recipeId': recipeId,
          'isIncluded': isIncluded,
          'householdId': householdId,
        },
      );
    }

    final detail = await _cache.getRecipeDetail(recipeId, userId: _userId);
    if (detail == null) return;
    final ingredients = detail.ingredients
        .map(
          (ingredient) => ingredient.id == ingredientId
              ? ingredient.copyWith(isIncluded: isIncluded)
              : ingredient,
        )
        .toList();
    await _cache.saveRecipeDetail(
      recipe: detail.recipe,
      ingredients: ingredients,
      steps: detail.steps,
      nutrition: detail.nutrition,
      forkedFromId: detail.forkedFromId,
    );
  }

  Future<void> updateIngredientIncludedRemote({
    required String ingredientId,
    required String recipeId,
    required bool isIncluded,
  }) async {
    await supabase
        .from(Ingredient.table_name)
        .update({Ingredient.c_isIncluded: isIncluded})
        .eq(Ingredient.c_id, ingredientId)
        .eq(Ingredient.c_recipeId, recipeId)
        .eq(Ingredient.c_isOptional, true);
  }

  Future<void> updateRecipe(
    String id,
    RecipeFormData form, {
    String? householdId,
    String? sourceLang,
  }) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);
    await _guardOfflinePhoto(form: form, isOnline: isOnline);

    if (isOnline) {
      try {
        await updateRecipeRemote(id, form, sourceLang: sourceLang);
        await _cacheRecipeDetailBestEffort(id);
        return;
      } catch (error) {
        if (shouldFallbackToCache(error)) {
          // Revalidate constraints before falling back
          await _guardOfflineMutation(
            householdId: householdId,
            isOnline: false,
          );
          await _guardOfflinePhoto(form: form, isOnline: false);
          await _updateRecipeOffline(id, form);
          return;
        }
        rethrow;
      }
    }

    await _updateRecipeOffline(id, form);
  }

  Future<void> updateRecipeRemote(
    String id,
    RecipeFormData form, {
    String? sourceLang,
  }) async {
    final validationError = form.validate();
    if (validationError != null) throw Exception(validationError);

    final updatePayload = Recipe.update(
      title: form.title.trim(),
      servings: form.servings,
      prepTime: form.prepTime,
      cookTime: form.cookTime,
      tags: sortedRecipeTags(form.tags),
      isPublic: form.canPublish ? form.isPublic : false,
      tips: form.tips.trim().isEmpty ? null : form.tips.trim(),
    );
    if (sourceLang != null) {
      updatePayload['source_lang'] = sourceLang;
    }

    await supabase
        .from(Recipe.table_name)
        .update(updatePayload)
        .eq(Recipe.c_id, id)
        .eq(Recipe.c_userId, _userId);

    await _syncChildren(id, form);
    await _syncPhoto(id, form);
  }

  Future<void> _updateRecipeOffline(String id, RecipeFormData form) async {
    final validationError = form.validate();
    if (validationError != null) throw Exception(validationError);

    final now = DateTime.now();
    final existing = await _cache.getRecipeDetail(id, userId: _userId);
    final built = _buildModelsFromForm(
      form: form,
      recipeId: id,
      userId: _userId,
      now: now,
      createdAt: existing?.recipe.createdAt,
    );

    await _cache.saveRecipeDetail(
      recipe: built.recipe,
      ingredients: built.ingredients,
      steps: built.steps,
      nutrition: built.nutrition,
      forkedFromId: form.forkedFromId,
    );

    await _cache.enqueueOperation(
      entityType: PendingEntity.recipe,
      opType: PendingOp.update,
      payload: {'recipeId': id, 'form': RecipeFormDataCodec.toJson(form)},
    );
  }

  Future<void> deleteRecipe(String id, {String? householdId}) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);

    if (isOnline) {
      try {
        await deleteRecipeRemote(id);
        await _cache.deleteRecipe(id);
        return;
      } catch (error) {
        if (shouldFallbackToCache(error)) {
          // Revalidate household constraint before falling back
          await _guardOfflineMutation(
            householdId: householdId,
            isOnline: false,
          );
          await _cache.deleteRecipe(id);
          await _cache.enqueueOperation(
            entityType: PendingEntity.recipe,
            opType: PendingOp.delete,
            payload: {'recipeId': id},
          );
          return;
        }
        rethrow;
      }
    }

    await _cache.deleteRecipe(id);
    await _cache.enqueueOperation(
      entityType: PendingEntity.recipe,
      opType: PendingOp.delete,
      payload: {'recipeId': id},
    );
  }

  Future<void> saveNutrition(
    String recipeId,
    NutritionFormData nutrition,
  ) async {
    if (!nutrition.hasAnyValue) {
      throw Exception(recipeAssistantFailedKey);
    }

    final isOnline = await NetworkStatus.isOnline;
    if (!isOnline) {
      throw Exception(recipeAssistantOfflineKey);
    }

    await supabase
        .from(NutritionInfo.table_name)
        .upsert(
          NutritionInfo.insert(
            recipeId: recipeId,
            calories: nutrition.calories,
            protein: nutrition.protein,
            carbohydrates: nutrition.carbohydrates,
            fat: nutrition.fat,
            fiber: nutrition.fiber,
          ),
          onConflict: NutritionInfo.c_recipeId,
        );

    await _cacheRecipeDetailBestEffort(recipeId);
  }

  /// Copies another member's (or public/shared) recipe into the current user's book.
  Future<String> forkIntoMyBook(
    String sourceRecipeId, {
    String? shareToken,
  }) async {
    final newId = await supabase.rpc<dynamic>(
      'fork_recipe_into_my_book',
      params: {
        'p_source_recipe_id': sourceRecipeId,
        'p_share_token': ?shareToken,
      },
    );
    final id = newId.toString();
    await _cacheRecipeDetailBestEffort(id);
    return id;
  }

  Future<void> deleteRecipeRemote(String id) async {
    final detail = await _fetchRecipeDetailRemote(id);
    if (detail.recipe.photoUrl != null) {
      await _deletePhotoFile(detail.recipe.photoUrl!);
    }

    await supabase
        .from(Recipe.table_name)
        .delete()
        .eq(Recipe.c_id, id)
        .eq(Recipe.c_userId, _userId);
  }

  _BuiltRecipe _buildModelsFromForm({
    required RecipeFormData form,
    required String recipeId,
    required String userId,
    required DateTime now,
    DateTime? createdAt,
  }) {
    final recipe = Recipe(
      id: recipeId,
      userId: userId,
      title: form.title.trim(),
      photoUrl: form.removePhoto ? null : form.existingPhotoPath,
      servings: form.servings,
      prepTime: form.prepTime,
      cookTime: form.cookTime,
      tags: sortedRecipeTags(form.tags),
      isPublic: form.canPublish ? form.isPublic : false,
      createdAt: createdAt ?? now,
      updatedAt: now,
      tips: form.tips.trim().isEmpty ? null : form.tips.trim(),
    );

    final ingredients = form.validIngredients
        .asMap()
        .entries
        .map(
          (entry) => Ingredient(
            id: newLocalId(),
            recipeId: recipeId,
            name: entry.value.name.trim(),
            quantity: entry.value.isToTaste ? null : entry.value.quantity,
            unit: entry.value.isToTaste
                ? null
                : normalizeUnit(entry.value.effectiveUnit),
            category: normalizeCategoryKey(entry.value.category),
            position: entry.key,
            isOptional: entry.value.isOptional,
            isIncluded: entry.value.isOptional ? entry.value.isIncluded : true,
            isToTaste: entry.value.isToTaste,
          ),
        )
        .toList();

    final steps = form.validSteps
        .asMap()
        .entries
        .map(
          (entry) => RecipeStep(
            id: newLocalId(),
            recipeId: recipeId,
            position: entry.key,
            description: entry.value.description.trim(),
            isOptional: entry.value.isOptional,
          ),
        )
        .toList();

    NutritionInfo? nutrition;
    if (form.nutrition.hasAnyValue) {
      nutrition = NutritionInfo(
        id: newLocalId(),
        recipeId: recipeId,
        calories: form.nutrition.calories,
        protein: form.nutrition.protein,
        carbohydrates: form.nutrition.carbohydrates,
        fat: form.nutrition.fat,
        fiber: form.nutrition.fiber,
      );
    }

    return _BuiltRecipe(
      recipe: recipe,
      ingredients: ingredients,
      steps: steps,
      nutrition: nutrition,
    );
  }

  Future<void> _syncChildren(String recipeId, RecipeFormData form) async {
    await supabase
        .from(Ingredient.table_name)
        .delete()
        .eq(Ingredient.c_recipeId, recipeId);
    await supabase
        .from(RecipeStep.table_name)
        .delete()
        .eq(RecipeStep.c_recipeId, recipeId);
    await supabase
        .from(NutritionInfo.table_name)
        .delete()
        .eq(NutritionInfo.c_recipeId, recipeId);

    final ingredients = form.validIngredients;
    if (ingredients.isNotEmpty) {
      await supabase
          .from(Ingredient.table_name)
          .insert(
            ingredients
                .asMap()
                .entries
                .map(
                  (entry) => Ingredient.insert(
                    recipeId: recipeId,
                    name: entry.value.name.trim(),
                    quantity: entry.value.isToTaste
                        ? null
                        : entry.value.quantity,
                    unit: entry.value.isToTaste
                        ? null
                        : normalizeUnit(entry.value.effectiveUnit),
                    category: normalizeCategoryKey(entry.value.category),
                    position: entry.key,
                    isOptional: entry.value.isOptional,
                    isIncluded: entry.value.isOptional
                        ? entry.value.isIncluded
                        : true,
                    isToTaste: entry.value.isToTaste,
                  ),
                )
                .toList(),
          );
    }

    final steps = form.validSteps;
    if (steps.isNotEmpty) {
      await supabase
          .from(RecipeStep.table_name)
          .insert(
            steps
                .asMap()
                .entries
                .map(
                  (entry) => RecipeStep.insert(
                    recipeId: recipeId,
                    position: entry.key,
                    description: entry.value.description.trim(),
                    isOptional: entry.value.isOptional,
                  ),
                )
                .toList(),
          );
    }

    if (form.nutrition.hasAnyValue) {
      await supabase
          .from(NutritionInfo.table_name)
          .insert(
            NutritionInfo.insert(
              recipeId: recipeId,
              calories: form.nutrition.calories,
              protein: form.nutrition.protein,
              carbohydrates: form.nutrition.carbohydrates,
              fat: form.nutrition.fat,
              fiber: form.nutrition.fiber,
            ),
          );
    }
  }

  Future<void> _syncPhoto(String recipeId, RecipeFormData form) async {
    if (form.removePhoto && form.existingPhotoPath != null) {
      await _deletePhotoFile(form.existingPhotoPath!);
      await supabase
          .from(Recipe.table_name)
          .update({Recipe.c_photoUrl: null})
          .eq(Recipe.c_id, recipeId);
      return;
    }

    if (form.pendingPhoto != null) {
      final path = await uploadRecipePhoto(
        recipeId: recipeId,
        file: form.pendingPhoto!,
      );
      await supabase
          .from(Recipe.table_name)
          .update(Recipe.update(photoUrl: path))
          .eq(Recipe.c_id, recipeId);
    }
  }

  Future<String> uploadRecipePhoto({
    required String recipeId,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = _extensionFromPath(file.path);
    final path = '$_userId/$recipeId.$extension';

    if (await formHasExistingPhoto(recipeId)) {
      final existing = await _getPhotoPath(recipeId);
      if (existing != null) await _deletePhotoFile(existing);
    }

    await supabase.storage
        .from(_photoBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: _mimeFromExtension(extension),
            upsert: true,
          ),
        );

    return path;
  }

  Future<bool> formHasExistingPhoto(String recipeId) async {
    final path = await _getPhotoPath(recipeId);
    return path != null && path.isNotEmpty;
  }

  Future<String?> _getPhotoPath(String recipeId) async {
    final data = await supabase
        .from(Recipe.table_name)
        .select(Recipe.c_photoUrl)
        .eq(Recipe.c_id, recipeId)
        .maybeSingle();
    return data?[Recipe.c_photoUrl] as String?;
  }

  Future<void> _deletePhotoFile(String path) async {
    if (path.startsWith('http')) return;
    await supabase.storage.from(_photoBucket).remove([path]);
  }

  String _extensionFromPath(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return 'jpg';
    final ext = path.substring(dot + 1).toLowerCase();
    if (ext == 'jpeg') return 'jpg';
    if (['jpg', 'png', 'webp'].contains(ext)) return ext;
    return 'jpg';
  }

  String _mimeFromExtension(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  RecipeFormData formDataFromDetail(RecipeDetail detail) {
    final recipe = detail.recipe;
    return RecipeFormData(
      title: recipe.title,
      servings: recipe.servings,
      prepTime: recipe.prepTime,
      cookTime: recipe.cookTime,
      tags: sortedRecipeTags(recipe.tags),
      tips: recipe.tips ?? '',
      ingredients: detail.ingredients.isEmpty
          ? [IngredientFormItem()]
          : detail.ingredients.map((ingredient) {
              final normalizedUnit = normalizeUnit(ingredient.unit);
              final isPredefined =
                  normalizedUnit != null &&
                  predefinedUnits.contains(normalizedUnit);
              return IngredientFormItem(
                name: ingredient.name,
                quantity: ingredient.isToTaste ? null : ingredient.quantity,
                unit: isPredefined ? normalizedUnit : null,
                category: normalizeCategoryKey(ingredient.category),
                customUnit: isPredefined ? '' : (normalizedUnit ?? ''),
                useCustomUnit: normalizedUnit != null && !isPredefined,
                isOptional: ingredient.isOptional,
                isIncluded: ingredient.isIncluded,
                isToTaste: ingredient.isToTaste,
              );
            }).toList(),
      steps: detail.steps.isEmpty
          ? [StepFormItem()]
          : detail.steps
                .map(
                  (step) => StepFormItem(
                    description: step.description,
                    isOptional: step.isOptional,
                  ),
                )
                .toList(),
      nutrition: NutritionFormData(
        calories: NutritionFormData.normalizeNutritionValue(
          detail.nutrition?.calories,
        ),
        protein: NutritionFormData.normalizeNutritionValue(
          detail.nutrition?.protein,
        ),
        carbohydrates: NutritionFormData.normalizeNutritionValue(
          detail.nutrition?.carbohydrates,
        ),
        fat: NutritionFormData.normalizeNutritionValue(detail.nutrition?.fat),
        fiber: NutritionFormData.normalizeNutritionValue(
          detail.nutrition?.fiber,
        ),
      ),
      existingPhotoPath: recipe.photoUrl,
      isPublic: recipe.isPublic,
      forkedFromId: detail.forkedFromId,
    );
  }

  static const _favoritesTable = 'recipe_favorites';

  String _favoritesStorageKey(String userId) => 'recipe.favorites.$userId';

  String _pendingFavoritesStorageKey(String userId) =>
      'recipe.favorites.pending.$userId';

  bool _isPermanentFavoriteReject(Object error) {
    if (error is! PostgrestException) return false;
    final code = error.code ?? '';
    // Transient HTTP / rate-limit style codes.
    if (code == '408' || code == '429') return false;
    // SQLSTATE class 40xxx (5-char): transaction rollback (e.g. 40001, 40P01).
    if (code.length == 5 && code.startsWith('40')) return false;
    return code == '23503' || code == '23505' || code == '42501';
  }

  Future<Set<String>> _readCachedFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favoritesStorageKey(_userId));
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return {};
      return decoded.map((id) => id.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeCachedFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _favoritesStorageKey(_userId),
      jsonEncode(ids.toList()),
    );
  }

  Future<Map<String, bool>> _readPendingFavoritesPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingFavoritesStorageKey(_userId));
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value == true),
      );
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, bool>> _readPendingFavoritesFromCache() async {
    final ops = await _cache.getPendingOperations(userId: _userId);
    final pending = <String, bool>{};
    for (final op in ops) {
      if (op.entityType != PendingEntity.recipe ||
          op.opType != PendingOp.setFavorite) {
        continue;
      }
      try {
        final payload = jsonDecode(op.payloadJson);
        if (payload is! Map) continue;
        final recipeId = payload['recipeId']?.toString();
        if (recipeId == null || recipeId.isEmpty) continue;
        pending[recipeId] = payload['isFavorite'] == true;
      } catch (_) {
        continue;
      }
    }
    return pending;
  }

  Future<Map<String, bool>> _readPendingFavorites() async {
    if (_cache.canQueueOperations) {
      // Prefs first, then cache on top so queued Drift ops win on conflict.
      final leftover = await _readPendingFavoritesPrefs();
      final queued = await _readPendingFavoritesFromCache();
      if (leftover.isNotEmpty) {
        final merged = {...leftover, ...queued};
        await _writePendingFavorites(merged);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_pendingFavoritesStorageKey(_userId));
        return merged;
      }
      return queued;
    }
    return _readPendingFavoritesPrefs();
  }

  Future<void> _writePendingFavorites(Map<String, bool> pending) async {
    if (_cache.canQueueOperations) {
      final ops = await _cache.getPendingOperations(userId: _userId);
      for (final op in ops) {
        if (op.entityType == PendingEntity.recipe &&
            op.opType == PendingOp.setFavorite) {
          await _cache.deletePendingOperation(op.id);
        }
      }
      for (final entry in pending.entries) {
        await _cache.enqueueOperation(
          entityType: PendingEntity.recipe,
          opType: PendingOp.setFavorite,
          payload: {'recipeId': entry.key, 'isFavorite': entry.value},
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (pending.isEmpty) {
      await prefs.remove(_pendingFavoritesStorageKey(_userId));
      return;
    }
    await prefs.setString(
      _pendingFavoritesStorageKey(_userId),
      jsonEncode(pending),
    );
  }

  /// Serializes all pending-favorite read-modify-write mutations.
  Future<void> _pendingFavoritesChain = Future<void>.value();

  Future<T> _withPendingFavoritesLock<T>(Future<T> Function() action) {
    final result = _pendingFavoritesChain.then((_) => action());
    _pendingFavoritesChain = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<void> _enqueuePendingFavorite(String recipeId, bool isFavorite) {
    return _withPendingFavoritesLock(() async {
      final pending = await _readPendingFavorites();
      pending[recipeId] = isFavorite;
      await _writePendingFavorites(pending);
    });
  }

  Future<void> _clearPendingFavorite(String recipeId) {
    return _withPendingFavoritesLock(() async {
      final pending = await _readPendingFavorites();
      if (!pending.containsKey(recipeId)) return;
      pending.remove(recipeId);
      await _writePendingFavorites(pending);
    });
  }

  Future<void> setFavoriteRemote(String recipeId, bool isFavorite) async {
    if (isFavorite) {
      await supabase.from(_favoritesTable).upsert({
        'user_id': _userId,
        'recipe_id': recipeId,
      }, onConflict: 'user_id,recipe_id');
    } else {
      await supabase
          .from(_favoritesTable)
          .delete()
          .eq('user_id', _userId)
          .eq('recipe_id', recipeId);
    }
  }

  Future<void> _replayPendingFavorites() {
    return _withPendingFavoritesLock(() async {
      final pending = await _readPendingFavorites();
      if (pending.isEmpty) return;

      final remaining = Map<String, bool>.from(pending);
      for (final entry in pending.entries) {
        try {
          await setFavoriteRemote(entry.key, entry.value);
          remaining.remove(entry.key);
        } catch (error) {
          if (_isPermanentFavoriteReject(error)) {
            remaining.remove(entry.key);
          }
        }
      }
      await _writePendingFavorites(remaining);
    });
  }

  Future<Set<String>> _favoriteIdsWithPending() async {
    final ids = await _readCachedFavoriteIds();
    return _applyPendingFavorites(ids, await _readPendingFavorites());
  }

  Set<String> _applyPendingFavorites(
    Set<String> ids,
    Map<String, bool> pending,
  ) {
    final next = Set<String>.from(ids);
    for (final entry in pending.entries) {
      if (entry.value) {
        next.add(entry.key);
      } else {
        next.remove(entry.key);
      }
    }
    return next;
  }

  /// Fetches remote favorite ids and caches them. Returns `false` on failure
  /// without overwriting callers' in-memory provider state.
  Future<bool> pullFavoriteIdsFromRemote() async {
    if (!await NetworkStatus.isOnline) return false;
    try {
      await _replayPendingFavorites();
      final data = await supabase
          .from(_favoritesTable)
          .select('recipe_id')
          .eq('user_id', _userId);
      final remoteIds = List<Map<String, dynamic>>.from(
        data,
      ).map((row) => row['recipe_id'].toString()).toSet();
      final ids = _applyPendingFavorites(
        remoteIds,
        await _readPendingFavorites(),
      );
      await _writeCachedFavoriteIds(ids);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Set<String>> fetchFavoriteIds() async {
    if (await NetworkStatus.isOnline) {
      try {
        await _replayPendingFavorites();
        final data = await supabase
            .from(_favoritesTable)
            .select('recipe_id')
            .eq('user_id', _userId);
        final remoteIds = List<Map<String, dynamic>>.from(
          data,
        ).map((row) => row['recipe_id'].toString()).toSet();
        final ids = _applyPendingFavorites(
          remoteIds,
          await _readPendingFavorites(),
        );
        await _writeCachedFavoriteIds(ids);
        return ids;
      } catch (_) {
        return _favoriteIdsWithPending();
      }
    }
    return _favoriteIdsWithPending();
  }

  Future<void> setFavorite(String recipeId, bool isFavorite) async {
    if (await NetworkStatus.isOnline) {
      try {
        await _replayPendingFavorites();
      } catch (_) {
        // Other pending favorites must not block this recipe's upsert/delete.
      }
      await setFavoriteRemote(recipeId, isFavorite);
      await _clearPendingFavorite(recipeId);
    } else {
      await _enqueuePendingFavorite(recipeId, isFavorite);
    }

    final cached = await _readCachedFavoriteIds();
    final next = Set<String>.from(cached);
    if (isFavorite) {
      next.add(recipeId);
    } else {
      next.remove(recipeId);
    }
    await _writeCachedFavoriteIds(next);
  }
}

class _BuiltRecipe {
  const _BuiltRecipe({
    required this.recipe,
    required this.ingredients,
    required this.steps,
    this.nutrition,
  });

  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final NutritionInfo? nutrition;
}

final recipesRepositoryProvider = Provider<RecipesRepository>((ref) {
  return RecipesRepository(ref.watch(localCacheStoreProvider));
});
