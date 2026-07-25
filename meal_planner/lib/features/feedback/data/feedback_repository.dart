import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/feedback/domain/user_feedback.dart';

class FeedbackRepository {
  static const _table = 'user_feedback';
  static const minMessageLength = 10;

  Future<void> submit({
    required String userId,
    required FeedbackCategory category,
    required String message,
  }) async {
    final trimmed = message.trim();
    if (trimmed.length < minMessageLength) {
      throw ArgumentError(
        'Feedback message must be at least $minMessageLength characters',
      );
    }

    await supabase.from(_table).insert({
      'user_id': userId,
      'category': category.dbValue,
      'message': trimmed,
      'status': FeedbackStatus.pending.dbValue,
    });
  }

  Future<List<UserFeedback>> listForAdmin({
    FeedbackCategory? category,
    FeedbackStatus? status,
  }) async {
    var query = supabase.from(_table).select(
          '*, user:profiles!user_feedback_user_id_fkey(username)',
        );

    if (category != null) {
      query = query.eq('category', category.dbValue);
    }
    if (status != null) {
      query = query.eq('status', status.dbValue);
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List<dynamic>)
        .map(
          (row) =>
              UserFeedback.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<void> updateStatus({
    required String feedbackId,
    required FeedbackStatus status,
  }) async {
    await supabase.from(_table).update({
      'status': status.dbValue,
    }).eq('id', feedbackId);
  }
}
