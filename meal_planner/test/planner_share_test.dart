import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/supabase/models/plan_slot.dart';
import 'package:meal_planner/features/planner/domain/slot_item.dart';
import 'package:meal_planner/features/planner/presentation/planner_share.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('formatPlannerSlotLine', () {
    test('marks leftovers only', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      expect(
        formatPlannerSlotLine(
          l10n,
          SlotItem(
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
          SlotItem(
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
}
