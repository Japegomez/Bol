import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meal_planner/core/supabase/models/plan_slot.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';
import 'package:meal_planner/features/planner/presentation/planner_share.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  group('formatPlannerSlotLine', () {
    test('marks leftovers only', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(
        formatPlannerSlotLine(
          l10n,
          const SlotItem(
            slot: PlanSlot(
              id: '1',
              planId: 'plan',
              dayOfWeek: 1,
              mealType: 'lunch',
              recipeId: 'r1',
              servings: 4,
              position: 0,
            ),
            recipeTitle: 'Lentejas',
          ),
        ),
        'Lentejas',
      );

      expect(
        formatPlannerSlotLine(
          l10n,
          const SlotItem(
            slot: PlanSlot(
              id: '2',
              planId: 'plan',
              dayOfWeek: 2,
              mealType: 'dinner',
              recipeId: 'r2',
              servings: 2,
              position: 0,
              isLeftover: true,
            ),
            recipeTitle: 'Pasta',
          ),
        ),
        'Pasta (sobras)',
      );
    });
  });

  group('formatWeeklyPlanForShare', () {
    test('empty slots returns planner title only', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      expect(
        formatWeeklyPlanForShare(
          l10n: l10n,
          weekStart: DateTime(2026, 7, 27),
          localeName: 'es',
          slots: const [],
        ),
        l10n.plannerTitle,
      );
    });

    test('groups by meal type and orders by position', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      final text = formatWeeklyPlanForShare(
        l10n: l10n,
        weekStart: DateTime(2026, 7, 27),
        localeName: 'es',
        slots: const [
          SlotItem(
            slot: PlanSlot(
              id: 'b',
              planId: 'plan',
              dayOfWeek: 1,
              mealType: 'lunch',
              recipeId: 'r2',
              servings: 2,
              position: 1,
            ),
            recipeTitle: 'Segundo',
          ),
          SlotItem(
            slot: PlanSlot(
              id: 'a',
              planId: 'plan',
              dayOfWeek: 1,
              mealType: 'lunch',
              recipeId: 'r1',
              servings: 2,
              position: 0,
            ),
            recipeTitle: 'Primero',
          ),
        ],
      );

      expect(text, contains('Primero'));
      expect(text, contains('Segundo'));
      expect(text.indexOf('Primero'), lessThan(text.indexOf('Segundo')));
      expect(text, isNot(endsWith('\n')));
    });
  });
}
