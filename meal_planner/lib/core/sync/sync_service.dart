import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/local_db/app_database.dart';
import 'package:meal_planner/core/local_db/local_cache_store.dart';
import 'package:meal_planner/core/local_db/local_db_provider.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/core/supabase/models/plan_slot.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/core/supabase/models/shopping_list.dart';
import 'package:meal_planner/core/supabase/models/weekly_plan.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/sync/pending_operation_types.dart';
import 'package:meal_planner/core/sync/recipe_form_data_codec.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/connectivity/connectivity_notifier.dart';
import 'package:meal_planner/features/planner/data/planner_repository.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/recipes/data/recipes_repository.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/shopping/presentation/shopping_provider.dart';

class SyncService {
  static const int maxRetries = 5;
  SyncService({
    required this.ref,
    required this.cache,
    required this.recipesRepository,
    required this.plannerRepository,
  });

  final Ref ref;
  final LocalCacheStore cache;
  final RecipesRepository recipesRepository;
  final PlannerRepository plannerRepository;

  bool _syncing = false;

  Future<bool> _remoteRowExists(String table, String id) async {
    final row = await supabase
        .from(table)
        .select('id')
        .eq('id', id)
        .maybeSingle();
    return row != null;
  }

  /// Skips a create replay when the row already exists remotely (retry-safe).
  Future<bool> _skipIfCreateAlreadyApplied(String? tempId, String table) async {
    if (tempId == null) return false;
    if (!await _remoteRowExists(table, tempId)) return false;
    await cache.saveIdMapping(tempId, tempId);
    return true;
  }

  Future<void> _recordTempIdMapping(String tempId, String realId) async {
    if (tempId == realId) {
      await cache.saveIdMapping(tempId, realId);
    } else {
      await cache.replaceTempId(tempId, realId);
    }
  }

  Future<void> syncIfOnline() async {
    if (kIsWeb) return;
    if (_syncing) return;
    if (!await NetworkStatus.isOnline) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    _syncing = true;
    try {
      final ops = await cache.getPendingOperations(userId: userId);
      var syncedAny = false;

      for (final op in ops) {
        if (await _replayWithRetries(op)) {
          syncedAny = true;
        }
      }

      if (syncedAny) {
        ref.invalidate(recipesProvider);
        ref.invalidate(recipeListProvider);
        ref.invalidate(planSlotsProvider);
        ref.invalidate(shoppingItemsProvider);
      }

      final hadFavoriteOps = ops.any(
        (op) =>
            op.entityType == PendingEntity.recipe &&
            op.opType == PendingOp.setFavorite,
      );
      if (hadFavoriteOps) {
        try {
          await recipesRepository.fetchFavoriteIds();
        } catch (_) {
          // Favorites sync is best-effort; recipe/plan replay already finished.
        }
      }
    } finally {
      _syncing = false;
    }
  }

  int _backoffDelayMs(int attempt) {
    final seconds = 1 << attempt.clamp(0, 5);
    return (seconds * 1000).clamp(1000, 30000);
  }

  Future<bool> _replayWithRetries(PendingOperation op) async {
    var attempts = op.retryCount;

    while (true) {
      if (!await NetworkStatus.isOnline) return false;

      try {
        await _replay(op.entityType, op.opType, op.payloadJson);
        await cache.deletePendingOperation(op.id);
        return true;
      } catch (error, stackTrace) {
        attempts++;
        log.e(
          'Sync replay failed for operation: ${op.entityType}.${op.opType} '
          '(id: ${op.id}, attempt: $attempts/$maxRetries)',
          error: error,
          stackTrace: stackTrace,
        );

        if (attempts >= maxRetries) {
          log.w(
            'Max retries ($maxRetries) reached for operation: ${op.entityType}.${op.opType} '
            '(id: ${op.id}). Removing from pending queue.',
          );
          await cache.deletePendingOperation(op.id);
          return false;
        }

        await cache.incrementRetry(op.id);
        if (!await NetworkStatus.isOnline) return false;

        await Future<void>.delayed(
          Duration(milliseconds: _backoffDelayMs(attempts)),
        );
      }
    }
  }

  Future<void> _replay(
    String entityType,
    String opType,
    String payloadJson,
  ) async {
    final payload = Map<String, dynamic>.from(
      jsonDecode(payloadJson) as Map<dynamic, dynamic>,
    );

    switch (entityType) {
      case PendingEntity.recipe:
        await _replayRecipe(opType, payload);
      case PendingEntity.planSlot:
        await _replayPlanSlot(opType, payload);
      case PendingEntity.weeklyPlan:
        await _replayWeeklyPlan(opType, payload);
      case PendingEntity.shoppingList:
        await _replayShoppingList(opType, payload);
      case PendingEntity.shoppingItem:
        await _replayShoppingItem(opType, payload);
      default:
        throw StateError('Unknown pending entity type: $entityType');
    }
  }

