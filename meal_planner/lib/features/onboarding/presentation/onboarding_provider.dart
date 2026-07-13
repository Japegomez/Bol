import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _storageKeyFor(String userId) => 'app.onboarding_completed.$userId';

/// `null` = loading or signed out, `false` = tour pending, `true` = completed.
final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool?>(
  OnboardingCompletedNotifier.new,
);

class OnboardingCompletedNotifier extends Notifier<bool?> {
  String? _activeUserId;

  @override
  bool? build() {
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      _syncForAuth(next);
    }, fireImmediately: true);
    return null;
  }

  void _syncForAuth(AsyncValue<AuthState> authAsync) {
    final userId = switch (authAsync.valueOrNull) {
      AuthAuthenticated(user: final user) => user.id,
      _ => null,
    };

    if (userId == _activeUserId) return;
    _activeUserId = userId;

    if (userId == null) {
      state = null;
      return;
    }

    Future.microtask(() => _restore(userId));
  }

  Future<void> _restore(String userId) async {
    if (_activeUserId != userId) return;

    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_storageKeyFor(userId)) ?? false;
  }

  Future<void> complete() async {
    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is! AuthAuthenticated) return;

    final userId = authState.user.id;
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKeyFor(userId), true);
  }
}
