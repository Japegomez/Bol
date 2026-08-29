import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

/// Stable keys for ingredient categories stored in the database.
const ingredientCategoryKeys = [
  'meat_fish',
  'vegetables',
  'fruits',
  'dairy',
  'grains',
  'legumes',
  'spices',
  'oils_vinegars',
  'canned',
  'nuts',
  'beverages',
  'baking',
  'frozen',
  'sauces',
  'other',
];

const defaultIngredientCategoryKey = 'vegetables';

/// Legacy Spanish labels still present in older rows.
const _legacyCategoryLabels = {
  'Carnes y pescados': 'meat_fish',
  'Verduras': 'vegetables',
  'Frutas': 'fruits',
  'Lácteos': 'dairy',
  'Cereales': 'grains',
  'Legumbres': 'legumes',
  'Especias': 'spices',
  'Aceites y vinagres': 'oils_vinegars',
  'Conservas': 'canned',
  'Frutos secos': 'nuts',
  'Bebidas': 'beverages',
  'Repostería': 'baking',
  'Panadería': 'baking',
  'Congelados': 'frozen',
  'Salsas y condimentos': 'sauces',
  'Otros': 'other',
};

String normalizeCategoryKey(String? value) {
  if (value == null || value.isEmpty) return defaultIngredientCategoryKey;
  if (ingredientCategoryKeys.contains(value)) return value;
  return _legacyCategoryLabels[value] ?? 'other';
}

String localizedCategoryLabel(AppLocalizations l10n, String key) {
  return switch (normalizeCategoryKey(key)) {
    'meat_fish' => l10n.categoryMeatFish,
    'vegetables' => l10n.categoryVegetables,
    'fruits' => l10n.categoryFruits,
    'dairy' => l10n.categoryDairy,
    'grains' => l10n.categoryGrains,
    'legumes' => l10n.categoryLegumes,
    'spices' => l10n.categorySpices,
    'oils_vinegars' => l10n.categoryOilsVinegars,
    'canned' => l10n.categoryCanned,
    'nuts' => l10n.categoryNuts,
    'beverages' => l10n.categoryBeverages,
    'baking' => l10n.categoryBaking,
    'frozen' => l10n.categoryFrozen,
    'sauces' => l10n.categorySauces,
    _ => l10n.categoryOther,
  };
}

