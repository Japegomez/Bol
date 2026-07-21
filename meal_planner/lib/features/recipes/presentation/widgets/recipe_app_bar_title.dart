import 'package:flutter/material.dart';

/// Title for recipe [FlexibleSpaceBar]s: scrim for contrast when expanded,
/// plain text (no scrim) when collapsed, with ellipsis so it does not overlap
/// leading/trailing actions.
class RecipeAppBarTitle extends StatelessWidget {
  const RecipeAppBarTitle({required this.title, super.key});

  final String title;

  static const _scrimOpacity = 0.8;
  static const _scrimColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final collapseT = _collapseT(settings);
    final isCollapsed = collapseT >= 0.85;
    final scrimT = (1.0 - collapseT).clamp(0.0, 1.0);

    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.black,
        );

    final text = Text(
      title,
      maxLines: isCollapsed ? 1 : 2,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );

    // Collapsed: plain title so AppBar vertical alignment stays correct.
    if (scrimT <= 0.01) return text;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scrimT,
        vertical: 4 * scrimT,
      ),
      decoration: BoxDecoration(
        color: _scrimColor.withValues(alpha: _scrimOpacity * scrimT),
        borderRadius: BorderRadius.circular(6 * scrimT),
      ),
      child: text,
    );
  }

  static double _collapseT(FlexibleSpaceBarSettings? settings) {
    if (settings == null) return 0;
    final range = settings.maxExtent - settings.minExtent;
    if (range <= 0) return 1;
    return ((settings.maxExtent - settings.currentExtent) / range)
        .clamp(0.0, 1.0);
  }
}
