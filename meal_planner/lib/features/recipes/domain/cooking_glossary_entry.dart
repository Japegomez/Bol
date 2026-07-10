class CookingGlossaryEntry {
  const CookingGlossaryEntry({
    required this.term,
    required this.definition,
    this.id,
    this.isCustom = false,
  });

  final String term;
  final String definition;
  final String? id;
  final bool isCustom;

  CookingGlossaryEntry copyWith({
    String? term,
    String? definition,
    String? id,
    bool? isCustom,
  }) {
    return CookingGlossaryEntry(
      term: term ?? this.term,
      definition: definition ?? this.definition,
      id: id ?? this.id,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'term': term,
        'definition': definition,
      };

  factory CookingGlossaryEntry.fromJson(Map<String, dynamic> json) {
    return CookingGlossaryEntry(
      id: json['id'] as String?,
      term: json['term'] as String,
      definition: json['definition'] as String,
      isCustom: true,
    );
  }
}
