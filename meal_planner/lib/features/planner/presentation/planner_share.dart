import 'package:meal_planner/core/utils/date_utils.dart';
import 'package:meal_planner/features/planner/domain/planner_constants.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

/// Builds a plain-text weekly plan for copy/share (same idea as shopping list).
String formatWeeklyPlanForShare({
  required AppLocalizations l10n,
  required DateTime weekStart,
  required String localeName,
  required List<SlotItem> slots,
}) {
  if (slots.isEmpty) return l10n.plannerTitle;

  final buffer = StringBuffer()
    ..writeln(l10n.plannerTitle)
    ..writeln(formatWeekRange(weekStart, localeName))
    ..writeln();

  for (var day = 1; day <= 7; day++) {
    final daySlots =
        slots.where((item) => item.slot.dayOfWeek == day).toList();
    if (daySlots.isEmpty) continue;

    final date = weekStart.add(Duration(days: day - 1));
    buffer.writeln(formatDayHeader(date, localeName));

    for (final mealType in MealType.all) {
      final cellSlots = daySlots
          .where((item) => item.slot.mealType == mealType)
          .toList()
        ..sort((a, b) => a.slot.position.compareTo(b.slot.position));
      if (cellSlots.isEmpty) continue;

      buffer.writeln('${MealType.label(l10n, mealType)}:');
      for (final item in cellSlots) {
        buffer.writeln('• ${formatPlannerSlotLine(l10n, item)}');
      }
      buffer.writeln();
    }
  }

  return buffer.toString().trimRight();
}

String formatPlannerSlotLine(AppLocalizations l10n, SlotItem item) {
  final title = item.displayTitle;
  if (item.slot.isLeftover) {
    return '$title (${l10n.plannerShareLeftoverLabel})';
  }
  return title;
}

bool weeklyPlanHasMeals(List<SlotItem> slots) => slots.isNotEmpty;
