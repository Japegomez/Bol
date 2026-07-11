import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/features/recipes/domain/ingredient_label.dart';
import 'package:meal_planner/features/shopping/presentation/widgets/add_edit_item_sheet.dart';

class ShoppingItemTile extends StatelessWidget {
  const ShoppingItemTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.canEdit = true,
    super.key,
  });

  final ShoppingItem item;
  final ValueChanged<bool> onToggle;
  final Future<void> Function(Map<String, dynamic> data) onEdit;
  final VoidCallback onDelete;
  final bool canEdit;

  String get _label => formatShoppingItemLabel(
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
      );

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ítem'),
        content: Text('¿Eliminar «${item.name}» de la lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete();
    }
  }

  Future<void> _openEdit(BuildContext context) async {
    final data = await AddEditItemSheet.show(
      context,
      item: item,
      canSave: canEdit,
    );
    if (data != null) {
      await onEdit(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          decoration: item.isChecked ? TextDecoration.lineThrough : null,
          color: item.isChecked ? colorScheme.outline : null,
        );

    return Slidable(
      key: ValueKey(item.id),
      startActionPane: canEdit
          ? ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _openEdit(context),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  icon: Icons.edit_outlined,
                  label: 'Editar',
                ),
              ],
            )
          : null,
      endActionPane: canEdit
          ? ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => _confirmDelete(context),
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  icon: Icons.delete_outline,
                  label: 'Eliminar',
                ),
              ],
            )
          : null,
      child: ListTile(
        leading: Checkbox(
          value: item.isChecked,
          onChanged: canEdit
              ? (value) {
                  if (value != null) onToggle(value);
                }
              : null,
        ),
        title: Text(_label, style: textStyle),
        onTap: canEdit ? () => onToggle(!item.isChecked) : null,
        onLongPress: canEdit ? () => _openEdit(context) : null,
      ),
    );
  }
}
