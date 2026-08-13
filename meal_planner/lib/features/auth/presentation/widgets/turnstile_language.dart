import 'package:flutter/widgets.dart';

/// Maps the app locale to a Turnstile `language` value.
String turnstileLanguageFor(Locale locale) {
  return switch (locale.languageCode) {
    'it' => 'it-IT',
    'pt' => 'pt-BR',
    'ca' || 'eu' || 'gl' => 'auto',
    _ => locale.languageCode,
  };
}
