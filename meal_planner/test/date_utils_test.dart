import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meal_planner/core/utils/date_utils.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
    await initializeDateFormatting('en');
  });

  group('startOfIsoWeek', () {
    test('returns Monday for a Wednesday', () {
      final wednesday = DateTime(2026, 8, 12);
      expect(startOfIsoWeek(wednesday), DateTime(2026, 8, 10));
    });

    test('returns the same day when already Monday', () {
      final monday = DateTime(2026, 8, 10);
      expect(startOfIsoWeek(monday), DateTime(2026, 8, 10));
    });
  });

  group('plannerDayDate', () {
    test('maps ISO weekday 1 to week start', () {
      final weekStart = DateTime(2026, 8, 10);
      expect(plannerDayDate(weekStart, 1), DateTime(2026, 8, 10));
    });

    test('maps ISO weekday 7 to Sunday', () {
      final weekStart = DateTime(2026, 8, 10);
      expect(plannerDayDate(weekStart, 7), DateTime(2026, 8, 16));
    });
  });

  group('isPastPlannerDay', () {
    test('is true for a day before today', () {
      expect(
        isPastPlannerDay(
          weekStart: DateTime(2026, 8, 10),
          dayOfWeek: 1,
          now: DateTime(2026, 8, 12),
        ),
        isTrue,
      );
    });

    test('is false for today', () {
      expect(
        isPastPlannerDay(
          weekStart: DateTime(2026, 8, 10),
          dayOfWeek: 3,
          now: DateTime(2026, 8, 12, 18),
        ),
        isFalse,
      );
    });

    test('is false for a future day', () {
      expect(
        isPastPlannerDay(
          weekStart: DateTime(2026, 8, 10),
          dayOfWeek: 7,
          now: DateTime(2026, 8, 12),
        ),
        isFalse,
      );
    });
  });

  group('formatWeekRange', () {
    test('includes start day and end year', () {
      final range = formatWeekRange(DateTime(2026, 8, 10), 'es');
      expect(range, contains('10'));
      expect(range, contains('16'));
      expect(range, contains('2026'));
      expect(range, contains('–'));
    });
  });

  group('formatDayHeader', () {
    test('capitalizes the first letter', () {
      final header = formatDayHeader(DateTime(2026, 8, 10), 'es');
      expect(header, isNotEmpty);
      expect(header[0], header[0].toUpperCase());
    });
  });

  group('formatRecipeCreatedAt', () {
    test('formats a local calendar date', () {
      final formatted = formatRecipeCreatedAt(
        DateTime.utc(2026, 1, 15, 12),
        'en',
      );
      expect(formatted, contains('2026'));
      expect(formatted, contains('15'));
    });
  });
}
