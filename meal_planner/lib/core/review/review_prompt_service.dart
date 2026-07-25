import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/utils/logger.dart';

/// Suggests a native store review at most once per week.
///
/// Call [maybeRequestReview] when the user reaches the main app shell.
/// The explicit Settings action uses [openRateApp] instead.
abstract final class ReviewPromptService {
  static const _lastPromptKey = 'review.last_prompt_at';
  static const cooldownDays = 7;

  static const _storage = FlutterSecureStorage();
  static final _inAppReview = InAppReview.instance;

  /// Shows the review prompt when available and at least [cooldownDays] have
  /// passed since the last request.
  static Future<void> maybeRequestReview() async {
    if (!await _inAppReview.isAvailable()) {
      log.d('In-app review not available on this platform');
      return;
    }

    if (!await _isOutsideCooldown()) return;

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
}
