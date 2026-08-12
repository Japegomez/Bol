class RecipeTranslationPayload {
  const RecipeTranslationPayload({
    required this.title,
    required this.tips,
    required this.tags,
    required this.ingredients,
    required this.steps,
    required this.sourceLang,
    required this.targetLang,
  });

  factory RecipeTranslationPayload.fromJson(Map<String, dynamic> json) {
    final ingredientsJson = json['ingredients'] as List<dynamic>? ?? [];
    final stepsJson = json['steps'] as List<dynamic>? ?? [];
    return RecipeTranslationPayload(
      title: json['title']?.toString() ?? '',
      tips: json['tips']?.toString(),
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      ingredients: ingredientsJson
          .map(
            (row) => TranslatedIngredient.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(),
      steps: stepsJson
          .map(
            (row) =>
                TranslatedStep.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .toList(),
      sourceLang: json['source_lang']?.toString() ?? 'es',
      targetLang: json['target_lang']?.toString() ?? 'en',
    );
  }

  final String title;
  final String? tips;
  final List<String> tags;
  final List<TranslatedIngredient> ingredients;
  final List<TranslatedStep> steps;
  final String sourceLang;
  final String targetLang;
}

class TranslatedIngredient {
  const TranslatedIngredient({
    required this.id,
    required this.name,
    this.unit,
    this.category,
  });

  factory TranslatedIngredient.fromJson(Map<String, dynamic> json) {
    return TranslatedIngredient(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unit: json['unit']?.toString(),
      category: json['category']?.toString(),
    );
  }

  final String id;
  final String name;
  final String? unit;
  final String? category;
}

class TranslatedStep {
  const TranslatedStep({required this.id, required this.description});

  factory TranslatedStep.fromJson(Map<String, dynamic> json) {
    return TranslatedStep(
      id: json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  final String id;
  final String description;
}
