import 'package:meal_planner/core/config/app_branding.dart';

/// Base URL for recipe share links (Supabase landing with Open Graph previews).
abstract final class ShareUrls {
  static const supabaseProjectRef = 'hxtynisikjpwlvpdgdbt';

  static const landingBase =
      'https://$supabaseProjectRef.supabase.co/functions/v1/share-landing';

  static const base = String.fromEnvironment(
    'SHARE_BASE_URL',
    defaultValue: landingBase,
  );

  static const host = 'mealplanner-a818e.web.app';
  static const firebaseHost = 'mealplanner-a818e.firebaseapp.com';
  static const supabaseHost = '$supabaseProjectRef.supabase.co';

  static String privateLink(String token) => '$base/r/$token';

  static String publicLink(String recipeId) => '$base/p/$recipeId';

  static bool isShareHost(String host) {
    final h = host.toLowerCase();
    return h == ShareUrls.host ||
        h == firebaseHost ||
        h == supabaseHost;
  }

  static String? _locationFromKindAndId(String kind, String id) {
    return switch (kind) {
      'p' => '/home/explore/$id',
      'r' => '/share/r/$id',
      _ => null,
    };
  }

  /// Maps an incoming platform/share URI to an in-app go_router location.
  ///
  /// Returns null when [uri] is not a recipe share link.
  static String? appLocationForIncomingUri(Uri uri) {
    if (uri.scheme == AppBranding.urlScheme) {
      final host = uri.host;
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if ((host == 'r' || host == 'p') && segments.isNotEmpty) {
        return _locationFromKindAndId(host, segments.first);
      }
      if (segments.length >= 2 && (segments[0] == 'r' || segments[0] == 'p')) {
        return _locationFromKindAndId(segments[0], segments[1]);
      }
      return null;
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

    // Supabase landing: .../functions/v1/share-landing/r/<token>
    final landingIndex = segments.indexOf('share-landing');
    if (landingIndex >= 0 && segments.length > landingIndex + 2) {
      return _locationFromKindAndId(
        segments[landingIndex + 1],
        segments[landingIndex + 2],
      );
    }

    if (segments.length < 2) return null;
    if (segments[0] != 'p' && segments[0] != 'r') return null;

    // Firebase Hosting (/p/…, /r/…) and path-only links.
    if (uri.host.isNotEmpty && !isShareHost(uri.host)) return null;

    return _locationFromKindAndId(segments[0], segments[1]);
  }
}
