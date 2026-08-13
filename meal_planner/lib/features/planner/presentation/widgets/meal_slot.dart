import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/utils/date_utils.dart';
import 'package:meal_planner/features/planner/domain/planner_constants.dart';
import 'package:meal_planner/features/planner/domain/planner_drag_payload.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/planner/presentation/recipe_picker_screen.dart';
import 'package:meal_planner/features/planner/presentation/widgets/past_meal_dialog.dart';
import 'package:meal_planner/features/planner/presentation/widgets/servings_dialog.dart';

/// A single meal row (breakfast/lunch/dinner) of a day.
class MealSlot extends ConsumerStatefulWidget {
  const MealSlot({
    required this.dayOfWeek,
    required this.mealType,
    required this.slots,
    this.onDragUpdate,
    this.onDragEnd,
    super.key,
  });

  final int dayOfWeek;
  final String mealType;
  final List<SlotItem> slots;
  final void Function(Offset globalPosition)? onDragUpdate;
  final VoidCallback? onDragEnd;

  @override
  ConsumerState<MealSlot> createState() => _MealSlotState();
}

class _MealSlotState extends ConsumerState<MealSlot> {
  bool _isHovering = false;

  bool get _isPastDay {
    final weekStart = ref.read(currentWeekProvider);
    return isPastPlannerDay(weekStart: weekStart, dayOfWeek: widget.dayOfWeek);
  }

  Future<void> _addRecipe(BuildContext context, Recipe recipe) async {
    final canEdit = ref.read(canEditOfflineProvider);
    final result = await showServingsDialog(
      context,
      defaultServings: recipe.servings,
      canConfirm: canEdit,
    );
    if (result == null || !context.mounted) return;

    final skipShopping = _isPastDay;
    if (skipShopping) {
      await showPastMealPlanDialog(context);
      if (!context.mounted) return;
    }

    await ref
        .read(planSlotsProvider.notifier)
        .addSlot(
          dayOfWeek: widget.dayOfWeek,
          mealType: widget.mealType,
          recipeId: recipe.id,
          servings: result.servings,
          recipeTitle: recipe.title,
          isLeftover: false,
          skipShopping: skipShopping,
        );
  }

  Future<void> _moveSlot(SlotItem item) async {
    final weekStart = ref.read(currentWeekProvider);
    final sourceIsPast = isPastPlannerDay(
      weekStart: weekStart,
      dayOfWeek: item.slot.dayOfWeek,
    );
    final destinationIsPast = _isPastDay;

    if (destinationIsPast && !sourceIsPast) {
      if (!mounted) return;
      await showPastMealPlanDialog(context);
      if (!mounted) return;
    }

    await ref
        .read(planSlotsProvider.notifier)
        .moveSlot(
          slotId: item.slot.id,
          dayOfWeek: widget.dayOfWeek,
          mealType: widget.mealType,
          sourceIsPast: sourceIsPast,
          destinationIsPast: destinationIsPast,
        );
  }

