import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/features/shopping/presentation/shopping_provider.dart';
import 'package:meal_planner/features/shopping/presentation/widgets/add_edit_item_sheet.dart';
import 'package:meal_planner/features/shopping/presentation/widgets/shopping_item_tile.dart';
import 'package:share_plus/share_plus.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  Future<void> _confirmClearList(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar lista'),
        content: const Text(
          '¿Eliminar todos los ítems de la lista de la compra?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpiar'),
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
    final text = formatShoppingListForShare(grouped);

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
    final itemsAsync = ref.watch(shoppingItemsProvider);
    final canEdit = ref.watch(canEditOfflineProvider);
    final items = itemsAsync.valueOrNull ?? const <ShoppingItem>[];
    final grouped = groupShoppingItemsByCategory(items);
    final isEmpty = items.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de la compra'),
        actions: [
          IconButton(
            onPressed: isEmpty ? null : () => _shareList(context, items),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Compartir lista',
          ),
          IconButton(
            onPressed: isEmpty || !canEdit
                ? null
                : () => _confirmClearList(context, ref),
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpiar lista',
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudo cargar la lista: $error'),
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
                      'Tu lista está vacía',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Añade recetas al planificador o ítems manualmente con el botón +.',
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
                    entry.key,
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
        tooltip: 'Añadir ítem',
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
