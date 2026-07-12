import 'package:flutter/material.dart';

/// Central list of locales supported by the app UI.
const supportedAppLocales = <Locale>[
  Locale('en'),
  Locale('es'),
  Locale('ca'),
  Locale('eu'),
  Locale('gl'),
  Locale('pt'),
];

/// BCP-47 language codes used for recipe translation and source_lang.
const supportedAppLanguageCodes = ['en', 'es', 'ca', 'eu', 'gl', 'pt'];

/// Native endonyms for the language picker (independent of the active UI locale).
const languageEndonyms = <String, String>{
  'en': 'English',
  'es': 'Español',
  'ca': 'Català',
  'eu': 'Euskara',
  'gl': 'Galego',
  'pt': 'Português',
};

String languageCodeFromLocale(Locale locale) => locale.languageCode;

Locale? localeFromLanguageCode(String? code) {
  if (code == null || code.isEmpty) return null;
  for (final locale in supportedAppLocales) {
    if (locale.languageCode == code) return locale;
  }
  return null;
}

String displayNameForLanguageCode(String code) =>
    languageEndonyms[code] ?? code;
