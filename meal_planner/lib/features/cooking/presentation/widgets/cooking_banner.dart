import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_session_provider.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_utils.dart';

/// Compact banner shown above the bottom [NavigationBar] while a cooking
/// session is minimized.
class CookingBanner extends ConsumerWidget {
  const CookingBanner({required this.session, super.key});

  final CookingSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch tick to refresh elapsed time display.
    ref.watch(cookingTickProvider);

    final notifier = ref.read(cookingSessionProvider.notifier);
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => notifier.setExpanded(true),
      child: ColoredBox(
        color: theme.colorScheme.primaryContainer,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        session.recipeTitle,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        session.isPaused
                            ? l10n.cookingPausedLabel
                            : formatCookingDuration(session.elapsed),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    session.isPaused ? Icons.play_arrow : Icons.pause,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  tooltip: session.isPaused
                      ? l10n.cookingResumeTooltip
                      : l10n.cookingPauseTooltip,
                  onPressed: session.isPaused
                      ? () => notifier.resume()
                      : () => notifier.pause(),
                ),
                IconButton(
                  icon: Icon(
                    Icons.stop,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  tooltip: l10n.finishCookingButton,
                  onPressed: () => confirmFinishCooking(context, notifier),
                ),
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  tooltip: l10n.expandCookingSession,
                  onPressed: () => notifier.setExpanded(true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
