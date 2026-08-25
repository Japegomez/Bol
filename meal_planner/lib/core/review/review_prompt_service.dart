import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/utils/logger.dart';

/// Suggests a native store review at most once per week.
///
/// Call [recordHomeShellSession] when the home shell mounts and
/// [recordNavChange] when the user switches tabs. [maybeRequestReview] only
/// runs after enough real usage (see [minHomeShellSessions] and
/// [minNavChanges]). The explicit Settings action uses [openRateApp] instead.
abstract final class ReviewPromptService {
  static const _lastPromptKey = 'review.last_prompt_at';
  static const _homeShellSessionsKey = 'review.home_shell_sessions';
  static const _navChangesKey = 'review.nav_changes';
  static const cooldownDays = 7;

  /// Home opens before prompting (first visit + onboarding finish do not count).
  static const minHomeShellSessions = 3;

  /// At least one tab change so the user has navigated beyond the landing tab.
  static const minNavChanges = 1;

  static const _storage = FlutterSecureStorage();
  static final _inAppReview = InAppReview.instance;

  /// Call once per app session when [HomeShell] becomes visible.
  static Future<void> recordHomeShellSession() async {
    await _incrementCounter(_homeShellSessionsKey);
  }

  /// Call when the user switches to a different bottom-nav destination.
  static Future<void> recordNavChange() async {
    await _incrementCounter(_navChangesKey);
  }

  /// Shows the review prompt when available, engagement thresholds are met,
  /// and at least [cooldownDays] have passed since the last request.
  static Future<void> maybeRequestReview() async {
    if (!await _inAppReview.isAvailable()) {
      log.d('In-app review not available on this platform');
      return;
    }

    if (!await _isOutsideCooldown()) return;
    if (!await _hasEnoughEngagement()) return;

    await _inAppReview.requestReview();
    await _storage.write(
      key: _lastPromptKey,
      value: DateTime.now().toUtc().toIso8601String(),
    );
    log.i('In-app review prompt requested');
  }

  /// Opens the store listing so the user can rate the app from Settings.
  ///
  /// Prefer this over [maybeRequestReview] for an explicit "Rate" action —
  /// platform review dialogs may be suppressed by quota.
  /// Returns `true` if the store was opened, `false` otherwise.
  static Future<bool> openRateApp() async {
    try {
      await _inAppReview.openStoreListing(appStoreId: AppBranding.appStoreId);
      log.i('Opened store listing for rating');
      return true;
    } catch (error, stackTrace) {
      log.e(
        'Failed to open store listing',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<bool> _isOutsideCooldown() async {
    final lastPrompt = await _storage.read(key: _lastPromptKey);
    if (lastPrompt == null) return true;

    final lastDate = DateTime.tryParse(lastPrompt);
    if (lastDate == null) return true;

    return DateTime.now().toUtc().difference(lastDate).inDays >= cooldownDays;
  }

  static Future<bool> _hasEnoughEngagement() async {
    final sessions = await _readCounter(_homeShellSessionsKey);
    final navChanges = await _readCounter(_navChangesKey);
    return sessions >= minHomeShellSessions && navChanges >= minNavChanges;
  }

  static Future<int> _readCounter(String key) async {
    return int.tryParse(await _storage.read(key: key) ?? '') ?? 0;
  }

  static Future<void> _incrementCounter(String key) async {
    final next = (await _readCounter(key)) + 1;
    await _storage.write(key: key, value: '$next');
  }
}
