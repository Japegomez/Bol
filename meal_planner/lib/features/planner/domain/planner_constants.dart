import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

abstract final class MealType {
  static const breakfast = 'breakfast';
  static const lunch = 'lunch';
  static const dinner = 'dinner';

  static const all = [breakfast, lunch, dinner];

  static String label(AppLocalizations l10n, String mealType) =>
      mealTypeLabel(l10n, mealType);
}

abstract final class DayOfWeek {
  static List<String> labels(AppLocalizations l10n) => dayAbbreviations(l10n);
}
