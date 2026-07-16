import 'dart:convert';

import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';

class CookingSession {
  const CookingSession({
    required this.recipeId,
    required this.recipeTitle,
    required this.ingredients,
    required this.steps,
    required this.currentStepIndex,
    required this.startedAt,
    this.pausedAt,
    required this.accumulatedPauseMs,
    this.isExpanded = true,
  });

  final String recipeId;
  final String recipeTitle;

  /// Snapshot of ingredients at the time cooking started.
  final List<Ingredient> ingredients;

  /// Snapshot of recipe steps. Step index 0 is synthetic "check ingredients".
  final List<RecipeStep> steps;

  /// 0 = "Check ingredients" (synthetic), 1..N = recipe steps.
  final int currentStepIndex;

  final DateTime startedAt;

  /// Non-null while the session is paused; null while running.
  final DateTime? pausedAt;

  /// Accumulated paused duration in milliseconds (excluding the current pause).
  final int accumulatedPauseMs;

  /// Whether the full-screen cooking overlay is visible.
  final bool isExpanded;

  bool get isPaused => pausedAt != null;

  /// Total steps including the synthetic "check ingredients" step.
  int get totalSteps => steps.length + 1;

  bool get isOnLastStep => currentStepIndex == totalSteps - 1;

  /// Elapsed cooking time, not counting paused periods.
  Duration get elapsed {
    final end = pausedAt ?? DateTime.now();
    final raw = end.difference(startedAt);
    return raw - Duration(milliseconds: accumulatedPauseMs);
  }

  CookingSession copyWith({
    int? currentStepIndex,
    DateTime? pausedAt,
    bool clearPausedAt = false,
    int? accumulatedPauseMs,
    bool? isExpanded,
  }) {
    return CookingSession(
      recipeId: recipeId,
      recipeTitle: recipeTitle,
      ingredients: ingredients,
      steps: steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      startedAt: startedAt,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      accumulatedPauseMs: accumulatedPauseMs ?? this.accumulatedPauseMs,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'ingredients': ingredients.map(_ingredientToMap).toList(),
      'steps': steps.map(_stepToMap).toList(),
      'currentStepIndex': currentStepIndex,
      'startedAtMs': startedAt.millisecondsSinceEpoch,
      'pausedAtMs': pausedAt?.millisecondsSinceEpoch,
      'accumulatedPauseMs': accumulatedPauseMs,
      'isExpanded': isExpanded,
    };
  }

  factory CookingSession.fromJson(Map<String, dynamic> json) {
    final ingredients = (json['ingredients'] as List<dynamic>)
        .map(
          (e) => Ingredient.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
    final steps = (json['steps'] as List<dynamic>)
        .map(
          (e) => RecipeStep.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();

    return CookingSession(
      recipeId: json['recipeId'] as String,
      recipeTitle: json['recipeTitle'] as String,
      ingredients: ingredients,
      steps: steps,
      currentStepIndex: json['currentStepIndex'] as int,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        json['startedAtMs'] as int,
      ),
      pausedAt: json['pausedAtMs'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['pausedAtMs'] as int)
          : null,
      accumulatedPauseMs: json['accumulatedPauseMs'] as int,
      isExpanded: json['isExpanded'] as bool? ?? true,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory CookingSession.fromJsonString(String source) =>
      CookingSession.fromJson(jsonDecode(source) as Map<String, dynamic>);

  // ── Private serialization helpers ─────────────────────────────────────────

  static Map<String, dynamic> _ingredientToMap(Ingredient i) => {
        'id': i.id,
        'recipe_id': i.recipeId,
        'name': i.name,
        if (i.quantity != null) 'quantity': i.quantity.toString(),
        if (i.unit != null) 'unit': i.unit,
        if (i.category != null) 'category': i.category,
        'position': i.position,
        'is_optional': i.isOptional,
        'is_included': i.isIncluded,
        'is_to_taste': i.isToTaste,
      };

  static Map<String, dynamic> _stepToMap(RecipeStep s) => {
        'id': s.id,
        'recipe_id': s.recipeId,
        'position': s.position,
        'description': s.description,
        'is_optional': s.isOptional,
      };
}
