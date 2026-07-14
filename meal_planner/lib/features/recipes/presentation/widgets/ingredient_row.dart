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
  static const _compactFieldsBreakpoint = 600.0;

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _customUnitController;

  IngredientFormItem get _ingredient => widget.ingredient;

  @override
  void initState() {
    super.initState();
    _ingredient.category = normalizeCategoryKey(_ingredient.category);
    if (!_ingredient.useCustomUnit && !_ingredient.isToTaste) {
      final normalized = normalizeUnit(_ingredient.unit);
      _ingredient.unit = normalized != null &&
              predefinedUnits.contains(normalized)
          ? normalized
          : defaultIngredientUnit;
    }
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

  Widget _buildQuantityField(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: _quantityController,
      decoration: InputDecoration(
        labelText: l10n.quantityLabel,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
      ],
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        final parsed = num.tryParse(value.trim().replaceAll(',', '.'));
        if (parsed == null) return l10n.enterValidNumber;
        return null;
      },
      onChanged: (value) {
        _ingredient.quantity = value.trim().isEmpty
            ? null
            : num.tryParse(value.replaceAll(',', '.'));
      },
    );
  }

  Widget _buildUnitDropdown(
    List<DropdownMenuItem<String>> unitDropdownItems,
  ) {
    return DropdownButtonFormField<String>(
      key: ValueKey(
        'unit-${widget.ingredient.key}-${_ingredient.useCustomUnit}',
      ),
      isExpanded: true,
      initialValue: _ingredient.useCustomUnit
          ? customUnitOption
          : (predefinedUnits.contains(_ingredient.unit)
              ? _ingredient.unit
              : defaultIngredientUnit),
      decoration: InputDecoration(
        labelText: context.l10n.unitLabel,
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
    );
  }

  Widget _buildCategoryDropdown(
    List<DropdownMenuItem<String>> categoryDropdownItems,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: ingredientCategoryKeys.contains(_ingredient.category)
          ? _ingredient.category
          : defaultIngredientCategoryKey,
      decoration: InputDecoration(
        labelText: context.l10n.categoryLabel,
        isDense: true,
      ),
      items: categoryDropdownItems,
      onChanged: (value) {
        if (value != null) _ingredient.category = value;
      },
    );
  }

  Widget _buildQuantityUnitCategorySection(
    BuildContext context,
    List<DropdownMenuItem<String>> unitDropdownItems,
    List<DropdownMenuItem<String>> categoryDropdownItems,
  ) {
    final categoryField = _buildCategoryDropdown(categoryDropdownItems);

    if (_ingredient.isToTaste) {
      return categoryField;
    }

    final compact =
        MediaQuery.sizeOf(context).width < _compactFieldsBreakpoint;
    final quantityField = _buildQuantityField(context);
    final unitField = _buildUnitDropdown(unitDropdownItems);

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 96, child: quantityField),
              const SizedBox(width: 8),
              Expanded(child: unitField),
            ],
          ),
          const SizedBox(height: 8),
          categoryField,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 96, child: quantityField),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: unitField),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: categoryField),
      ],
    );
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
            _buildQuantityUnitCategorySection(
              context,
              unitDropdownItems,
              categoryDropdownItems,
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
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l10n.toTaste),
                    subtitle: _ingredient.isToTaste
                        ? Text(
                            l10n.toTasteShoppingHint,
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
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
                        } else if (_ingredient.unit == null &&
                            !_ingredient.useCustomUnit) {
                          _ingredient.unit = defaultIngredientUnit;
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l10n.optional),
                    subtitle: _ingredient.isOptional
                        ? Text(
                            l10n.optionalIngredientHint,
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                    value: _ingredient.isOptional,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _ingredient.isOptional = value;
                        if (!value) _ingredient.isIncluded = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}
