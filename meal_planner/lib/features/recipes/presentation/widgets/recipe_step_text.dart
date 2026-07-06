import 'package:flutter/material.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';

class RecipeStepText extends StatelessWidget {
  const RecipeStepText({required this.step, super.key});

  final RecipeStep step;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    if (!step.isOptional) {
      return Text(step.description, style: style);
    }
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(
            text: 'Opcional: ',
            style: style.copyWith(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: step.description),
        ],
      ),
    );
  }
}
