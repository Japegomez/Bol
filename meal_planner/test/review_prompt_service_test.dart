import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/review/review_prompt_service.dart';

void main() {
  group('ReviewPromptService', () {
    test('cooldown is 7 days (once per week)', () {
      expect(ReviewPromptService.cooldownDays, 7);
    });

    test('App Store ID is configured for store listing', () {
      expect(AppBranding.appStoreId, isNotEmpty);
      expect(AppBranding.appStoreId, matches(RegExp(r'^\d+$')));
    });
  });
}