/// Localized singular/plural forms per predefined unit key (stored in Spanish).
///
/// Only word-units are listed here; abbreviated units (g, kg, ml, l) and custom
/// units are returned verbatim. Basque keeps the singular form after cardinals.
const _unitWordForms = <String, Map<String, List<String>>>{
  'unidad': {
    'es': ['unidad', 'unidades'],
    'en': ['unit', 'units'],
    'ca': ['unitat', 'unitats'],
    'eu': ['unitate', 'unitate'],
    'gl': ['unidade', 'unidades'],
    'pt': ['unidade', 'unidades'],
    'it': ['unità', 'unità'],
  },
  'pizca': {
    'es': ['pizca', 'pizcas'],
    'en': ['pinch', 'pinches'],
    'ca': ['pessic', 'pessics'],
    'eu': ['atximur', 'atximur'],
    'gl': ['pitada', 'pitadas'],
    'pt': ['pitada', 'pitadas'],
    'it': ['pizzico', 'pizzichi'],
  },
  'cucharadita': {
    'es': ['cucharadita', 'cucharaditas'],
    'en': ['teaspoon', 'teaspoons'],
    'ca': ['culleradeta', 'culleradetes'],
    'eu': ['koilaratxo', 'koilaratxo'],
    'gl': ['culleradiña', 'culleradiñas'],
    'pt': ['colher de chá', 'colheres de chá'],
    'it': ['cucchiaino', 'cucchiaini'],
  },
  'cucharada': {
    'es': ['cucharada', 'cucharadas'],
    'en': ['tablespoon', 'tablespoons'],
    'ca': ['cullerada', 'cullerades'],
    'eu': ['koilarada', 'koilarada'],
    'gl': ['cullerada', 'culleradas'],
    'pt': ['colher de sopa', 'colheres de sopa'],
    'it': ['cucchiaio', 'cucchiai'],
  },
  'vaso': {
    'es': ['vaso', 'vasos'],
    'en': ['glass', 'glasses'],
    'ca': ['got', 'gots'],
    'eu': ['edalontzi', 'edalontzi'],
    'gl': ['vaso', 'vasos'],
    'pt': ['copo', 'copos'],
    'it': ['bicchiere', 'bicchieri'],
  },
  'taza': {
    'es': ['taza', 'tazas'],
    'en': ['cup', 'cups'],
    'ca': ['tassa', 'tasses'],
    'eu': ['katilu', 'katilu'],
    'gl': ['cunca', 'cuncas'],
    'pt': ['chávena', 'chávenas'],
    'it': ['tazza', 'tazze'],
  },
  'puñado': {
    'es': ['puñado', 'puñados'],
    'en': ['handful', 'handfuls'],
    'ca': ['grapat', 'grapats'],
    'eu': ['eskutada', 'eskutada'],
    'gl': ['puñado', 'puñados'],
    'pt': ['punhado', 'punhados'],
    'it': ['manciata', 'manciate'],
  },
  'hoja': {
    'es': ['hoja', 'hojas'],
    'en': ['leaf', 'leaves'],
    'ca': ['fulla', 'fulles'],
    'eu': ['orri', 'orri'],
    'gl': ['folla', 'follas'],
    'pt': ['folha', 'folhas'],
    'it': ['foglia', 'foglie'],
  },
  'diente': {
    'es': ['diente', 'dientes'],
    'en': ['clove', 'cloves'],
    'ca': ['dent', 'dents'],
    'eu': ['ale', 'ale'],
    'gl': ['dente', 'dentes'],
    'pt': ['dente', 'dentes'],
    'it': ['spicchio', 'spicchi'],
  },
  'chorrito': {
    'es': ['chorrito', 'chorritos'],
    'en': ['splash', 'splashes'],
    'ca': ['rajolí', 'rajolins'],
    'eu': ['txorrota', 'txorrota'],
    'gl': ['chorro', 'chorros'],
    'pt': ['fio', 'fios'],
    'it': ['goccio', 'gocci'],
  },
  'rebanada': {
    'es': ['rebanada', 'rebanadas'],
    'en': ['slice', 'slices'],
    'ca': ['llesca', 'llesques'],
    'eu': ['xerra', 'xerra'],
    'gl': ['rebanda', 'rebandas'],
    'pt': ['fatia', 'fatias'],
    'it': ['fetta', 'fette'],
  },
  'rama': {
    'es': ['rama', 'ramas'],
    'en': ['sprig', 'sprigs'],
    'ca': ['branca', 'branques'],
    'eu': ['adar', 'adar'],
    'gl': ['rama', 'ramas'],
    'pt': ['ramo', 'ramos'],
    'it': ['rametto', 'rametti'],
  },
  'trozo': {
    'es': ['trozo', 'trozos'],
    'en': ['piece', 'pieces'],
    'ca': ['tros', 'trossos'],
    'eu': ['zati', 'zati'],
    'gl': ['anaco', 'anacos'],
    'pt': ['pedaço', 'pedaços'],
    'it': ['pezzo', 'pezzi'],
  },
  'filete': {
    'es': ['filete', 'filetes'],
    'en': ['fillet', 'fillets'],
    'ca': ['filet', 'filets'],
    'eu': ['xerra', 'xerra'],
    'gl': ['filete', 'filetes'],
    'pt': ['filete', 'filetes'],
    'it': ['filetto', 'filetti'],
  },
  'rodaja': {
    'es': ['rodaja', 'rodajas'],
    'en': ['round slice', 'round slices'],
    'ca': ['rodanxa', 'rodanxes'],
    'eu': ['xerra biribil', 'xerra biribil'],
    'gl': ['rolda', 'roldas'],
    'pt': ['rodela', 'rodelas'],
    'it': ['rotella', 'rotelle'],
  },
  'lata': {
    'es': ['lata', 'latas'],
    'en': ['can', 'cans'],
    'ca': ['llauna', 'llaunes'],
    'eu': ['lata', 'lata'],
    'gl': ['lata', 'latas'],
    'pt': ['lata', 'latas'],
    'it': ['lattina', 'lattine'],
  },
  'bote': {
    'es': ['bote', 'botes'],
    'en': ['jar', 'jars'],
    'ca': ['pot', 'pots'],
    'eu': ['potu', 'potu'],
    'gl': ['bote', 'botes'],
    'pt': ['frasco', 'frascos'],
    'it': ['barattolo', 'barattoli'],
  },
  'paquete': {
    'es': ['paquete', 'paquetes'],
    'en': ['package', 'packages'],
    'ca': ['paquet', 'paquets'],
    'eu': ['pakete', 'pakete'],
    'gl': ['paquete', 'paquetes'],
    'pt': ['pacote', 'pacotes'],
    'it': ['pacchetto', 'pacchetti'],
  },
  'sobre': {
    'es': ['sobre', 'sobres'],
    'en': ['sachet', 'sachets'],
    'ca': ['sobre', 'sobres'],
    'eu': ['zorro', 'zorro'],
    'gl': ['sobre', 'sobres'],
    'pt': ['saqueta', 'saquetas'],
    'it': ['bustina', 'bustine'],
  },
};

