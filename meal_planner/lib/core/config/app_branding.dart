/// User-visible product name (TestFlight / App Store: Böl).
abstract final class AppBranding {
  static const String displayName = 'Böl';

  /// Custom URL scheme for deep links (`bol://…`).
  /// ASCII only — URL schemes cannot include diacritics.
  static const String urlScheme = 'bol';

  /// Apple App Store ID (App Store Connect → App Information → Apple ID).
  static const String appStoreId = '6785110375';
}
