import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/l10n/app_localizations.dart';
import 'package:meal_planner/core/supabase/models/shopping_list.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/household/presentation/household_provider.dart';
import 'package:meal_planner/features/recipes/domain/ingredient_label.dart';
import 'package:meal_planner/features/recipes/domain/recipe_constants.dart';
import 'package:meal_planner/features/shopping/data/shopping_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final activeShoppingListProvider =
    FutureProvider.autoDispose<ShoppingList>((ref) async {
  ref.watch(currentHouseholdProvider);

  final household = ref.watch(currentHouseholdProvider).valueOrNull;
  final authState = ref.watch(authStateProvider).valueOrNull;
  if (authState is! AuthAuthenticated) {
    throw StateError('User not authenticated');
  }

  return ref.read(shoppingRepositoryProvider).getOrCreateShoppingList(
        userId: authState.user.id,
        householdId: household?.id,
      );
});

final shoppingItemsProvider =
    AsyncNotifierProvider<ShoppingItemsNotifier, List<ShoppingItem>>(
  ShoppingItemsNotifier.new,
);

class ShoppingItemsNotifier extends AsyncNotifier<List<ShoppingItem>> {
  RealtimeChannel? _channel;
  String? _listId;

  ShoppingRepository get _repository => ref.read(shoppingRepositoryProvider);

  @override
  Future<List<ShoppingItem>> build() async {
    ref.watch(authStateProvider);
    ref.watch(currentHouseholdProvider);
    final list = await ref.watch(activeShoppingListProvider.future);

    ref.onDispose(_unsubscribe);

    _subscribeToList(list.id);

    return _repository.getItemsForList(list.id);
  }

