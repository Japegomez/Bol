import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_utils.dart';

CookingSession _session({
  int currentStepIndex = 0,
  DateTime? startedAt,
  DateTime? pausedAt,
  int accumulatedPauseMs = 0,
  List<RecipeStep>? steps,
}) {
  return CookingSession(
    recipeId: 'r1',
    recipeTitle: 'Tortilla',
    ingredients: const [
      Ingredient(
        id: 'i1',
        recipeId: 'r1',
        name: 'Huevo',
        quantity: 3,
        unit: 'unidad',
        position: 0,
      ),
    ],
    steps:
        steps ??
        const [
          RecipeStep(
            id: 's1',
            recipeId: 'r1',
            position: 0,
            description: 'Batir',
          ),
          RecipeStep(
            id: 's2',
            recipeId: 'r1',
            position: 1,
            description: 'Freír',
          ),
        ],
    currentStepIndex: currentStepIndex,
    startedAt: startedAt ?? DateTime(2026, 8, 13, 12),
    pausedAt: pausedAt,
    accumulatedPauseMs: accumulatedPauseMs,
  );
}

void main() {
  group('CookingSession', () {
    test('counts the synthetic ingredients step', () {
      final session = _session();
      expect(session.totalSteps, 3);
      expect(session.isOnLastStep, isFalse);
      expect(_session(currentStepIndex: 2).isOnLastStep, isTrue);
    });

    test('is paused when pausedAt is set', () {
      expect(_session().isPaused, isFalse);
      expect(_session(pausedAt: DateTime(2026, 8, 13, 12, 5)).isPaused, isTrue);
    });

    test('elapsed ignores accumulated pause while running', () {
      final started = DateTime(2026, 8, 13, 12);
      final session = _session(
        startedAt: started,
        pausedAt: started.add(const Duration(minutes: 10)),
        accumulatedPauseMs: 60 * 1000,
      );
      expect(session.elapsed, const Duration(minutes: 9));
    });

    test('copyWith can clear the pause', () {
      final paused = _session(pausedAt: DateTime(2026, 8, 13, 12, 5));
      expect(paused.copyWith(clearPausedAt: true).pausedAt, isNull);
    });

    test('round-trips JSON including pause and completed steps', () {
      final original = _session(
        currentStepIndex: 1,
        pausedAt: DateTime(2026, 8, 13, 12, 8),
        accumulatedPauseMs: 1500,
      ).copyWith(completedSteps: {0, 1}, isExpanded: false);

      final restored = CookingSession.fromJsonString(original.toJsonString());

      expect(restored.recipeTitle, 'Tortilla');
      expect(restored.currentStepIndex, 1);
      expect(restored.pausedAt, original.pausedAt);
      expect(restored.accumulatedPauseMs, 1500);
      expect(restored.isExpanded, isFalse);
      expect(restored.completedSteps, {0, 1});
      expect(restored.ingredients.single.name, 'Huevo');
      expect(restored.steps, hasLength(2));
    });

    test('rejects an out-of-range currentStepIndex', () {
      final json = _session().toJson()..['currentStepIndex'] = 9;
      expect(() => CookingSession.fromJson(json), throwsFormatException);
    });
  });

  group('formatCookingDuration', () {
    test('formats minutes and seconds', () {
      expect(
        formatCookingDuration(const Duration(minutes: 3, seconds: 7)),
        '03:07',
      );
    });

    test('includes hours when needed', () {
      expect(
        formatCookingDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });
  });
}