String _unitWord(String localeName, String unitKey, {required bool plural}) {
  final byLocale = _unitWordForms[unitKey];
  if (byLocale == null) return unitKey;
  final forms = byLocale[localeName] ?? byLocale['en'] ?? [unitKey, unitKey];
  return plural ? forms.last : forms.first;
}

String localizedUnitLabel(AppLocalizations l10n, String? unit) {
  final normalized = normalizeUnit(unit);
  if (normalized == null || normalized.isEmpty) return '';
  return _unitWord(l10n.localeName, normalized, plural: false);
}

String localizedUnitForLocale(String localeName, String? unit, num? quantity) {
  final normalized = normalizeUnit(unit);
  if (normalized == null || normalized.isEmpty) return '';
  final plural = quantity != null && quantity > 1;
  return _unitWord(localeName, normalized, plural: plural);
}

/// Localized unit, pluralized according to [quantity] and the current locale.
String localizedUnit(AppLocalizations l10n, String? unit, num? quantity) {
  return localizedUnitForLocale(l10n.localeName, unit, quantity);
}

/// Connector placed between the unit and the ingredient name
/// (e.g. "4 units *of* egg", "4 unidades *de* huevo"). Empty when the target
/// language does not use one.
String ingredientNameConnector(String localeName) {
  return switch (localeName) {
    'en' => 'of',
    'eu' => '',
    'it' => 'di',
    _ => 'de',
  };
}

const suggestedRecipeTagKeys = [
  'main_course',
  'dessert',
  'breakfast',
  'appetizer',
  'side_dish',
  'vegetarian',
  'vegan',
  'pescatarian',
  'gluten_free',
  'lactose_free',
  'dairy_free',
  'egg_free',
  'nut_free',
  'peanut_free',
  'soy_free',
  'fish_free',
  'shellfish_free',
  'sugar_free',
  'high_protein',
  'low_calorie',
  'low_carb',
  'high_fiber',
  'healthy',
  'spanish',
  'italian',
  'asian',
  'mexican',
  'indian',
  'quick',
  'budget',
  'batch_cooking',
  'freezer_friendly',
  'no_oven',
  'spicy',
  'kid_friendly',
];

/// Allergen / intolerance keys reused as the "sin" recipe tags. Stored on the
/// profile so the recipe assistant can omit/substitute ingredients and
/// auto-apply the matching tags. Must stay in sync with the Edge Function's
/// `SIN_TAG_KEYS`.
const allergenTagKeys = [
  'gluten_free',
  'lactose_free',
  'dairy_free',
  'egg_free',
  'nut_free',
  'peanut_free',
  'soy_free',
  'fish_free',
  'shellfish_free',
  'sugar_free',
];

/// Prefix for free-text custom allergies stored in `profiles.allergens`.
/// Format: `custom:<normalized_label>` (must stay in sync with DB + Edge Function).
const customAllergenPrefix = 'custom:';

/// Max length of the free-text label after [customAllergenPrefix].
const maxCustomAllergenLabelLength = 40;

/// Max number of custom allergy entries per profile.
const maxCustomAllergens = 10;

bool isCustomAllergenKey(String key) =>
    key.trim().startsWith(customAllergenPrefix);

