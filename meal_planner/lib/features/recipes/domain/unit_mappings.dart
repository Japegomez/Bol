/// Unidades predefinidas (siempre en singular en el dropdown y en BD).
const weightUnits = ['g', 'kg'];
const volumeUnits = ['ml', 'l'];
const countUnits = ['unidad'];
const relativeUnits = [
  'pizca',
  'cucharadita',
  'cucharada',
  'vaso',
  'taza',
  'puñado',
  'hoja',
  'diente',
  'chorrito',
  'rebanada',
  'rama',
  'trozo',
  'filete',
  'rodaja',
  'lata',
  'bote',
  'paquete',
  'sobre',
  ];

const predefinedUnits = [
  ...weightUnits,
  ...volumeUnits,
  ...countUnits,
  ...relativeUnits,
];

const customUnitOption = 'Otra';

/// Mapeo singular → plural. Edita aquí para corregir pluralizaciones.
const unitPluralMap = <String, String>{
  'unidad': 'unidades',
  'pizca': 'pizcas',
  'cucharadita': 'cucharaditas',
  'cucharada': 'cucharadas',
  'vaso': 'vasos',
  'taza': 'tazas',
  'puñado': 'puñados',
  'hoja': 'hojas',
  'diente': 'dientes',
  'chorrito': 'chorritos',
  'rebanada': 'rebanadas',
  'rama': 'ramas',
  'trozo': 'trozos',
  'filete': 'filetes',
  'rodaja': 'rodajas',
  'lata': 'latas',
  'bote': 'botes',
  'paquete': 'paquetes',
  'sobre': 'sobres',
};

/// Normaliza unidades legacy (p. ej. "unidades" → "unidad").
String? normalizeUnit(String? unit) {
  if (unit == null || unit.isEmpty) return unit;
  if (unit == 'unidades') return 'unidad';
  if (predefinedUnits.contains(unit)) return unit;
  for (final entry in unitPluralMap.entries) {
    if (entry.value == unit) return entry.key;
  }
  return unit;
}

const abbreviatedUnits = [
  ...weightUnits,
  ...volumeUnits,
];

bool isAbbreviatedUnit(String? unit) {
  final normalized = normalizeUnit(unit);
  return normalized != null && abbreviatedUnits.contains(normalized);
}

/// Devuelve la unidad en singular o plural según la cantidad.
String? formatUnit(String? unit, num? quantity) {
  final normalized = normalizeUnit(unit);
  if (normalized == null || normalized.isEmpty) return null;
  if (quantity != null && quantity > 1) {
    return unitPluralMap[normalized] ?? normalized;
  }
  return normalized;
}
