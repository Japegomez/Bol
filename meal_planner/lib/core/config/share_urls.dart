/// Base URL for recipe share deep links (Firebase Hosting).
abstract final class ShareUrls {
  static const base = String.fromEnvironment(
    'SHARE_BASE_URL',
    defaultValue: 'https://mealplanner-a818e.web.app',
  );

  static const host = 'mealplanner-a818e.web.app';
  static const firebaseHost = 'mealplanner-a818e.firebaseapp.com';

  static String privateLink(String token) => '$base/r/$token';

  static String publicLink(String recipeId) => '$base/p/$recipeId';

  static bool isShareHost(String host) {
    final h = host.toLowerCase();
    return h == ShareUrls.host || h == firebaseHost;
  }

  /// Maps an incoming platform/share URI to an in-app go_router location.
  ///
  /// Returns null when [uri] is not a recipe share link.
  static String? appLocationForIncomingUri(Uri uri) {
    if (uri.scheme == 'recetea') {
      final host = uri.host;
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if ((host == 'r' || host == 'p') && segments.isNotEmpty) {
        return host == 'p'
            ? '/home/explore/${segments.first}'
            : '/share/r/${segments.first}';
      }
      if (segments.length >= 2 && (segments[0] == 'r' || segments[0] == 'p')) {
        return segments[0] == 'p'
            ? '/home/explore/${segments[1]}'
            : '/share/r/${segments[1]}';
      }
      return null;
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) return null;
    if (segments[0] != 'p' && segments[0] != 'r') return null;

    // Accept path-only (/p/…, /r/…) and Hosting hosts.
    if (uri.host.isNotEmpty && !isShareHost(uri.host)) return null;

    return segments[0] == 'p'
        ? '/home/explore/${segments[1]}'
        : '/share/r/${segments[1]}';
  }
}
