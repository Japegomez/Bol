import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/features/cooking/platform/cooking_live_activity_service.dart';
import 'package:meal_planner/features/cooking/platform/cooking_notification_service.dart';
import 'package:meal_planner/features/cooking/platform/cooking_pending_action_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSessionKey = 'cooking_session_v1';

// ── Public providers ─────────────────────────────────────────────────────────

final cookingSessionProvider =
    NotifierProvider<CookingSessionNotifier, CookingSession?>(
  CookingSessionNotifier.new,
);

/// Ticks every second; listeners use it to refresh the elapsed-time display.
final cookingTickProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
});

// ── Notifier ─────────────────────────────────────────────────────────────────

class CookingSessionNotifier extends Notifier<CookingSession?>
    with WidgetsBindingObserver {
  bool _isRestoring = false;

  @override
  CookingSession? build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));

    CookingNotificationService.setDirectActionCallback(_applyAction);

    _isRestoring = true;
    Future.microtask(() async {
      try {
        await _restore();
      } finally {
        _isRestoring = false;
      }
    });
    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handlePendingBackgroundAction();
    }
  }

  Future<void> start({
    required String recipeId,
    required String recipeTitle,
    required List<Ingredient> ingredients,
    required List<RecipeStep> steps,
  }) async {
    while (_isRestoring) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    state = CookingSession(
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      ingredients: ingredients,
      steps: steps,
      currentStepIndex: 0,
      startedAt: DateTime.now(),
      accumulatedPauseMs: 0,
      isExpanded: true,
    );
    await _persist();
    await _syncPlatform();
  }

  Future<void> pause() async {
    if (state == null || state!.isPaused) return;
    state = state!.copyWith(pausedAt: DateTime.now());
    await _persist();
    await _syncPlatform();
  }

  Future<void> resume() async {
    if (state == null || !state!.isPaused) return;
    final extra =
        DateTime.now().difference(state!.pausedAt!).inMilliseconds;
    state = state!.copyWith(
      clearPausedAt: true,
      accumulatedPauseMs: state!.accumulatedPauseMs + extra,
    );
    await _persist();
    await _syncPlatform();
  }

  Future<void> finish() async {
    await _clearPlatform();
    state = null;
    await _persist();
  }

  Future<void> nextStep() async {
    if (state == null) return;
    final next = state!.currentStepIndex + 1;
    if (next < state!.totalSteps) {
      state = state!.copyWith(currentStepIndex: next);
      await _persist();
      await _syncPlatform();
    }
  }

  Future<void> completeStep() async {
    if (state == null) return;
    final completed = {...state!.completedSteps, state!.currentStepIndex};
    final next = state!.currentStepIndex + 1;
    state = state!.copyWith(
      completedSteps: completed,
      currentStepIndex:
          next < state!.totalSteps ? next : state!.currentStepIndex,
    );
    await _persist();
    await _syncPlatform();
  }

  Future<void> previousStep() async {
    if (state == null) return;
    final prev = state!.currentStepIndex - 1;
    if (prev >= 0) {
      // Going back un-completes the step we return to and any later ones.
      await goToStep(prev);
    }
  }

  Future<void> goToStep(int index) async {
    if (state == null) return;
    if (index >= 0 && index < state!.totalSteps) {
      var completed = state!.completedSteps;
      // Jumping backward un-completes that step and any later ones.
      if (index < state!.currentStepIndex) {
        completed = {...completed}..removeWhere((i) => i >= index);
      }
      state = state!.copyWith(
        currentStepIndex: index,
        completedSteps: completed,
      );
      await _persist();
      await _syncPlatform();
    }
  }

  Future<void> setExpanded(bool expanded) async {
    if (state == null) return;
    state = state!.copyWith(isExpanded: expanded);
    await _persist();
  }

  Future<void> _applyAction(String action) async {
    switch (action) {
      case 'pause':
        await pause();
      case 'resume':
        await resume();
      case 'finish':
        await finish();
      case 'next':
        await completeStep();
      case 'prev':
        await previousStep();
    }
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kSessionKey);
    if (json != null) {
      try {
        final restored = CookingSession.fromJsonString(json);
        if (state == null) {
          state = restored;
        }
      } catch (_) {
        await prefs.remove(_kSessionKey);
      }
    }
    await _handlePendingBackgroundAction();
    if (state != null) {
      await _syncPlatform();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    if (state != null) {
      await prefs.setString(_kSessionKey, state!.toJsonString());
    } else {
      await prefs.remove(_kSessionKey);
    }
  }

  Future<void> _syncPlatform() async {
    final s = state;
    if (s == null) return;
    try {
      await CookingNotificationService.instance.show(s);
    } on Object catch (e) {
      log.w('CookingNotificationService.show failed: $e');
    }
    try {
      await CookingLiveActivityService.instance.update(s);
    } on Object catch (e) {
      log.w('CookingLiveActivityService.update failed: $e');
    }
  }

  Future<void> _clearPlatform() async {
    try {
      await CookingNotificationService.instance.cancel();
    } on Object catch (e) {
      log.w('CookingNotificationService.cancel failed: $e');
    }
    try {
      await CookingLiveActivityService.instance.end();
    } on Object catch (e) {
      log.w('CookingLiveActivityService.end failed: $e');
    }
  }

  Future<void> _handlePendingBackgroundAction() async {
    final action = await CookingPendingActionStore.read();
    if (action == null) return;
    await CookingPendingActionStore.clear();
    await _applyAction(action);
  }
}

/// Applies a notification action from a background isolate: mutates the
/// persisted session, updates the ongoing notification, and does not wait for
/// the UI isolate to resume.
@pragma('vm:entry-point')
Future<void> cookingApplyBackgroundAction(String action) async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString(_kSessionKey);

  if (action == 'finish') {
    await prefs.remove(_kSessionKey);
    await CookingPendingActionStore.clear();
    await CookingNotificationService.instance.initialize();
    await CookingNotificationService.instance.cancel();
    return;
  }

  if (json == null) return;

  try {
    var session = CookingSession.fromJsonString(json);
    if (action == 'pause' && !session.isPaused) {
      session = session.copyWith(pausedAt: DateTime.now());
    } else if (action == 'resume' && session.isPaused) {
      final extra =
          DateTime.now().difference(session.pausedAt!).inMilliseconds;
      session = session.copyWith(
        clearPausedAt: true,
        accumulatedPauseMs: session.accumulatedPauseMs + extra,
      );
    } else {
      return;
    }
    await prefs.setString(_kSessionKey, session.toJsonString());
    await CookingPendingActionStore.clear();
    await CookingNotificationService.instance.initialize();
    await CookingNotificationService.instance.show(session);
  } catch (_) {
    // Ignore corrupt session payloads in the background isolate.
  }
}

/// Queues a pending action for the main isolate (iOS Live Activity intents).
Future<void> cookingQueueBackgroundAction(String action) async {
  await CookingPendingActionStore.write(action);
}
