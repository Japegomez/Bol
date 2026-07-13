import 'package:flutter/material.dart';

/// UI elements that can be highlighted during the onboarding tour.
enum OnboardingTarget {
  plannerWeekHeader,
  plannerFab,
  recipesSearchBar,
  recipesGlossaryFab,
  recipesFab,
  shoppingAddFab,
  shoppingShareButton,
  exploreFeedButton,
  profileEditTile,
  profileHouseholdTile,
}

/// Global registry of [GlobalKey]s for onboarding spotlight targets.
abstract final class OnboardingTargets {
  static final _keys = <OnboardingTarget, GlobalKey>{
    for (final target in OnboardingTarget.values) target: GlobalKey(),
  };

  static GlobalKey keyFor(OnboardingTarget target) => _keys[target]!;

  /// Returns the global bounds of [target] if it is currently laid out.
  static Rect? boundsFor(OnboardingTarget target) {
    final context = _keys[target]?.currentContext;
    if (context == null) return null;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;

    final offset = renderObject.localToGlobal(Offset.zero);
    return offset & renderObject.size;
  }

  static List<Rect> boundsForTargets(List<OnboardingTarget> targets) {
    return [
      for (final target in targets)
        ?boundsFor(target),
    ].nonNulls.toList();
  }

  static Rect? unionBounds(List<OnboardingTarget> targets) {
    final rects = boundsForTargets(targets);
    if (rects.isEmpty) return null;
    return rects.reduce((a, b) => a.expandToInclude(b));
  }
}