  void _subscribeToList(String listId) {
    if (_listId == listId && _channel != null) return;

    _unsubscribe();
    _listId = listId;

    _channel = supabase
        .channel('shopping_items:$listId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'shopping_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'shopping_list_id',
            value: listId,
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
    _listId = null;
  }

  Future<void> _reloadFromServer() async {
    final listId = _listId;
    if (listId == null) return;

    state = await AsyncValue.guard(
      () => _repository.getItemsForList(listId),
    );
  }

  /// Refreshes items. Works both online (from server) and offline (from cache).
  Future<void> reload() async {
    final listId = _listId;
    if (listId == null) {
      ref.invalidateSelf();
      return;
    }

    state = await AsyncValue.guard(
      () => _repository.getItemsForList(listId),
    );
  }

  Future<void> toggleItem(String id, bool isChecked) async {
    final previous = state.valueOrNull ?? const <ShoppingItem>[];
    final itemIds = _consolidatedItemIds(previous, id);
    final household = ref.read(currentHouseholdProvider).valueOrNull;

    state = AsyncData(
      previous.map((item) {
        if (itemIds.contains(item.id)) {
          return item.copyWith(isChecked: isChecked);
        }
        return item;
      }).toList(),
    );

    try {
      await Future.wait(
        itemIds.map(
          (itemId) => _repository.toggleItem(
            itemId,
            isChecked,
            householdId: household?.id,
          ),
        ),
      );
    } catch (_) {
      state = AsyncData(previous);
    }
  }

  Future<void> addManualItem({
    required String name,
    num? quantity,
    String? unit,
    String? category,
  }) async {
    final list = await ref.read(activeShoppingListProvider.future);
    final previous = state.valueOrNull ?? const <ShoppingItem>[];
    final household = ref.read(currentHouseholdProvider).valueOrNull;

    try {
      final created = await _repository.addManualItem(
        listId: list.id,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        householdId: household?.id,
      );
      state = AsyncData([...previous, created]);
    } catch (_) {
      state = AsyncData(previous);
    }
  }

  Future<void> updateItem({
    required String id,
    required String name,
    num? quantity,
    String? unit,
    String? category,
  }) async {
    final previous = state.valueOrNull ?? const <ShoppingItem>[];
    final household = ref.read(currentHouseholdProvider).valueOrNull;

    state = AsyncData(
      previous.map((item) {
        if (item.id == id) {
          return item.copyWith(
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
          );
        }
        return item;
      }).toList(),
    );

    try {
      final updated = await _repository.updateItem(
        id: id,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        householdId: household?.id,
      );
      state = AsyncData(
        previous.map((item) => item.id == id ? updated : item).toList(),
      );
    } catch (_) {
      state = AsyncData(previous);
    }
  }

  Future<void> deleteItem(String id) async {
    final previous = state.valueOrNull ?? const <ShoppingItem>[];
    final itemIds = _consolidatedItemIds(previous, id);
    final household = ref.read(currentHouseholdProvider).valueOrNull;

    state = AsyncData(
      previous.where((item) => !itemIds.contains(item.id)).toList(),
    );

    try {
      await Future.wait(
        itemIds.map(
          (itemId) =>
              _repository.deleteItem(itemId, householdId: household?.id),
        ),
      );
    } catch (_) {
      state = AsyncData(previous);
    }
  }

  Set<String> _consolidatedItemIds(List<ShoppingItem> items, String id) {
    final target = items.where((item) => item.id == id).firstOrNull;
    if (target == null) return {id};

    final key = shoppingItemConsolidationKey(target);
    if (key == null) return {id};

    return {
      for (final item in items)
        if (shoppingItemConsolidationKey(item) == key) item.id,
    };
  }

  Future<void> clearList() async {
    final list = await ref.read(activeShoppingListProvider.future);
    final previous = state.valueOrNull ?? const <ShoppingItem>[];
    final household = ref.read(currentHouseholdProvider).valueOrNull;

    state = const AsyncData([]);

    try {
      await _repository.clearList(list.id, householdId: household?.id);
    } catch (_) {
      state = AsyncData(previous);
    }
  }
}

/// Groups items by category with unchecked first, then checked at the end.
Map<String, List<ShoppingItem>> groupShoppingItemsByCategory(
  List<ShoppingItem> items,
) {
  final grouped = <String, List<ShoppingItem>>{};

  for (final item in consolidateShoppingItems(items)) {
    final category = normalizeCategoryKey(item.category);
    grouped.putIfAbsent(category, () => []).add(item);
  }

  for (final category in grouped.keys) {
    grouped[category]!.sort((a, b) {
      if (a.isChecked != b.isChecked) {
        return a.isChecked ? 1 : -1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  final orderedCategories = ingredientCategories
      .where(grouped.containsKey)
      .toList();

  for (final category in grouped.keys) {
    if (!orderedCategories.contains(category)) {
      orderedCategories.add(category);
    }
  }

  return {for (final category in orderedCategories) category: grouped[category]!};
}

String? shoppingItemConsolidationKey(ShoppingItem item) {
  if (item.isManual || item.quantity == null) return null;

  final normalizedName = item.name.trim().toLowerCase();
  if (normalizedName.isEmpty) return null;

  final normalizedUnit = normalizeUnit(item.unit) ?? '';
  final normalizedCategory = (item.category ?? '').trim().toLowerCase();
  return '$normalizedCategory|$normalizedName|$normalizedUnit|${item.isChecked}';
}

List<ShoppingItem> consolidateShoppingItems(List<ShoppingItem> items) {
  final consolidated = <String, ShoppingItem>{};
  final ungrouped = <ShoppingItem>[];

  for (final item in items) {
    final key = shoppingItemConsolidationKey(item);
    if (key == null) {
      ungrouped.add(item);
      continue;
    }

    final existing = consolidated[key];
    if (existing == null) {
      consolidated[key] = item.copyWith(unit: normalizeUnit(item.unit));
      continue;
    }

    consolidated[key] = existing.copyWith(
      quantity: existing.quantity! + item.quantity!,
    );
  }

  return [...ungrouped, ...consolidated.values];
}

String formatShoppingListForShare(
  AppLocalizations l10n,
  Map<String, List<ShoppingItem>> grouped,
) {
  final buffer = StringBuffer('${l10n.shoppingListTitle}\n\n');

  for (final entry in grouped.entries) {
    buffer.writeln('${localizedCategoryLabel(l10n, entry.key)}:');
    for (final item in entry.value) {
      buffer.writeln('• ${formatShoppingItemLabel(
        l10n,
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
      )}');
    }
    buffer.writeln();
  }

  return buffer.toString().trimRight();
}
