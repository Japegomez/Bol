import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/plan_slot.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/core/supabase/models/shopping_list.dart';
import 'package:meal_planner/core/supabase/models/weekly_plan.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';

class PlannerRepository {
  Future<WeeklyPlan> getOrCreateWeeklyPlan({
    required DateTime weekStart,
    required String userId,
    String? householdId,
  }) async {
    final dateStr = _formatDate(weekStart);

    final data = await supabase.rpc<Map<String, dynamic>>(
      'get_or_create_weekly_plan',
      params: {'p_week_start': dateStr},
    );

    return WeeklyPlan.fromJson(data);
  }

  Future<List<SlotItem>> getSlotsForPlan(String planId) async {
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
  }) async {
    final existingSlots = await getSlotsForPlan(planId);
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

  Future<void> removeSlot(String slotId) async {
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

  Future<ShoppingList> getOrCreateShoppingList({
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
    required String recipeId, // never null when this method is called
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

    // Legacy fallback: quantities merged into shared rows without a slot link.
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

  bool _matchesForConsolidation(
    ShoppingItem item, {
    required String name,
    required String? unit,
  }) {
    return item.name.toLowerCase() == name.toLowerCase() && item.unit == unit;
  }

  /// Scales an ingredient quantity for the planner and rounds to a whole number.
  num? _scaleQuantity(num? quantity, double scale) {
    if (quantity == null) return null;
    return (quantity * scale).round();
  }

  String _formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T').first;
  }
}