/// Human-readable substance from a `custom:…` key, or null if not custom.
String? customAllergenSubstance(String key) {
  final trimmed = key.trim();
  if (!trimmed.startsWith(customAllergenPrefix)) return null;
  final label = trimmed.substring(customAllergenPrefix.length).trim();
  return label.isEmpty ? null : label;
}

/// Strips a leading "sin"/"without"/… word from free-text allergy input.
String stripLeadingAllergyFreePrefix(String input) {
  return input
      .trim()
      .replaceFirst(
        RegExp(
          r'^(sin|sense|sen|sem|senza|without)(\s+|$)',
          caseSensitive: false,
        ),
        '',
      )
      .trim();
}

final _customAllergenLabelPattern = RegExp(
  r'^[\p{L}\p{N}][\p{L}\p{N} _-]{0,39}$',
  unicode: true,
);

/// Normalizes a user-entered custom allergy label for storage.
///
/// Keeps accents, lowercases, collapses spaces, and strips a leading "sin"
/// (or locale equivalents). Returns null when empty/invalid after cleanup.
String? normalizeCustomAllergenLabel(String raw) {
  final collapsed = stripLeadingAllergyFreePrefix(raw)
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (collapsed.isEmpty) return null;
  if (collapsed.length > maxCustomAllergenLabelLength) return null;
  if (!_customAllergenLabelPattern.hasMatch(collapsed)) return null;
  return collapsed;
}

