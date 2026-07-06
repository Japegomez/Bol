import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/recipes/domain/recipe_constants.dart';
import 'package:meal_planner/features/recipes/domain/recipe_detail.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipesRepository {
  static const _photoBucket = 'recipe-photos';
  static const _signedUrlExpiry = 3600;

  String get _userId {
    final id = supabase.auth.currentUser?.id;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  Future<List<Recipe>> fetchRecipes({String? search, String? tag}) async {
    var query = supabase
        .from(Recipe.table_name)
        .select()
        .eq(Recipe.c_userId, _userId);

    if (search != null && search.trim().isNotEmpty) {
      query = query.ilike(Recipe.c_title, '%${search.trim()}%');
    }
    if (tag != null && tag.isNotEmpty) {
      query = query.contains(Recipe.c_tags, [tag]);
    }

    final data = await query.order(Recipe.c_createdAt, ascending: false);
    return Recipe.converter(List<Map<String, dynamic>>.from(data));
  }

  Future<Set<String>> fetchAllTags() async {
    final recipes = await fetchRecipes();
    final tags = <String>{};
    for (final recipe in recipes) {
      tags.addAll(recipe.tags);
    }
    return tags;
  }

  Future<RecipeDetail> fetchRecipeDetail(String id) async {
    final recipeData = await supabase
        .from(Recipe.table_name)
        .select()
        .eq(Recipe.c_id, id)
        .eq(Recipe.c_userId, _userId)
        .maybeSingle();

    if (recipeData == null) {
      throw Exception('Receta no encontrada');
    }

    final recipe = Recipe.converterSingle(
      Map<String, dynamic>.from(recipeData),
    );
    final forkedFromId = recipeData['forked_from_id']?.toString();

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

    final photoDisplayUrl = await resolvePhotoUrl(recipe.photoUrl);

    return RecipeDetail(
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
      forkedFromId: forkedFromId,
    );
  }

  Future<String?> resolvePhotoUrl(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return null;
    if (photoPath.startsWith('http')) return photoPath;

    return supabase.storage
        .from(_photoBucket)
        .createSignedUrl(photoPath, _signedUrlExpiry);
  }

  Future<String> createRecipe(RecipeFormData form) async {
    final validationError = form.validate();
    if (validationError != null) throw Exception(validationError);

    final recipeData = await supabase
        .from(Recipe.table_name)
        .insert(
          Recipe.insert(
            userId: _userId,
            title: form.title.trim(),
            servings: form.servings,
            prepTime: form.prepTime,
            cookTime: form.cookTime,
            tags: form.tags,
            isPublic: form.isPublic,
            tips: form.tips.trim().isEmpty ? null : form.tips.trim(),
          ),
        )
        .select()
        .single();

    final recipeId = recipeData['id'].toString();
    await _syncChildren(recipeId, form);
    await _syncPhoto(recipeId, form);
    return recipeId;
  }

  Future<void> setRecipeVisibility(String id, bool isPublic) async {
    if (isPublic) {
      final recipeData = await supabase
          .from(Recipe.table_name)
          .select('forked_from_id')
          .eq(Recipe.c_id, id)
          .eq(Recipe.c_userId, _userId)
          .maybeSingle();

      if (recipeData?['forked_from_id'] != null) {
        throw Exception('Las recetas guardadas de otros usuarios no se pueden publicar');
      }
    }

    await supabase
        .from(Recipe.table_name)
        .update(Recipe.update(isPublic: isPublic))
        .eq(Recipe.c_id, id)
        .eq(Recipe.c_userId, _userId);
  }

  Future<void> updateIngredientIncluded({
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

  Future<void> updateRecipe(String id, RecipeFormData form) async {
    final validationError = form.validate();
    if (validationError != null) throw Exception(validationError);

    await supabase
        .from(Recipe.table_name)
        .update(
          Recipe.update(
            title: form.title.trim(),
            servings: form.servings,
            prepTime: form.prepTime,
            cookTime: form.cookTime,
            tags: form.tags,
            isPublic: form.canPublish ? form.isPublic : false,
            tips: form.tips.trim().isEmpty ? null : form.tips.trim(),
          ),
        )
        .eq(Recipe.c_id, id)
        .eq(Recipe.c_userId, _userId);

    await _syncChildren(id, form);
    await _syncPhoto(id, form);
  }

  Future<void> deleteRecipe(String id) async {
    final detail = await fetchRecipeDetail(id);
    if (detail.recipe.photoUrl != null) {
      await _deletePhotoFile(detail.recipe.photoUrl!);
    }

    await supabase
        .from(Recipe.table_name)
        .delete()
        .eq(Recipe.c_id, id)
        .eq(Recipe.c_userId, _userId);
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
      await supabase.from(Ingredient.table_name).insert(
            ingredients
                .asMap()
                .entries
                .map(
                  (entry) => Ingredient.insert(
                    recipeId: recipeId,
                    name: entry.value.name.trim(),
                    quantity: entry.value.isToTaste ? null : entry.value.quantity,
                    unit: entry.value.isToTaste
                        ? null
                        : normalizeUnit(entry.value.effectiveUnit),
                    category: entry.value.category,
                    position: entry.key,
                    isOptional: entry.value.isOptional,
                    isIncluded:
                        entry.value.isOptional ? entry.value.isIncluded : true,
                    isToTaste: entry.value.isToTaste,
                  ),
                )
                .toList(),
          );
    }

    final steps = form.validSteps;
    if (steps.isNotEmpty) {
      await supabase.from(RecipeStep.table_name).insert(
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
      await supabase.from(NutritionInfo.table_name).insert(
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

    await supabase.storage.from(_photoBucket).uploadBinary(
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
      tags: List<String>.from(recipe.tags),
      tips: recipe.tips ?? '',
      ingredients: detail.ingredients.isEmpty
          ? [IngredientFormItem()]
          : detail.ingredients
              .map(
                (ingredient) {
                  final normalizedUnit = normalizeUnit(ingredient.unit);
                  final isPredefined = normalizedUnit != null &&
                      predefinedUnits.contains(normalizedUnit);
                  return IngredientFormItem(
                    name: ingredient.name,
                    quantity: ingredient.isToTaste ? null : ingredient.quantity,
                    unit: isPredefined ? normalizedUnit : predefinedUnits.first,
                    category: ingredient.category ?? 'Carnes y pescados',
                    customUnit: isPredefined ? '' : (normalizedUnit ?? ''),
                    useCustomUnit:
                        normalizedUnit != null && !isPredefined,
                    isOptional: ingredient.isOptional,
                    isIncluded: ingredient.isIncluded,
                    isToTaste: ingredient.isToTaste,
                  );
                },
              )
              .toList(),
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
        calories: detail.nutrition?.calories,
        protein: detail.nutrition?.protein,
        carbohydrates: detail.nutrition?.carbohydrates,
        fat: detail.nutrition?.fat,
        fiber: detail.nutrition?.fiber,
      ),
      existingPhotoPath: recipe.photoUrl,
      isPublic: recipe.isPublic,
      forkedFromId: detail.forkedFromId,
    );
  }
}
