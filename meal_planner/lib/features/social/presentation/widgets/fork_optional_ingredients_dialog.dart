import 'package:flutter/material.dart';
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
      return AlertDialog(
        title: const Text('Ingredientes opcionales'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Esta receta contiene ingredientes opcionales. '
                'Añádelos o elimínalos en tu receta.',
              ),
              const SizedBox(height: 16),
              ...optionalIngredients.map(
                (ingredient) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(formatIngredientLabel(ingredient)),
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
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(ForkOptionalNoticeAction.edit),
            child: const Text('Editar receta'),
          ),
        ],
      );
    },
  );
}
