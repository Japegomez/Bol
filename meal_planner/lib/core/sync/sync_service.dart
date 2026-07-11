import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/local_db/local_cache_store.dart';
import 'package:meal_planner/core/local_db/local_db_provider.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/core/supabase/models/plan_slot.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
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
    final row =
        await supabase.from(table).select('id').eq('id', id).maybeSingle();
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

    _syncing = true;
    try {
      final ops = await cache.getPendingOperations();
      for (final op in ops) {
        try {
          await _replay(op.entityType, op.opType, op.payloadJson);
          await cache.deletePendingOperation(op.id);
        } catch (error, stackTrace) {
          log.e(
            'Sync replay failed for operation: ${op.entityType}.${op.opType} '
            '(id: ${op.id}, retryCount: ${op.retryCount})',
            error: error,
            stackTrace: stackTrace,
          );

          if (op.retryCount >= maxRetries) {
            log.w(
              'Max retries ($maxRetries) reached for operation: ${op.entityType}.${op.opType} '
              '(id: ${op.id}). Removing from pending queue to prevent infinite retries.',
            );
            await cache.deletePendingOperation(op.id);
          } else {
            await cache.incrementRetry(op.id);
          }
        }
      }

      if (ops.isNotEmpty) {
        ref.invalidate(recipesProvider);
        ref.invalidate(recipeListProvider);
        ref.invalidate(planSlotsProvider);
        ref.invalidate(shoppingItemsProvider);
      }
    } finally {
      _syncing = false;
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
      case PendingEntity.shoppingItem:
        await _replayShoppingItem(opType, payload);
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
        final realId =
            await recipesRepository.createRecipeRemote(form, id: tempId);
        if (tempId != null) {
          await _recordTempIdMapping(tempId, realId);
        }
      case PendingOp.update:
        final recipeId =
            await cache.resolveIdOrSelf(payload['recipeId'] as String);
        final form = RecipeFormDataCodec.fromJson(
          Map<String, dynamic>.from(payload['form'] as Map),
        );
        await recipesRepository.updateRecipeRemote(recipeId, form);
      case PendingOp.delete:
        final recipeId =
            await cache.resolveIdOrSelf(payload['recipeId'] as String);
        await recipesRepository.deleteRecipeRemote(recipeId);
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
        final planId =
            await cache.resolveIdOrSelf(payload['planId'] as String);
        final recipeId = payload['recipeId'] as String?;
        final resolvedRecipeId =
            recipeId != null ? await cache.resolveIdOrSelf(recipeId) : null;
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
        );
        if (tempId != null) {
          await _recordTempIdMapping(tempId, slot.id);
        }
      case PendingOp.remove:
        final slotId =
            await cache.resolveIdOrSelf(payload['slotId'] as String);
        await plannerRepository.removeSlotRemote(slotId);
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
        if (await _skipIfCreateAlreadyApplied(tempId, ShoppingItem.table_name)) {
          return;
        }
        final listId =
            await cache.resolveIdOrSelf(payload['listId'] as String);
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
        final listId =
            await cache.resolveIdOrSelf(payload['listId'] as String);
        await supabase
            .from(ShoppingItem.table_name)
            .delete()
            .eq(ShoppingItem.c_shoppingListId, listId);
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
    final wasOffline = previous?.maybeWhen(
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
