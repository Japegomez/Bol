import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/core/widgets/app_button.dart';
import 'package:meal_planner/features/profile/presentation/profile_provider.dart';

/// Standalone checklist to edit profile allergies / intolerances.
class EditAllergiesScreen extends ConsumerStatefulWidget {
  const EditAllergiesScreen({super.key});

  @override
  ConsumerState<EditAllergiesScreen> createState() =>
      _EditAllergiesScreenState();
}

class _EditAllergiesScreenState extends ConsumerState<EditAllergiesScreen> {
  Set<String> _allergens = {};
  bool _initialized = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<String> get _customAllergens {
    final customs = _allergens.where(isCustomAllergenKey).toList()..sort();
    return customs;
  }

  bool _sameAs(List<String> other) {
    final normalized = normalizeAllergenKeys(_allergens);
    final otherNormalized = normalizeAllergenKeys(other);
    if (normalized.length != otherNormalized.length) return false;
    for (var i = 0; i < normalized.length; i++) {
      if (normalized[i] != otherNormalized[i]) return false;
    }
    return true;
  }

  Future<void> _save() async {
    final current = ref.read(profileProvider).valueOrNull;
    final toSave = normalizeAllergenKeys(_allergens);
    if (current != null && _sameAs(current.allergens)) {
      if (mounted) context.pop();
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ref.read(profileProvider.notifier).updateAllergens(toSave);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _addCustomAllergy() async {
    if (_isSaving) return;
    final customCount = _customAllergens.length;
    if (customCount >= maxCustomAllergens) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.customAllergyLimitReached)),
      );
      return;
    }

    final l10n = context.l10n;
    final controller = TextEditingController();
    String? fieldError;

    final result = await showAdaptiveDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.customAllergyDialogTitle),
              content: TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                maxLength: maxCustomAllergenLabelLength,
                decoration: InputDecoration(
                  hintText: l10n.customAllergyHint,
                  errorText: fieldError,
                ),
                onSubmitted: (_) {
                  final encoded = encodeCustomAllergen(controller.text);
                  if (encoded == null) {
                    setDialogState(() {
                      fieldError = l10n.customAllergyInvalid;
                    });
                    return;
                  }
                  if (hasEquivalentCustomAllergen(_allergens, encoded)) {
                    setDialogState(() {
                      fieldError = l10n.customAllergyDuplicate;
                    });
                    return;
                  }
                  Navigator.of(dialogContext).pop(encoded);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final encoded = encodeCustomAllergen(controller.text);
                    if (encoded == null) {
                      setDialogState(() {
                        fieldError = l10n.customAllergyInvalid;
                      });
                      return;
                    }
                    if (hasEquivalentCustomAllergen(_allergens, encoded)) {
                      setDialogState(() {
                        fieldError = l10n.customAllergyDuplicate;
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(encoded);
                  },
                  child: Text(l10n.customAllergyAdd),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    if (result == null || !mounted) return;
    setState(() => _allergens.add(result));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;

    // Initialize once from the first loaded profile; never overwrite local edits.
    if (!_initialized && profile != null) {
      _allergens = {...normalizeAllergenKeys(profile.allergens)};
      _initialized = true;
    }

    final customs = _customAllergens;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.allergiesSection)),
      body: profileAsync.hasError && !_initialized
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      profileAsync.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: l10n.retry,
                      onPressed: () => ref.invalidate(profileProvider),
                    ),
                  ],
                ),
              ),
            )
          : !_initialized
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  l10n.allergiesHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < allergenTagKeys.length; i++) ...[
                        if (i > 0) const Divider(height: 1),
                        CheckboxListTile(
                          value: _allergens.contains(allergenTagKeys[i]),
                          title: Text(allergenLabel(l10n, allergenTagKeys[i])),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: _isSaving
                              ? null
                              : (selected) {
                                  setState(() {
                                    final key = allergenTagKeys[i];
                                    if (selected ?? false) {
                                      _allergens.add(key);
                                    } else {
                                      _allergens.remove(key);
                                    }
                                  });
                                },
                        ),
                      ],
                      for (final customKey in customs) ...[
                        const Divider(height: 1),
                        CheckboxListTile(
                          value: true,
                          title: Text(allergenLabel(l10n, customKey)),
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: IconButton(
                            tooltip: l10n.delete,
                            icon: const Icon(Icons.close),
                            onPressed: _isSaving
                                ? null
                                : () {
                                    setState(() {
                                      _allergens.remove(customKey);
                                    });
                                  },
                          ),
                          onChanged: _isSaving
                              ? null
                              : (selected) {
                                  if (selected == false) {
                                    setState(() {
                                      _allergens.remove(customKey);
                                    });
                                  }
                                },
                        ),
                      ],
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.add_circle_outline,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(l10n.addCustomAllergy),
                        enabled: !_isSaving,
                        onTap: _isSaving ? null : _addCustomAllergy,
                      ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 24),
                AppButton(
                  label: l10n.save,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
    );
  }
}
