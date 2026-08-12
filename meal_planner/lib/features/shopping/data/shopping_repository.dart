import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/local_db/local_cache_store.dart';
import 'package:meal_planner/core/local_db/local_db_provider.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/core/offline/offline_exceptions.dart';
import 'package:meal_planner/core/offline/supabase_error_utils.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/core/supabase/models/shopping_list.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/sync/pending_operation_types.dart';

class ShoppingRepository {
  ShoppingRepository(this._cache);

  final LocalCacheStore _cache;

  Future<void> _guardOfflineMutation({
    String? householdId,
    required bool isOnline,
  }) async {
    if (householdId != null && !isOnline) {
      throw OfflineEditBlockedException();
    }
  }

  Future<ShoppingList> getOrCreateShoppingList({
    required String userId,
    String? householdId,
  }) async {
    if (await NetworkStatus.isOnline) {
      try {
        final list = await _getOrCreateRemote(
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

  Future<ShoppingList> _getOrCreateRemote({
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

  Future<List<ShoppingItem>> getItemsForList(String listId) async {
    if (await NetworkStatus.isOnline) {
      try {
        final data = await supabase
            .from(ShoppingItem.table_name)
            .select()
            .eq(ShoppingItem.c_shoppingListId, listId)
            .order(ShoppingItem.c_isChecked)
            .order(ShoppingItem.c_category)
            .order(ShoppingItem.c_name);

        final items = ShoppingItem.converter(
          (data as List).cast<Map<String, dynamic>>(),
        );
        await _cache.cacheShoppingItems(listId, items);
        return items;
      } catch (error) {
        if (!shouldFallbackToCache(error)) rethrow;
        return _cache.getShoppingItems(listId);
      }
    }

    return _cache.getShoppingItems(listId);
  }

  Future<void> toggleItem(
    String id,
    bool isChecked, {
    String? householdId,
  }) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);

    if (isOnline) {
      await supabase
          .from(ShoppingItem.table_name)
          .update({ShoppingItem.c_isChecked: isChecked})
          .eq(ShoppingItem.c_id, id);

      final items = await _findItemInCache(id);
      if (items != null) {
        await _cache.upsertShoppingItem(items.copyWith(isChecked: isChecked));
      }
      return;
    }

    final existing = await _findItemInCache(id);
    if (existing == null) return;

    await _cache.upsertShoppingItemWithPendingOp(
      item: existing.copyWith(isChecked: isChecked),
      opType: PendingOp.toggle,
      payload: {'id': id, 'isChecked': isChecked},
    );
  }

  Future<ShoppingItem?> _findItemInCache(String id) async {
    // Scan cached lists — items are keyed by id globally.
    return _cache.getShoppingItemById(id);
  }

  Future<ShoppingItem> addManualItem({
    required String listId,
    required String name,
    num? quantity,
    String? unit,
    String? category,
    String? householdId,
  }) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);

    if (isOnline) {
      final data = await supabase
          .from(ShoppingItem.table_name)
          .insert(
            ShoppingItem.insert(
              shoppingListId: listId,
              name: name,
              quantity: quantity,
              unit: unit,
              category: category,
              isManual: true,
            ),
          )
          .select()
          .single();

      final item = ShoppingItem.fromJson(data);
      await _cache.upsertShoppingItem(item);
      return item;
    }

    final tempId = newLocalId();
    final item = ShoppingItem(
      id: tempId,
      shoppingListId: listId,
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      isChecked: false,
      isManual: true,
      createdAt: DateTime.now(),
    );
    await _cache.upsertShoppingItemWithPendingOp(
      item: item,
      opType: PendingOp.create,
      payload: {
        'tempId': tempId,
        'listId': listId,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'category': category,
      },
    );
    return item;
  }

  Future<ShoppingItem> updateItem({
    required String id,
    required String name,
    num? quantity,
    String? unit,
    String? category,
    String? householdId,
  }) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);

    if (isOnline) {
      final data = await supabase
          .from(ShoppingItem.table_name)
          .update(
            ShoppingItem.update(
              name: name,
              quantity: quantity,
              unit: unit,
              category: category,
            ),
          )
          .eq(ShoppingItem.c_id, id)
          .select()
          .single();

      final item = ShoppingItem.fromJson(data);
      await _cache.upsertShoppingItem(item);
      return item;
    }

    final existing = await _findItemInCache(id);
    if (existing == null) {
      throw Exception('Ítem no encontrado');
    }

    final updated = existing.copyWith(
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
    );
    await _cache.upsertShoppingItemWithPendingOp(
      item: updated,
      opType: PendingOp.update,
      payload: {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'category': category,
      },
    );
    return updated;
  }

  Future<void> deleteItem(String id, {String? householdId}) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);

    if (isOnline) {
      await supabase
          .from(ShoppingItem.table_name)
          .delete()
          .eq(ShoppingItem.c_id, id);
      await _cache.deleteShoppingItem(id);
      return;
    }

    await _cache.deleteShoppingItemWithPendingOp(id: id, payload: {'id': id});
  }

  Future<void> clearList(String listId, {String? householdId}) async {
    final isOnline = await NetworkStatus.isOnline;
    await _guardOfflineMutation(householdId: householdId, isOnline: isOnline);

    if (isOnline) {
      await supabase
          .from(ShoppingItem.table_name)
          .delete()
          .eq(ShoppingItem.c_shoppingListId, listId);
      await _cache.clearShoppingItems(listId);
      return;
    }

    await _cache.clearShoppingItemsWithPendingOp(
      listId: listId,
      payload: {'listId': listId},
    );
  }
}

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository(ref.watch(localCacheStoreProvider));
});
