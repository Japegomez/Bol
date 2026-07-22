import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Title for recipe [FlexibleSpaceBar]s: white scrim + black text when expanded
/// over a photo; plain text (no scrim) when collapsed so the AppBar centers it.
///
/// Parents should use a small [FlexibleSpaceBar.titlePadding] start (~16); this
/// widget adds leading inset as the bar collapses so the title clears the back
/// button.
class RecipeAppBarTitle extends StatelessWidget {
  const RecipeAppBarTitle({required this.title, super.key});

  final String title;

  static const _scrimOpacity = 0.8;
  static const _scrimColor = Colors.white;
  /// Extra start inset when fully collapsed (with parent start ≈ 16 → ~72 total).
  static const _collapsedLeadingInset = 56.0;

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final collapseT = _collapseT(settings);
    final isCollapsed = collapseT >= 0.85;
    final scrimT = (1.0 - collapseT).clamp(0.0, 1.0);
    final leadingInset =
        lerpDouble(0, _collapsedLeadingInset, collapseT) ?? 0;

    // Same token as section headers (Ingredientes, etc.); only color forced.
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.black,
        );

    final text = Text(
      title,
      maxLines: isCollapsed ? 1 : 2,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );

    final child = scrimT <= 0.01
        ? text
        : Container(
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

    return Padding(
      padding: EdgeInsetsDirectional.only(start: leadingInset),
      child: child,
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