/// Folds accents for duplicate detection only (storage keeps accents).
String foldAllergenDiacritics(String input) {
  const from = 'áàäâãåéèëêíìïîóòöôõúùüûñç';
  const to = 'aaaaaaeeeeiiiiooooouuuunc';
  final buffer = StringBuffer();
  for (final codeUnit in input.codeUnits) {
    final char = String.fromCharCode(codeUnit);
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString();
}

/// Encodes a free-text label as `custom:<label>`, or null if invalid.
String? encodeCustomAllergen(String rawLabel) {
  final label = normalizeCustomAllergenLabel(rawLabel);
  if (label == null) return null;
  return '$customAllergenPrefix$label';
}

/// Whether [keys] already contains the same custom allergy as [encoded]
/// (accent-insensitive).
bool hasEquivalentCustomAllergen(Iterable<String> keys, String encoded) {
  final substance = customAllergenSubstance(encoded);
  if (substance == null) return keys.contains(encoded);
  final folded = foldAllergenDiacritics(substance);
  for (final key in keys) {
    if (key == encoded) return true;
    final other = customAllergenSubstance(key);
    if (other != null && foldAllergenDiacritics(other) == folded) {
      return true;
    }
  }
  return false;
}

/// Localized chip/tag label for an allergen key (includes "sin …").
String allergenLabel(AppLocalizations l10n, String key) {
  final custom = customAllergenSubstance(key);
  if (custom != null) {
    return l10n.customAllergenFreeLabel(custom);
  }
  return localizedTagLabel(l10n, key);
}

/// Substance name for dialogs (without the leading "sin"), e.g. "huevo".
String allergenSubstanceLabel(AppLocalizations l10n, String key) {
  final custom = customAllergenSubstance(key);
  if (custom != null) return custom;
  return switch (key.trim()) {
    'gluten_free' => l10n.allergenSubstanceGluten,
    'lactose_free' => l10n.allergenSubstanceLactose,
    'dairy_free' => l10n.allergenSubstanceDairy,
    'egg_free' => l10n.allergenSubstanceEgg,
    'nut_free' => l10n.allergenSubstanceNuts,
    'peanut_free' => l10n.allergenSubstancePeanuts,
    'soy_free' => l10n.allergenSubstanceSoy,
    'fish_free' => l10n.allergenSubstanceFish,
    'shellfish_free' => l10n.allergenSubstanceShellfish,
    'sugar_free' => l10n.allergenSubstanceSugar,
    _ => allergenLabel(l10n, key),
  };
}

bool _isValidStoredAllergenKey(String key) {
  if (allergenTagKeys.contains(key)) return true;
  final custom = customAllergenSubstance(key);
  if (custom == null) return false;
  // Re-validate the stored substance without stripping again incorrectly:
  // stored labels are already normalized (lowercase, no leading "sin").
  if (custom.length > maxCustomAllergenLabelLength) return false;
  return _customAllergenLabelPattern.hasMatch(custom) &&
      custom == custom.toLowerCase();
}

/// Valid allergen keys from [keys], preserving order and dropping unknowns.
/// Predefined keys keep input order among themselves; customs are kept as
/// valid `custom:…` entries (deduped, accent-insensitive).
List<String> normalizeAllergenKeys(Iterable<String> keys) {
  final seen = <String>{};
  final seenCustomFolded = <String>{};
  final predefined = <String>[];
  final customs = <String>[];
  for (final key in keys) {
    final trimmed = key.trim().toLowerCase();
    if (!_isValidStoredAllergenKey(trimmed)) continue;
    if (isCustomAllergenKey(trimmed)) {
      final substance = customAllergenSubstance(trimmed);
      if (substance == null) continue;
      final folded = foldAllergenDiacritics(substance);
      if (!seenCustomFolded.add(folded)) continue;
      if (!seen.add(trimmed)) continue;
      customs.add(trimmed);
    } else {
      if (!seen.add(trimmed)) continue;
      predefined.add(trimmed);
    }
  }
  // Stable product order for checklist keys, then customs alphabetically.
  final orderedPredefined = allergenTagKeys
      .where(predefined.contains)
      .toList(growable: false);
  customs.sort();
  final limitedCustoms = customs.take(maxCustomAllergens).toList(growable: false);
  return [...orderedPredefined, ...limitedCustoms];
}

/// Conflict dialog lines that always name each allergen/intolerance.
List<String> allergenConflictMessages(
  AppLocalizations l10n,
  Iterable<String> allergenKeys,
) {
  final keys = normalizeAllergenKeys(allergenKeys);
  if (keys.isEmpty) return [l10n.recipeAssistantAllergenConflict];
  return [
    for (final key in keys)
      l10n.allergenConflictBody(allergenSubstanceLabel(l10n, key)),
  ];
}

/// Adjustment dialog notes that always name each allergen/intolerance.
List<String> allergenAdjustmentMessages(
  AppLocalizations l10n,
  Iterable<String> allergenKeys,
) {
  final keys = normalizeAllergenKeys(allergenKeys);
  return [
    for (final key in keys)
      l10n.allergenAdjustmentNote(allergenSubstanceLabel(l10n, key)),
  ];
}

/// Recovers allergen keys when the model adapted the dish but forgot to
/// return [adjustedAllergens] (e.g. title ends with "Adaptado").
///
/// [title] is optional; when empty, only explicit keys / free-text notes apply.
List<String> inferAdjustedAllergens({
  required Iterable<String> adjustedAllergens,
  required Iterable<String> allergenAdjustments,
  required Iterable<String> userAllergens,
  String title = '',
}) {
  final parsed = normalizeAllergenKeys(adjustedAllergens);
  if (parsed.isNotEmpty) return parsed;

  final users = normalizeAllergenKeys(userAllergens);
  if (users.isEmpty) return const [];

  final notes = allergenAdjustments
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty);
  if (notes.isNotEmpty) return users;

  if (title.isNotEmpty &&
      RegExp(r'adaptad|adapted', caseSensitive: false).hasMatch(title)) {
    return users;
  }
  return const [];
}

const _legacyTagLabels = {
  'entrante': 'starter',
  'plato principal': 'main_course',
  'postre': 'dessert',
  'vegetariana': 'vegetarian',
  'vegano': 'vegan',
  'pescetariana': 'pescatarian',
  'sin gluten': 'gluten_free',
  'sin lactosa': 'lactose_free',
  'sin huevo': 'egg_free',
  'sin frutos secos': 'nut_free',
  'sin soja': 'soy_free',
  'sin marisco': 'shellfish_free',
  'sin azúcar': 'sugar_free',
  'alto en proteínas': 'high_protein',
  'baja en calorías': 'low_calorie',
  'baja en carbohidratos': 'low_carb',
  'alta en fibra': 'high_fiber',
  'rápida': 'quick',
  'económica': 'budget',
  'batch cooking': 'batch_cooking',
  'para congelar': 'freezer_friendly',
  'picante': 'spicy',
  'para niños': 'kid_friendly',
  'desayuno': 'breakfast',
  'tentempié': 'appetizer',
  'aperitivo': 'appetizer',
  'snack': 'appetizer',
  'sopa': 'soup',
  'ensalada': 'salad',
  'acompañamiento': 'side_dish',
  'sin lácteos': 'dairy_free',
  'sin cacahuetes': 'peanut_free',
  'sin pescado': 'fish_free',
  'saludable': 'healthy',
  'española': 'spanish',
  'italiana': 'italian',
  'asiática': 'asian',
  'mexicana': 'mexican',
  'india': 'indian',
  'sin horno': 'no_oven',
};

