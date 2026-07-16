import 'dart:io';

import 'package:live_activities/live_activities.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';

/// App Group used to share data between the Runner and the Widget Extension.
///
/// This must also be configured in:
///  • Runner.entitlements (com.apple.security.application-groups)
///  • CookingActivity.entitlements (same)
///  • Both targets' App Groups capability in Xcode
const _kAppGroupId = 'group.com.japegomez.mealPlanner.cooking';

/// Keys used in the shared activity data map.
const _kKeyRecipeTitle = 'recipeTitle';
const _kKeyStepIndex = 'stepIndex';
const _kKeyTotalSteps = 'totalSteps';
const _kKeyStepText = 'stepText';
const _kKeyIsPaused = 'isPaused';
const _kKeyStartedAtMs = 'startedAtMs';
const _kKeyAccumulatedPauseMs = 'accumulatedPauseMs';
const _kKeyPausedAtMs = 'pausedAtMs';

/// Singleton that wraps the [LiveActivities] plugin for iOS.
///
/// On Android (or iOS < 16.1) all calls are no-ops and fail silently.
class CookingLiveActivityService {
  CookingLiveActivityService._();

  static final CookingLiveActivityService instance =
      CookingLiveActivityService._();

  final LiveActivities _plugin = LiveActivities();
  String? _activityId;
  bool _initialized = false;

  Future<void> initialize() async {
    if (!Platform.isIOS) return;
    try {
      await _plugin.init(appGroupId: _kAppGroupId);
      _initialized = true;
      log.d('LiveActivities initialized');
    } catch (e) {
      log.w('LiveActivities init failed (extension not configured?): $e');
    }
  }

  Future<void> update(CookingSession session) async {
    if (!Platform.isIOS || !_initialized) return;
    try {
      final data = _buildData(session);
      if (_activityId == null) {
        _activityId = await _plugin.createActivity(data);
        log.d('LiveActivity created: $_activityId');
      } else {
        await _plugin.updateActivity(_activityId!, data);
        log.d('LiveActivity updated');
      }
    } catch (e) {
      log.w('LiveActivity update failed: $e');
    }
  }

  Future<void> end() async {
    if (!Platform.isIOS || !_initialized) return;
    try {
      if (_activityId != null) {
        await _plugin.endActivity(_activityId!);
        _activityId = null;
        log.d('LiveActivity ended');
      }
    } catch (e) {
      log.w('LiveActivity end failed: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Map<String, dynamic> _buildData(CookingSession session) {
    final stepIndex = session.currentStepIndex;
    final stepText = stepIndex == 0
        ? 'Comprobar ingredientes'
        : session.steps[stepIndex - 1].description;

    return {
      _kKeyRecipeTitle: session.recipeTitle,
      _kKeyStepIndex: stepIndex,
      _kKeyTotalSteps: session.totalSteps,
      _kKeyStepText: stepText,
      _kKeyIsPaused: session.isPaused,
      _kKeyStartedAtMs: session.startedAt.millisecondsSinceEpoch,
      _kKeyAccumulatedPauseMs: session.accumulatedPauseMs,
      _kKeyPausedAtMs: session.pausedAt?.millisecondsSinceEpoch,
    };
  }
}
