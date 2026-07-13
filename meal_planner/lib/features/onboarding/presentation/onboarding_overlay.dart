import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_tour_provider.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

class OnboardingOverlay extends ConsumerStatefulWidget {
  const OnboardingOverlay({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends ConsumerState<OnboardingOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTabForStep());
  }

  void _syncTabForStep() {
    final step = ref.read(onboardingTourStepProvider);
    final tabIndex = onboardingTourSteps[step].tabIndex;

    if (tabIndex == OnboardingTabIndex.explore && ref.read(isOfflineProvider)) {
      return;
    }

    if (widget.navigationShell.currentIndex != tabIndex) {
      widget.navigationShell.goBranch(tabIndex, initialLocation: false);
    }
  }

  ({String title, String body}) _copyForStep(AppLocalizations l10n, int step) {
    return switch (step) {
      0 => (title: l10n.onboardingStep0Title, body: l10n.onboardingStep0Body),
      1 => (title: l10n.onboardingStep1Title, body: l10n.onboardingStep1Body),
      2 => (title: l10n.onboardingStep2Title, body: l10n.onboardingStep2Body),
      3 => (title: l10n.onboardingStep3Title, body: l10n.onboardingStep3Body),
      4 => (title: l10n.onboardingStep4Title, body: l10n.onboardingStep4Body),
      5 => (title: l10n.onboardingStep5Title, body: l10n.onboardingStep5Body),
      6 => (title: l10n.onboardingStep6Title, body: l10n.onboardingStep6Body),
      7 => (title: l10n.onboardingStep7Title, body: l10n.onboardingStep7Body),
      _ => (title: l10n.onboardingStep0Title, body: l10n.onboardingStep0Body),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final step = ref.watch(onboardingTourStepProvider);
    final tour = ref.read(onboardingTourStepProvider.notifier);
    final isLast = tour.isLastStep;
    final copy = _copyForStep(l10n, step);

    ref.listen<int>(onboardingTourStepProvider, (previous, next) {
      if (previous != next) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _syncTabForStep());
      }
    });

    ref.listen<bool>(isOfflineProvider, (previous, next) {
      if (previous == true && next == false) {
        final currentStep = ref.read(onboardingTourStepProvider);
        if (onboardingTourSteps[currentStep].tabIndex ==
            OnboardingTabIndex.explore) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _syncTabForStep());
        }
      }
    });

    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.padding.bottom;
    final topInset = mediaQuery.padding.top;
    const navBarHeight = kBottomNavigationBarHeight;
    const bottomMargin = 12.0;
    final fabClearance = onboardingTourSteps[step].fabClearance;
    final maxPanelHeight = mediaQuery.size.height -
        topInset -
        navBarHeight -
        bottomInset -
        bottomMargin;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      left: 16,
      right: 16 + fabClearance,
      bottom: navBarHeight + bottomInset + bottomMargin,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Material(
          key: ValueKey<int>(step),
          color: Colors.transparent,
          child: Card(
            elevation: 8,
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxPanelHeight),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children:
                          List.generate(onboardingTourSteps.length, (index) {
                        final active = index == step;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index < onboardingTourSteps.length - 1
                                  ? 6
                                  : 0,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 4,
                              decoration: BoxDecoration(
                                color: active
                                    ? theme.colorScheme.primary
                                    : theme
                                        .colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      copy.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      copy.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: tour.skip,
                          child: Text(l10n.onboardingSkip),
                        ),
                        const Spacer(),
                        if (step > 0)
                          TextButton(
                            onPressed: tour.previous,
                            child: Text(l10n.onboardingPrevious),
                          ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: tour.next,
                          child: Text(
                            isLast
                                ? l10n.onboardingFinish
                                : l10n.onboardingNext,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
