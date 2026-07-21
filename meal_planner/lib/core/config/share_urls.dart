/// Base URL for recipe share deep links (Firebase Hosting).
abstract final class ShareUrls {
  static const base = String.fromEnvironment(
    'SHARE_BASE_URL',
    defaultValue: 'https://mealplanner-a818e.web.app',
  );

  static const host = 'mealplanner-a818e.web.app';

  static String privateLink(String token) => '$base/r/$token';

  static String publicLink(String recipeId) => '$base/p/$recipeId';
}
