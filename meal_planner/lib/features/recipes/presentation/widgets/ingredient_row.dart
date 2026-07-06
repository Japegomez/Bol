import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/features/recipes/domain/recipe_constants.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';

class IngredientRow extends StatelessWidget {
  const IngredientRow({
    required this.index,
    required this.ingredient,
    required this.onChanged,
    required this.onRemove,
    required this.canRemove,
    super.key,
  });

  final int index;
  final IngredientFormItem ingredient;
  final ValueChanged<IngredientFormItem> onChanged;
  final VoidCallback onRemove;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final unitItems = [
      ...predefinedUnits,
      customUnitOption,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: ingredient.name,
                    decoration: const InputDecoration(
                      labelText: 'Ingrediente',
                      isDense: true,
                    ),
                    onChanged: (value) =>
                        onChanged(ingredient.copyWith(name: value)),
                  ),
                ),
                if (canRemove)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onRemove,
                    tooltip: 'Eliminar ingrediente',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (!ingredient.isToTaste)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: ingredient.quantity?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*[.,]?\d*'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        final parsed =
                            num.tryParse(value.trim().replaceAll(',', '.'));
                        if (parsed == null) {
                          return 'Introduce un número válido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value.trim().isEmpty) {
                          onChanged(ingredient.copyWith(quantity: null));
                          return;
                        }
                        final parsed =
                            num.tryParse(value.replaceAll(',', '.'));
                        onChanged(ingredient.copyWith(quantity: parsed));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: ingredient.useCustomUnit
                          ? customUnitOption
                          : (ingredient.unit ?? predefinedUnits.first),
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        isDense: true,
                      ),
                      items: unitItems
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == customUnitOption) {
                          onChanged(
                            ingredient.copyWith(
                              useCustomUnit: true,
                              unit: null,
                            ),
                          );
                        } else {
                          onChanged(
                            ingredient.copyWith(
                              useCustomUnit: false,
                              unit: value,
                              customUnit: '',
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            if (ingredient.useCustomUnit && !ingredient.isToTaste) ...[
              const SizedBox(height: 8),
              TextFormField(
                initialValue: ingredient.customUnit,
                decoration: const InputDecoration(
                  labelText: 'Unidad personalizada',
                  isDense: true,
                ),
                onChanged: (value) =>
                    onChanged(ingredient.copyWith(customUnit: value)),
              ),
            ],
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: ingredientCategories.contains(ingredient.category)
                  ? ingredient.category
                  : ingredientCategories.first,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                isDense: true,
              ),
              items: ingredientCategories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(ingredient.copyWith(category: value));
                }
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Al gusto'),
              subtitle: const Text(
                'No se añade a la lista de la compra (p. ej. sal, pimienta)',
                style: TextStyle(fontSize: 12),
              ),
              value: ingredient.isToTaste,
              onChanged: (value) {
                if (value != null) {
                  onChanged(
                    ingredient.copyWith(
                      isToTaste: value,
                      quantity: value ? null : ingredient.quantity,
                      unit: value ? null : ingredient.unit,
                      useCustomUnit: value ? false : ingredient.useCustomUnit,
                      customUnit: value ? '' : ingredient.customUnit,
                    ),
                  );
                }
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Opcional'),
              subtitle: const Text(
                'Puedes incluirlo o excluirlo en la ficha de la receta',
                style: TextStyle(fontSize: 12),
              ),
              value: ingredient.isOptional,
              onChanged: (value) {
                if (value != null) {
                  onChanged(
                    ingredient.copyWith(
                      isOptional: value,
                      isIncluded: value ? ingredient.isIncluded : true,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
