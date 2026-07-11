import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/local_db/local_cache_store.dart';
import 'package:meal_planner/core/local_db/local_db_provider.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/core/sync/pending_operation_types.dart';
import 'package:meal_planner/core/sync/recipe_form_data_codec.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/connectivity/connectivity_notifier.dart';
import 'package:meal_planner/features/planner/data/planner_repository.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/recipes/data/recipes_repository.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/shopping/presentation/shopping_provider.dart';

class SyncService {
  SyncService({
    required this.ref,
    required LocalCacheStore cache,
    required RecipesRepository recipesRepository,
    required PlannerRepository plannerRepository,
  })  : _cache = cache,
        _recipesRepository = recipesRepository,
        _plannerRepository = plannerRepository;

  final Ref ref;
  final LocalCacheStore _cache;
  final RecipesRepository _recipesRepository;
  final PlannerRepository _plannerRepository;

  bool _syncing = false;

  Future<void> syncIfOnline() async {
    if (_syncing) return;
    if (!await NetworkStatus.isOnline) return;

    _syncing = true;
    try {
      final ops = await _cache.getPendingOperations();
      for (final op in ops) {
        try {
          await _replay(op.entityType, op.opType, op.payloadJson);
          await _cache.deletePendingOperation(op.id);
        } catch (_) {
          await _cache.incrementRetry(op.id);
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
    final tempId = payload['tempId'] as String?;
    switch (opType) {
      case PendingOp.create:
        final form = RecipeFormDataCodec.fromJson(
          Map<String, dynamic>.from(payload['form'] as Map),
        );
        final realId = await _recipesRepository.createRecipeRemote(form);
        if (tempId != null) {
          await _cache.replaceTempId(tempId, realId);
        }
      case PendingOp.update:
        final recipeId =
            await _cache.resolveIdOrSelf(payload['recipeId'] as String);
        final form = RecipeFormDataCodec.fromJson(
          Map<String, dynamic>.from(payload['form'] as Map),
        );
        await _recipesRepository.updateRecipeRemote(recipeId, form);
      case PendingOp.delete:
        final recipeId =
            await _cache.resolveIdOrSelf(payload['recipeId'] as String);
        await _recipesRepository.deleteRecipeRemote(recipeId);
    }
  }

  Future<void> _replayPlanSlot(
    String opType,
    Map<String, dynamic> payload,
  ) async {
    switch (opType) {
      case PendingOp.add:
        final planId =
            await _cache.resolveIdOrSelf(payload['planId'] as String);
        final recipeId = payload['recipeId'] as String?;
        final resolvedRecipeId =
            recipeId != null ? await _cache.resolveIdOrSelf(recipeId) : null;
        final slot = await _plannerRepository.addSlotRemote(
          planId: planId,
          dayOfWeek: payload['dayOfWeek'] as int,
          mealType: payload['mealType'] as String,
          recipeId: resolvedRecipeId,
          servings: payload['servings'] as int,
          userId: payload['userId'] as String,
          householdId: payload['householdId'] as String?,
          isLeftover: payload['isLeftover'] as bool? ?? false,
          notes: payload['notes'] as String?,
        );
        final tempId = payload['tempId'] as String?;
        if (tempId != null) {
          await _cache.replaceTempId(tempId, slot.id);
        }
      case PendingOp.remove:
        final slotId =
            await _cache.resolveIdOrSelf(payload['slotId'] as String);
        await _plannerRepository.removeSlotRemote(slotId);
    }
  }

  Future<void> _replayShoppingItem(
    String opType,
    Map<String, dynamic> payload,
  ) async {
    switch (opType) {
      case PendingOp.toggle:
        final id = await _cache.resolveIdOrSelf(payload['id'] as String);
        await supabase
            .from(ShoppingItem.table_name)
            .update({ShoppingItem.c_isChecked: payload['isChecked']})
            .eq(ShoppingItem.c_id, id);
      case PendingOp.create:
        final listId =
            await _cache.resolveIdOrSelf(payload['listId'] as String);
        final data = await supabase
            .from(ShoppingItem.table_name)
            .insert(
              ShoppingItem.insert(
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
        final tempId = payload['tempId'] as String?;
        if (tempId != null) {
          await _cache.replaceTempId(tempId, data['id'].toString());
        }
      case PendingOp.update:
        final id = await _cache.resolveIdOrSelf(payload['id'] as String);
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
        final id = await _cache.resolveIdOrSelf(payload['id'] as String);
        await supabase
            .from(ShoppingItem.table_name)
            .delete()
            .eq(ShoppingItem.c_id, id);
      case PendingOp.clear:
        final listId =
            await _cache.resolveIdOrSelf(payload['listId'] as String);
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

/// Watches connectivity and triggers sync when back online.
final syncOnReconnectProvider = Provider<void>((ref) {
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
