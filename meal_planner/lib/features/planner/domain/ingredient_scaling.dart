/// Scale factor when assigning a recipe to a planner slot.
///
/// [chosenServings] is what the user picked for that meal;
/// [recipeServings] is the base yield on the recipe card.
double servingsScale({
  required int chosenServings,
  required int recipeServings,
}) {
  if (recipeServings < 1) return 0;
  return chosenServings / recipeServings;
}

/// Scales an ingredient quantity for the shopping list.
///
/// Returns `null` when the ingredient has no quantity (e.g. "to taste").
/// Otherwise multiplies by [scale] and rounds to the nearest integer
/// (same behaviour as planner → shopping sync).
num? scaleIngredientQuantity(num? quantity, double scale) {
  if (quantity == null) return null;
  return (quantity * scale).round();
}
