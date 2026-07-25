import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_card_layout.dart';

void main() {
  group('resolveOnboardingCardLayout', () {
    test(
      'placeAbove with insufficient space clamps top to safeTop',
      () {
        const screenSize = Size(390, 844);
        const viewPadding = EdgeInsets.only(top: 47, bottom: 34);
        const cardWidth = 358.0;
        // Tall target collapses to an 88px top band; spaceAbove barely beats
        // spaceBelow so placeAbove wins even though the full card does not fit.
        const targetRect = Rect.fromLTWH(20, 350, 350, 400);

        final layout = resolveOnboardingCardLayout(
          screenSize: screenSize,
          viewPadding: viewPadding,
          cardWidth: cardWidth,
          targetRect: targetRect,
        );

        final safeTop = viewPadding.top + 12;
        expect(layout.pointerOnTop, isFalse);
        expect(layout.top, safeTop);
      },
    );

    test('horizontal clamp respects left and right view padding', () {
      const screenSize = Size(390, 844);
      const viewPadding = EdgeInsets.only(left: 20, right: 30, top: 47);
      const cardWidth = 300.0;
      const targetRect = Rect.fromLTWH(-40, 400, 40, 40);

      final layout = resolveOnboardingCardLayout(
        screenSize: screenSize,
        viewPadding: viewPadding,
        cardWidth: cardWidth,
        targetRect: targetRect,
      );

      expect(layout.left, viewPadding.left + 16);
    });
  });
}
