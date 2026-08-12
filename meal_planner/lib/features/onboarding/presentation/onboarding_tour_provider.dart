import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_provider.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_targets.dart';

/// Bottom-nav branch index for each main tab.
abstract final class OnboardingTabIndex {
  static const explore = 0;
  static const recipes = 1;
  static const planner = 2;
  static const shopping = 3;
  static const profile = 4;
}

class OnboardingTourStep {
  const OnboardingTourStep({required this.tabIndex, this.targets = const []});

  final int tabIndex;

  /// UI elements to spotlight; empty for centered card without spotlight.
  final List<OnboardingTarget> targets;
}

const onboardingTourSteps = <OnboardingTourStep>[
  OnboardingTourStep(tabIndex: OnboardingTabIndex.planner),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.planner,
    targets: [OnboardingTarget.plannerWeekHeader],
  ),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.planner,
    targets: [OnboardingTarget.plannerFab],
  ),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.recipes,
    targets: [
      OnboardingTarget.recipesSearchBar,
      OnboardingTarget.recipesGlossaryFab,
    ],
  ),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.recipes,
    targets: [OnboardingTarget.recipesFab],
  ),
  OnboardingTourStep(tabIndex: OnboardingTabIndex.shopping),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.shopping,
    targets: [OnboardingTarget.shoppingAddFab],
  ),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.shopping,
    targets: [OnboardingTarget.shoppingShareButton],
  ),
  OnboardingTourStep(tabIndex: OnboardingTabIndex.explore),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.explore,
    targets: [OnboardingTarget.exploreFeedButton],
  ),
  OnboardingTourStep(
    tabIndex: OnboardingTabIndex.profile,
    targets: [
      OnboardingTarget.profileEditTile,
      OnboardingTarget.profileHouseholdTile,
    ],
  ),
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
