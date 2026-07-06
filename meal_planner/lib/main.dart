import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meal_planner/app.dart';
import 'package:meal_planner/core/analytics/analytics_service.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<void> bootstrap() async {
    await initializeDateFormatting('es', null);

    if (Env.hasSupabase) {
      await SupabaseConfig.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
      log.i('Supabase initialized');
    } else {
      log.w('SUPABASE_URL / SUPABASE_ANON_KEY not set — running offline scaffold');
    }

    await AnalyticsService.initialize();
    await AnalyticsService.trackAppOpened();
  }

  if (Env.hasSentry) {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = Env.sentryDsn
          ..tracesSampleRate = Env.isProduction ? 0.2 : 1.0
          ..environment = Env.isProduction ? 'production' : 'development';
      },
      appRunner: () async {
        await bootstrap();
        runApp(const ProviderScope(child: MealPlannerApp()));
      },
    );
  } else {
    await bootstrap();
    runApp(const ProviderScope(child: MealPlannerApp()));
  }
}
