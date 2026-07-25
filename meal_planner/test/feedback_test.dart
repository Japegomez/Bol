import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/feedback/domain/user_feedback.dart';

void main() {
  group('FeedbackCategory', () {
    test('round-trips db values', () {
      for (final category in FeedbackCategory.values) {
        expect(FeedbackCategory.fromDb(category.dbValue), category);
      }
    });

    test('unknown db value falls back to other', () {
      expect(FeedbackCategory.fromDb('unknown'), FeedbackCategory.other);
    });
  });

  group('FeedbackStatus', () {
    test('round-trips db values', () {
      for (final status in FeedbackStatus.values) {
        expect(FeedbackStatus.fromDb(status.dbValue), status);
      }
    });
  });

  group('UserFeedback', () {
    test('parses joined username and status', () {
      final feedback = UserFeedback.fromJson({
        'id': 'fb-1',
        'user_id': 'user-1',
        'category': 'issue',
        'status': 'pending',
        'message': 'Something broke in the planner',
        'created_at': '2026-07-25T10:00:00Z',
        'user': {'username': 'Chef'},
      });

      expect(feedback.category, FeedbackCategory.issue);
      expect(feedback.status, FeedbackStatus.pending);
      expect(feedback.userDisplayName, 'Chef');
      expect(feedback.message, contains('planner'));
    });
  });
}
