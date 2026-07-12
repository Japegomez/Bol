import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/core/supabase/models/shopping_item.dart';
import 'package:meal_planner/features/recipes/domain/recipe_constants.dart';

class AddEditItemSheet extends StatefulWidget {
  const AddEditItemSheet({
    this.item,
    this.canSave = true,
    super.key,
  });

  final ShoppingItem? item;
  final bool canSave;

  bool get isEditing => item != null;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    ShoppingItem? item,
    bool canSave = true,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddEditItemSheet(item: item, canSave: canSave),
    );
  }

  @override
  State<AddEditItemSheet> createState() => _AddEditItemSheetState();
}

class _AddEditItemSheetState extends State<AddEditItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late String? _unit;
  late String _category;
  bool _useCustomUnit = false;
  late final TextEditingController _customUnitController;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _quantityController = TextEditingController(
      text: item?.quantity?.toString() ?? '',
    );
    _customUnitController = TextEditingController();

    final itemUnit = normalizeUnit(item?.unit);
    if (itemUnit != null && !predefinedUnits.contains(itemUnit)) {
      _useCustomUnit = true;
      _unit = customUnitOption;
      _customUnitController.text = itemUnit;
    } else {
      _unit = itemUnit ?? predefinedUnits.first;
    }

    _category = normalizeCategoryKey(item?.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  String? get _resolvedUnit {
    if (_useCustomUnit) {
      final custom = _customUnitController.text.trim();
      return custom.isEmpty ? null : custom;
    }
    return _unit;
  }

  String? _normalizeResolvedUnit() => normalizeUnit(_resolvedUnit);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final quantityText = _quantityController.text.trim();
    final quantity = quantityText.isEmpty
        ? null
        : num.tryParse(quantityText.replaceAll(',', '.'));

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'quantity': quantity,
      'unit': _normalizeResolvedUnit(),
      'category': _category,
    });
  }

  String _unitLabel(String unit) {
    final l10n = context.l10n;
    if (unit == customUnitOption) return l10n.unitCustomOption;
    final localized = localizedUnitLabel(l10n, unit);
    return localized.isEmpty ? unit : localized;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.isEditing ? l10n.editItem : l10n.addItem,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.nameLabel,
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.nameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: l10n.quantityLabel,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                        return l10n.enterValidNumber;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('unit-$_useCustomUnit-$_unit'),
                    initialValue: _useCustomUnit ? customUnitOption : _unit,
                    decoration: InputDecoration(
                      labelText: l10n.unitLabel,
                    ),
                    items: [
                      ...predefinedUnits,
                      customUnitOption,
                    ]
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(_unitLabel(unit)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        if (value == customUnitOption) {
                          _useCustomUnit = true;
                          _unit = customUnitOption;
                        } else {
                          _useCustomUnit = false;
                          _unit = value;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_useCustomUnit) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _customUnitController,
                decoration: InputDecoration(
                  labelText: l10n.customUnitLabel,
                ),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('category-$_category'),
              initialValue: _category,
              decoration: InputDecoration(
                labelText: l10n.categoryLabel,
              ),
              items: ingredientCategories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(localizedCategoryLabel(l10n, category)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: widget.canSave ? _submit : null,
              child: Text(widget.isEditing ? l10n.save : l10n.add),
            ),
          ],
        ),
      ),
    );
  }
}
