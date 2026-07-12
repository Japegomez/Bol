import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/features/recipes/domain/ingredient_label.dart';

enum ForkOptionalNoticeAction { close, edit }

/// Informs the user that the forked recipe includes optional ingredients.
Future<ForkOptionalNoticeAction?> showForkOptionalIngredientsNoticeDialog(
  BuildContext context, {
  required List<Ingredient> optionalIngredients,
}) {
  return showDialog<ForkOptionalNoticeAction>(
    context: context,
    builder: (dialogContext) {
      final l10n = dialogContext.l10n;
      return AlertDialog(
        title: Text(l10n.optionalIngredientsTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.optionalIngredientsMessage),
              const SizedBox(height: 16),
              ...optionalIngredients.map(
                (ingredient) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(formatIngredientLabel(l10n, ingredient)),
                  value: true,
                  onChanged: null,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(ForkOptionalNoticeAction.close),
            child: Text(l10n.understood),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(ForkOptionalNoticeAction.edit),
            child: Text(l10n.editRecipe),
          ),
        ],
      );
    },
  );
}
