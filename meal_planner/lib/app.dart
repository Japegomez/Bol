import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/auth/session_lifecycle_handler.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/deep_links/deep_link_listener.dart';
import 'package:meal_planner/core/locale/locale_provider.dart';
import 'package:meal_planner/core/sync/sync_service.dart';
import 'package:meal_planner/core/theme/app_theme.dart';
import 'package:meal_planner/core/theme/theme_mode_provider.dart';
import 'package:meal_planner/core/widgets/connectivity_banner.dart';
import 'package:meal_planner/core/widgets/offline_entry_listener.dart';
import 'package:meal_planner/l10n/app_localizations.dart';
import 'package:meal_planner/router/app_router.dart';
import 'package:upgrader/upgrader.dart';

class MealPlannerApp extends ConsumerWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncOnReconnectProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return SessionLifecycleHandler(
      child: DeepLinkListener(
        child: MaterialApp.router(
          title: AppBranding.displayName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) {
            return UpgradeAlert(
              child: OfflineEntryListener(
                child: ConnectivityBanner(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
