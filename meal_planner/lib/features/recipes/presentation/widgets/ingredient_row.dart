import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';

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
    _ingredient.category = normalizeCategoryKey(_ingredient.category);
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
    final l10n = context.l10n;
    final unitDropdownItems = <DropdownMenuItem<String>>[
      ...predefinedUnits.map(
        (unit) => DropdownMenuItem<String>(
          value: unit,
          child: Text(localizedUnitLabel(l10n, unit)),
        ),
      ),
      DropdownMenuItem<String>(
        value: customUnitOption,
        child: Text(l10n.unitCustomOption),
      ),
    ];
    final categoryDropdownItems = ingredientCategoryKeys
        .map(
          (key) => DropdownMenuItem<String>(
            value: key,
            child: Text(localizedCategoryLabel(l10n, key)),
          ),
        )
        .toList(growable: false);

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
                    decoration: InputDecoration(
                      labelText: l10n.ingredientLabel,
                      isDense: true,
                    ),
                    onChanged: (value) => _ingredient.name = value,
                  ),
                ),
                if (widget.canRemove)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onRemove,
                    tooltip: l10n.removeIngredientTooltip,
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
                      decoration: InputDecoration(
                        labelText: l10n.quantityLabel,
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
                        if (parsed == null) return l10n.enterValidNumber;
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
                          : _ingredient.unit,
                      decoration: InputDecoration(
                        labelText: l10n.unitLabel,
                        isDense: true,
                      ),
                      items: unitDropdownItems,
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
                decoration: InputDecoration(
                  labelText: l10n.customUnitLabel,
                  isDense: true,
                ),
                onChanged: (value) => _ingredient.customUnit = value,
              ),
            ],
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: ingredientCategoryKeys.contains(_ingredient.category)
                  ? _ingredient.category
                  : ingredientCategoryKeys.first,
              decoration: InputDecoration(
                labelText: l10n.categoryLabel,
                isDense: true,
              ),
              items: categoryDropdownItems,
              onChanged: (value) {
                if (value != null) _ingredient.category = value;
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(l10n.toTaste),
              subtitle: Text(
                l10n.toTasteShoppingHint,
                style: const TextStyle(fontSize: 12),
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
                  } else {
                    // When re-enabling unit, set to default if null
                    if (_ingredient.unit == null && !_ingredient.useCustomUnit) {
                      _ingredient.unit = predefinedUnits.first;
                    }
                  }
                });
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(l10n.optional),
              subtitle: Text(
                l10n.optionalIngredientHint,
                style: const TextStyle(fontSize: 12),
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