  Future<void> _openPicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => RecipePickerSheet(
        dayOfWeek: widget.dayOfWeek,
        mealType: widget.mealType,
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, SlotItem item) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeMealTitle),
        content: Text(l10n.removeMealConfirm(item.displayTitle)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(planSlotsProvider.notifier).removeSlot(item.slot.id);
    }
  }

  void _handleDrop(BuildContext context, PlannerDragPayload payload) {
    switch (payload) {
      case PlannerRecipeDrag(:final recipe):
        _addRecipe(context, recipe);
      case PlannerSlotDrag(:final item):
        _moveSlot(item);
    }
  }

  bool _willAccept(PlannerDragPayload payload) {
    return switch (payload) {
      PlannerRecipeDrag() => true,
      PlannerSlotDrag(:final item) =>
        item.slot.dayOfWeek != widget.dayOfWeek ||
            item.slot.mealType != widget.mealType,
    };
  }

  void _finishDrag() {
    ref.read(plannerDragActiveProvider.notifier).state = false;
    widget.onDragEnd?.call();
  }

  void _setHovering(bool hovering) {
    if (_isHovering == hovering) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isHovering != hovering) {
        setState(() => _isHovering = hovering);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canEdit = ref.watch(canEditOfflineProvider);
    final dragActive = ref.watch(plannerDragActiveProvider);
    final labelColor = _isHovering
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  MealType.label(context.l10n, widget.mealType),
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: labelColor,
                    fontWeight: _isHovering ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.slots.isEmpty)
                        _EmptySlot(
                          onTap: canEdit ? () => _openPicker(context) : null,
                        )
                      else ...[
                        ...widget.slots.map(
                          (item) => _RecipeChip(
                            item: item,
                            canRemove: canEdit,
                            canDrag: canEdit,
                            onDragStart: () =>
                                ref
                                        .read(
                                          plannerDragActiveProvider.notifier,
                                        )
                                        .state =
                                    true,
                            onDragUpdate: widget.onDragUpdate,
                            onDragEnd: _finishDrag,
                            onOpenRecipe: item.isTextSlot
                                ? null
                                : () => context.push(
                                    '/home/recipes/${item.slot.recipeId}',
                                  ),
                            onRemove: () => _confirmRemove(context, item),
                          ),
                        ),
                        if (canEdit)
                          _AddMoreButton(onTap: () => _openPicker(context)),
                      ],
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !dragActive,
                    child: DragTarget<PlannerDragPayload>(
                      onWillAcceptWithDetails: canEdit
                          ? (details) => _willAccept(details.data)
                          : null,
                      onAcceptWithDetails: canEdit
                          ? (details) => _handleDrop(context, details.data)
                          : null,
                      onLeave: (_) => _setHovering(false),
                      builder: (context, candidate, rejected) {
                        final isHovering = candidate.isNotEmpty;
                        _setHovering(isHovering);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          decoration: BoxDecoration(
                            color: isHovering
                                ? colorScheme.primaryContainer.withValues(
                                    alpha: 0.5,
                                  )
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isHovering
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(Icons.add, size: 18, color: colorScheme.outline),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                l10n.dragOrTap,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
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
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(
          children: [
            Icon(Icons.add, size: 16, color: colorScheme.primary),
            const SizedBox(width: 2),
            Text(
              context.l10n.add,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colorScheme.primary),
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
    this.canDrag = false,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  final SlotItem item;
  final VoidCallback? onOpenRecipe;
  final VoidCallback onRemove;
  final bool canRemove;
  final bool canDrag;
  final VoidCallback? onDragStart;
  final void Function(Offset globalPosition)? onDragUpdate;
  final VoidCallback? onDragEnd;

  @override
  Widget build(BuildContext context) {
    final chip = _RecipeChipBody(
      item: item,
      onOpenRecipe: onOpenRecipe,
      onRemove: onRemove,
      canRemove: canRemove,
      showDragHandle: canDrag,
    );

    if (!canDrag) return chip;

    return Draggable<PlannerDragPayload>(
      data: PlannerSlotDrag(item),
      rootOverlay: true,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      maxSimultaneousDrags: 1,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.72,
          ),
          child: _RecipeChipBody(
            item: item,
            onOpenRecipe: null,
            onRemove: () {},
            canRemove: false,
            showDragHandle: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: chip),
      onDragStarted: onDragStart,
      onDragUpdate: onDragUpdate == null
          ? null
          : (details) => onDragUpdate!(details.globalPosition),
      onDragEnd: (_) => onDragEnd?.call(),
      onDraggableCanceled: (_, _) => onDragEnd?.call(),
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: chip),
    );
  }
}

class _RecipeChipBody extends StatelessWidget {
  const _RecipeChipBody({
    required this.item,
    required this.onRemove,
    this.onOpenRecipe,
    this.canRemove = true,
    this.showDragHandle = false,
  });

  final SlotItem item;
  final VoidCallback? onOpenRecipe;
  final VoidCallback onRemove;
  final bool canRemove;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final isText = item.isTextSlot;
    final isLeftover = !isText && item.slot.isLeftover;
    final isRecipe = onOpenRecipe != null;
    final chipColor = _chipBackgroundColor(colorScheme, item);
    final onChipColor = _chipForegroundColor(colorScheme, item);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      constraints: const BoxConstraints(minHeight: 52),
      child: Material(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.drag_indicator,
                  size: 20,
                  color: onChipColor.withValues(alpha: 0.7),
                ),
              ),
            Expanded(
              child: InkWell(
                onTap: onOpenRecipe,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    showDragHandle ? 4 : 12,
                    10,
                    8,
                    10,
                  ),
                  child: Row(
                    children: [
                      if (isText) ...[
                        Icon(Icons.edit_note, size: 18, color: onChipColor),
                        const SizedBox(width: 8),
                      ] else if (isLeftover) ...[
                        Icon(
                          Icons.replay_rounded,
                          size: 18,
                          color: onChipColor,
                        ),
                        const SizedBox(width: 8),
                      ] else ...[
                        Icon(
                          Icons.restaurant_menu,
                          size: 18,
                          color: onChipColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          item.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: onChipColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (item.slot.servings > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          l10n.servingsCountShort(item.slot.servings),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
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
                tooltip: l10n.remove,
              ),
          ],
        ),
      ),
    );
  }
}

Color _chipBackgroundColor(ColorScheme colorScheme, SlotItem item) {
  if (item.isTextSlot) return Colors.orange.shade100;
  if (item.slot.isLeftover) return colorScheme.tertiaryContainer;
  return colorScheme.primaryContainer;
}

Color _chipForegroundColor(ColorScheme colorScheme, SlotItem item) {
  if (item.isTextSlot) return Colors.orange.shade900;
  if (item.slot.isLeftover) return colorScheme.onTertiaryContainer;
  return colorScheme.onPrimaryContainer;
}
