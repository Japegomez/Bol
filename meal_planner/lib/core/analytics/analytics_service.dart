import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_planner/core/firebase/firebase_options.dart';
import 'package:meal_planner/core/utils/logger.dart';

abstract final class AnalyticsService {
  static FirebaseAnalytics? _analytics;

  static bool get isEnabled => _analytics != null;

  static Future<void> initialize() async {
    if (kIsWeb) {
      log.i('Firebase Analytics skipped on web (not configured)');
      return;
    }

    if (!DefaultFirebaseOptions.isConfigured) {
      log.w(
        'Firebase Analytics disabled — run `flutterfire configure` in meal_planner/',
      );
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _analytics = FirebaseAnalytics.instance;
      log.i('Firebase Analytics initialized');
    } catch (e, st) {
      log.w('Firebase Analytics init failed: $e\n$st');
    }
  }

  static Future<void> trackAppOpened() async {
    await _analytics?.logAppOpen();
  }

  static Future<void> track(
    String event, {
    Map<String, Object>? properties,
  }) async {
    await _analytics?.logEvent(name: event, parameters: properties);
  }
}
