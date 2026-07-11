import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/features/shopping/presentation/shopping_provider.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index, WidgetRef ref, BuildContext context) {
    final isOffline = ref.read(isOfflineProvider);
    if (index == 0 && isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Explorar no está disponible sin conexión'),
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

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(index, ref, context),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.explore_outlined,
              color: isOffline
                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)
                  : null,
            ),
            selectedIcon: Icon(
              Icons.explore,
              color: isOffline
                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)
                  : null,
            ),
            label: 'Explorar',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Recetario',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Planificador',
          ),
          const NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Compra',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
