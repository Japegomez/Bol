import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';

/// Drag payload for planner drop targets (palette recipes or assigned meals).
sealed class PlannerDragPayload {
  const PlannerDragPayload();
}

/// A recipe dragged from the side palette to create a new slot assignment.
final class PlannerRecipeDrag extends PlannerDragPayload {
  const PlannerRecipeDrag(this.recipe);

  final Recipe recipe;
}

/// An existing planner slot being moved to another day or meal.
final class PlannerSlotDrag extends PlannerDragPayload {
  const PlannerSlotDrag(this.item);

  final SlotItem item;
}