  Future<void> _replayRecipe(
    String opType,
    Map<String, dynamic> payload,
  ) async {
    switch (opType) {
      case PendingOp.create:
        final tempId = payload['tempId'] as String?;
        if (await _skipIfCreateAlreadyApplied(tempId, Recipe.table_name)) {
          return;
        }
        final form = RecipeFormDataCodec.fromJson(
          Map<String, dynamic>.from(payload['form'] as Map),
        );
        final realId = await recipesRepository.createRecipeRemote(
          form,
          id: tempId,
        );
        if (tempId != null) {
          await _recordTempIdMapping(tempId, realId);
        }
      case PendingOp.update:
        final recipeId = await cache.resolveIdOrSelf(
          payload['recipeId'] as String,
        );
        final form = RecipeFormDataCodec.fromJson(
          Map<String, dynamic>.from(payload['form'] as Map),
        );
        await recipesRepository.updateRecipeRemote(recipeId, form);
      case PendingOp.delete:
        final recipeId = await cache.resolveIdOrSelf(
          payload['recipeId'] as String,
        );
        await recipesRepository.deleteRecipeRemote(recipeId);
      case PendingOp.setVisibility:
        final recipeId = await cache.resolveIdOrSelf(
          payload['recipeId'] as String,
        );
        await recipesRepository.setRecipeVisibilityRemote(
          recipeId,
          payload['isPublic'] as bool,
        );
      case PendingOp.setFavorite:
        final recipeId = await cache.resolveIdOrSelf(
          payload['recipeId'] as String,
        );
        await recipesRepository.setFavoriteRemote(
          recipeId,
          payload['isFavorite'] as bool,
        );
      case PendingOp.setIngredientIncluded:
        final recipeId = await cache.resolveIdOrSelf(
          payload['recipeId'] as String,
        );
        final ingredientId = await cache.resolveIdOrSelf(
          payload['ingredientId'] as String,
        );
        await recipesRepository.updateIngredientIncludedRemote(
          ingredientId: ingredientId,
          recipeId: recipeId,
          isIncluded: payload['isIncluded'] as bool,
        );
      default:
        throw StateError('Unknown recipe op type: $opType');
    }
  }

  Future<void> _replayPlanSlot(
    String opType,
    Map<String, dynamic> payload,
  ) async {
    switch (opType) {
      case PendingOp.add:
        final tempId = payload['tempId'] as String?;
        if (await _skipIfCreateAlreadyApplied(tempId, PlanSlot.table_name)) {
          return;
        }
        final planId = await cache.resolveIdOrSelf(payload['planId'] as String);
        final recipeId = payload['recipeId'] as String?;
        final resolvedRecipeId = recipeId != null
            ? await cache.resolveIdOrSelf(recipeId)
            : null;
        final slot = await plannerRepository.addSlotRemote(
          planId: planId,
          dayOfWeek: payload['dayOfWeek'] as int,
          mealType: payload['mealType'] as String,
          recipeId: resolvedRecipeId,
          servings: payload['servings'] as int,
          userId: payload['userId'] as String,
          householdId: payload['householdId'] as String?,
          isLeftover: payload['isLeftover'] as bool? ?? false,
          notes: payload['notes'] as String?,
          slotId: tempId,
          skipShopping: payload['skipShopping'] as bool? ?? false,
        );
        if (tempId != null) {
          await _recordTempIdMapping(tempId, slot.id);
        }
      case PendingOp.remove:
        final slotId = await cache.resolveIdOrSelf(payload['slotId'] as String);
        await plannerRepository.removeSlotRemote(slotId);
      case PendingOp.update:
        final slotId = await cache.resolveIdOrSelf(payload['slotId'] as String);
        await plannerRepository.moveSlotRemote(
          slotId: slotId,
          dayOfWeek: payload['dayOfWeek'] as int,
          mealType: payload['mealType'] as String,
          userId: payload['userId'] as String?,
          householdId: payload['householdId'] as String?,
          sourceIsPast: payload['sourceIsPast'] as bool? ?? false,
          destinationIsPast: payload['destinationIsPast'] as bool? ?? false,
        );
      default:
        throw StateError('Unknown plan slot op type: $opType');
    }
  }

