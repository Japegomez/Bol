import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_targets.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_tour_provider.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

class OnboardingOverlay extends ConsumerStatefulWidget {
  const OnboardingOverlay({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends ConsumerState<OnboardingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  List<Rect> _targetRects = const [];
  int _measureGeneration = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTabForStep();
      _scheduleMeasure();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleMeasure();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _syncTabForStep() {
    final step = ref.read(onboardingTourStepProvider);
    final tabIndex = onboardingTourSteps[step].tabIndex;

    if (tabIndex == OnboardingTabIndex.explore && ref.read(isOfflineProvider)) {
      return;
    }

    if (widget.navigationShell.currentIndex != tabIndex) {
      widget.navigationShell.goBranch(tabIndex, initialLocation: false);
    }
  }

  void _scheduleMeasure() {
    final generation = ++_measureGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _measureGeneration) return;
      _measureTarget();
    });
  }

  void _measureTarget() {
    final step = ref.read(onboardingTourStepProvider);
    final targets = onboardingTourSteps[step].targets;
    final rects = OnboardingTargets.boundsForTargets(targets);

    if (!mounted) return;
    setState(() => _targetRects = rects);
  }

  Rect? get _layoutRect {
    if (_targetRects.isEmpty) return null;
    return _targetRects.reduce((a, b) => a.expandToInclude(b));
  }

  ({String title, String body}) _copyForStep(AppLocalizations l10n, int step) {
    return switch (step) {
      0 => (title: l10n.onboardingStep0Title, body: l10n.onboardingStep0Body),
      1 => (title: l10n.onboardingStep1Title, body: l10n.onboardingStep1Body),
      2 => (title: l10n.onboardingStep2Title, body: l10n.onboardingStep2Body),
      3 => (title: l10n.onboardingStep3Title, body: l10n.onboardingStep3Body),
      4 => (title: l10n.onboardingStep4Title, body: l10n.onboardingStep4Body),
      5 => (title: l10n.onboardingStep5Title, body: l10n.onboardingStep5Body),
      6 => (title: l10n.onboardingStep6Title, body: l10n.onboardingStep6Body),
      7 => (title: l10n.onboardingStep7Title, body: l10n.onboardingStep7Body),
      8 => (title: l10n.onboardingStep8Title, body: l10n.onboardingStep8Body),
      9 => (title: l10n.onboardingStep9Title, body: l10n.onboardingStep9Body),
      10 => (title: l10n.onboardingStep10Title, body: l10n.onboardingStep10Body),
      _ => (title: l10n.onboardingStep0Title, body: l10n.onboardingStep0Body),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final step = ref.watch(onboardingTourStepProvider);
    final tour = ref.read(onboardingTourStepProvider.notifier);
    final isLast = tour.isLastStep;
    final copy = _copyForStep(l10n, step);
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;

    ref.listen<int>(onboardingTourStepProvider, (previous, next) {
      if (previous != next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _syncTabForStep();
          _scheduleMeasure();
        });
      }
    });

    ref.listen<bool>(isOfflineProvider, (previous, next) {
      if (previous == true && next == false) {
        final currentStep = ref.read(onboardingTourStepProvider);
        if (onboardingTourSteps[currentStep].tabIndex ==
            OnboardingTabIndex.explore) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _syncTabForStep();
            _scheduleMeasure();
          });
        }
      }
    });

    final cardWidth = math.min(screenSize.width - 32, 420.0);
    final cardLayout = _resolveCardLayout(
      screenSize: screenSize,
      padding: padding,
      cardWidth: cardWidth,
      targetRect: _layoutRect,
    );

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _OnboardingScrimPainter(
                        targetRects: _targetRects,
                        pulseValue: _pulseController.value,
                        scrimColor: Colors.black.withValues(alpha: 0.62),
                        haloColor: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              left: cardLayout.left,
              top: cardLayout.top,
              width: cardWidth,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.96, end: 1).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: _OnboardingCard(
                  key: ValueKey<int>(step),
                  cardWidth: cardWidth,
                  title: copy.title,
                  body: copy.body,
                  step: step,
                  totalSteps: onboardingTourSteps.length,
                  showPrevious: step > 0,
                  isLast: isLast,
                  pointerOnTop: cardLayout.pointerOnTop,
                  pointerOffset: cardLayout.pointerOffset,
                  skipLabel: l10n.onboardingSkip,
                  previousLabel: l10n.onboardingPrevious,
                  nextLabel: l10n.onboardingNext,
                  finishLabel: l10n.onboardingFinish,
                  onSkip: tour.skip,
                  onPrevious: tour.previous,
                  onNext: tour.next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardLayout {
  const _CardLayout({
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

_CardLayout _resolveCardLayout({
  required Size screenSize,
  required EdgeInsets padding,
  required double cardWidth,
  required Rect? targetRect,
}) {
  const horizontalMargin = 16.0;
  const gap = 16.0;
  const estimatedCardHeight = 220.0;
  const pointerSize = 12.0;

  final safeTop = padding.top + 12;
  final safeBottom = screenSize.height - padding.bottom - 12;
  final centeredLeft = (screenSize.width - cardWidth) / 2;
  final centeredTop =
      (screenSize.height - estimatedCardHeight) / 2 - pointerSize;

  if (targetRect == null) {
    return _CardLayout(
      left: centeredLeft.clamp(horizontalMargin, screenSize.width - cardWidth - horizontalMargin),
      top: centeredTop.clamp(safeTop, safeBottom - estimatedCardHeight),
      pointerOnTop: false,
      pointerOffset: cardWidth / 2,
    );
  }

  final spaceAbove = targetRect.top - safeTop;
  final spaceBelow = safeBottom - targetRect.bottom;
  final placeAbove = spaceAbove >= spaceBelow;

  final targetCenterX = targetRect.center.dx;
  var left = targetCenterX - cardWidth / 2;
  left = left.clamp(
    horizontalMargin,
    screenSize.width - cardWidth - horizontalMargin,
  );

  final pointerOffset =
      (targetCenterX - left).clamp(24.0, cardWidth - 24.0);

  final top = placeAbove
      ? targetRect.top - estimatedCardHeight - gap - pointerSize
      : targetRect.bottom + gap + pointerSize;

  return _CardLayout(
    left: left,
    top: top.clamp(safeTop, safeBottom - estimatedCardHeight),
    pointerOnTop: !placeAbove,
    pointerOffset: pointerOffset,
  );
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required super.key,
    required this.cardWidth,
    required this.title,
    required this.body,
    required this.step,
    required this.totalSteps,
    required this.showPrevious,
    required this.isLast,
    required this.pointerOnTop,
    required this.pointerOffset,
    required this.skipLabel,
    required this.previousLabel,
    required this.nextLabel,
    required this.finishLabel,
    required this.onSkip,
    required this.onPrevious,
    required this.onNext,
  });

  final double cardWidth;
  final String title;
  final String body;
  final int step;
  final int totalSteps;
  final bool showPrevious;
  final bool isLast;
  final bool pointerOnTop;
  final double pointerOffset;
  final String skipLabel;
  final String previousLabel;
  final String nextLabel;
  final String finishLabel;
  final VoidCallback onSkip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pointerOnTop)
          _CardPointer(
            cardWidth: cardWidth,
            offset: pointerOffset,
            color: colorScheme.surfaceContainerLowest,
            pointingUp: true,
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: List.generate(totalSteps, (index) {
                    final active = index == step;
                    final passed = index < step;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < totalSteps - 1 ? 5 : 0,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          height: active ? 8 : 6,
                          decoration: BoxDecoration(
                            color: active || passed
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(
                      onPressed: onSkip,
                      child: Text(skipLabel),
                    ),
                    const Spacer(),
                    if (showPrevious) ...[
                      Semantics(
                        button: true,
                        label: previousLabel,
                        child: IconButton.filledTonal(
                          onPressed: onPrevious,
                          tooltip: previousLabel,
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Semantics(
                      button: true,
                      label: isLast ? finishLabel : nextLabel,
                      child: IconButton.filled(
                        onPressed: onNext,
                        tooltip: isLast ? finishLabel : nextLabel,
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        icon: Icon(
                          isLast
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (!pointerOnTop)
          _CardPointer(
            cardWidth: cardWidth,
            offset: pointerOffset,
            color: colorScheme.surfaceContainerLowest,
            pointingUp: false,
          ),
      ],
    );
  }
}

class _CardPointer extends StatelessWidget {
  const _CardPointer({
    required this.cardWidth,
    required this.offset,
    required this.color,
    required this.pointingUp,
  });

  final double cardWidth;
  final double offset;
  final Color color;
  final bool pointingUp;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Align(
        alignment: Alignment(-1 + (2 * offset / cardWidth), 0),
        child: CustomPaint(
          size: const Size(18, 12),
          painter: _CardPointerPainter(
            color: color,
            pointingUp: pointingUp,
          ),
        ),
      ),
    );
  }
}

class _CardPointerPainter extends CustomPainter {
  const _CardPointerPainter({
    required this.color,
    required this.pointingUp,
  });

  final Color color;
  final bool pointingUp;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (pointingUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CardPointerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.pointingUp != pointingUp;
  }
}

class _OnboardingScrimPainter extends CustomPainter {
  const _OnboardingScrimPainter({
    required this.targetRects,
    required this.pulseValue,
    required this.scrimColor,
    required this.haloColor,
  });

  final List<Rect> targetRects;
  final double pulseValue;
  final Color scrimColor;
  final Color haloColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;
    final scrimPaint = Paint()..color = scrimColor;

    if (targetRects.isEmpty) {
      canvas.drawRect(fullRect, scrimPaint);
      return;
    }

    final scrimPath = Path()..addRect(fullRect);
    for (final targetRect in targetRects) {
      final holeRect = _holeRectFor(targetRect);
      scrimPath.addRRect(
        RRect.fromRectAndRadius(holeRect, const Radius.circular(14)),
      );
    }
    scrimPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(scrimPath, scrimPaint);

    final pulse = 0.5 + 0.5 * math.sin(pulseValue * 2 * math.pi);
    for (final targetRect in targetRects) {
      final holeRect = _holeRectFor(targetRect);
      final haloPaint = Paint()
        ..color = haloColor.withValues(alpha: 0.18 + pulse * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 + pulse * 2;
      final haloRect = holeRect.inflate(6 + pulse * 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(haloRect, const Radius.circular(18)),
        haloPaint,
      );

      final innerGlow = Paint()
        ..color = haloColor.withValues(alpha: 0.12 + pulse * 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(holeRect, const Radius.circular(14)),
        innerGlow,
      );
    }
  }

  Rect _holeRectFor(Rect target) {
    const padding = 6.0;
    final isCompact = target.width <= 72 && target.height <= 72;

    if (isCompact) {
      final side = math.max(target.width, target.height) + padding * 2;
      return Rect.fromCenter(
        center: target.center,
        width: side,
        height: side,
      );
    }

    return target.inflate(padding);
  }

  @override
  bool shouldRepaint(covariant _OnboardingScrimPainter oldDelegate) {
    return oldDelegate.targetRects != targetRects ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.scrimColor != scrimColor ||
        oldDelegate.haloColor != haloColor;
  }
}
