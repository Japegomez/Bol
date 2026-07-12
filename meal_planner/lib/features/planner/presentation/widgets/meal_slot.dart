import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/features/planner/domain/planner_constants.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/planner/presentation/recipe_picker_screen.dart';
import 'package:meal_planner/features/planner/presentation/widgets/servings_dialog.dart';

/// A single meal row (breakfast/lunch/dinner) of a day.
/// Acts as a [DragTarget] so recipes can be dropped from the palette.
class MealSlot extends ConsumerWidget {
  const MealSlot({
    required this.dayOfWeek,
    required this.mealType,
    required this.slots,
    super.key,
  });

  final int dayOfWeek;
  final String mealType;
  final List<SlotItem> slots;

  Future<void> _addRecipe(
    BuildContext context,
    WidgetRef ref,
    Recipe recipe,
  ) async {
    final canEdit = ref.read(canEditOfflineProvider);
    final result = await showServingsDialog(
      context,
      defaultServings: recipe.servings,
      canConfirm: canEdit,
    );
    if (result == null || !context.mounted) return;

    await ref.read(planSlotsProvider.notifier).addSlot(
          dayOfWeek: dayOfWeek,
          mealType: mealType,
          recipeId: recipe.id,
          servings: result.servings,
          recipeTitle: recipe.title,
          isLeftover: result.isLeftover,
        );
  }

  Future<void> _openPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => RecipePickerSheet(
        dayOfWeek: dayOfWeek,
        mealType: mealType,
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    SlotItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitar comida'),
        content: Text(
          '¿Quitar "${item.displayTitle}" del planificador?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(planSlotsProvider.notifier).removeSlot(item.slot.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final canEdit = ref.watch(canEditOfflineProvider);

    return DragTarget<Recipe>(
      onAcceptWithDetails: canEdit
          ? (details) => _addRecipe(context, ref, details.data)
          : null,
      builder: (context, candidate, rejected) {
        final isHovering = candidate.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isHovering
                ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHovering ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    MealType.label(mealType),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
              Expanded(
                child: slots.isEmpty
                    ? _EmptySlot(
                        isHovering: isHovering,
                        onTap: canEdit ? () => _openPicker(context) : null,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...slots.map(
                            (item) => _RecipeChip(
                              item: item,
                              canRemove: canEdit,
                              onOpenRecipe: item.isTextSlot
                                  ? null
                                  : () => context.push(
                                        '/home/recipes/${item.slot.recipeId}',
                                      ),
                              onRemove: () =>
                                  _confirmRemove(context, ref, item),
                            ),
                          ),
                          if (canEdit)
                            _AddMoreButton(onTap: () => _openPicker(context)),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.isHovering, this.onTap});

  final bool isHovering;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 18,
              color: colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              isHovering ? 'Soltar aquí' : 'Arrastra o pulsa',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddMoreButton extends StatelessWidget {
  const _AddMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(Icons.add, size: 16, color: colorScheme.primary),
            const SizedBox(width: 2),
            Text(
              'Añadir',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeChip extends StatelessWidget {
  const _RecipeChip({
    required this.item,
    required this.onRemove,
    this.onOpenRecipe,
    this.canRemove = true,
  });

  final SlotItem item;
  final VoidCallback? onOpenRecipe;
  final VoidCallback onRemove;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isText = item.isTextSlot;
    final isLeftover = !isText && item.slot.isLeftover;
    final isRecipe = onOpenRecipe != null;

    final chipColor = isText
        ? Colors.orange.shade100
        : isLeftover
            ? colorScheme.tertiaryContainer
            : colorScheme.primaryContainer;

    final onChipColor = isText
        ? Colors.orange.shade900
        : isLeftover
            ? colorScheme.onTertiaryContainer
            : colorScheme.onPrimaryContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      constraints: const BoxConstraints(minHeight: 52),
      child: Material(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onOpenRecipe,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                  child: Row(
                    children: [
                      if (isText) ...[
                        Icon(Icons.edit_note, size: 18, color: onChipColor),
                        const SizedBox(width: 8),
                      ] else if (isLeftover) ...[
                        Icon(Icons.replay_rounded, size: 18, color: onChipColor),
                        const SizedBox(width: 8),
                      ] else ...[
                        Icon(Icons.restaurant_menu, size: 18, color: onChipColor),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          item.displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: onChipColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (item.slot.servings > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${item.slot.servings} raciones',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: onChipColor.withValues(alpha: 0.85),
                              ),
                        ),
                      ],
                      if (isRecipe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: onChipColor.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (canRemove)
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: onRemove,
                icon: Icon(Icons.close, size: 18, color: onChipColor),
                tooltip: 'Quitar',
              ),
          ],
        ),
      ),
    );
  }
}