  Future<void> _replayWeeklyPlan(
    String opType,
    Map<String, dynamic> payload,
  ) async {
    switch (opType) {
      case PendingOp.create:
        final tempId = payload['tempId'] as String?;
        if (await _skipIfCreateAlreadyApplied(tempId, WeeklyPlan.table_name)) {
          return;
        }
        final data = await supabase
            .from(WeeklyPlan.table_name)
            .insert(
              WeeklyPlan.insert(
                id: tempId,
                userId: payload['userId'] as String?,
                weekStart: DateTime.parse(payload['weekStart'] as String),
              ),
            )
            .select()
            .single();
        if (tempId != null) {
          await _recordTempIdMapping(tempId, data['id'].toString());
        }
      default:
        throw StateError('Unknown weekly plan op type: $opType');
    }
  }

  Future<void> _replayShoppingList(
    String opType,
    Map<String, dynamic> payload,
  ) async {
    switch (opType) {
      case PendingOp.create:
        final tempId = payload['tempId'] as String?;
        if (await _skipIfCreateAlreadyApplied(
          tempId,
          ShoppingList.table_name,
        )) {
          return;
        }
        final data = await supabase
            .from(ShoppingList.table_name)
            .insert(
              ShoppingList.insert(
                id: tempId,
                userId: payload['userId'] as String?,
              ),
            )
            .select()
            .single();
        if (tempId != null) {
          await _recordTempIdMapping(tempId, data['id'].toString());
        }
      default:
        throw StateError('Unknown shopping list op type: $opType');
    }
  }

  Future<void> _replayShoppingItem(
    String opType,
    Map<String, dynamic> payload,
  ) async {
    switch (opType) {
      case PendingOp.toggle:
        final id = await cache.resolveIdOrSelf(payload['id'] as String);
        await supabase
            .from(ShoppingItem.table_name)
            .update({ShoppingItem.c_isChecked: payload['isChecked']})
            .eq(ShoppingItem.c_id, id);
      case PendingOp.create:
        final tempId = payload['tempId'] as String?;
        if (await _skipIfCreateAlreadyApplied(
          tempId,
          ShoppingItem.table_name,
        )) {
          return;
        }
        final listId = await cache.resolveIdOrSelf(payload['listId'] as String);
        final data = await supabase
            .from(ShoppingItem.table_name)
            .insert(
              ShoppingItem.insert(
                id: tempId,
                shoppingListId: listId,
                name: payload['name'] as String,
                quantity: payload['quantity'] as num?,
                unit: payload['unit'] as String?,
                category: payload['category'] as String?,
                isManual: true,
              ),
            )
            .select()
            .single();
        if (tempId != null) {
          await _recordTempIdMapping(tempId, data['id'].toString());
        }
      case PendingOp.update:
        final id = await cache.resolveIdOrSelf(payload['id'] as String);
        await supabase
            .from(ShoppingItem.table_name)
            .update(
              ShoppingItem.update(
                name: payload['name'] as String,
                quantity: payload['quantity'] as num?,
                unit: payload['unit'] as String?,
                category: payload['category'] as String?,
              ),
            )
            .eq(ShoppingItem.c_id, id);
      case PendingOp.delete:
        final id = await cache.resolveIdOrSelf(payload['id'] as String);
        await supabase
            .from(ShoppingItem.table_name)
            .delete()
            .eq(ShoppingItem.c_id, id);
      case PendingOp.clear:
        final listId = await cache.resolveIdOrSelf(payload['listId'] as String);
        await supabase
            .from(ShoppingItem.table_name)
            .delete()
            .eq(ShoppingItem.c_shoppingListId, listId);
      default:
        throw StateError('Unknown shopping item op type: $opType');
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref: ref,
    cache: ref.watch(localCacheStoreProvider),
    recipesRepository: ref.watch(recipesRepositoryProvider),
    plannerRepository: ref.watch(plannerRepositoryProvider),
  );
});

/// Watches connectivity and triggers sync when back online (mobile only).
final syncOnReconnectProvider = Provider<void>((ref) {
  if (kIsWeb) return;

  ref.listen(connectivityProvider, (previous, next) {
    final wasOffline =
        previous?.maybeWhen(
          data: isOfflineFromConnectivity,
          orElse: () => false,
        ) ??
        false;
    final isOnline = next.maybeWhen(
      data: (results) => !isOfflineFromConnectivity(results),
      orElse: () => false,
    );

    if (wasOffline && isOnline) {
      ref.read(syncServiceProvider).syncIfOnline();
    }
  });
});
