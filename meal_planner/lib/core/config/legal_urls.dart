/// Public legal documents hosted on GitHub Pages.
abstract final class LegalUrls {
  static const base = String.fromEnvironment(
    'LEGAL_BASE_URL',
    defaultValue: 'https://japegomez.github.io/Bol',
  );

  static String get terms => '$base/terminos.html';
  static String get privacy => '$base/privacidad.html';
}
