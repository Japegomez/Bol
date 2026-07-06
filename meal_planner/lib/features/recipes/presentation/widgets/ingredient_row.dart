import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/features/recipes/domain/recipe_constants.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';

// Computed once at module load; reused across every IngredientRow rebuild.
// Avoids creating 20–30 DropdownMenuItem instances per dropdown per rebuild.
final _unitDropdownItems = <DropdownMenuItem<String>>[
  ...predefinedUnits
      .map((u) => DropdownMenuItem<String>(value: u, child: Text(u))),
  const DropdownMenuItem<String>(
    value: customUnitOption,
    child: Text(customUnitOption),
  ),
];

final _categoryDropdownItems = ingredientCategories
    .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
    .toList(growable: false);

/// Row for a single ingredient in the recipe form.
///
/// Stateful and controller-based so that typing mutates the model in place
/// without rebuilding the parent form. Only layout-affecting changes ("al
/// gusto", custom unit) trigger a local setState; category changes are free.
class IngredientRow extends StatefulWidget {
  const IngredientRow({
    required this.index,
    required this.ingredient,
    required this.onRemove,
    required this.canRemove,
    super.key,
  });

  final int index;
  final IngredientFormItem ingredient;
  final VoidCallback onRemove;
  final bool canRemove;

  @override
  State<IngredientRow> createState() => _IngredientRowState();
}

class _IngredientRowState extends State<IngredientRow> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _customUnitController;

  IngredientFormItem get _ingredient => widget.ingredient;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _ingredient.name);
    _quantityController = TextEditingController(
      text: _ingredient.quantity?.toString() ?? '',
    );
    _customUnitController = TextEditingController(text: _ingredient.customUnit);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: Icon(
                    Icons.drag_handle,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ingrediente',
                      isDense: true,
                    ),
                    onChanged: (value) => _ingredient.name = value,
                  ),
                ),
                if (widget.canRemove)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onRemove,
                    tooltip: 'Eliminar ingrediente',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (!_ingredient.isToTaste)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
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
                        if (value == null || value.trim().isEmpty) return null;
                        final parsed =
                            num.tryParse(value.trim().replaceAll(',', '.'));
                        if (parsed == null) return 'Introduce un número válido';
                        return null;
                      },
                      onChanged: (value) {
                        _ingredient.quantity = value.trim().isEmpty
                            ? null
                            : num.tryParse(value.replaceAll(',', '.'));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      // Key forces recreation when useCustomUnit changes so
                      // the displayed value resets to the model's current state.
                      key: ValueKey(
                        'unit-${widget.ingredient.key}-${_ingredient.useCustomUnit}',
                      ),
                      initialValue: _ingredient.useCustomUnit
                          ? customUnitOption
                          : (_ingredient.unit ?? predefinedUnits.first),
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        isDense: true,
                      ),
                      items: _unitDropdownItems,
                      onChanged: (value) {
                        if (value == customUnitOption) {
                          setState(() {
                            _ingredient.useCustomUnit = true;
                            _ingredient.unit = null;
                          });
                        } else {
                          setState(() {
                            _ingredient.useCustomUnit = false;
                            _ingredient.unit = value;
                            _ingredient.customUnit = '';
                            _customUnitController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            if (_ingredient.useCustomUnit && !_ingredient.isToTaste) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _customUnitController,
                decoration: const InputDecoration(
                  labelText: 'Unidad personalizada',
                  isDense: true,
                ),
                onChanged: (value) => _ingredient.customUnit = value,
              ),
            ],
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: ingredientCategories.contains(_ingredient.category)
                  ? _ingredient.category
                  : ingredientCategories.first,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                isDense: true,
              ),
              items: _categoryDropdownItems,
              onChanged: (value) {
                if (value != null) _ingredient.category = value;
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
              value: _ingredient.isToTaste,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _ingredient.isToTaste = value;
                  if (value) {
                    _ingredient.quantity = null;
                    _ingredient.unit = null;
                    _ingredient.useCustomUnit = false;
                    _ingredient.customUnit = '';
                    _quantityController.clear();
                    _customUnitController.clear();
                  }
                });
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
              value: _ingredient.isOptional,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _ingredient.isOptional = value;
                  if (!value) _ingredient.isIncluded = true;
                });
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}
