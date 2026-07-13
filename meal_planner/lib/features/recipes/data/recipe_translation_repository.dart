import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/locale_provider.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/features/recipes/domain/recipe_translation_payload.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeTranslationRepository {
  static const _cachePrefix = 'recipe_translation.';

  Future<RecipeTranslationPayload?> fetchTranslation({
    required String recipeId,
    required String targetLang,
    String? sourceLang,
  }) async {
    if (sourceLang != null && sourceLang == targetLang) return null;

    // When online, always hit the server first so the DB cache (which may have
    // been corrected) takes precedence over any stale localStorage entry.
    if (!await NetworkStatus.isOnline) {
      return _readLocalCache(recipeId, targetLang);
    }

    try {
      final response = await supabase.functions.invoke(
        'translate-recipe',
        body: {
          'recipe_id': recipeId,
          'target_lang': targetLang,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.status != 200) {
        throw Exception(
          response.data?['error']?.toString() ?? 'translation_failed',
        );
      }

      final data = response.data;
      if (data is! Map) throw Exception('translation_failed');

      final payloadMap = data['payload'];
      if (payloadMap is! Map) throw Exception('translation_failed');

      final payload = RecipeTranslationPayload.fromJson(
        Map<String, dynamic>.from(payloadMap),
      );
      // Overwrite any stale localStorage entry with the fresh server result.
      await _writeLocalCache(recipeId, targetLang, payloadMap);
      return payload;
    } catch (_) {
      // Network hiccup despite being "online" – fall back to local cache.
      final fallback = await _readLocalCache(recipeId, targetLang);
      if (fallback != null) return fallback;
      rethrow;
    }
  }

  Future<RecipeTranslationPayload?> _readLocalCache(
    String recipeId,
    String targetLang,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_cachePrefix$recipeId.$targetLang');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return RecipeTranslationPayload.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeLocalCache(
    String recipeId,
    String targetLang,
    Map<dynamic, dynamic> payload,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_cachePrefix$recipeId.$targetLang',
      jsonEncode(payload),
    );
  }
}

final recipeTranslationRepositoryProvider =
    Provider<RecipeTranslationRepository>((ref) {
  return RecipeTranslationRepository();
});

final publicRecipeTranslationProvider = FutureProvider.family<
    RecipeTranslationPayload?,
    PublicRecipeTranslationRequest>((ref, request) async {
  if (request.sourceLang == request.targetLang) return null;

  return ref.read(recipeTranslationRepositoryProvider).fetchTranslation(
        recipeId: request.recipeId,
        targetLang: request.targetLang,
        sourceLang: request.sourceLang,
      );
});

class PublicRecipeTranslationRequest {
  const PublicRecipeTranslationRequest({
    required this.recipeId,
    required this.sourceLang,
    required this.targetLang,
  });

  final String recipeId;
  final String sourceLang;
  final String targetLang;

  @override
  bool operator ==(Object other) {
    return other is PublicRecipeTranslationRequest &&
        other.recipeId == recipeId &&
        other.sourceLang == sourceLang &&
        other.targetLang == targetLang;
  }

  @override
  int get hashCode => Object.hash(recipeId, sourceLang, targetLang);
}

final currentLanguageCodeProvider = Provider<String>((ref) {
  // Watch the STATE (Locale?) so this provider re-evaluates on every locale
  // change. Watching `.notifier` subscribes to the notifier object itself,
  // which never changes, so locale switches would go undetected.
  final locale = ref.watch(localeProvider);
  return locale?.languageCode ??
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
});
