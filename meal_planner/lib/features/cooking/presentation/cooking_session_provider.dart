import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/features/cooking/platform/cooking_live_activity_service.dart';
import 'package:meal_planner/features/cooking/platform/cooking_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSessionKey = 'cooking_session_v1';
const _kPendingActionKey = 'cooking_pending_action_v1';

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
  @override
  CookingSession? build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));

    Future.microtask(_restore);
    return null;
  }

  // ── WidgetsBindingObserver ────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) {
      _handlePendingBackgroundAction();
    }
  }

  // ── Public actions ────────────────────────────────────────────────────────

  Future<void> start({
    required String recipeId,
    required String recipeTitle,
    required List<Ingredient> ingredients,
    required List<RecipeStep> steps,
  }) async {
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
    final extra = DateTime.now()
        .difference(state!.pausedAt!)
        .inMilliseconds;
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

  void nextStep() {
    if (state == null) return;
    final next = state!.currentStepIndex + 1;
    if (next < state!.totalSteps) {
      state = state!.copyWith(currentStepIndex: next);
      _persist();
      _syncPlatform();
    }
  }

  void previousStep() {
    if (state == null) return;
    final prev = state!.currentStepIndex - 1;
    if (prev >= 0) {
      state = state!.copyWith(currentStepIndex: prev);
      _persist();
      _syncPlatform();
    }
  }

  void goToStep(int index) {
    if (state == null) return;
    if (index >= 0 && index < state!.totalSteps) {
      state = state!.copyWith(currentStepIndex: index);
      _persist();
      _syncPlatform();
    }
  }

  void setExpanded(bool expanded) {
    if (state == null) return;
    state = state!.copyWith(isExpanded: expanded);
    _persist();
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kSessionKey);
    if (json != null) {
      try {
        state = CookingSession.fromJsonString(json);
      } catch (_) {
        await prefs.remove(_kSessionKey);
      }
    }
    // Process any action queued by a background notification tap.
    await _handlePendingBackgroundAction();
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
    await CookingNotificationService.instance.show(s);
    await CookingLiveActivityService.instance.update(s);
  }

  Future<void> _clearPlatform() async {
    await CookingNotificationService.instance.cancel();
    await CookingLiveActivityService.instance.end();
  }

  /// Applies an action queued by a background notification button tap.
  Future<void> _handlePendingBackgroundAction() async {
    final prefs = await SharedPreferences.getInstance();
    final action = prefs.getString(_kPendingActionKey);
    if (action == null) return;
    await prefs.remove(_kPendingActionKey);

    switch (action) {
      case 'pause':
        await pause();
      case 'resume':
        await resume();
      case 'finish':
        await finish();
    }
  }
}

/// Called from the background notification isolate to queue an action.
Future<void> cookingQueueBackgroundAction(String action) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kPendingActionKey, action);
}
