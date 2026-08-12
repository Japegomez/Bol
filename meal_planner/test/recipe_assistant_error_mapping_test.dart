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
        recipeAssistantMissingInputKey,
        recipeAssistantImageTooLargeKey,
        recipeAssistantInvalidImageKey,
      ];

      for (final key in keys) {
        expect(key, isNotEmpty, reason: 'Key should not be empty');
      }

      expect(
        keys.toSet().length,
        equals(keys.length),
        reason: 'All error keys must be distinct',
      );
    });

    test('quota keys are distinct from legacy rate_limited key', () {
      expect(
        recipeAssistantDailyLimitKey,
        isNot(equals(recipeAssistantRateLimitedKey)),
      );
      expect(
        recipeAssistantTooFastKey,
        isNot(equals(recipeAssistantRateLimitedKey)),
      );
      expect(
        recipeAssistantServiceAtCapacityKey,
        isNot(equals(recipeAssistantRateLimitedKey)),
      );
    });

    test('quota keys are distinct from each other', () {
      expect(
        recipeAssistantDailyLimitKey,
        isNot(equals(recipeAssistantTooFastKey)),
      );
      expect(
        recipeAssistantDailyLimitKey,
        isNot(equals(recipeAssistantServiceAtCapacityKey)),
      );
      expect(
        recipeAssistantTooFastKey,
        isNot(equals(recipeAssistantServiceAtCapacityKey)),
      );
    });
  });

  group('mapRecipeAssistantFunctionError', () {
    test('maps 422 status to not_a_recipe_request', () {
      expect(
        mapRecipeAssistantFunctionError(422, <String, dynamic>{}),
        equals(recipeAssistantNotRecipeRequestKey),
      );
    });

    test('maps not_a_recipe_request error code to not_a_recipe_request', () {
      expect(
        mapRecipeAssistantFunctionError(400, {'error': 'not_a_recipe_request'}),
        equals(recipeAssistantNotRecipeRequestKey),
      );
    });

    test('maps too_fast error code to too_fast key', () {
      expect(
        mapRecipeAssistantFunctionError(429, {'error': 'too_fast'}),
        equals(recipeAssistantTooFastKey),
      );
    });

    test('maps daily_limit_reached error code to daily_limit key', () {
      expect(
        mapRecipeAssistantFunctionError(429, {'error': 'daily_limit_reached'}),
        equals(recipeAssistantDailyLimitKey),
      );
    });

    test('maps service_at_capacity error code to service_at_capacity key', () {
      expect(
        mapRecipeAssistantFunctionError(503, {'error': 'service_at_capacity'}),
        equals(recipeAssistantServiceAtCapacityKey),
      );
    });

    test('maps quota_check_failed error code to service_at_capacity key', () {
      expect(
        mapRecipeAssistantFunctionError(503, {'error': 'quota_check_failed'}),
        equals(recipeAssistantServiceAtCapacityKey),
      );
    });

    test('maps 429 status with rate_limited code to rate_limited key', () {
      expect(
        mapRecipeAssistantFunctionError(429, {'error': 'rate_limited'}),
        equals(recipeAssistantRateLimitedKey),
      );
    });

    test('maps 429 status without error code to rate_limited key', () {
      expect(
        mapRecipeAssistantFunctionError(429, <String, dynamic>{}),
        equals(recipeAssistantRateLimitedKey),
      );
    });

    test('maps 503 status with not_configured code to not_configured key', () {
      expect(
        mapRecipeAssistantFunctionError(503, {'error': 'not_configured'}),
        equals(recipeAssistantNotConfiguredKey),
      );
    });

    test('maps 503 status without error code to not_configured key', () {
      expect(
        mapRecipeAssistantFunctionError(503, <String, dynamic>{}),
        equals(recipeAssistantNotConfiguredKey),
      );
    });

    test('maps unknown status to failed key', () {
      expect(
        mapRecipeAssistantFunctionError(500, <String, dynamic>{}),
        equals(recipeAssistantFailedKey),
      );
    });

    test('maps unknown error code to failed key', () {
      expect(
        mapRecipeAssistantFunctionError(400, {'error': 'unknown_error'}),
        equals(recipeAssistantFailedKey),
      );
    });

    test('maps null details to failed key', () {
      expect(
        mapRecipeAssistantFunctionError(400, null),
        equals(recipeAssistantFailedKey),
      );
    });

    test('maps non-map details to failed key', () {
      expect(
        mapRecipeAssistantFunctionError(400, 'string error'),
        equals(recipeAssistantFailedKey),
      );
    });
  });
}
