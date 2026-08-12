import 'package:meal_planner/core/config/app_branding.dart';

/// Base URL for recipe share links (Firebase Hosting → App Links).
///
/// WhatsApp/link crawlers: Hosting redirects to `share-landing`, which publishes
/// a title-only HTML page to Supabase Storage (`text/html`). Edge Functions on
/// `*.supabase.co` are forced to `text/plain`, so Storage is used for the page.
abstract final class ShareUrls {
  static const supabaseProjectRef = 'hxtynisikjpwlvpdgdbt';

  static const landingBase =
      'https://$supabaseProjectRef.supabase.co/functions/v1/share-landing';

  static const storageOgBase =
      'https://$supabaseProjectRef.supabase.co/storage/v1/object/public/share-og';

  static const base = String.fromEnvironment(
    'SHARE_BASE_URL',
    defaultValue: 'https://mealplanner-a818e.web.app',
  );

  static const host = 'mealplanner-a818e.web.app';
  static const firebaseHost = 'mealplanner-a818e.firebaseapp.com';
  static const supabaseHost = '$supabaseProjectRef.supabase.co';

  static String privateLink(String token) => '$base/r/$token';

  static String publicLink(String recipeId) => '$base/p/$recipeId';

  static String householdInviteLink(String code) => '$base/h/$code';

  static bool isShareHost(String host) {
    final h = host.toLowerCase();
    return h == ShareUrls.host || h == firebaseHost || h == supabaseHost;
  }

  static bool _isShareKind(String kind) =>
      kind == 'p' || kind == 'r' || kind == 'h';

  static String? _locationFromKindAndId(String kind, String id) {
    final cleanId = id.endsWith('.html') ? id.substring(0, id.length - 5) : id;
    return switch (kind) {
      'p' => '/home/explore/$cleanId',
      'r' => '/share/r/$cleanId',
      'h' =>
        '/home/profile/household/join?code=${Uri.encodeComponent(cleanId)}',
      _ => null,
    };
  }

  /// Maps an incoming platform/share URI to an in-app go_router location.
  ///
  /// Returns null when [uri] is not a recipe or household invite share link.
  static String? appLocationForIncomingUri(Uri uri) {
    if (uri.scheme == AppBranding.urlScheme) {
      final host = uri.host;
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (_isShareKind(host) && segments.isNotEmpty) {
        return _locationFromKindAndId(host, segments.first);
      }
      if (segments.length >= 2 && _isShareKind(segments[0])) {
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

    // Storage OG page: .../storage/v1/object/public/share-og/p/<id>.html
    final ogIndex = segments.indexOf('share-og');
    if (ogIndex >= 0 && segments.length > ogIndex + 2) {
      return _locationFromKindAndId(
        segments[ogIndex + 1],
        segments[ogIndex + 2],
      );
    }

    if (segments.length < 2) return null;
    if (!_isShareKind(segments[0])) return null;

    // Firebase Hosting (/p/…, /r/…, /h/…) and path-only links.
    if (uri.host.isNotEmpty && !isShareHost(uri.host)) return null;

    return _locationFromKindAndId(segments[0], segments[1]);
  }
}
