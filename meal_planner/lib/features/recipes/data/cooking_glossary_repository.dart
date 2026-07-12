import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/recipes/domain/cooking_glossary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'cooking_glossary.custom_entries';

class CookingGlossaryRepository {
  Future<List<CookingGlossaryEntry>> loadCustomEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .map((item) {
            if (item is! Map<String, dynamic>) return null;
            return CookingGlossaryEntry.fromJson(item);
          })
          .whereType<CookingGlossaryEntry>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomEntries(List<CookingGlossaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    final success = await prefs.setString(_storageKey, encoded);
    if (!success) {
      throw Exception('Failed to persist cooking glossary entries');
    }
  }
}

final cookingGlossaryRepositoryProvider =
    Provider<CookingGlossaryRepository>((ref) => CookingGlossaryRepository());
