import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/locale/supported_locales.dart';

void main() {
  group('localeFromLanguageCode', () {
    test('returns null for missing codes', () {
      expect(localeFromLanguageCode(null), isNull);
      expect(localeFromLanguageCode(''), isNull);
    });

    test('resolves supported codes', () {
      expect(localeFromLanguageCode('es'), const Locale('es'));
      expect(localeFromLanguageCode('eu'), const Locale('eu'));
    });

    test('returns null for unsupported codes', () {
      expect(localeFromLanguageCode('fr'), isNull);
    });
  });

  group('languageCodeFromLocale', () {
    test('reads the language code', () {
      expect(languageCodeFromLocale(const Locale('pt', 'BR')), 'pt');
    });
  });

  group('displayNameForLanguageCode', () {
    test('returns the endonym for known codes', () {
      expect(displayNameForLanguageCode('es'), 'Español');
      expect(displayNameForLanguageCode('eu'), 'Euskara');
    });

    test('falls back to the raw code', () {
      expect(displayNameForLanguageCode('fr'), 'fr');
    });
  });
}
