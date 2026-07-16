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
                child: _StepContent(session: session),
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
    // Watch tick to refresh elapsed time display.
    ref.watch(cookingTickProvider);

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final elapsed = session.elapsed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            tooltip: l10n.minimize,
            onPressed: () => notifier.setExpanded(false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  session.recipeTitle,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
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
          IconButton(
            icon: Icon(session.isPaused ? Icons.play_arrow : Icons.pause),
            tooltip: session.isPaused ? l10n.cookingResumeTooltip : l10n.cookingPauseTooltip,
            onPressed:
                session.isPaused ? () => notifier.resume() : () => notifier.pause(),
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            tooltip: l10n.finishCookingButton,
            onPressed: () => confirmFinishCooking(context, notifier),
          ),
        ],
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

// ── Navigation bar ────────────────────────────────────────────────────────────

class _NavigationBar extends StatelessWidget {
  const _NavigationBar({required this.session, required this.notifier});

  final CookingSession session;
  final CookingSessionNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isFirst = session.currentStepIndex == 0;
    final isLast = session.isOnLastStep;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton.outlined(
            icon: const Icon(Icons.arrow_back_ios_new),
            tooltip: l10n.previousStep,
            onPressed: isFirst ? null : notifier.previousStep,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: isLast
                  ? () => confirmFinishCooking(context, notifier)
                  : notifier.nextStep,
              child: Text(
                isLast ? l10n.finishCookingButton : l10n.completeStepButton,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.outlined(
            icon: const Icon(Icons.arrow_forward_ios),
            tooltip: l10n.nextStep,
            onPressed: isLast ? null : notifier.nextStep,
          ),
        ],
      ),
    );
  }
}

