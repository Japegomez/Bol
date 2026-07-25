import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/feedback/data/feedback_repository.dart';
import 'package:meal_planner/features/feedback/domain/user_feedback.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository();
});

final adminFeedbackListProvider = FutureProvider.autoDispose
    .family<List<UserFeedback>, AdminFeedbackFilters>((ref, filters) async {
  return ref.read(feedbackRepositoryProvider).listForAdmin(
        category: filters.category,
        status: filters.status,
      );
});

class SubmitFeedbackNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required FeedbackCategory category,
    required String message,
  }) async {
    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is! AuthAuthenticated) {
      throw StateError('Not authenticated');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(feedbackRepositoryProvider).submit(
            userId: authState.user.id,
            category: category,
            message: message,
          );
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}

final submitFeedbackProvider =
    AutoDisposeAsyncNotifierProvider<SubmitFeedbackNotifier, void>(
  SubmitFeedbackNotifier.new,
);

class UpdateFeedbackStatusNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateStatus({
    required String feedbackId,
    required FeedbackStatus status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(feedbackRepositoryProvider).updateStatus(
            feedbackId: feedbackId,
            status: status,
          );
    });

    if (state.hasError) {
      throw state.error!;
    }
  }
}

final updateFeedbackStatusProvider =
    AutoDisposeAsyncNotifierProvider<UpdateFeedbackStatusNotifier, void>(
  UpdateFeedbackStatusNotifier.new,
);
