import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';

/// Request for batch title translation of a set of recipes into [targetLang].
class TitleTranslationRequest {
  TitleTranslationRequest({
    required this.targetLang,
    required Iterable<String> ids,
  }) : ids = List.unmodifiable(ids.toSet().toList()..sort());

  final String targetLang;
  final List<String> ids;

  @override
  bool operator ==(Object other) {
    if (other is! TitleTranslationRequest) return false;
    if (other.targetLang != targetLang) return false;
    if (other.ids.length != ids.length) return false;
    for (var i = 0; i < ids.length; i++) {
      if (other.ids[i] != ids[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(targetLang, Object.hashAll(ids));
}

/// Returns a map of `recipeId -> translated title` for the requested recipes.
///
/// Only recipes whose source language differs from [targetLang] are returned;
/// callers fall back to the original title for any id not present in the map.
/// Translations are cached server-side, so repeated calls are cheap.
final listTitleTranslationsProvider = FutureProvider.autoDispose.family<
    Map<String, String>, TitleTranslationRequest>((ref, request) async {
  if (request.ids.isEmpty) return const {};

  try {
    final response = await supabase.functions.invoke(
      'translate-titles',
      body: {
        'recipe_ids': request.ids,
        'target_lang': request.targetLang,
      },
    );

    if (response.status != 200) return const {};

    final data = response.data;
    if (data is! Map) return const {};
    final translations = data['translations'];
    if (translations is! Map) return const {};

    return Map<String, String>.unmodifiable(
      translations.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
    );
  } catch (_) {
    // Offline or transient error — callers show the original titles.
    return const {};
  }
});
