import 'package:intl/intl.dart';

DateTime startOfIsoWeek(DateTime date) {
  final weekday = date.weekday;
  return DateTime(date.year, date.month, date.day - (weekday - 1));
}

String formatWeekRange(DateTime weekStart) {
  final weekEnd = weekStart.add(const Duration(days: 6));
  final dayFmt = DateFormat('d MMM', 'es');
  final yearFmt = DateFormat('d MMM yyyy', 'es');
  return '${dayFmt.format(weekStart)} – ${yearFmt.format(weekEnd)}';
}

String formatDayHeader(DateTime date) {
  final formatted = DateFormat('EEEE d', 'es').format(date);
  if (formatted.isEmpty) return formatted;
  return formatted[0].toUpperCase() + formatted.substring(1);
}

String formatRecipeCreatedAt(DateTime date) {
  return DateFormat('d MMM yyyy', 'es').format(date.toLocal());
}
