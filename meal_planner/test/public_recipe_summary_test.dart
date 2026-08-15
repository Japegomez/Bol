import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/social/domain/public_recipe_summary.dart';

void main() {
  group('PublicRecipeSummary.fromJson', () {
    test('parses a complete payload', () {
      final recipe = PublicRecipeSummary.fromJson({
        'id': 'abc',
        'user_id': 'user-1',
        'title': 'Arroz con leche',
        'photo_url': 'https://example.com/photo.jpg',
        'servings': 4,
        'tags': ['vegetarian', 'dessert'],
        'created_at': '2026-08-01T10:00:00Z',
        'author_name': 'Javi',
        'avg_score': '4.5',
        'rating_count': '12',
      });

      expect(recipe.id, 'abc');
      expect(recipe.userId, 'user-1');
      expect(recipe.title, 'Arroz con leche');
      expect(recipe.photoUrl, 'https://example.com/photo.jpg');
      expect(recipe.servings, 4);
      expect(recipe.tags, ['dessert', 'vegetarian']);
      expect(recipe.authorName, 'Javi');
      expect(recipe.avgScore, 4.5);
      expect(recipe.ratingCount, 12);
    });

    test('defaults missing author, tags and scores', () {
      final recipe = PublicRecipeSummary.fromJson({
        'id': 7,
        'user_id': 3,
        'title': 'Sopa',
        'servings': '2',
        'created_at': '2026-08-01T10:00:00Z',
      });

      expect(recipe.tags, isEmpty);
      expect(recipe.authorName, 'Usuario');
      expect(recipe.avgScore, 0);
      expect(recipe.ratingCount, 0);
      expect(recipe.photoUrl, isNull);
    });
  });
}
