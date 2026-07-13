import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/features/shopping/presentation/shopping_provider.dart';
import 'package:meal_planner/features/shopping/presentation/widgets/add_edit_item_sheet.dart';
import 'package:meal_planner/features/shopping/presentation/widgets/shopping_item_tile.dart';
import 'package:share_plus/share_plus.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  Future<void> _confirmClearList(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearListTitle),
        content: Text(l10n.clearListConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(shoppingItemsProvider.notifier).clearList();
    }
  }

  Future<void> _shareList(
    BuildContext context,
    List<ShoppingItem> items,
  ) async {
    if (items.isEmpty) return;

    final grouped = groupShoppingItemsByCategory(items);
    final text = formatShoppingListForShare(context.l10n, grouped);

    // iOS (especially iPad) requires an anchor rect for the share sheet.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : const Rect.fromLTWH(0, 0, 1, 1);

    await Share.share(text, sharePositionOrigin: origin);
  }

  Future<void> _openAddSheet(
    BuildContext context,
    WidgetRef ref, {
    required bool canEdit,
  }) async {
    final data = await AddEditItemSheet.show(context, canSave: canEdit);
    if (data == null) return;

    await ref.read(shoppingItemsProvider.notifier).addManualItem(
          name: data['name'] as String,
          quantity: data['quantity'] as num?,
          unit: data['unit'] as String?,
          category: data['category'] as String?,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final itemsAsync = ref.watch(shoppingItemsProvider);
    final canEdit = ref.watch(canEditOfflineProvider);
    final items = itemsAsync.valueOrNull ?? const <ShoppingItem>[];
    final grouped = groupShoppingItemsByCategory(items);
    final isEmpty = items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shoppingListTitle),
        actions: [
          IconButton(
            onPressed: isEmpty ? null : () => _shareList(context, items),
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.shareListTooltip,
          ),
          IconButton(
            onPressed: isEmpty || !canEdit
                ? null
                : () => _confirmClearList(context, ref),
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: l10n.clearListTooltip,
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.shoppingListLoadError(error.toString())),
          ),
        ),
        data: (_) {
          if (isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.shoppingListEmpty,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.shoppingListEmptyHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    localizedCategoryLabel(l10n, entry.key),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                for (final item in entry.value)
                  ShoppingItemTile(
                    item: item,
                    canEdit: canEdit,
                    canEditDetails: !_isConsolidated(items, item),
                    onToggle: (checked) => ref
                        .read(shoppingItemsProvider.notifier)
                        .toggleItem(item.id, checked),
                    onEdit: (data) => ref
                        .read(shoppingItemsProvider.notifier)
                        .updateItem(
                          id: item.id,
                          name: data['name'] as String,
                          quantity: data['quantity'] as num?,
                          unit: data['unit'] as String?,
                          category: data['category'] as String?,
                        ),
                    onDelete: () => ref
                        .read(shoppingItemsProvider.notifier)
                        .deleteItem(item.id),
                  ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: canEdit ? () => _openAddSheet(context, ref, canEdit: canEdit) : null,
        tooltip: l10n.addItemTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}

bool _isConsolidated(List<ShoppingItem> items, ShoppingItem item) {
  final key = shoppingItemConsolidationKey(item);
  if (key == null) return false;

  return items
          .where((source) => shoppingItemConsolidationKey(source) == key)
          .length >
      1;
}
