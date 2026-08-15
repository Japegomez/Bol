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

  bool _sameAs(List<String> other) {
    if (_allergens.length != other.length) return false;
    for (final item in other) {
      if (!_allergens.contains(item)) return false;
    }
    return true;
  }

  Future<void> _save() async {
    final current = ref.read(profileProvider).valueOrNull;
    if (current != null && _sameAs(current.allergens)) {
      if (mounted) context.pop();
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(profileProvider.notifier)
          .updateAllergens(_allergens.toList()..sort());
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;

    // Initialize once from the first loaded profile; never overwrite local edits.
    if (!_initialized && profile != null) {
      _allergens = {...profile.allergens};
      _initialized = true;
    }

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
