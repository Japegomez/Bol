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

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => CookingGlossaryEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomEntries(List<CookingGlossaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((entry) => entry.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}

final cookingGlossaryRepositoryProvider =
    Provider<CookingGlossaryRepository>((ref) => CookingGlossaryRepository());
