import 'package:meal_planner/core/local_db/local_cache_store.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/core/offline/offline_exceptions.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/plan_slot.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/core/supabase/models/shopping_list.dart';
import 'package:meal_planner/core/supabase/models/weekly_plan.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/sync/pending_operation_types.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';

class PlannerRepository {
  PlannerRepository(this._cache);

  final LocalCacheStore _cache;

  Future<void> _guardOfflineMutation({String? householdId}) async {
    if (householdId != null && !await NetworkStatus.isOnline) {
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
      } catch (_) {
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
    await _cache.cacheWeeklyPlan(tempPlan);
    return tempPlan;
  }

  Future<List<SlotItem>> getSlotsForPlan(String planId) async {
    if (await NetworkStatus.isOnline) {
      try {
        final slots = await _fetchSlotsRemote(planId);
        await _cache.cacheSlots(planId, slots);
        return slots;
      } catch (_) {
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
  }) async {
    await _guardOfflineMutation(householdId: householdId);

    if (await NetworkStatus.isOnline) {
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
      );
      final slots = await _fetchSlotsRemote(planId);
      await _cache.cacheSlots(planId, slots);
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

    if (recipeId != null && !isLeftover) {
      await _syncShoppingListAdd(
        slot: slot,
        recipeId: recipeId,
        servings: servings,
        userId: userId,
        householdId: householdId,
      );
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

    await _cache.upsertSlot(
      SlotItem(slot: slot, recipeTitle: recipeTitle),
    );

    if (recipeId != null && !isLeftover) {
      await _syncShoppingListAddOffline(
        slot: slot,
        recipeId: recipeId,
        servings: servings,
        userId: userId,
      );
    }

    await _cache.enqueueOperation(
      entityType: PendingEntity.planSlot,
      opType: PendingOp.add,
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
      },
    );

    return slot;
  }

  Future<void> removeSlot(String slotId, {String? householdId}) async {
    await _guardOfflineMutation(householdId: householdId);

    if (await NetworkStatus.isOnline) {
      await removeSlotRemote(slotId);
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
      final userId = planData?[WeeklyPlan.c_userId]?.toString() ??
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

  Future<void> _removeSlotOffline(
    String slotId, {
    String? householdId,
  }) async {
    final slots = await _findSlotAcrossPlans(slotId);
    if (slots != null) {
      final slot = slots.slot;
      if (slot.recipeId != null && !slot.isLeftover) {
        await _syncShoppingListRemoveOffline(slot: slot);
      } else {
        final linked = await _cache.getShoppingItemsByPlanSlot(slotId);
        for (final item in linked) {
          await _cache.deleteShoppingItem(item.id);
        }
      }
      await _cache.deleteSlot(slotId);
    }

    await _cache.enqueueOperation(
      entityType: PendingEntity.planSlot,
      opType: PendingOp.remove,
      payload: {'slotId': slotId},
    );
  }

  Future<SlotItem?> _findSlotAcrossPlans(String slotId) async {
    // Slots are keyed by id in local db; read directly via getSlots if needed.
    // Query all plan slots with matching id through cache helper.
    final row = await _cache.getSlotsForPlanBySlotId(slotId);
    return row;
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
      } catch (_) {
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
    await _cache.cacheShoppingList(tempList);
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

  Future<void> _syncShoppingListAdd({
    required PlanSlot slot,
    required String recipeId,
    required int servings,
    required String userId,
    String? householdId,
  }) async {
    final list = await getOrCreateShoppingList(
      userId: userId,
      householdId: householdId,
    );

    final recipeData = await supabase
        .from(Recipe.table_name)
        .select(Recipe.c_servings)
        .eq(Recipe.c_id, recipeId)
        .single();

    final recipeServings = int.parse(recipeData[Recipe.c_servings].toString());
    if (recipeServings <= 0) return;

    final scale = servings / recipeServings;

    final ingredientsData = await supabase
        .from(Ingredient.table_name)
        .select()
        .eq(Ingredient.c_recipeId, recipeId)
        .order(Ingredient.c_position, ascending: true);

    final ingredients = Ingredient.converter(
      (ingredientsData as List).cast<Map<String, dynamic>>(),
    );

    if (ingredients.isEmpty) return;

    for (final ingredient in ingredients) {
      if (!ingredient.isIncluded) continue;
      if (ingredient.isToTaste) continue;

      final scaledQty = _scaleQuantity(ingredient.quantity, scale);

      await supabase.from(ShoppingItem.table_name).insert(
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
          );
    }
  }

  Future<void> _syncShoppingListAddOffline({
    required PlanSlot slot,
    required String recipeId,
    required int servings,
    required String userId,
  }) async {
    final list = await getOrCreateShoppingList(userId: userId);
    final recipe = await _cache.getRecipeById(recipeId);
    if (recipe == null || recipe.servings <= 0) return;

    final scale = servings / recipe.servings;
    final ingredients = await _cache.getIngredientsForRecipe(recipeId);
    if (ingredients.isEmpty) return;

    for (final ingredient in ingredients) {
      if (!ingredient.isIncluded) continue;
      if (ingredient.isToTaste) continue;

      final scaledQty = _scaleQuantity(ingredient.quantity, scale);
      final item = ShoppingItem(
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
      );
      await _cache.upsertShoppingItem(item);
    }
  }

  Future<void> _syncShoppingListRemove({
    required PlanSlot slot,
    required String userId,
    String? householdId,
  }) async {
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
      await supabase
          .from(ShoppingItem.table_name)
          .delete()
          .eq(ShoppingItem.c_planSlotId, slot.id);
      return;
    }

    final recipeId = slot.recipeId;
    if (recipeId == null) return;

    final recipeData = await supabase
        .from(Recipe.table_name)
        .select(Recipe.c_servings)
        .eq(Recipe.c_id, recipeId)
        .single();

    final recipeServings = int.parse(recipeData[Recipe.c_servings].toString());
    if (recipeServings <= 0) return;

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
      final newQty = (match.quantity ?? 0) - scaledQty;

      if (newQty <= 0) {
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
  }

  Future<void> _syncShoppingListRemoveOffline({required PlanSlot slot}) async {
    final linked = await _cache.getShoppingItemsByPlanSlot(slot.id);
    for (final item in linked) {
      await _cache.deleteShoppingItem(item.id);
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
