import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_provider.dart';

/// Bottom-nav branch index for each main tab.
abstract final class OnboardingTabIndex {
  static const explore = 0;
  static const recipes = 1;
  static const planner = 2;
  static const shopping = 3;
  static const profile = 4;
}

class OnboardingTourStep {
  const OnboardingTourStep({
    required this.tabIndex,
    this.fabClearance = 0,
  });

  final int tabIndex;

  /// Horizontal space reserved on the right so bottom-right FABs stay visible.
  final double fabClearance;
}

/// Room for a standard FAB (56) plus scaffold margin.
const _singleFabClearance = 88.0;

/// Room for stacked small + standard FABs on the recipe list screen.
const _doubleFabClearance = 140.0;

const onboardingTourSteps = <OnboardingTourStep>[
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.planner,
    fabClearance: _singleFabClearance,
  ),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.planner,
    fabClearance: _singleFabClearance,
  ),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.planner,
    fabClearance: _singleFabClearance,
  ),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.recipes,
    fabClearance: _doubleFabClearance,
  ),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.recipes,
    fabClearance: _doubleFabClearance,
  ),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.shopping,
    fabClearance: _singleFabClearance,
  ),
  OnboardingTourStep(tabIndex: OnboardingTabIndex.explore),
  OnboardingTourStep(tabIndex: OnboardingTabIndex.profile),
];

final onboardingTourStepProvider =
    NotifierProvider<OnboardingTourNotifier, int>(OnboardingTourNotifier.new);

class OnboardingTourNotifier extends Notifier<int> {
  String? _activeUserId;

  @override
  int build() {
    final initialUserId = switch (ref.read(authStateProvider).valueOrNull) {
      AuthAuthenticated(user: final user) => user.id,
      _ => null,
    };
    _activeUserId = initialUserId;

    ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) {
      final userId = switch (next.valueOrNull) {
        AuthAuthenticated(user: final user) => user.id,
        _ => null,
      };

      if (userId == _activeUserId) return;
      _activeUserId = userId;
      state = 0;
    });

    return 0;
  }

  OnboardingTourStep get currentStep => onboardingTourSteps[state];

  bool get isLastStep => state >= onboardingTourSteps.length - 1;

  void next() {
    if (isLastStep) {
      skip();
      return;
    }
    state = state + 1;
  }

  void previous() {
    if (state > 0) {
      state = state - 1;
    }
  }

  Future<void> skip() async {
    await ref.read(onboardingCompletedProvider.notifier).complete();
  }
}
