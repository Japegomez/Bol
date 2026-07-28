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
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/sync/pending_operation_types.dart';
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
          mode: InsertMode.insertOrIgnore,
        );
        batch.update(
          _db.localRecipes,
          _recipeToRow(recipe).copyWith(forkedFromId: const Value.absent()),
          where: (_) => _db.localRecipes.id.equals(recipe.id),
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

  Future<RecipeDetail?> getRecipeDetail(String id, {required String userId}) async {
    if (_db == null) return null;

    final recipeRow = await (_db.select(_db.localRecipes)
          ..where((r) => r.id.equals(id) & r.userId.equals(userId)))
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

    final protectedIds = await _pendingProtectedPlanSlotIds(planId);

    await _db.transaction(() async {
      if (protectedIds.isEmpty) {
        await (_db.delete(_db.localPlanSlots)
              ..where((s) => s.planId.equals(planId)))
            .go();
      } else {
        await (_db.delete(_db.localPlanSlots)
              ..where((s) => s.planId.equals(planId))
              ..where((s) => s.id.isNotIn(protectedIds)))
            .go();
      }
      for (final item in slots) {
        if (protectedIds.contains(item.slot.id)) continue;
        await _db.into(_db.localPlanSlots).insertOnConflictUpdate(
              _slotItemToRow(item),
            );
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
    if (await _hasPendingClearForList(listId)) return;

    final protectedIds = await _pendingProtectedShoppingItemIds(listId);

    await _db.transaction(() async {
      if (protectedIds.isEmpty) {
        await (_db.delete(_db.localShoppingItems)
              ..where((i) => i.shoppingListId.equals(listId)))
            .go();
      } else {
        await (_db.delete(_db.localShoppingItems)
              ..where((i) => i.shoppingListId.equals(listId))
              ..where((i) => i.id.isNotIn(protectedIds)))
            .go();
      }
      for (final item in items) {
        if (protectedIds.contains(item.id)) continue;
        await _db.into(_db.localShoppingItems).insertOnConflictUpdate(
              _shoppingItemToRow(item),
            );
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

  /// Persists [ingredients] for [recipeId] without touching other recipe data.
  /// Replaces any previously cached ingredients for that recipe.
  Future<void> cacheIngredientsForRecipe(
    String recipeId,
    List<Ingredient> ingredients,
  ) async {
    if (_db == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.localIngredients)
            ..where((i) => i.recipeId.equals(recipeId)))
          .go();
      for (final ingredient in ingredients) {
        await _db
            .into(_db.localIngredients)
            .insert(_ingredientToRow(ingredient));
      }
    });
  }

  Future<Recipe?> getRecipeById(String id) async {
    if (_db == null) return null;

    final row = await (_db.select(_db.localRecipes)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _rowToRecipe(row) : null;
  }

  // ── Pending operations ─────────────────────────────────────────────────────

  Future<Set<String>> _pendingProtectedPlanSlotIds(String planId) async {
    if (_db == null) return const {};

    final ids = <String>{};
    for (final op in await getPendingOperations()) {
      if (op.entityType != PendingEntity.planSlot) continue;
      final payload = jsonDecode(op.payloadJson) as Map<String, dynamic>;
      switch (op.opType) {
        case PendingOp.add:
          if (payload['planId'] == planId) {
            final tempId = payload['tempId'] as String?;
            if (tempId != null) ids.add(tempId);
          }
        case PendingOp.remove:
        case PendingOp.update:
          final slotId = payload['slotId'] as String?;
          if (slotId != null) ids.add(slotId);
      }
    }
    return ids;
  }

  Future<Set<String>> _pendingProtectedShoppingItemIds(String listId) async {
    if (_db == null) return const {};

    final ids = <String>{};
    for (final op in await getPendingOperations()) {
      if (op.entityType != PendingEntity.shoppingItem) continue;
      final payload = jsonDecode(op.payloadJson) as Map<String, dynamic>;
      switch (op.opType) {
        case PendingOp.create:
          if (payload['listId'] == listId) {
            final tempId = payload['tempId'] as String?;
            if (tempId != null) ids.add(tempId);
          }
        case PendingOp.update:
        case PendingOp.delete:
        case PendingOp.toggle:
          final id = payload['id'] as String?;
          if (id != null) {
            final item = await getShoppingItemById(id);
            if (item?.shoppingListId == listId) ids.add(id);
          }
      }
    }
    return ids;
  }

  Future<bool> _hasPendingClearForList(String listId) async {
    if (_db == null) return false;

    for (final op in await getPendingOperations()) {
      if (op.entityType != PendingEntity.shoppingItem ||
          op.opType != PendingOp.clear) {
        continue;
      }
      final payload = jsonDecode(op.payloadJson) as Map<String, dynamic>;
      if (payload['listId'] == listId) return true;
    }
    return false;
  }

  Future<void> _insertPendingOperation({
    required String userId,
    required String entityType,
    required String opType,
    required Map<String, dynamic> payload,
  }) async {
    await _db!.into(_db.pendingOperations).insert(
          PendingOperationsCompanion.insert(
            id: newLocalId(),
            userId: Value(userId),
            entityType: entityType,
            opType: opType,
            payloadJson: jsonEncode(payload),
            createdAt: DateTime.now(),
          ),
        );
  }

  String? _requireCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  Future<void> enqueueOperation({
    required String entityType,
    required String opType,
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) return;

    final userId = _requireCurrentUserId();
    if (userId == null) return;

    await _insertPendingOperation(
      userId: userId,
      entityType: entityType,
      opType: opType,
      payload: payload,
    );
  }

  Future<List<PendingOperation>> getPendingOperations({String? userId}) async {
    if (_db == null) return const [];

    final resolvedUserId = userId ?? _requireCurrentUserId();
    if (resolvedUserId == null) return const [];

    final query = _db.select(_db.pendingOperations)
      ..where((o) => o.userId.equals(resolvedUserId))
      ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]);

    return query.get();
  }

  Future<void> clearUserSyncState(String userId) async {
    if (_db == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.pendingOperations)
            ..where((o) => o.userId.equals(userId) | o.userId.isNull()))
          .go();
      await _db.delete(_db.idMappings).go();
    });
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

    await _db.transaction(() async {
      await _db.into(_db.idMappings).insertOnConflictUpdate(
            IdMappingsCompanion.insert(tempId: tempId, realId: realId),
          );

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
      await (_db.update(_db.localWeeklyPlans)..where((p) => p.id.equals(tempId)))
          .write(LocalWeeklyPlansCompanion(id: Value(realId)));
      await (_db.update(_db.localPlanSlots)..where((s) => s.planId.equals(tempId)))
          .write(LocalPlanSlotsCompanion(planId: Value(realId)));
      await (_db.update(_db.localPlanSlots)
            ..where((s) => s.recipeId.equals(tempId)))
          .write(LocalPlanSlotsCompanion(recipeId: Value(realId)));
      await (_db.update(_db.localPlanSlots)..where((s) => s.id.equals(tempId)))
          .write(LocalPlanSlotsCompanion(id: Value(realId)));
      await (_db.update(_db.localShoppingLists)..where((l) => l.id.equals(tempId)))
          .write(LocalShoppingListsCompanion(id: Value(realId)));
      await (_db.update(_db.localShoppingItems)
            ..where((i) => i.shoppingListId.equals(tempId)))
          .write(LocalShoppingItemsCompanion(shoppingListId: Value(realId)));
      await (_db.update(_db.localShoppingItems)..where((i) => i.id.equals(tempId)))
          .write(LocalShoppingItemsCompanion(id: Value(realId)));
      await (_db.update(_db.localShoppingItems)
            ..where((i) => i.planSlotId.equals(tempId)))
          .write(LocalShoppingItemsCompanion(planSlotId: Value(realId)));
      await (_db.update(_db.localIngredients)..where((i) => i.id.equals(tempId)))
          .write(LocalIngredientsCompanion(id: Value(realId)));
    });
  }

  // ── Planner: atomic cache + pending op ───────────────────────────────────────

  Future<void> cacheWeeklyPlanWithPendingCreate({
    required WeeklyPlan plan,
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) return;

    final userId = _requireCurrentUserId();
    if (userId == null) return;

    await _db.transaction(() async {
      await _db.into(_db.localWeeklyPlans).insertOnConflictUpdate(
            LocalWeeklyPlansCompanion.insert(
              id: plan.id,
              householdId: Value(plan.householdId),
              userId: Value(plan.userId),
              weekStart: plan.weekStart.toIso8601String().split('T').first,
              createdAt: plan.createdAt,
            ),
          );
      await _insertPendingOperation(
        userId: userId,
        entityType: PendingEntity.weeklyPlan,
        opType: PendingOp.create,
        payload: payload,
      );
    });
  }

  // ── Shopping: atomic cache + pending op ────────────────────────────────────

  Future<void> cacheShoppingListWithPendingCreate({
    required ShoppingList list,
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) return;

    final userId = _requireCurrentUserId();
    if (userId == null) return;

    await _db.transaction(() async {
      await _db.into(_db.localShoppingLists).insertOnConflictUpdate(
            LocalShoppingListsCompanion.insert(
              id: list.id,
              householdId: Value(list.householdId),
              userId: Value(list.userId),
              createdAt: list.createdAt,
            ),
          );
      await _insertPendingOperation(
        userId: userId,
        entityType: PendingEntity.shoppingList,
        opType: PendingOp.create,
        payload: payload,
      );
    });
  }

  Future<void> upsertShoppingItemWithPendingOp({
    required ShoppingItem item,
    required String opType,
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) return;

    final userId = _requireCurrentUserId();
    if (userId == null) return;

    await _db.transaction(() async {
      await _db.into(_db.localShoppingItems).insertOnConflictUpdate(
            _shoppingItemToRow(item),
          );
      await _insertPendingOperation(
        userId: userId,
        entityType: PendingEntity.shoppingItem,
        opType: opType,
        payload: payload,
      );
    });
  }

  Future<void> deleteShoppingItemWithPendingOp({
    required String id,
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) return;

    final userId = _requireCurrentUserId();
    if (userId == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.localShoppingItems)..where((i) => i.id.equals(id)))
          .go();
      await _insertPendingOperation(
        userId: userId,
        entityType: PendingEntity.shoppingItem,
        opType: PendingOp.delete,
        payload: payload,
      );
    });
  }

  Future<void> clearShoppingItemsWithPendingOp({
    required String listId,
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) return;

    final userId = _requireCurrentUserId();
    if (userId == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.localShoppingItems)
            ..where((i) => i.shoppingListId.equals(listId)))
          .go();
      await _insertPendingOperation(
        userId: userId,
        entityType: PendingEntity.shoppingItem,
        opType: PendingOp.clear,
        payload: payload,
      );
    });
  }

  // ── Planner Slots: atomic cache + pending op + shopping items ──────────────

  Future<void> upsertSlotWithShoppingAndPendingOp({
    required SlotItem slotItem,
    required List<ShoppingItem> shoppingItems,
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) return;

    final userId = _requireCurrentUserId();
    if (userId == null) return;

    await _db.transaction(() async {
      await _db.into(_db.localPlanSlots).insertOnConflictUpdate(
            _slotItemToRow(slotItem),
          );
      for (final item in shoppingItems) {
        await _db.into(_db.localShoppingItems).insertOnConflictUpdate(
              _shoppingItemToRow(item),
            );
      }
      await _insertPendingOperation(
        userId: userId,
        entityType: PendingEntity.planSlot,
        opType: PendingOp.add,
        payload: payload,
      );
    });
  }

  Future<void> deleteSlotWithShoppingAndPendingOp({
    required String slotId,
    required List<String> shoppingItemIds,
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) return;

    final userId = _requireCurrentUserId();
    if (userId == null) return;

    await _db.transaction(() async {
      for (final itemId in shoppingItemIds) {
        await (_db.delete(_db.localShoppingItems)
              ..where((i) => i.id.equals(itemId)))
            .go();
      }
      await (_db.delete(_db.localPlanSlots)
            ..where((s) => s.id.equals(slotId)))
          .go();
      await _insertPendingOperation(
        userId: userId,
        entityType: PendingEntity.planSlot,
        opType: PendingOp.remove,
        payload: payload,
      );
    });
  }

  Future<void> moveSlotWithPendingOp({
    required SlotItem slotItem,
    required Map<String, dynamic> payload,
  }) async {
    if (_db == null) return;

    final userId = _requireCurrentUserId();
    if (userId == null) return;

    await _db.transaction(() async {
      await _db.into(_db.localPlanSlots).insertOnConflictUpdate(
            _slotItemToRow(slotItem),
          );
      await _insertPendingOperation(
        userId: userId,
        entityType: PendingEntity.planSlot,
        opType: PendingOp.update,
        payload: payload,
      );
    });
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
