import 'package:intl/intl.dart';

DateTime startOfIsoWeek(DateTime date) {
  final weekday = date.weekday;
  return DateTime(date.year, date.month, date.day - (weekday - 1));
}

/// Calendar date for an ISO weekday (`1` = Monday … `7` = Sunday) in [weekStart].
DateTime plannerDayDate(DateTime weekStart, int dayOfWeek) {
  final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
  return start.add(Duration(days: dayOfWeek - 1));
}

/// True when the planner cell's calendar day is before local today.
bool isPastPlannerDay({
  required DateTime weekStart,
  required int dayOfWeek,
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  return plannerDayDate(weekStart, dayOfWeek).isBefore(today);
}

String formatWeekRange(DateTime weekStart, String localeName) {
  final weekEnd = weekStart.add(const Duration(days: 6));
  final dayFmt = DateFormat('d MMM', localeName);
  final yearFmt = DateFormat('d MMM yyyy', localeName);
  return '${dayFmt.format(weekStart)} – ${yearFmt.format(weekEnd)}';
}

String formatDayHeader(DateTime date, String localeName) {
  final formatted = DateFormat('EEEE d', localeName).format(date);
  if (formatted.isEmpty) return formatted;
  return formatted[0].toUpperCase() + formatted.substring(1);
}

String formatRecipeCreatedAt(DateTime date, String localeName) {
  return DateFormat('d MMM yyyy', localeName).format(date.toLocal());
}
