import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/features/cooking/platform/cooking_platform_copy.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

const _kChannel = MethodChannel('com.japegomez.mealPlanner/live_activity');

/// Manages iOS Live Activities for the cooking session.
///
/// Communicates with the native [CookingActivityManager] via a [MethodChannel]
/// so that ActivityKit creates activities of type `CookingActivityAttributes` —
/// the exact type the `CookingActivityWidget` extension listens for.
class CookingLiveActivityService {
  CookingLiveActivityService._();

  static final CookingLiveActivityService instance =
      CookingLiveActivityService._();

  static bool get _isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// No-op — the native channel is set up in SceneDelegate on app launch.
  Future<void> initialize() async {}

  /// Create (if needed) or update the cooking Live Activity.
  Future<void> update(CookingSession session) async {
    if (!_isIOS) return;
    try {
      await _kChannel.invokeMethod<void>('update', _buildData(session));
      log.d('LiveActivity updated');
    } on Object catch (e) {
      log.w('LiveActivity update failed: $e');
    }
  }

  /// End the cooking Live Activity immediately.
  Future<void> end() async {
    if (!_isIOS) return;
    try {
      await _kChannel.invokeMethod<void>('end');
      log.d('LiveActivity ended');
    } on Object catch (e) {
      log.w('LiveActivity end failed: $e');
    }
  }

  static Map<String, dynamic> _buildData(CookingSession session) {
    final copy = CookingPlatformCopy.resolve(session);

    // Resolve l10n for building all-step arrays.
    AppLocalizations l10n;
    try {
      l10n = lookupAppLocalizations(PlatformDispatcher.instance.locale);
    } catch (_) {
      l10n = lookupAppLocalizations(const Locale('en'));
    }

    final total = session.totalSteps;

    // All step texts: index 0 is the synthetic "check ingredients" step.
    final allStepTexts = <String>[
      l10n.checkIngredientsStep,
      ...session.steps.map((s) => s.description),
    ];

    // Localized step labels ("Step X of Y") for each index.
    final allStepLabels = <String>[
      for (int i = 0; i < total; i++) l10n.stepXofY(i + 1, total),
    ];

    return {
      'recipeTitle': session.recipeTitle,
      'stepIndex': session.currentStepIndex,
      'totalSteps': total,
      'stepText': copy.stepText,
      'isPaused': session.isPaused,
      'startedAtMs': session.startedAt.millisecondsSinceEpoch,
      'accumulatedPauseMs': session.accumulatedPauseMs,
      // Do NOT include pausedAtMs when null: native [String: Any] cannot hold nil.
      if (session.pausedAt != null)
        'pausedAtMs': session.pausedAt!.millisecondsSinceEpoch,
      'pausedLabel': copy.pausedLabel,
      'stepLabel': copy.stepLabel,
      'pauseAction': copy.pauseAction,
      'resumeAction': copy.resumeAction,
      'finishAction': copy.finishAction,
      // Step navigation data for Live Activity intents.
      'allStepTexts': allStepTexts,
      'allStepLabels': allStepLabels,
      // Always reset to collapsed; the native manager preserves the value
      // when the step index has not changed (see CookingActivityManager.update).
      'isTextExpanded': false,
    };
  }
}
