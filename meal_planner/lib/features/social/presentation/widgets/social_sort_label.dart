import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';

class SocialSortOption<T> {
  const SocialSortOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Shows the active sort order above recipe lists.
///
/// When [options] and [onSelected] are set, the current label opens a menu.
class SocialSortLabel<T> extends StatelessWidget {
  const SocialSortLabel({
    required this.label,
    this.value,
    this.options,
    this.onSelected,
    super.key,
  });

  final String label;
  final T? value;
  final List<SocialSortOption<T>>? options;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    final canSelect =
        options != null && options!.isNotEmpty && onSelected != null;
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final style = Theme.of(
      context,
    ).textTheme.labelMedium?.copyWith(color: color);

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.sort, size: 16, color: color),
        const SizedBox(width: 6),
        Text(context.l10n.sortedBy(label), style: style),
        if (canSelect) Icon(Icons.arrow_drop_down, size: 20, color: color),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: canSelect
            ? PopupMenuButton<T>(
                initialValue: value,
                tooltip: context.l10n.sortedBy(label),
                padding: EdgeInsets.zero,
                onSelected: onSelected,
                itemBuilder: (context) => [
                  for (final option in options!)
                    PopupMenuItem(
                      value: option.value,
                      child: Text(option.label),
                    ),
                ],
                child: row,
              )
            : row,
      ),
    );
  }
}
