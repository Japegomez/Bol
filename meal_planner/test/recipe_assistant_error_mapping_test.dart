import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/recipes/data/recipe_assistant_repository.dart';

void main() {
  group('recipe assistant error keys', () {
    test('all keys are non-empty and distinct', () {
      final keys = [
        recipeAssistantNotRecipeRequestKey,
        recipeAssistantRateLimitedKey,
        recipeAssistantDailyLimitKey,
        recipeAssistantTooFastKey,
        recipeAssistantServiceAtCapacityKey,
        recipeAssistantFailedKey,
        recipeAssistantOfflineKey,
        recipeAssistantNotConfiguredKey,
        recipeAssistantTimeoutKey,
      ];

      for (final key in keys) {
        expect(key, isNotEmpty, reason: 'Key should not be empty');
      }

      // Each key must be unique — avoids silent fallback to a wrong message.
      expect(keys.toSet().length, equals(keys.length),
          reason: 'All error keys must be distinct');
    });

    test('quota keys are distinct from legacy rate_limited key', () {
      expect(recipeAssistantDailyLimitKey,
          isNot(equals(recipeAssistantRateLimitedKey)));
      expect(recipeAssistantTooFastKey,
          isNot(equals(recipeAssistantRateLimitedKey)));
      expect(recipeAssistantServiceAtCapacityKey,
          isNot(equals(recipeAssistantRateLimitedKey)));
    });

    test('quota keys are distinct from each other', () {
      expect(recipeAssistantDailyLimitKey,
          isNot(equals(recipeAssistantTooFastKey)));
      expect(recipeAssistantDailyLimitKey,
          isNot(equals(recipeAssistantServiceAtCapacityKey)));
      expect(recipeAssistantTooFastKey,
          isNot(equals(recipeAssistantServiceAtCapacityKey)));
    });
  });
}
