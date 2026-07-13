import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_overlay.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_provider.dart';
import 'package:meal_planner/features/shopping/presentation/shopping_provider.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(
    int index,
    WidgetRef ref,
    BuildContext context, {
    required bool onboardingActive,
  }) {
    if (onboardingActive) return;

    final isOffline = ref.read(isOfflineProvider);
    if (index == 0 && isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.exploreUnavailableOffline),
        ),
      );
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );

    if (index == 3) {
      ref.read(shoppingItemsProvider.notifier).reload();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    final l10n = context.l10n;

    final onboardingPending = ref.watch(onboardingCompletedProvider) == false;
    final theme = Theme.of(context);
    final navDisabledColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.38);

    Color? navIconColor(int index) {
      if (!onboardingPending) {
        return index == 0 && isOffline ? navDisabledColor : null;
      }
      if (index == navigationShell.currentIndex) return null;
      return navDisabledColor;
    }

    return Stack(
      children: [
        Scaffold(
          body: navigationShell,
          bottomNavigationBar: IgnorePointer(
            ignoring: onboardingPending,
            child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => _onTap(
              index,
              ref,
              context,
              onboardingActive: onboardingPending,
            ),
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.explore_outlined,
                  color: navIconColor(0),
                ),
                selectedIcon: Icon(
                  Icons.explore,
                  color: navIconColor(0),
                ),
                label: l10n.navExplore,
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.menu_book_outlined,
                  color: navIconColor(1),
                ),
                selectedIcon: Icon(
                  Icons.menu_book,
                  color: navIconColor(1),
                ),
                label: l10n.navRecipeBook,
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.calendar_month_outlined,
                  color: navIconColor(2),
                ),
                selectedIcon: Icon(
                  Icons.calendar_month,
                  color: navIconColor(2),
                ),
                label: l10n.navPlanner,
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: navIconColor(3),
                ),
                selectedIcon: Icon(
                  Icons.shopping_cart,
                  color: navIconColor(3),
                ),
                label: l10n.navShopping,
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.person_outline,
                  color: navIconColor(4),
                ),
                selectedIcon: Icon(
                  Icons.person,
                  color: navIconColor(4),
                ),
                label: l10n.navProfile,
              ),
            ],
            ),
          ),
        ),
        if (onboardingPending)
          OnboardingOverlay(navigationShell: navigationShell),
      ],
    );
  }
}
