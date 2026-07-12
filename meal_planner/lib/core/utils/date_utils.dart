import 'package:intl/intl.dart';

DateTime startOfIsoWeek(DateTime date) {
  final weekday = date.weekday;
  return DateTime(date.year, date.month, date.day - (weekday - 1));
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
