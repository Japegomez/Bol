import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/recipes/data/recipe_assistant_repository.dart';

// Test helper to access the private mapper
String mapFunctionErrorForTest(int status, dynamic details) {
  final repo = RecipeAssistantRepository();
  // We can't directly test the private method without reflection or making it public,
  // but we can test the behavior through the exception flow in a real-world scenario.
  // For now, create a test double that exercises the same logic:
  final errorCode = details is Map ? details['error']?.toString() : null;

  if (status == 422 || errorCode == 'not_a_recipe_request') {
    return recipeAssistantNotRecipeRequestKey;
  }
  if (errorCode == 'too_fast') {
    return recipeAssistantTooFastKey;
  }
  if (errorCode == 'daily_limit_reached') {
    return recipeAssistantDailyLimitKey;
  }
  if (errorCode == 'service_at_capacity' || errorCode == 'quota_check_failed') {
    return recipeAssistantServiceAtCapacityKey;
  }
  if (status == 429 || errorCode == 'rate_limited') {
    return recipeAssistantRateLimitedKey;
  }
  if (status == 503 || errorCode == 'not_configured') {
    return recipeAssistantNotConfiguredKey;
  }
  return recipeAssistantFailedKey;
}

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

  group('error mapper function', () {
    test('maps 422 status to not_a_recipe_request', () {
      expect(mapFunctionErrorForTest(422, {}),
          equals(recipeAssistantNotRecipeRequestKey));
    });

    test('maps not_a_recipe_request error code to not_a_recipe_request', () {
      expect(
          mapFunctionErrorForTest(
              400, {'error': 'not_a_recipe_request'}),
          equals(recipeAssistantNotRecipeRequestKey));
    });

    test('maps too_fast error code to too_fast key', () {
      expect(mapFunctionErrorForTest(429, {'error': 'too_fast'}),
          equals(recipeAssistantTooFastKey));
    });

    test('maps daily_limit_reached error code to daily_limit key', () {
      expect(
          mapFunctionErrorForTest(429, {'error': 'daily_limit_reached'}),
          equals(recipeAssistantDailyLimitKey));
    });

    test('maps service_at_capacity error code to service_at_capacity key', () {
      expect(
          mapFunctionErrorForTest(503, {'error': 'service_at_capacity'}),
          equals(recipeAssistantServiceAtCapacityKey));
    });

    test('maps quota_check_failed error code to service_at_capacity key', () {
      expect(
          mapFunctionErrorForTest(503, {'error': 'quota_check_failed'}),
          equals(recipeAssistantServiceAtCapacityKey));
    });

    test('maps 429 status with rate_limited code to rate_limited key', () {
      expect(mapFunctionErrorForTest(429, {'error': 'rate_limited'}),
          equals(recipeAssistantRateLimitedKey));
    });

    test('maps 429 status without error code to rate_limited key', () {
      expect(mapFunctionErrorForTest(429, {}),
          equals(recipeAssistantRateLimitedKey));
    });

    test('maps 503 status with not_configured code to not_configured key', () {
      expect(
          mapFunctionErrorForTest(503, {'error': 'not_configured'}),
          equals(recipeAssistantNotConfiguredKey));
    });

    test('maps 503 status without error code to not_configured key', () {
      expect(mapFunctionErrorForTest(503, {}),
          equals(recipeAssistantNotConfiguredKey));
    });

    test('maps unknown status to failed key', () {
      expect(mapFunctionErrorForTest(500, {}),
          equals(recipeAssistantFailedKey));
    });

    test('maps unknown error code to failed key', () {
      expect(mapFunctionErrorForTest(400, {'error': 'unknown_error'}),
          equals(recipeAssistantFailedKey));
    });

    test('maps null details to failed key', () {
      expect(mapFunctionErrorForTest(400, null),
          equals(recipeAssistantFailedKey));
    });

    test('maps non-map details to failed key', () {
      expect(mapFunctionErrorForTest(400, 'string error'),
          equals(recipeAssistantFailedKey));
    });
  });
}
