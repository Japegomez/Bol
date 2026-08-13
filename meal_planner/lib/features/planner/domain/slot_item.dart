import 'package:meal_planner/core/supabase/models/plan_slot.dart';

class SlotItem {
  const SlotItem({required this.slot, this.recipeTitle});

  final PlanSlot slot;
  final String? recipeTitle;

  /// True when the slot has no recipe (free-text entry).
  bool get isTextSlot => slot.recipeId == null;

  /// Label shown in the planner chip.
  String get displayTitle => recipeTitle ?? slot.notes ?? 'Receta';

  factory SlotItem.fromJson(Map<String, dynamic> json) {
    final recipeJson = json['recipes'];
    String? title;
    if (recipeJson is Map<String, dynamic>) {
      title = recipeJson['title'] as String?;
    }

    return SlotItem(slot: PlanSlot.fromJson(json), recipeTitle: title);
  }
}
