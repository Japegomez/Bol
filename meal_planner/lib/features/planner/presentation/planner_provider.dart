import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/local_db/local_db_provider.dart';
import 'package:meal_planner/core/supabase/models/plan_slot.dart';
import 'package:meal_planner/core/supabase/models/weekly_plan.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/utils/date_utils.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/household/presentation/household_provider.dart';
import 'package:meal_planner/features/planner/data/planner_repository.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';
import 'package:meal_planner/features/shopping/presentation/shopping_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepository(ref.watch(localCacheStoreProvider));
});

final currentWeekProvider = StateProvider<DateTime>((ref) {
  return startOfIsoWeek(DateTime.now());
});

/// True while a recipe or assigned meal is being dragged onto the planner.
final plannerDragActiveProvider = StateProvider<bool>((ref) => false);

final weeklyPlanProvider = FutureProvider.autoDispose<WeeklyPlan>((ref) async {
  ref.watch(currentWeekProvider);
  ref.watch(currentHouseholdProvider);

  final weekStart = ref.read(currentWeekProvider);
  final household = ref.watch(currentHouseholdProvider).valueOrNull;
  final authState = ref.watch(authStateProvider).valueOrNull;
  if (authState is! AuthAuthenticated) {
    throw StateError('User not authenticated');
  }

  return ref.read(plannerRepositoryProvider).getOrCreateWeeklyPlan(
        weekStart: weekStart,
        userId: authState.user.id,
        householdId: household?.id,
      );
});

final planSlotsProvider =
    AsyncNotifierProvider<PlanSlotsNotifier, List<SlotItem>>(
  PlanSlotsNotifier.new,
);

class PlanSlotsNotifier extends AsyncNotifier<List<SlotItem>> {
  RealtimeChannel? _channel;

  PlannerRepository get _repository => ref.read(plannerRepositoryProvider);

  String? get _userId {
    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is AuthAuthenticated) return authState.user.id;
    return null;
  }

  @override
  Future<List<SlotItem>> build() async {
    ref.watch(currentWeekProvider);
    final plan = await ref.watch(weeklyPlanProvider.future);

    ref.onDispose(_unsubscribe);

    _subscribeToPlan(plan.id);

    return _repository.getSlotsForPlan(plan.id);
  }

  void _subscribeToPlan(String planId) {
    _unsubscribe();

    _channel = supabase
        .channel('plan_slots:$planId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'plan_slots',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'plan_id',
            value: planId,
          ),
          callback: (_) => _reloadFromServer(),
        )
        .subscribe();
  }

  void _unsubscribe() {
    final channel = _channel;
    if (channel != null) {
      supabase.removeChannel(channel);
      _channel = null;
    }
  }

  Future<void> _reloadFromServer() async {
    final plan = ref.read(weeklyPlanProvider).valueOrNull;
    if (plan == null) return;

    state = await AsyncValue.guard(
      () => _repository.getSlotsForPlan(plan.id),
    );
  }

  Future<void> addSlot({
    required int dayOfWeek,
    required String mealType,
    String? recipeId,
    required int servings,
    String? recipeTitle,
    bool isLeftover = false,
    String? notes,
  }) async {
    final plan = await ref.read(weeklyPlanProvider.future);
    final household = ref.read(currentHouseholdProvider).valueOrNull;
    final userId = _userId;
    if (userId == null) return;

    final previous = state.valueOrNull ?? const <SlotItem>[];

    final position = previous
        .where(
          (item) =>
              item.slot.dayOfWeek == dayOfWeek && item.slot.mealType == mealType,
        )
        .length;

    final optimistic = SlotItem(
      slot: PlanSlot(
        id: 'temp-${DateTime.now().microsecondsSinceEpoch}',
        planId: plan.id,
        dayOfWeek: dayOfWeek,
        mealType: mealType,
        recipeId: recipeId,
        servings: servings,
        position: position,
        isLeftover: isLeftover,
        notes: notes,
      ),
      recipeTitle: recipeTitle,
    );

    state = AsyncData([...previous, optimistic]);

    try {
      await _repository.addSlot(
        planId: plan.id,
        dayOfWeek: dayOfWeek,
        mealType: mealType,
        recipeId: recipeId,
        servings: servings,
        userId: userId,
        householdId: household?.id,
        isLeftover: isLeftover,
        notes: notes,
        recipeTitle: recipeTitle,
      );
      state = AsyncData(await _repository.getSlotsForPlan(plan.id));
      await ref.read(shoppingItemsProvider.notifier).reload();
    } catch (_) {
      state = AsyncData(previous);
    }
  }

  Future<void> removeSlot(String slotId) async {
    final plan = ref.read(weeklyPlanProvider).valueOrNull;
    if (plan == null) return;

    final previous = state.valueOrNull ?? const <SlotItem>[];

    state = AsyncData(
      previous.where((item) => item.slot.id != slotId).toList(),
    );

    final household = ref.read(currentHouseholdProvider).valueOrNull;

    try {
      await _repository.removeSlot(slotId, householdId: household?.id);
      state = AsyncData(await _repository.getSlotsForPlan(plan.id));
      await ref.read(shoppingItemsProvider.notifier).reload();
    } catch (_) {
      state = AsyncData(previous);
    }
  }

  Future<void> moveSlot({
    required String slotId,
    required int dayOfWeek,
    required String mealType,
  }) async {
    final plan = ref.read(weeklyPlanProvider).valueOrNull;
    if (plan == null) return;

    final previous = state.valueOrNull ?? const <SlotItem>[];
    final moving = previous.where((item) => item.slot.id == slotId).firstOrNull;
    if (moving == null) return;
    if (moving.slot.dayOfWeek == dayOfWeek &&
        moving.slot.mealType == mealType) {
      return;
    }

    final destinationCount = previous
        .where(
          (item) =>
              item.slot.id != slotId &&
              item.slot.dayOfWeek == dayOfWeek &&
              item.slot.mealType == mealType,
        )
        .length;

    state = AsyncData([
      for (final item in previous)
        if (item.slot.id == slotId)
          SlotItem(
            slot: item.slot.copyWith(
              dayOfWeek: dayOfWeek,
              mealType: mealType,
              position: destinationCount,
            ),
            recipeTitle: item.recipeTitle,
          )
        else
          item,
    ]);

    final household = ref.read(currentHouseholdProvider).valueOrNull;

    try {
      await _repository.moveSlot(
        slotId: slotId,
        dayOfWeek: dayOfWeek,
        mealType: mealType,
        householdId: household?.id,
      );
      state = AsyncData(await _repository.getSlotsForPlan(plan.id));
    } catch (_) {
      state = AsyncData(previous);
    }
  }
}