String normalizeTagKey(String tag) {
  if (suggestedRecipeTagKeys.contains(tag)) return tag;
  return _legacyTagLabels[tag] ?? tag;
}

/// Suggested chips first (catalog order), then custom tags in original order.
List<String> sortedRecipeTags(Iterable<String> tags) {
  final seen = <String>{};
  final custom = <String>[];
  for (final tag in tags) {
    final key = normalizeTagKey(tag.trim());
    if (key.isEmpty || !seen.add(key)) continue;
    if (!suggestedRecipeTagKeys.contains(key)) {
      custom.add(key);
    }
  }
  return [...suggestedRecipeTagKeys.where(seen.contains), ...custom];
}

String localizedTagLabel(AppLocalizations l10n, String tag) {
  return switch (normalizeTagKey(tag)) {
    'starter' => l10n.tagStarter,
    'main_course' => l10n.tagMainCourse,
    'dessert' => l10n.tagDessert,
    'breakfast' => l10n.tagBreakfast,
    'appetizer' => l10n.tagAppetizer,
    'soup' => l10n.tagSoup,
    'salad' => l10n.tagSalad,
    'side_dish' => l10n.tagSideDish,
    'vegetarian' => l10n.tagVegetarian,
    'vegan' => l10n.tagVegan,
    'pescatarian' => l10n.tagPescatarian,
    'gluten_free' => l10n.tagGlutenFree,
    'lactose_free' => l10n.tagLactoseFree,
    'dairy_free' => l10n.tagDairyFree,
    'egg_free' => l10n.tagEggFree,
    'nut_free' => l10n.tagNutFree,
    'peanut_free' => l10n.tagPeanutFree,
    'soy_free' => l10n.tagSoyFree,
    'fish_free' => l10n.tagFishFree,
    'shellfish_free' => l10n.tagShellfishFree,
    'sugar_free' => l10n.tagSugarFree,
    'high_protein' => l10n.tagHighProtein,
    'low_calorie' => l10n.tagLowCalorie,
    'low_carb' => l10n.tagLowCarb,
    'high_fiber' => l10n.tagHighFiber,
    'healthy' => l10n.tagHealthy,
    'spanish' => l10n.tagSpanish,
    'italian' => l10n.tagItalian,
    'asian' => l10n.tagAsian,
    'mexican' => l10n.tagMexican,
    'indian' => l10n.tagIndian,
    'quick' => l10n.tagQuick,
    'budget' => l10n.tagBudget,
    'batch_cooking' => l10n.tagBatchCooking,
    'freezer_friendly' => l10n.tagFreezerFriendly,
    'no_oven' => l10n.tagNoOven,
    'spicy' => l10n.tagSpicy,
    'kid_friendly' => l10n.tagKidFriendly,
    _ => tag,
  };
}

String mealTypeLabel(AppLocalizations l10n, String mealType) {
  return switch (mealType) {
    'breakfast' => l10n.mealBreakfast,
    'lunch' => l10n.mealLunch,
    'dinner' => l10n.mealDinner,
    _ => mealType,
  };
}

List<String> dayAbbreviations(AppLocalizations l10n) => [
  l10n.dayMon,
  l10n.dayTue,
  l10n.dayWed,
  l10n.dayThu,
  l10n.dayFri,
  l10n.daySat,
  l10n.daySun,
];

String deleteConfirmationWord(AppLocalizations l10n) {
  return switch (l10n.localeName) {
    'en' => 'DELETE',
    'eu' => 'EZABATU',
    'it' => 'ELIMINA',
    'es' || 'ca' || 'gl' || 'pt' => 'ELIMINAR',
    _ => 'DELETE',
  };
}
