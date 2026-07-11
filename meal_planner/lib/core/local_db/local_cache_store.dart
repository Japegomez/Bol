import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meal_planner/core/local_db/app_database.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/models/plan_slot.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/core/supabase/models/shopping_list.dart';
import 'package:meal_planner/core/supabase/models/weekly_plan.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';
import 'package:meal_planner/features/recipes/domain/recipe_detail.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String newLocalId() => _uuid.v4();

class LocalCacheStore {
  LocalCacheStore(AppDatabase db) : _db = db;

  LocalCacheStore.disabled() : _db = null;

  final AppDatabase? _db;

  // ── Recipes ────────────────────────────────────────────────────────────────

  Future<void> cacheRecipes(List<Recipe> recipes) async {
    if (_db == null) return;
    await _db.batch((batch) {
      for (final recipe in recipes) {
        batch.insert(
          _db.localRecipes,
          _recipeToRow(recipe),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<Recipe>> getRecipes({
    required String userId,
    String? search,
    Set<String>? tags,
  }) async {
    if (_db == null) return const [];

    final query = _db.select(_db.localRecipes)
      ..where((r) => r.userId.equals(userId))
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);

    final rows = await query.get();
    var recipes = rows.map(_rowToRecipe).toList();

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      recipes = recipes
          .where((r) => r.title.toLowerCase().contains(q))
          .toList();
    }

    if (tags != null && tags.isNotEmpty) {
      recipes = recipes.where((r) => tags.every(r.tags.contains)).toList();
    }

    return recipes;
  }

  Future<RecipeDetail?> getRecipeDetail(String id) async {
    if (_db == null) return null;

    final recipeRow = await (_db.select(_db.localRecipes)
          ..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    if (recipeRow == null) return null;

    final ingredients = await (_db.select(_db.localIngredients)
          ..where((i) => i.recipeId.equals(id))
          ..orderBy([(i) => OrderingTerm.asc(i.position)]))
        .get();

    final steps = await (_db.select(_db.localRecipeSteps)
          ..where((s) => s.recipeId.equals(id))
          ..orderBy([(s) => OrderingTerm.asc(s.position)]))
        .get();

    final nutritionRow = await (_db.select(_db.localNutritionInfo)
          ..where((n) => n.recipeId.equals(id)))
        .getSingleOrNull();

    return RecipeDetail(
      recipe: _rowToRecipe(recipeRow),
      ingredients: ingredients.map(_rowToIngredient).toList(),
      steps: steps.map(_rowToStep).toList(),
      nutrition:
          nutritionRow != null ? _rowToNutrition(nutritionRow) : null,
      photoDisplayUrl: recipeRow.photoUrl,
      forkedFromId: recipeRow.forkedFromId,
    );
  }

  Future<void> saveRecipeDetail({
    required Recipe recipe,
    required List<Ingredient> ingredients,
    required List<RecipeStep> steps,
    NutritionInfo? nutrition,
    String? forkedFromId,
  }) async {
    if (_db == null) return;

    await _db.transaction(() async {
      await _db.into(_db.localRecipes).insertOnConflictUpdate(
            _recipeToRow(recipe, forkedFromId: forkedFromId),
          );

      await (_db.delete(_db.localIngredients)
            ..where((i) => i.recipeId.equals(recipe.id)))
          .go();
      await (_db.delete(_db.localRecipeSteps)
            ..where((s) => s.recipeId.equals(recipe.id)))
          .go();
      await (_db.delete(_db.localNutritionInfo)
            ..where((n) => n.recipeId.equals(recipe.id)))
          .go();

      for (final ingredient in ingredients) {
        await _db.into(_db.localIngredients).insert(_ingredientToRow(ingredient));
      }
      for (final step in steps) {
        await _db.into(_db.localRecipeSteps).insert(_stepToRow(step));
      }
      if (nutrition != null) {
        await _db.into(_db.localNutritionInfo).insertOnConflictUpdate(
              _nutritionToRow(nutrition),
            );
      }
    });
  }

  Future<void> deleteRecipe(String id) async {
    if (_db == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.localRecipes)..where((r) => r.id.equals(id))).go();
      await (_db.delete(_db.localIngredients)
            ..where((i) => i.recipeId.equals(id)))
          .go();
      await (_db.delete(_db.localRecipeSteps)
            ..where((s) => s.recipeId.equals(id)))
          .go();
      await (_db.delete(_db.localNutritionInfo)
            ..where((n) => n.recipeId.equals(id)))
          .go();
    });
  }

  // ── Planner ────────────────────────────────────────────────────────────────

  Future<void> cacheWeeklyPlan(WeeklyPlan plan) async {
    if (_db == null) return;

    await _db.into(_db.localWeeklyPlans).insertOnConflictUpdate(
          LocalWeeklyPlansCompanion.insert(
            id: plan.id,
            householdId: Value(plan.householdId),
            userId: Value(plan.userId),
            weekStart: plan.weekStart.toIso8601String().split('T').first,
            createdAt: plan.createdAt,
          ),
        );
  }

  Future<WeeklyPlan?> getWeeklyPlan({
    required String weekStart,
    String? userId,
    String? householdId,
  }) async {
    if (_db == null) return null;

    final query = _db.select(_db.localWeeklyPlans)
      ..where((p) => p.weekStart.equals(weekStart));

    if (householdId != null) {
      query.where((p) => p.householdId.equals(householdId));
    } else if (userId != null) {
      query.where((p) => p.userId.equals(userId));
    }

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    return WeeklyPlan(
      id: row.id,
      householdId: row.householdId,
      userId: row.userId,
      weekStart: DateTime.parse(row.weekStart),
      createdAt: row.createdAt,
    );
  }

  Future<void> cacheSlots(String planId, List<SlotItem> slots) async {
    if (_db == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.localPlanSlots)
            ..where((s) => s.planId.equals(planId)))
          .go();
      for (final item in slots) {
        await _db.into(_db.localPlanSlots).insert(_slotItemToRow(item));
      }
    });
  }

  Future<List<SlotItem>> getSlotsForPlan(String planId) async {
    if (_db == null) return const [];

    final rows = await (_db.select(_db.localPlanSlots)
          ..where((s) => s.planId.equals(planId))
          ..orderBy([
            (s) => OrderingTerm.asc(s.dayOfWeek),
            (s) => OrderingTerm.asc(s.mealType),
            (s) => OrderingTerm.asc(s.position),
          ]))
        .get();

    return rows.map(_rowToSlotItem).toList();
  }

  Future<void> upsertSlot(SlotItem item) async {
    if (_db == null) return;

    await _db.into(_db.localPlanSlots).insertOnConflictUpdate(
          _slotItemToRow(item),
        );
  }

  Future<void> deleteSlot(String slotId) async {
    if (_db == null) return;

    await (_db.delete(_db.localPlanSlots)..where((s) => s.id.equals(slotId)))
        .go();
  }

  Future<SlotItem?> getSlotsForPlanBySlotId(String slotId) async {
    if (_db == null) return null;

    final row = await (_db.select(_db.localPlanSlots)
          ..where((s) => s.id.equals(slotId)))
        .getSingleOrNull();
    return row != null ? _rowToSlotItem(row) : null;
  }

  // ── Shopping ───────────────────────────────────────────────────────────────

  Future<void> cacheShoppingList(ShoppingList list) async {
    if (_db == null) return;

    await _db.into(_db.localShoppingLists).insertOnConflictUpdate(
          LocalShoppingListsCompanion.insert(
            id: list.id,
            householdId: Value(list.householdId),
            userId: Value(list.userId),
            createdAt: list.createdAt,
          ),
        );
  }

  Future<ShoppingList?> getShoppingList({
    String? userId,
    String? householdId,
  }) async {
    if (_db == null) return null;

    final query = _db.select(_db.localShoppingLists)
      ..orderBy([(l) => OrderingTerm.desc(l.createdAt)])
      ..limit(1);

    if (householdId != null) {
      query.where((l) => l.householdId.equals(householdId));
    } else if (userId != null) {
      query.where((l) => l.userId.equals(userId));
    }

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    return ShoppingList(
      id: row.id,
      householdId: row.householdId,
      userId: row.userId,
      createdAt: row.createdAt,
    );
  }

  Future<void> cacheShoppingItems(String listId, List<ShoppingItem> items) async {
    if (_db == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.localShoppingItems)
            ..where((i) => i.shoppingListId.equals(listId)))
          .go();
      for (final item in items) {
        await _db.into(_db.localShoppingItems).insert(_shoppingItemToRow(item));
      }
    });
  }

  Future<List<ShoppingItem>> getShoppingItems(String listId) async {
    if (_db == null) return const [];

    final rows = await (_db.select(_db.localShoppingItems)
          ..where((i) => i.shoppingListId.equals(listId))
          ..orderBy([
            (i) => OrderingTerm.asc(i.isChecked),
            (i) => OrderingTerm.asc(i.category),
            (i) => OrderingTerm.asc(i.name),
          ]))
        .get();

    return rows.map(_rowToShoppingItem).toList();
  }

  Future<ShoppingItem?> getShoppingItemById(String id) async {
    if (_db == null) return null;

    final row = await (_db.select(_db.localShoppingItems)
          ..where((i) => i.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _rowToShoppingItem(row) : null;
  }

  Future<void> upsertShoppingItem(ShoppingItem item) async {
    if (_db == null) return;

    await _db.into(_db.localShoppingItems).insertOnConflictUpdate(
          _shoppingItemToRow(item),
        );
  }

  Future<void> deleteShoppingItem(String id) async {
    if (_db == null) return;

    await (_db.delete(_db.localShoppingItems)..where((i) => i.id.equals(id)))
        .go();
  }

  Future<void> clearShoppingItems(String listId) async {
    if (_db == null) return;

    await (_db.delete(_db.localShoppingItems)
          ..where((i) => i.shoppingListId.equals(listId)))
        .go();
  }

  Future<List<ShoppingItem>> getShoppingItemsByPlanSlot(String slotId) async {
    if (_db == null) return const [];

    final rows = await (_db.select(_db.localShoppingItems)
          ..where((i) => i.planSlotId.equals(slotId)))
        .get();
    return rows.map(_rowToShoppingItem).toList();
  }

  Future<Ingredient?> getIngredient(String id) async {
    if (_db == null) return null;

    final row = await (_db.select(_db.localIngredients)
          ..where((i) => i.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _rowToIngredient(row) : null;
  }

  Future<List<Ingredient>> getIngredientsForRecipe(String recipeId) async {
    if (_db == null) return const [];

    final rows = await (_db.select(_db.localIngredients)
          ..where((i) => i.recipeId.equals(recipeId))
          ..orderBy([(i) => OrderingTerm.asc(i.position)]))
        .get();
    return rows.map(_rowToIngredient).toList();
  }

  Future<Recipe?> getRecipeById(String id) async {
    if (_db == null) return null;

    final row = await (_db.select(_db.localRecipes)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _rowToRecipe(row) : null;
  }

  // ── Pending operations ─────────────────────────────────────────────────────

  Future<void> enqueueOperation({
    required String entityType,
    required String opType,
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) return;

    await _db.into(_db.pendingOperations).insert(
          PendingOperationsCompanion.insert(
            id: newLocalId(),
            entityType: entityType,
            opType: opType,
            payloadJson: jsonEncode(payload),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<List<PendingOperation>> getPendingOperations() async {
    if (_db == null) return const [];

    final rows = await (_db.select(_db.pendingOperations)
          ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
        .get();
    return rows;
  }

  Future<void> deletePendingOperation(String id) async {
    if (_db == null) return;

    await (_db.delete(_db.pendingOperations)..where((o) => o.id.equals(id)))
        .go();
  }

  Future<void> incrementRetry(String id) async {
    if (_db == null) return;

    final row = await (_db.select(_db.pendingOperations)
          ..where((o) => o.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;
    await (_db.update(_db.pendingOperations)..where((o) => o.id.equals(id)))
        .write(PendingOperationsCompanion(retryCount: Value(row.retryCount + 1)));
  }

  Future<void> saveIdMapping(String tempId, String realId) async {
    if (_db == null) return;

    await _db.into(_db.idMappings).insertOnConflictUpdate(
          IdMappingsCompanion.insert(tempId: tempId, realId: realId),
        );
  }

  Future<String?> resolveId(String id) async {
    if (_db == null) return id;

    final mapping = await (_db.select(_db.idMappings)
          ..where((m) => m.tempId.equals(id)))
        .getSingleOrNull();
    return mapping?.realId ?? id;
  }

  Future<String> resolveIdOrSelf(String id) async {
    return await resolveId(id) ?? id;
  }

  Future<void> replaceTempId(String tempId, String realId) async {
    if (_db == null) return;

    await saveIdMapping(tempId, realId);

    await (_db.update(_db.localRecipes)..where((r) => r.id.equals(tempId)))
        .write(LocalRecipesCompanion(id: Value(realId)));
    await (_db.update(_db.localIngredients)
          ..where((i) => i.recipeId.equals(tempId)))
        .write(LocalIngredientsCompanion(recipeId: Value(realId)));
    await (_db.update(_db.localRecipeSteps)
          ..where((s) => s.recipeId.equals(tempId)))
        .write(LocalRecipeStepsCompanion(recipeId: Value(realId)));
    await (_db.update(_db.localNutritionInfo)
          ..where((n) => n.recipeId.equals(tempId)))
        .write(LocalNutritionInfoCompanion(recipeId: Value(realId)));
    await (_db.update(_db.localPlanSlots)..where((s) => s.recipeId.equals(tempId)))
        .write(LocalPlanSlotsCompanion(recipeId: Value(realId)));
    await (_db.update(_db.localPlanSlots)..where((s) => s.id.equals(tempId)))
        .write(LocalPlanSlotsCompanion(id: Value(realId)));
    await (_db.update(_db.localShoppingItems)..where((i) => i.id.equals(tempId)))
        .write(LocalShoppingItemsCompanion(id: Value(realId)));
    await (_db.update(_db.localShoppingItems)
          ..where((i) => i.planSlotId.equals(tempId)))
        .write(LocalShoppingItemsCompanion(planSlotId: Value(realId)));
    await (_db.update(_db.localIngredients)..where((i) => i.id.equals(tempId)))
        .write(LocalIngredientsCompanion(id: Value(realId)));
  }

  // ── Mappers ────────────────────────────────────────────────────────────────

  LocalRecipesCompanion _recipeToRow(Recipe recipe, {String? forkedFromId}) {
    return LocalRecipesCompanion.insert(
      id: recipe.id,
      userId: recipe.userId,
      title: recipe.title,
      photoUrl: Value(recipe.photoUrl),
      servings: recipe.servings,
      prepTime: Value(recipe.prepTime),
      cookTime: Value(recipe.cookTime),
      tagsJson: jsonEncode(recipe.tags),
      isPublic: Value(recipe.isPublic),
      createdAt: recipe.createdAt,
      updatedAt: recipe.updatedAt,
      tips: Value(recipe.tips),
      forkedFromId: Value(forkedFromId),
    );
  }

  Recipe _rowToRecipe(LocalRecipe row) {
    return Recipe(
      id: row.id,
      userId: row.userId,
      title: row.title,
      photoUrl: row.photoUrl,
      servings: row.servings,
      prepTime: row.prepTime,
      cookTime: row.cookTime,
      tags: (jsonDecode(row.tagsJson) as List<dynamic>).cast<String>(),
      isPublic: row.isPublic,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      tips: row.tips,
    );
  }

  LocalIngredientsCompanion _ingredientToRow(Ingredient ingredient) {
    return LocalIngredientsCompanion.insert(
      id: ingredient.id,
      recipeId: ingredient.recipeId,
      name: ingredient.name,
      quantity: Value(ingredient.quantity?.toDouble()),
      unit: Value(ingredient.unit),
      category: Value(ingredient.category),
      position: ingredient.position,
      isOptional: Value(ingredient.isOptional),
      isIncluded: Value(ingredient.isIncluded),
      isToTaste: Value(ingredient.isToTaste),
    );
  }

  Ingredient _rowToIngredient(LocalIngredient row) {
    return Ingredient(
      id: row.id,
      recipeId: row.recipeId,
      name: row.name,
      quantity: row.quantity,
      unit: row.unit,
      category: row.category,
      position: row.position,
      isOptional: row.isOptional,
      isIncluded: row.isIncluded,
      isToTaste: row.isToTaste,
    );
  }

  LocalRecipeStepsCompanion _stepToRow(RecipeStep step) {
    return LocalRecipeStepsCompanion.insert(
      id: step.id,
      recipeId: step.recipeId,
      position: step.position,
      description: step.description,
      isOptional: Value(step.isOptional),
    );
  }

  RecipeStep _rowToStep(LocalRecipeStep row) {
    return RecipeStep(
      id: row.id,
      recipeId: row.recipeId,
      position: row.position,
      description: row.description,
      isOptional: row.isOptional,
    );
  }

  LocalNutritionInfoCompanion _nutritionToRow(NutritionInfo nutrition) {
    return LocalNutritionInfoCompanion.insert(
      id: nutrition.id,
      recipeId: nutrition.recipeId,
      calories: Value(nutrition.calories?.toDouble()),
      protein: Value(nutrition.protein?.toDouble()),
      carbohydrates: Value(nutrition.carbohydrates?.toDouble()),
      fat: Value(nutrition.fat?.toDouble()),
      fiber: Value(nutrition.fiber?.toDouble()),
    );
  }

  NutritionInfo _rowToNutrition(LocalNutritionInfoData row) {
    return NutritionInfo(
      id: row.id,
      recipeId: row.recipeId,
      calories: row.calories,
      protein: row.protein,
      carbohydrates: row.carbohydrates,
      fat: row.fat,
      fiber: row.fiber,
    );
  }

  LocalPlanSlotsCompanion _slotItemToRow(SlotItem item) {
    final slot = item.slot;
    return LocalPlanSlotsCompanion.insert(
      id: slot.id,
      planId: slot.planId,
      dayOfWeek: slot.dayOfWeek,
      mealType: slot.mealType,
      recipeId: Value(slot.recipeId),
      recipeTitle: Value(item.recipeTitle),
      servings: slot.servings,
      position: slot.position,
      isLeftover: Value(slot.isLeftover),
      notes: Value(slot.notes),
    );
  }

  SlotItem _rowToSlotItem(LocalPlanSlot row) {
    return SlotItem(
      slot: PlanSlot(
        id: row.id,
        planId: row.planId,
        dayOfWeek: row.dayOfWeek,
        mealType: row.mealType,
        recipeId: row.recipeId,
        servings: row.servings,
        position: row.position,
        isLeftover: row.isLeftover,
        notes: row.notes,
      ),
      recipeTitle: row.recipeTitle,
    );
  }

  LocalShoppingItemsCompanion _shoppingItemToRow(ShoppingItem item) {
    return LocalShoppingItemsCompanion.insert(
      id: item.id,
      shoppingListId: item.shoppingListId,
      name: item.name,
      quantity: Value(item.quantity?.toDouble()),
      unit: Value(item.unit),
      category: Value(item.category),
      isChecked: Value(item.isChecked),
      isManual: Value(item.isManual),
      planSlotId: Value(item.planSlotId),
      ingredientId: Value(item.ingredientId),
      createdAt: item.createdAt,
    );
  }

  ShoppingItem _rowToShoppingItem(LocalShoppingItem row) {
    return ShoppingItem(
      id: row.id,
      shoppingListId: row.shoppingListId,
      name: row.name,
      quantity: row.quantity,
      unit: row.unit,
      category: row.category,
      isChecked: row.isChecked,
      isManual: row.isManual,
      planSlotId: row.planSlotId,
      ingredientId: row.ingredientId,
      createdAt: row.createdAt,
    );
  }
}
