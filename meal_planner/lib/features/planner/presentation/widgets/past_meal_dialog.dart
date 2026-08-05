import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';

/// Informs the user that a past-day meal will not sync ingredients to shopping.
Future<void> showPastMealPlanDialog(BuildContext context) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.pastMealPlanTitle),
      content: Text(l10n.pastMealPlanMessage),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.understood),
        ),
      ],
    ),
  );
}
