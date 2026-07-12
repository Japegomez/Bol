import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/features/shopping/presentation/shopping_provider.dart';

ShoppingItem _recipeItem({
  required String id,
  required num quantity,
  required String unit,
}) {
  return ShoppingItem(
    id: id,
    shoppingListId: 'list-id',
    name: 'Huevo',
    quantity: quantity,
    unit: unit,
    category: 'Huevos y lácteos',
    isChecked: false,
    isManual: false,
    createdAt: DateTime(2026),
  );
}

void main() {
  test('consolidates recipe items with singular and plural units', () {
    final items = consolidateShoppingItems([
      _recipeItem(id: 'one-egg', quantity: 1, unit: 'unidad'),
      _recipeItem(id: 'five-eggs', quantity: 5, unit: 'unidades'),
    ]);

    expect(items, hasLength(1));
    expect(items.single.quantity, 6);
    expect(items.single.unit, 'unidad');
  });
}
