import 'dart:math' as math;

import 'package:flutter/material.dart';

class OnboardingCardLayout {
  const OnboardingCardLayout({
    required this.left,
    required this.top,
    required this.pointerOnTop,
    required this.pointerOffset,
  });

  final double left;
  final double top;
  final bool pointerOnTop;
  final double pointerOffset;
}

/// Places the onboarding tooltip card relative to [targetRect] and safe areas.
OnboardingCardLayout resolveOnboardingCardLayout({
  required Size screenSize,
  required EdgeInsets viewPadding,
  required double cardWidth,
  required Rect? targetRect,
}) {
  const horizontalMargin = 16.0;
  const gap = 16.0;
  // Tall enough for localized copy + actions; underestimating overlaps FABs.
  const estimatedCardHeight = 280.0;
  const pointerSize = 12.0;
  // App bottom NavigationBar sits above system insets; keep cards clear of it.
  const bottomNavClearance = 80.0;

  final safeTop = viewPadding.top + 12;
  final safeBottom =
      screenSize.height - viewPadding.bottom - bottomNavClearance - 12;
  final maxTop = math.max(safeTop, safeBottom - estimatedCardHeight);
  final minLeft = viewPadding.left + horizontalMargin;
  final maxLeft =
      screenSize.width - cardWidth - (viewPadding.right + horizontalMargin);
  final centeredLeft = (screenSize.width - cardWidth) / 2;
  final centeredTop =
      (screenSize.height - estimatedCardHeight) / 2 - pointerSize;

  if (targetRect == null) {
    return OnboardingCardLayout(
      left: centeredLeft.clamp(minLeft, math.max(minLeft, maxLeft)),
      top: centeredTop.clamp(safeTop, maxTop),
      pointerOnTop: false,
      pointerOffset: cardWidth / 2,
    );
  }

  // Multi-target unions (e.g. search + glossary FAB) can span most of the
  // screen; anchor the card to the top band so it does not fall under the
  // Android system navigation bar.
  final placementRect = targetRect.height > screenSize.height * 0.35
      ? Rect.fromLTWH(
          targetRect.left,
          targetRect.top,
          targetRect.width,
          math.min(88, targetRect.height),
        )
      : targetRect;

  final spaceAbove = placementRect.top - safeTop;
  final spaceBelow = safeBottom - placementRect.bottom;
  var placeAbove =
      spaceAbove >= estimatedCardHeight + gap + pointerSize ||
      spaceAbove >= spaceBelow;

  // Bottom FABs: always prefer above so the tooltip does not cover them.
  final isBottomTarget = placementRect.center.dy > screenSize.height * 0.55;
  if (isBottomTarget && spaceAbove >= estimatedCardHeight * 0.6) {
    placeAbove = true;
  }

  final targetCenterX = placementRect.center.dx;
  var left = targetCenterX - cardWidth / 2;
  left = left.clamp(minLeft, math.max(minLeft, maxLeft));

  final pointerOffset = (targetCenterX - left).clamp(24.0, cardWidth - 24.0);

  double top;
  if (placeAbove) {
    final desiredTop =
        placementRect.top - estimatedCardHeight - gap - pointerSize;
    top = math.max(safeTop, desiredTop);
  } else {
    final desiredTop = placementRect.bottom + gap + pointerSize;
    top = desiredTop.clamp(safeTop, maxTop);
  }

  top = top.clamp(safeTop, maxTop);

  return OnboardingCardLayout(
    left: left,
    top: top,
    pointerOnTop: !placeAbove,
    pointerOffset: pointerOffset,
  );
}
