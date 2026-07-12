import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';

class RecipeStepText extends StatelessWidget {
  const RecipeStepText({required this.step, super.key});

  final RecipeStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = DefaultTextStyle.of(context).style;
    if (!step.isOptional) {
      return Text(step.description, style: style);
    }
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(
            text: '${l10n.optionalStepPrefix} ',
            style: style.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: step.description),
        ],
      ),
    );
  }
}
