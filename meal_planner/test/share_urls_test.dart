import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/config/share_urls.dart';

void main() {
  group('ShareUrls.appLocationForIncomingUri', () {
    test('maps Hosting public recipe URL', () {
      final uri = Uri.parse(
        'https://mealplanner-a818e.web.app/p/3101fa52-2927-4259-b9f1-9b206acc27bb',
      );
      expect(
        ShareUrls.appLocationForIncomingUri(uri),
        '/home/explore/3101fa52-2927-4259-b9f1-9b206acc27bb',
      );
    });

    test('maps Hosting private share URL', () {
      final uri = Uri.parse(
        'https://mealplanner-a818e.web.app/r/edaabb97dda745298bdb24c06b2fbf9abf71d8cbe9364f62b038774361470ab8',
      );
      expect(
        ShareUrls.appLocationForIncomingUri(uri),
        '/share/r/edaabb97dda745298bdb24c06b2fbf9abf71d8cbe9364f62b038774361470ab8',
      );
    });

    test('maps path-only public and private links', () {
      expect(
        ShareUrls.appLocationForIncomingUri(
          Uri.parse('/p/3101fa52-2927-4259-b9f1-9b206acc27bb'),
        ),
        '/home/explore/3101fa52-2927-4259-b9f1-9b206acc27bb',
      );
      expect(
        ShareUrls.appLocationForIncomingUri(Uri.parse('/r/abc123')),
        '/share/r/abc123',
      );
    });

    test('maps custom scheme', () {
      expect(
        ShareUrls.appLocationForIncomingUri(
          Uri.parse('recetea://p/3101fa52-2927-4259-b9f1-9b206acc27bb'),
        ),
        '/home/explore/3101fa52-2927-4259-b9f1-9b206acc27bb',
      );
      expect(
        ShareUrls.appLocationForIncomingUri(Uri.parse('recetea://r/tok')),
        '/share/r/tok',
      );
    });

    test('ignores unrelated hosts and paths', () {
      expect(
        ShareUrls.appLocationForIncomingUri(
          Uri.parse('https://example.com/p/abc'),
        ),
        isNull,
      );
      expect(
        ShareUrls.appLocationForIncomingUri(Uri.parse('/home/explore/abc')),
        isNull,
      );
    });
  });
}
