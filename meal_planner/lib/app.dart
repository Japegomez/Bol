import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/auth/session_lifecycle_handler.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/theme/app_theme.dart';
import 'package:meal_planner/core/widgets/connectivity_banner.dart';
import 'package:meal_planner/router/app_router.dart';
import 'package:upgrader/upgrader.dart';

class MealPlannerApp extends ConsumerWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return SessionLifecycleHandler(
      child: MaterialApp.router(
        title: AppBranding.displayName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router,
        builder: (context, child) {
          return UpgradeAlert(
            child: ConnectivityBanner(
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
