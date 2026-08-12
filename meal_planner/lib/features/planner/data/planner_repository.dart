import 'package:meal_planner/core/local_db/local_cache_store.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/core/offline/offline_exceptions.dart';
import 'package:meal_planner/core/offline/supabase_error_utils.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/plan_slot.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/core/supabase/models/shopping_list.dart';
import 'package:meal_planner/core/supabase/models/weekly_plan.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';

class PlannerRepository {
  PlannerRepository(this._cache);

  final LocalCacheStore _cache;

  Future<void> _guardOfflineMutation({
    String? householdId,
    required bool isOnline,
  }) async {
    if (householdId != null && !isOnline) {
      throw OfflineEditBlockedException();
    }
  }

  Future<WeeklyPlan> getOrCreateWeeklyPlan({
    required DateTime weekStart,
    required String userId,
    String? householdId,
  }) async {
    final dateStr = _formatDate(weekStart);

    if (await NetworkStatus.isOnline) {
      try {
        final data = await supabase.rpc<Map<String, dynamic>>(
          'get_or_create_weekly_plan',
          params: {'p_week_start': dateStr},
        );
        final plan = WeeklyPlan.fromJson(data);
        await _cache.cacheWeeklyPlan(plan);
        return plan;
      } catch (error) {
        if (!shouldFallbackToCache(error)) rethrow;
        final cached = await _cache.getWeeklyPlan(
          weekStart: dateStr,
          userId: householdId == null ? userId : null,
          householdId: householdId,
        );
        if (cached != null) return cached;
        rethrow;
      }
    }

    final cached = await _cache.getWeeklyPlan(
      weekStart: dateStr,
      userId: householdId == null ? userId : null,
      householdId: householdId,
    );
    if (cached != null) return cached;

    if (householdId != null) {
      throw OfflineEditBlockedException(
        'Sin conexión: no hay planificador guardado para esta semana',
      );
    }

    final tempPlan = WeeklyPlan(
      id: newLocalId(),
      userId: userId,
      weekStart: DateTime.parse(dateStr),
      createdAt: DateTime.now(),
    );
    await _cache.cacheWeeklyPlanWithPendingCreate(
      plan: tempPlan,
      payload: {'tempId': tempPlan.id, 'userId': userId, 'weekStart': dateStr},
    );
    return tempPlan;
  }

  Future<List<SlotItem>> getSlotsForPlan(String planId) async {
    if (await NetworkStatus.isOnline) {
      try {
        final slots = await _fetchSlotsRemote(planId);
        await _cache.cacheSlots(planId, slots);
        return slots;
      } catch (error) {
        if (!shouldFallbackToCache(error)) rethrow;
        return _cache.getSlotsForPlan(planId);
      }
    }
    return _cache.getSlotsForPlan(planId);
  }

  Future<List<SlotItem>> _fetchSlotsRemote(String planId) async {
    final data = await supabase
        .from(PlanSlot.table_name)
        .select('*, recipes(id, title, servings)')
        .eq(PlanSlot.c_planId, planId)
        .order(PlanSlot.c_dayOfWeek)
        .order(PlanSlot.c_mealType)
        .order(PlanSlot.c_position);

    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(SlotItem.fromJson)
        .toList();
  }

