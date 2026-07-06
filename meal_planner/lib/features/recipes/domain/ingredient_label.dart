import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';

String _formatQuantity(num quantity, {bool round = false}) {
  final value = round ? quantity.round() : quantity;
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toString();
}

String formatIngredientDisplay({
  required String name,
  num? quantity,
  String? unit,
  bool isToTaste = false,
  bool roundQuantity = false,
}) {
  if (isToTaste) {
    return '${name.toLowerCase()} al gusto';
  }

  final formattedUnit = formatUnit(unit, quantity);
  final hasQuantity = quantity != null;
  final hasUnit = formattedUnit != null && formattedUnit.isNotEmpty;

  if (hasQuantity && hasUnit && isAbbreviatedUnit(unit)) {
    return '${_formatQuantity(quantity, round: roundQuantity)}$formattedUnit de ${name.toLowerCase()}';
  }

  if (hasQuantity && hasUnit) {
    return '${_formatQuantity(quantity, round: roundQuantity)} $formattedUnit de ${name.toLowerCase()}';
  }

  if (hasQuantity) {
    return '${_formatQuantity(quantity, round: roundQuantity)} $name';
  }

  return name;
}

String formatIngredientLabel(Ingredient ingredient) {
  return formatIngredientDisplay(
    name: ingredient.name,
    quantity: ingredient.quantity,
    unit: ingredient.unit,
    isToTaste: ingredient.isToTaste,
  );
}

String formatShoppingItemLabel({
  required String name,
  num? quantity,
  String? unit,
}) {
  return formatIngredientDisplay(
    name: name,
    quantity: quantity,
    unit: unit,
    roundQuantity: true,
  );
}
