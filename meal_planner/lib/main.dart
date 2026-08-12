import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meal_planner/app.dart';
import 'package:meal_planner/core/analytics/analytics_service.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:meal_planner/core/locale/supported_locales.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/cooking/platform/cooking_live_activity_service.dart';
import 'package:meal_planner/features/cooking/platform/cooking_notification_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<void> bootstrap() async {
    for (final code in supportedAppLanguageCodes) {
      await initializeDateFormatting(code, null);
    }

    if (Env.hasSupabase) {
      await SupabaseConfig.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
      log.i('Supabase initialized');
    } else {
      log.w(
        'SUPABASE_URL / SUPABASE_ANON_KEY not set — running offline scaffold',
      );
    }

    await AnalyticsService.initialize();
    await AnalyticsService.trackAppOpened();

    await CookingNotificationService.instance.initialize();
    await CookingLiveActivityService.instance.initialize();
  }

  if (Env.hasSentry) {
    await SentryFlutter.init(
      (options) {
        options
          ..dsn = Env.sentryDsn
          ..tracesSampleRate = Env.isProduction ? 0.2 : 1.0
          ..environment = Env.isProduction ? 'production' : 'development'
          // Scrub credentials from breadcrumbs and request data before they
          // are sent to Sentry, so auth headers / tokens / passwords are not
          // shipped with crash reports.
          ..beforeSend = _scrubSentryEvent;
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

const _sensitiveKeyFragments = [
  'authorization',
  'token',
  'password',
  'cookie',
  'apikey',
  'api_key',
  'api-key',
  'secret',
  'access_token',
  'refresh_token',
];

bool _isSensitiveKey(String key) {
  final lower = key.toLowerCase();
  return _sensitiveKeyFragments.any((f) => lower.contains(f));
}

/// Sentry `beforeSend` hook: redacts credential-bearing fields from the
/// event (request headers and breadcrumb data) while preserving the rest
/// of the report for diagnosis. Only mutates map values in place, so it
/// doesn't depend on protocol field setters.
SentryEvent? _scrubSentryEvent(SentryEvent event, Hint hint) {
  final request = event.request;
  final headers = request?.headers;
  if (headers != null) {
    for (final key in headers.keys.toList()) {
      if (_isSensitiveKey(key)) headers[key] = '[REDACTED]';
    }
  }

  for (final crumb in event.breadcrumbs ?? const <Breadcrumb>[]) {
    final data = crumb.data;
    if (data == null) continue;
    for (final key in data.keys.toList()) {
      if (_isSensitiveKey(key)) data[key] = '[REDACTED]';
    }
  }

  return event;
}
