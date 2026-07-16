import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_session_provider.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_utils.dart';
import 'package:meal_planner/features/cooking/presentation/widgets/cooking_finish_hold_button.dart';

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
    final onContainer = theme.colorScheme.onPrimaryContainer;

    return GestureDetector(
      onTap: () => notifier.setExpanded(true),
      child: ColoredBox(
        color: theme.colorScheme.primaryContainer,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SizedBox(
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 88),
                      child: Text(
                        session.recipeTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: onContainer,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Text(
                    session.isPaused
                        ? l10n.cookingPausedLabel
                        : formatCookingDuration(session.elapsed),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w600,
                      color: onContainer,
                      height: 1.1,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BannerIconButton(
                          icon: session.isPaused
                              ? Icons.play_arrow
                              : Icons.pause,
                          tooltip: session.isPaused
                              ? l10n.cookingResumeTooltip
                              : l10n.cookingPauseTooltip,
                          color: onContainer,
                          onPressed: session.isPaused
                              ? () => notifier.resume()
                              : () => notifier.pause(),
                        ),
                        CookingFinishHoldButton(
                          notifier: notifier,
                          iconColor: onContainer,
                          backgroundColor: Colors.transparent,
                          size: 48,
                          innerSize: 36,
                          iconSize: 26,
                        ),
                        _BannerIconButton(
                          icon: Icons.keyboard_arrow_up,
                          tooltip: l10n.expandCookingSession,
                          color: onContainer,
                          onPressed: () => notifier.setExpanded(true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerIconButton extends StatelessWidget {
  const _BannerIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: color, size: 26),
      style: IconButton.styleFrom(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.all(2),
        minimumSize: const Size(48, 48),
      ),
    );
  }
}