  Future<PlanSlot> addSlot({
    required String planId,
    required int dayOfWeek,
    required String mealType,
    String? recipeId,
    required int servings,
    required String userId,
    String? householdId,
    bool isLeftover = false,
    String? notes,
    String? recipeTitle,
    bool skipShopping = false,
  }) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);

    if (isOnline) {
      final slot = await addSlotRemote(
        planId: planId,
        dayOfWeek: dayOfWeek,
        mealType: mealType,
        recipeId: recipeId,
        servings: servings,
        userId: userId,
        householdId: householdId,
        isLeftover: isLeftover,
        notes: notes,
        skipShopping: skipShopping,
      );
      // Update cache with the returned slot immediately
      await _cache.upsertSlot(SlotItem(slot: slot, recipeTitle: recipeTitle));
      // Best-effort full refresh
      try {
        final slots = await _fetchSlotsRemote(planId);
        await _cache.cacheSlots(planId, slots);
      } catch (_) {
        // Ignore refresh errors; the operation succeeded
      }
      return slot;
    }

    return _addSlotOffline(
      planId: planId,
      dayOfWeek: dayOfWeek,
      mealType: mealType,
      recipeId: recipeId,
      servings: servings,
      userId: userId,
      isLeftover: isLeftover,
      notes: notes,
      recipeTitle: recipeTitle,
      skipShopping: skipShopping,
    );
  }

  Future<PlanSlot> addSlotRemote({
    required String planId,
    required int dayOfWeek,
    required String mealType,
    String? recipeId,
    required int servings,
    required String userId,
    String? householdId,
    bool isLeftover = false,
    String? notes,
    String? slotId,
    bool skipShopping = false,
  }) async {
    final existingSlots = await _fetchSlotsRemote(planId);
    final position = existingSlots
        .where(
          (item) =>
              item.slot.dayOfWeek == dayOfWeek &&
              item.slot.mealType == mealType,
        )
        .length;

    final data = await supabase
        .from(PlanSlot.table_name)
        .insert(
          PlanSlot.insert(
            id: slotId,
            planId: planId,
            dayOfWeek: dayOfWeek,
            mealType: mealType,
            recipeId: recipeId,
            servings: servings,
            position: position,
            isLeftover: isLeftover,
            notes: notes,
          ),
        )
        .select()
        .single();

    final slot = PlanSlot.fromJson(data);

    if (recipeId != null && !isLeftover && !skipShopping) {
      try {
        await _syncShoppingListAdd(
          slot: slot,
          recipeId: recipeId,
          servings: servings,
          userId: userId,
          householdId: householdId,
        );
      } catch (error) {
        // Compensation: delete the slot since shopping sync failed.
        // (Shopping items are already rolled back by _syncShoppingListAdd.)
        try {
          await supabase
              .from(PlanSlot.table_name)
              .delete()
              .eq(PlanSlot.c_id, slot.id);
        } catch (_) {
          // Best-effort; log if needed but rethrow original error.
        }
        rethrow;
      }
    }

    return slot;
  }

  Future<PlanSlot> _addSlotOffline({
    required String planId,
    required int dayOfWeek,
    required String mealType,
    String? recipeId,
    required int servings,
    required String userId,
    bool isLeftover = false,
    String? notes,
    String? recipeTitle,
    bool skipShopping = false,
  }) async {
    final existingSlots = await _cache.getSlotsForPlan(planId);
    final position = existingSlots
        .where(
          (item) =>
              item.slot.dayOfWeek == dayOfWeek &&
              item.slot.mealType == mealType,
        )
        .length;

    final tempId = newLocalId();
    final slot = PlanSlot(
      id: tempId,
      planId: planId,
      dayOfWeek: dayOfWeek,
      mealType: mealType,
      recipeId: recipeId,
      servings: servings,
      position: position,
      isLeftover: isLeftover,
      notes: notes,
    );

    final shoppingItems = <ShoppingItem>[];
    if (recipeId != null && !isLeftover && !skipShopping) {
      final list = await getOrCreateShoppingList(userId: userId);
      final recipe = await _cache.getRecipeById(recipeId);
      if (recipe != null && recipe.servings > 0) {
        final scale = servings / recipe.servings;
        final ingredients = await _cache.getIngredientsForRecipe(recipeId);
        for (final ingredient in ingredients) {
          if (!ingredient.isIncluded || ingredient.isToTaste) continue;
          final scaledQty = _scaleQuantity(ingredient.quantity, scale);
          shoppingItems.add(
            ShoppingItem(
              id: newLocalId(),
              shoppingListId: list.id,
              name: ingredient.name,
              quantity: scaledQty,
              unit: ingredient.unit,
              category: ingredient.category,
              isChecked: false,
              isManual: false,
              planSlotId: slot.id,
              ingredientId: ingredient.id,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    }

    // Atomic: upsert slot, add shopping items, enqueue operation
    await _cache.upsertSlotWithShoppingAndPendingOp(
      slotItem: SlotItem(slot: slot, recipeTitle: recipeTitle),
      shoppingItems: shoppingItems,
      payload: {
        'tempId': tempId,
        'planId': planId,
        'dayOfWeek': dayOfWeek,
        'mealType': mealType,
        'recipeId': recipeId,
        'servings': servings,
        'userId': userId,
        'householdId': null,
        'isLeftover': isLeftover,
        'notes': notes,
        'skipShopping': skipShopping,
      },
    );

    return slot;
  }

  Future<void> removeSlot(String slotId, {String? householdId}) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);

    if (isOnline) {
      await removeSlotRemote(slotId);
      // Delete from cache immediately after remote deletion
      await _cache.deleteSlot(slotId);
      return;
    }

    await _removeSlotOffline(slotId, householdId: householdId);
  }

  Future<void> removeSlotRemote(String slotId) async {
    final slotRow = await supabase
        .from(PlanSlot.table_name)
        .select('*, weekly_plans(user_id, household_id)')
        .eq(PlanSlot.c_id, slotId)
        .maybeSingle();

    if (slotRow != null) {
      final slot = PlanSlot.fromJson(slotRow);
      final planData = slotRow['weekly_plans'] as Map<String, dynamic>?;
      final householdId = planData?[WeeklyPlan.c_householdId]?.toString();
      final userId =
          planData?[WeeklyPlan.c_userId]?.toString() ??
          supabase.auth.currentUser?.id;

      if (slot.recipeId != null && !slot.isLeftover && userId != null) {
        await _syncShoppingListRemove(
          slot: slot,
          userId: userId,
          householdId: householdId,
        );
      } else {
        await supabase
            .from(ShoppingItem.table_name)
            .delete()
            .eq(ShoppingItem.c_planSlotId, slotId);
      }
    }

    await supabase.from(PlanSlot.table_name).delete().eq(PlanSlot.c_id, slotId);
  }

  Future<void> _removeSlotOffline(String slotId, {String? householdId}) async {
    final linked = await _cache.getShoppingItemsByPlanSlot(slotId);
    final itemIds = linked.map((item) => item.id).toList();

    // Atomic: delete shopping items, delete slot, enqueue operation
    await _cache.deleteSlotWithShoppingAndPendingOp(
      slotId: slotId,
      shoppingItemIds: itemIds,
      payload: {'slotId': slotId},
    );
  }

  Future<void> moveSlot({
    required String slotId,
    required int dayOfWeek,
    required String mealType,
    String? householdId,
    String? userId,
    bool sourceIsPast = false,
    bool destinationIsPast = false,
  }) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);

    if (isOnline) {
      final cached = await _cache.getSlotsForPlanBySlotId(slotId);
      await moveSlotRemote(
        slotId: slotId,
        dayOfWeek: dayOfWeek,
        mealType: mealType,
        userId: userId,
        householdId: householdId,
        sourceIsPast: sourceIsPast,
        destinationIsPast: destinationIsPast,
      );
      if (cached != null) {
        try {
          final slots = await _fetchSlotsRemote(cached.slot.planId);
          await _cache.cacheSlots(cached.slot.planId, slots);
        } catch (_) {
          // Best-effort cache refresh; remote move succeeded.
        }
      }
      return;
    }

    await _moveSlotOffline(
      slotId: slotId,
      dayOfWeek: dayOfWeek,
      mealType: mealType,
      userId: userId,
      householdId: householdId,
      sourceIsPast: sourceIsPast,
      destinationIsPast: destinationIsPast,
    );
  }

  Future<void> moveSlotRemote({
    required String slotId,
    required int dayOfWeek,
    required String mealType,
    String? userId,
    String? householdId,
    bool sourceIsPast = false,
    bool destinationIsPast = false,
  }) async {
    final slotRow = await supabase
        .from(PlanSlot.table_name)
        .select()
        .eq(PlanSlot.c_id, slotId)
        .maybeSingle();
    if (slotRow == null) return;

    final slot = PlanSlot.fromJson(slotRow);
    if (slot.dayOfWeek == dayOfWeek && slot.mealType == mealType) return;

    final existingSlots = await _fetchSlotsRemote(slot.planId);
    final position = existingSlots
        .where(
          (item) =>
              item.slot.id != slotId &&
              item.slot.dayOfWeek == dayOfWeek &&
              item.slot.mealType == mealType,
        )
        .length;

    await supabase
        .from(PlanSlot.table_name)
        .update(
          PlanSlot.update(
            dayOfWeek: dayOfWeek,
            mealType: mealType,
            position: position,
          ),
        )
        .eq(PlanSlot.c_id, slotId);

    final moved = slot.copyWith(
      dayOfWeek: dayOfWeek,
      mealType: mealType,
      position: position,
    );

    if (userId == null) return;

    final shouldSyncShopping = moved.recipeId != null && !moved.isLeftover;
    if (!shouldSyncShopping) return;

    try {
      if (destinationIsPast && !sourceIsPast) {
        await _syncShoppingListRemove(
          slot: moved,
          userId: userId,
          householdId: householdId,
        );
      } else if (!destinationIsPast && sourceIsPast) {
        await _syncShoppingListAdd(
          slot: moved,
          recipeId: moved.recipeId!,
          servings: moved.servings,
          userId: userId,
          householdId: householdId,
        );
      }
    } catch (_) {
      // Shopping sync methods already compensate their own mutations internally.
      // Roll back the slot position update so planner and shopping stay aligned.
      try {
        await supabase
            .from(PlanSlot.table_name)
            .update(
              PlanSlot.update(
                dayOfWeek: slot.dayOfWeek,
                mealType: slot.mealType,
                position: slot.position,
              ),
            )
            .eq(PlanSlot.c_id, slotId);
      } catch (_) {
        // Best-effort rollback; log if needed but rethrow original error.
      }
      rethrow;
    }
  }

  Future<void> _moveSlotOffline({
    required String slotId,
    required int dayOfWeek,
    required String mealType,
    String? userId,
    String? householdId,
    bool sourceIsPast = false,
    bool destinationIsPast = false,
  }) async {
    final cached = await _cache.getSlotsForPlanBySlotId(slotId);
    if (cached == null) return;
    if (cached.slot.dayOfWeek == dayOfWeek &&
        cached.slot.mealType == mealType) {
      return;
    }

    final existingSlots = await _cache.getSlotsForPlan(cached.slot.planId);
    final position = existingSlots
        .where(
          (item) =>
              item.slot.id != slotId &&
              item.slot.dayOfWeek == dayOfWeek &&
              item.slot.mealType == mealType,
        )
        .length;

    final updated = SlotItem(
      slot: cached.slot.copyWith(
        dayOfWeek: dayOfWeek,
        mealType: mealType,
        position: position,
      ),
      recipeTitle: cached.recipeTitle,
    );

    final shouldSyncShopping =
        cached.slot.recipeId != null && !cached.slot.isLeftover;
    if (destinationIsPast && !sourceIsPast && shouldSyncShopping) {
      final linked = await _cache.getShoppingItemsByPlanSlot(slotId);
      for (final item in linked) {
        await _cache.deleteShoppingItem(item.id);
      }
    }

    await _cache.moveSlotWithPendingOp(
      slotItem: updated,
      payload: {
        'slotId': slotId,
        'dayOfWeek': dayOfWeek,
        'mealType': mealType,
        'userId': userId,
        'householdId': householdId,
        'sourceIsPast': sourceIsPast,
        'destinationIsPast': destinationIsPast,
      },
    );
  }

  Future<ShoppingList> getOrCreateShoppingList({
    required String userId,
    String? householdId,
  }) async {
    if (await NetworkStatus.isOnline) {
      try {
        final list = await _getOrCreateShoppingListRemote(
          userId: userId,
          householdId: householdId,
        );
        await _cache.cacheShoppingList(list);
        return list;
      } catch (error) {
        if (!shouldFallbackToCache(error)) rethrow;
        final cached = await _cache.getShoppingList(
          userId: householdId == null ? userId : null,
          householdId: householdId,
        );
        if (cached != null) return cached;
        rethrow;
      }
    }

    final cached = await _cache.getShoppingList(
      userId: householdId == null ? userId : null,
      householdId: householdId,
    );
    if (cached != null) return cached;

    if (householdId != null) {
      throw OfflineEditBlockedException(
        'Sin conexión: no hay lista de la compra guardada',
      );
    }

    final tempList = ShoppingList(
      id: newLocalId(),
      userId: userId,
      createdAt: DateTime.now(),
    );
    await _cache.cacheShoppingListWithPendingCreate(
      list: tempList,
      payload: {'tempId': tempList.id, 'userId': userId},
    );
    return tempList;
  }

  Future<ShoppingList> _getOrCreateShoppingListRemote({
    required String userId,
    String? householdId,
  }) async {
    final Map<String, dynamic>? existing;
    if (householdId != null) {
      existing = await supabase
          .from(ShoppingList.table_name)
          .select()
          .eq(ShoppingList.c_householdId, householdId)
          .order(ShoppingList.c_createdAt, ascending: false)
          .limit(1)
          .maybeSingle();
    } else {
      existing = await supabase
          .from(ShoppingList.table_name)
          .select()
          .eq(ShoppingList.c_userId, userId)
          .order(ShoppingList.c_createdAt, ascending: false)
          .limit(1)
          .maybeSingle();
    }

    if (existing != null) {
      return ShoppingList.fromJson(existing);
    }

    final data = await supabase
        .from(ShoppingList.table_name)
        .insert(
          ShoppingList.insert(
            householdId: householdId,
            userId: householdId == null ? userId : null,
          ),
        )
        .select()
        .single();

    return ShoppingList.fromJson(data);
  }

  Future<List<String>> _syncShoppingListAdd({
    required PlanSlot slot,
    required String recipeId,
    required int servings,
    required String userId,
    String? householdId,
  }) async {
    final addedIds = <String>[];
    try {
      final existingLinked = await supabase
          .from(ShoppingItem.table_name)
          .select(ShoppingItem.c_id)
          .eq(ShoppingItem.c_planSlotId, slot.id)
          .limit(1);
      if ((existingLinked as List).isNotEmpty) return addedIds;

      final list = await getOrCreateShoppingList(
        userId: userId,
        householdId: householdId,
      );

      final recipeData = await supabase
          .from(Recipe.table_name)
          .select(Recipe.c_servings)
          .eq(Recipe.c_id, recipeId)
          .single();

      final recipeServings = int.parse(
        recipeData[Recipe.c_servings].toString(),
      );
      if (recipeServings <= 0) return addedIds;

      final scale = servings / recipeServings;

      final ingredientsData = await supabase
          .from(Ingredient.table_name)
          .select()
          .eq(Ingredient.c_recipeId, recipeId)
          .order(Ingredient.c_position, ascending: true);

      final ingredients = Ingredient.converter(
        (ingredientsData as List).cast<Map<String, dynamic>>(),
      );

      if (ingredients.isEmpty) return addedIds;

      // Persist ingredients to local cache so they're available offline later.
      try {
        await _cache.cacheIngredientsForRecipe(recipeId, ingredients);
      } catch (_) {
        // Best-effort; cache failure must not block the online path.
      }

      for (final ingredient in ingredients) {
        if (!ingredient.isIncluded) continue;
        if (ingredient.isToTaste) continue;

        final scaledQty = _scaleQuantity(ingredient.quantity, scale);

        final insertedData = await supabase
            .from(ShoppingItem.table_name)
            .insert(
              ShoppingItem.insert(
                shoppingListId: list.id,
                name: ingredient.name,
                quantity: scaledQty,
                unit: ingredient.unit,
                category: ingredient.category,
                isManual: false,
                planSlotId: slot.id,
                ingredientId: ingredient.id,
              ),
            )
            .select(ShoppingItem.c_id)
            .single();
        addedIds.add(insertedData[ShoppingItem.c_id].toString());
      }
      return addedIds;
    } catch (e) {
      // Roll back any items that were successfully added before the error.
      for (final id in addedIds) {
        try {
          await supabase
              .from(ShoppingItem.table_name)
              .delete()
              .eq(ShoppingItem.c_id, id);
        } catch (_) {
          // Best-effort rollback; log if needed but don't mask original error.
        }
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _syncShoppingListRemove({
    required PlanSlot slot,
    required String userId,
    String? householdId,
  }) async {
    final removedItems = <Map<String, dynamic>>[];
    try {
      final list = await getOrCreateShoppingList(
        userId: userId,
        householdId: householdId,
      );

      final linkedData = await supabase
          .from(ShoppingItem.table_name)
          .select()
          .eq(ShoppingItem.c_shoppingListId, list.id)
          .eq(ShoppingItem.c_planSlotId, slot.id);

      final linkedItems = ShoppingItem.converter(
        (linkedData as List).cast<Map<String, dynamic>>(),
      );

      if (linkedItems.isNotEmpty) {
        // Track removed items for compensation.
        for (final item in linkedItems) {
          removedItems.add({
            'id': item.id,
            'shoppingListId': item.shoppingListId,
            'name': item.name,
            'quantity': item.quantity,
            'unit': item.unit,
            'category': item.category,
            'isChecked': item.isChecked,
            'isManual': item.isManual,
            'planSlotId': item.planSlotId,
            'ingredientId': item.ingredientId,
          });
        }
        await supabase
            .from(ShoppingItem.table_name)
            .delete()
            .eq(ShoppingItem.c_planSlotId, slot.id);
        return removedItems;
      }

      final recipeId = slot.recipeId;
      if (recipeId == null) return removedItems;

      final recipeData = await supabase
          .from(Recipe.table_name)
          .select(Recipe.c_servings)
          .eq(Recipe.c_id, recipeId)
          .single();

      final recipeServings = int.parse(
        recipeData[Recipe.c_servings].toString(),
      );
      if (recipeServings <= 0) return removedItems;

      final scale = slot.servings / recipeServings;

      final ingredientsData = await supabase
          .from(Ingredient.table_name)
          .select()
          .eq(Ingredient.c_recipeId, recipeId)
          .order(Ingredient.c_position, ascending: true);

      final ingredients = Ingredient.converter(
        (ingredientsData as List).cast<Map<String, dynamic>>(),
      );

      final existingData = await supabase
          .from(ShoppingItem.table_name)
          .select()
          .eq(ShoppingItem.c_shoppingListId, list.id);

      var existingItems = ShoppingItem.converter(
        (existingData as List).cast<Map<String, dynamic>>(),
      );

      for (final ingredient in ingredients) {
        if (!ingredient.isIncluded) continue;
        if (ingredient.isToTaste) continue;

        final scaledQty = _scaleQuantity(ingredient.quantity, scale);
        if (scaledQty == null) continue;

        final matchIndex = existingItems.indexWhere(
          (item) => _matchesForConsolidation(
            item,
            name: ingredient.name,
            unit: ingredient.unit,
          ),
        );
        if (matchIndex < 0) continue;

        final match = existingItems[matchIndex];
        final oldQty = match.quantity ?? 0;
        final newQty = oldQty - scaledQty;

        if (newQty <= 0) {
          // Track deleted item for compensation.
          removedItems.add({
            'id': match.id,
            'shoppingListId': match.shoppingListId,
            'name': match.name,
            'quantity': match.quantity,
            'unit': match.unit,
            'category': match.category,
            'isChecked': match.isChecked,
            'isManual': match.isManual,
            'planSlotId': match.planSlotId,
            'ingredientId': match.ingredientId,
          });
          await supabase
              .from(ShoppingItem.table_name)
              .delete()
              .eq(ShoppingItem.c_id, match.id);
          existingItems = [
            ...existingItems.sublist(0, matchIndex),
            ...existingItems.sublist(matchIndex + 1),
          ];
          continue;
        }

        // Track updated item (store old quantity for compensation).
        removedItems.add({
          'id': match.id,
          'shoppingListId': match.shoppingListId,
          'name': match.name,
          'quantity': oldQty,
          'unit': match.unit,
          'category': match.category,
          'isChecked': match.isChecked,
          'isManual': match.isManual,
          'planSlotId': match.planSlotId,
          'ingredientId': match.ingredientId,
          'wasUpdate': true,
        });
        await supabase
            .from(ShoppingItem.table_name)
            .update({ShoppingItem.c_quantity: newQty.toString()})
            .eq(ShoppingItem.c_id, match.id);

        existingItems = [
          ...existingItems.sublist(0, matchIndex),
          match.copyWith(quantity: newQty),
          ...existingItems.sublist(matchIndex + 1),
        ];
      }
      return removedItems;
    } catch (e) {
      // Compensate: restore deleted items and revert updated quantities.
      for (final itemData in removedItems) {
        try {
          if (itemData['wasUpdate'] == true) {
            // Revert quantity update.
            await supabase
                .from(ShoppingItem.table_name)
                .update({
                  ShoppingItem.c_quantity: itemData['quantity'].toString(),
                })
                .eq(ShoppingItem.c_id, itemData['id'] as Object);
          } else {
            // Restore deleted item.
            await supabase.from(ShoppingItem.table_name).insert({
              ShoppingItem.c_id: itemData['id'],
              ShoppingItem.c_shoppingListId: itemData['shoppingListId'],
              ShoppingItem.c_name: itemData['name'],
              ShoppingItem.c_quantity: itemData['quantity']?.toString(),
              ShoppingItem.c_unit: itemData['unit'],
              ShoppingItem.c_category: itemData['category'],
              ShoppingItem.c_isChecked: itemData['isChecked'],
              ShoppingItem.c_isManual: itemData['isManual'],
              ShoppingItem.c_planSlotId: itemData['planSlotId'],
              ShoppingItem.c_ingredientId: itemData['ingredientId'],
            });
          }
        } catch (_) {
          // Best-effort compensation; log if needed but don't mask original error.
        }
      }
      rethrow;
    }
  }

  bool _matchesForConsolidation(
    ShoppingItem item, {
    required String name,
    required String? unit,
  }) {
    return item.name.toLowerCase() == name.toLowerCase() && item.unit == unit;
  }

  num? _scaleQuantity(num? quantity, double scale) {
    if (quantity == null) return null;
    return (quantity * scale).round();
  }

  String _formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }
}
