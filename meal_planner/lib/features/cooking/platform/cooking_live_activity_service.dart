import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:live_activities/live_activities.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/features/cooking/platform/cooking_platform_copy.dart';

/// App Group used to share data between the Runner and the Widget Extension.
const _kAppGroupId = 'group.com.japegomez.mealPlanner.cooking';

/// Stable ID for the single active cooking Live Activity.
const _kActivityId = 'cooking_active';

const _kKeyRecipeTitle = 'recipeTitle';
const _kKeyStepIndex = 'stepIndex';
const _kKeyTotalSteps = 'totalSteps';
const _kKeyStepText = 'stepText';
const _kKeyIsPaused = 'isPaused';
const _kKeyStartedAtMs = 'startedAtMs';
const _kKeyAccumulatedPauseMs = 'accumulatedPauseMs';
const _kKeyPausedAtMs = 'pausedAtMs';
const _kKeyPausedLabel = 'pausedLabel';
const _kKeyStepLabel = 'stepLabel';
const _kKeyPauseAction = 'pauseAction';
const _kKeyResumeAction = 'resumeAction';
const _kKeyFinishAction = 'finishAction';

/// Singleton that wraps the [LiveActivities] plugin for iOS.
class CookingLiveActivityService {
  CookingLiveActivityService._();

  static final CookingLiveActivityService instance =
      CookingLiveActivityService._();

  final LiveActivities _plugin = LiveActivities();
  bool _initialized = false;

  static bool get _isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> initialize() async {
    if (!_isIOS) return;
    try {
      await _plugin.init(appGroupId: _kAppGroupId);
      _initialized = true;
      log.d('LiveActivities initialized');
    } catch (e) {
      log.w('LiveActivities init failed (extension not configured?): $e');
    }
  }

  Future<void> update(CookingSession session) async {
    if (!_isIOS || !_initialized) return;
    try {
      final data = _buildData(session);
      await _plugin.createOrUpdateActivity(_kActivityId, data);
      log.d('LiveActivity synced');
    } on Object catch (e) {
      // Catches both Dart exceptions (PlatformException, MissingPluginException)
      // and any Error subclasses (e.g. AssertionError from native bridge).
      log.w('LiveActivity update failed: $e');
      // Disable further attempts if the extension isn't reachable.
      _initialized = false;
    }
  }

  Future<void> end() async {
    if (!_isIOS || !_initialized) return;
    try {
      await _plugin.endActivity(_kActivityId);
      log.d('LiveActivity ended');
    } on Object catch (e) {
      log.w('LiveActivity end failed: $e');
    }
  }

  static Map<String, dynamic> _buildData(CookingSession session) {
    final copy = CookingPlatformCopy.resolve(session);

    return {
      _kKeyRecipeTitle: session.recipeTitle,
      _kKeyStepIndex: session.currentStepIndex,
      _kKeyTotalSteps: session.totalSteps,
      _kKeyStepText: copy.stepText,
      _kKeyIsPaused: session.isPaused,
      _kKeyStartedAtMs: session.startedAt.millisecondsSinceEpoch,
      _kKeyAccumulatedPauseMs: session.accumulatedPauseMs,
      _kKeyPausedAtMs: session.pausedAt?.millisecondsSinceEpoch,
      _kKeyPausedLabel: copy.pausedLabel,
      _kKeyStepLabel: copy.stepLabel,
      _kKeyPauseAction: copy.pauseAction,
      _kKeyResumeAction: copy.resumeAction,
      _kKeyFinishAction: copy.finishAction,
    };
  }
}
