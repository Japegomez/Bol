import 'package:flutter/material.dart';

/// Full recipe title shown at the top of the detail body (never truncated).
class RecipeDetailBodyTitle extends StatelessWidget {
  const RecipeDetailBodyTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
    );
  }
}

/// Single-line title for the collapsed recipe [SliverAppBar] toolbar.
class RecipeAppBarTitle extends StatelessWidget {
  const RecipeAppBarTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

/// Scroll offset at which the flexible recipe header is effectively collapsed.
double recipeAppBarCollapseOffset({required bool hasPhoto}) {
  final expanded = hasPhoto ? 240.0 : 120.0;
  return (expanded - kToolbarHeight) * 0.85;
}
