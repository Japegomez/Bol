import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';

void main() {
  group('normalizeUnit', () {
    test('returns null and empty unchanged', () {
      expect(normalizeUnit(null), isNull);
      expect(normalizeUnit(''), '');
    });

    test('maps unidades to unidad', () {
      expect(normalizeUnit('unidades'), 'unidad');
    });

    test('maps other plurals to singular', () {
      expect(normalizeUnit('cucharadas'), 'cucharada');
      expect(normalizeUnit('tazas'), 'taza');
    });

    test('keeps predefined singular units', () {
      expect(normalizeUnit('g'), 'g');
      expect(normalizeUnit('unidad'), 'unidad');
    });

    test('keeps unknown custom units', () {
      expect(normalizeUnit('ramita'), 'ramita');
    });
  });

  group('isAbbreviatedUnit', () {
    test('is true for weight and volume', () {
      expect(isAbbreviatedUnit('g'), isTrue);
      expect(isAbbreviatedUnit('ml'), isTrue);
    });

    test('is false for word units', () {
      expect(isAbbreviatedUnit('unidad'), isFalse);
      expect(isAbbreviatedUnit('cucharada'), isFalse);
    });
  });

  group('formatUnit', () {
    test('returns null for missing units', () {
      expect(formatUnit(null, 2), isNull);
      expect(formatUnit('', 2), isNull);
    });

    test('pluralizes when quantity is greater than 1', () {
      expect(formatUnit('unidad', 2), 'unidades');
      expect(formatUnit('cucharadita', 3), 'cucharaditas');
    });

    test('keeps singular for 1 or missing quantity', () {
      expect(formatUnit('unidad', 1), 'unidad');
      expect(formatUnit('unidad', null), 'unidad');
    });

    test('keeps abbreviated units unchanged', () {
      expect(formatUnit('g', 200), 'g');
    });
  });
}
