import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/locale_provider.dart';
import 'package:meal_planner/features/recipes/data/cooking_glossary_repository.dart';
import 'package:meal_planner/features/recipes/domain/cooking_glossary_entry.dart';
import 'package:meal_planner/features/recipes/domain/default_cooking_glossary.dart';

final cookingGlossaryProvider =
    AsyncNotifierProvider<CookingGlossaryNotifier, List<CookingGlossaryEntry>>(
      CookingGlossaryNotifier.new,
    );

class CookingGlossaryNotifier
    extends AsyncNotifier<List<CookingGlossaryEntry>> {
  @override
  Future<List<CookingGlossaryEntry>> build() async {
    ref.watch(localeProvider);
    final custom = await ref
        .read(cookingGlossaryRepositoryProvider)
        .loadCustomEntries();
    return _mergeEntries(custom);
  }

  List<CookingGlossaryEntry> _defaultEntries() {
    final locale = ref.read(localeProvider);
    final languageCode =
        locale?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return defaultGlossaryForLocale(languageCode);
  }

  List<CookingGlossaryEntry> _mergeEntries(
    List<CookingGlossaryEntry> customEntries,
  ) {
    final merged = <String, CookingGlossaryEntry>{
      for (final entry in _defaultEntries()) _normalizeTerm(entry.term): entry,
      for (final entry in customEntries) _normalizeTerm(entry.term): entry,
    };

    final entries = merged.values.toList()
      ..sort((a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()));
    return entries;
  }

  Future<void> addEntry({
    required String term,
    required String definition,
  }) async {
    final trimmedTerm = term.trim();
    final trimmedDefinition = definition.trim();
    if (trimmedTerm.isEmpty || trimmedDefinition.isEmpty) return;

    final current = state.valueOrNull ?? await future;
    final normalized = _normalizeTerm(trimmedTerm);
    if (current.any((entry) => _normalizeTerm(entry.term) == normalized)) {
      throw StateError('duplicate_term');
    }

    final customEntries = [
      ...current.where((entry) => entry.isCustom),
      CookingGlossaryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        term: trimmedTerm,
        definition: trimmedDefinition,
        isCustom: true,
      ),
    ];

    await ref
        .read(cookingGlossaryRepositoryProvider)
        .saveCustomEntries(customEntries);
    state = AsyncData(_mergeEntries(customEntries));
  }

  Future<void> removeCustomEntry(String id) async {
    final current = state.valueOrNull ?? await future;
    final customEntries = current
        .where((entry) => entry.isCustom && entry.id != id)
        .toList();

    await ref
        .read(cookingGlossaryRepositoryProvider)
        .saveCustomEntries(customEntries);
    state = AsyncData(_mergeEntries(customEntries));
  }

  String _normalizeTerm(String term) => term.trim().toLowerCase();
}
