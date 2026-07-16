import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_session_provider.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_utils.dart';
import 'package:meal_planner/features/recipes/domain/ingredient_label.dart';

/// Full-screen overlay displayed when a cooking session is expanded.
///
/// Mounted in [HomeShell]'s outer Stack so it covers the entire screen,
/// including the bottom navigation bar.
class CookingScreen extends ConsumerWidget {
  const CookingScreen({required this.session, super.key});

  final CookingSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cookingSessionProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => notifier.setExpanded(false),
      child: Material(
        color: colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(session: session, notifier: notifier),
              const Divider(height: 1),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StepRail(session: session, notifier: notifier),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _StepContent(session: session),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _NavigationBar(session: session, notifier: notifier),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.session, required this.notifier});

  final CookingSession session;
  final CookingSessionNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(cookingTickProvider);

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final elapsed = session.elapsed;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 4, top: 4, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.recipeTitle,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  session.isPaused
                      ? l10n.cookingPausedLabel
                      : formatCookingDuration(elapsed),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: session.isPaused
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.keyboard_arrow_down),
            tooltip: l10n.minimize,
            onPressed: () => notifier.setExpanded(false),
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step rail ─────────────────────────────────────────────────────────────────

/// Minimal vertical graph of steps: numbered nodes joined by downward arrows.
/// Completed steps become green nodes with a check; the current one is
/// highlighted. Tapping a node jumps to that step.
class _StepRail extends StatelessWidget {
  const _StepRail({required this.session, required this.notifier});

  final CookingSession session;
  final CookingSessionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 56,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            for (var i = 0; i < session.totalSteps; i++) ...[
              if (i > 0) _RailConnector(color: colorScheme.outlineVariant),
              _RailNode(
                index: i,
                isCompleted: session.completedSteps.contains(i),
                isCurrent: i == session.currentStepIndex,
                onTap: () => notifier.goToStep(i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RailConnector extends StatelessWidget {
  const _RailConnector({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 2, height: 10, color: color),
        Icon(Icons.keyboard_arrow_down, size: 14, color: color),
      ],
    );
  }
}

class _RailNode extends StatelessWidget {
  const _RailNode({
    required this.index,
    required this.isCompleted,
    required this.isCurrent,
    required this.onTap,
  });

  final int index;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color background;
    final Color foreground;
    final Border? border;

    if (isCompleted) {
      background = colorScheme.primary;
      foreground = colorScheme.onPrimary;
      // Ring to keep the current step visible when it is already completed.
      border = isCurrent
          ? Border.all(color: colorScheme.onPrimary, width: 2)
          : null;
    } else if (isCurrent) {
      background = colorScheme.primary;
      foreground = colorScheme.onPrimary;
      border = null;
    } else {
      background = Colors.transparent;
      foreground = colorScheme.onSurfaceVariant;
      border = Border.all(color: colorScheme.outlineVariant, width: 1.5);
    }

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: border,
        ),
        alignment: Alignment.center,
        child: isCompleted
            ? Icon(Icons.check, size: 18, color: colorScheme.onPrimary)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: foreground,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}

// ── Step content ──────────────────────────────────────────────────────────────

class _StepContent extends ConsumerWidget {
  const _StepContent({required this.session});

  final CookingSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isIngredientStep = session.currentStepIndex == 0;
    final stepNumber = session.currentStepIndex + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.stepXofY(stepNumber, session.totalSteps),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isIngredientStep
                ? l10n.checkIngredientsStep
                : (session.steps[session.currentStepIndex - 1].isOptional
                    ? '${l10n.optionalStepPrefix} ${session.steps[session.currentStepIndex - 1].description}'
                    : session.steps[session.currentStepIndex - 1].description),
            style: theme.textTheme.titleLarge,
          ),
          if (isIngredientStep) ...[
            const SizedBox(height: 16),
            ...session.ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        formatIngredientLabel(l10n, ingredient),
                        style: ingredient.isOptional && !ingredient.isIncluded
                            ? TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _NavigationBar extends StatefulWidget {
  const _NavigationBar({required this.session, required this.notifier});

  final CookingSession session;
  final CookingSessionNotifier notifier;

  @override
  State<_NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<_NavigationBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _finishController;

  static const _holdDuration = Duration(milliseconds: 1600);

  @override
  void initState() {
    super.initState();
    _finishController = AnimationController(
      vsync: this,
      duration: _holdDuration,
    )..addStatusListener(_onFinishStatus);
  }

  @override
  void dispose() {
    _finishController.dispose();
    super.dispose();
  }

  void _onFinishStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _finishController.reset();
      confirmFinishCooking(context, widget.notifier);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final session = widget.session;
    final notifier = widget.notifier;
    final isFirst = session.currentStepIndex == 0;
    final isLast = session.isOnLastStep;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CookingIconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: l10n.previousStep,
            onPressed: isFirst ? null : notifier.previousStep,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CookingIconButton(
                icon: Icon(
                  session.isPaused ? Icons.play_arrow : Icons.pause,
                ),
                tooltip: session.isPaused
                    ? l10n.cookingResumeTooltip
                    : l10n.cookingPauseTooltip,
                onPressed: session.isPaused
                    ? notifier.resume
                    : notifier.pause,
              ),
              const SizedBox(width: 16),
              Tooltip(
                message: l10n.finishCookingButton,
                child: GestureDetector(
                  onLongPressStart: (_) => _finishController.forward(),
                  onLongPressEnd: (_) {
                    if (_finishController.status !=
                        AnimationStatus.completed) {
                      _finishController.reset();
                    }
                  },
                  onLongPressCancel: _finishController.reset,
                  child: AnimatedBuilder(
                    animation: _finishController,
                    builder: (context, _) {
                      final progress = _finishController.value;
                      return SizedBox(
                        width: 48,
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.stop_rounded,
                                color: colorScheme.primary,
                                size: 22,
                              ),
                            ),
                            if (progress > 0)
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 3,
                                  color: colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          _CookingIconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            tooltip: l10n.nextStep,
            onPressed: isLast ? null : notifier.completeStep,
          ),
        ],
      ),
    );
  }
}

class _CookingIconButton extends StatelessWidget {
  const _CookingIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: icon,
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor:
            colorScheme.onSurface.withValues(alpha: 0.38),
        backgroundColor: colorScheme.primaryContainer,
        disabledBackgroundColor:
            colorScheme.primaryContainer.withValues(alpha: 0.4),
      ),
    );
  }
}

