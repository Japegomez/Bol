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
  'starter',
  'main_course',
  'dessert',
  'vegetarian',
  'vegan',
  'pescatarian',
  'gluten_free',
  'lactose_free',
  'egg_free',
  'nut_free',
  'soy_free',
  'shellfish_free',
  'sugar_free',
  'high_protein',
  'low_calorie',
  'low_carb',
  'high_fiber',
  'mediterranean',
  'quick',
  'budget',
  'batch_cooking',
  'freezer_friendly',
  'spicy',
  'kid_friendly',
];

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
  'mediterránea': 'mediterranean',
  'rápida': 'quick',
  'económica': 'budget',
  'batch cooking': 'batch_cooking',
  'para congelar': 'freezer_friendly',
  'picante': 'spicy',
  'para niños': 'kid_friendly',
};

String normalizeTagKey(String tag) {
  if (suggestedRecipeTagKeys.contains(tag)) return tag;
  return _legacyTagLabels[tag] ?? tag;
}

String localizedTagLabel(AppLocalizations l10n, String tag) {
  return switch (normalizeTagKey(tag)) {
    'starter' => l10n.tagStarter,
    'main_course' => l10n.tagMainCourse,
    'dessert' => l10n.tagDessert,
    'vegetarian' => l10n.tagVegetarian,
    'vegan' => l10n.tagVegan,
    'pescatarian' => l10n.tagPescatarian,
    'gluten_free' => l10n.tagGlutenFree,
    'lactose_free' => l10n.tagLactoseFree,
    'egg_free' => l10n.tagEggFree,
    'nut_free' => l10n.tagNutFree,
    'soy_free' => l10n.tagSoyFree,
    'shellfish_free' => l10n.tagShellfishFree,
    'sugar_free' => l10n.tagSugarFree,
    'high_protein' => l10n.tagHighProtein,
    'low_calorie' => l10n.tagLowCalorie,
    'low_carb' => l10n.tagLowCarb,
    'high_fiber' => l10n.tagHighFiber,
    'mediterranean' => l10n.tagMediterranean,
    'quick' => l10n.tagQuick,
    'budget' => l10n.tagBudget,
    'batch_cooking' => l10n.tagBatchCooking,
    'freezer_friendly' => l10n.tagFreezerFriendly,
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
