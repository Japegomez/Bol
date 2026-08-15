import 'package:meal_planner/core/locale/localized_data.dart';

class PublicRecipeSummary {
  const PublicRecipeSummary({
    required this.id,
    required this.userId,
    required this.title,
    this.photoUrl,
    required this.servings,
    required this.tags,
    required this.createdAt,
    required this.authorName,
    required this.avgScore,
    required this.ratingCount,
  });

  final String id;
  final String userId;
  final String title;
  final String? photoUrl;
  final int servings;
  final List<String> tags;
  final DateTime createdAt;
  final String authorName;
  final double avgScore;
  final int ratingCount;

  factory PublicRecipeSummary.fromJson(Map<String, dynamic> json) {
    return PublicRecipeSummary(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      title: json['title'].toString(),
      photoUrl: json['photo_url']?.toString(),
      servings: int.parse(json['servings'].toString()),
      tags: json['tags'] != null
          ? sortedRecipeTags(
              (json['tags'] as List<dynamic>).map((e) => e.toString()),
            )
          : <String>[],
      createdAt: DateTime.parse(json['created_at'].toString()),
      authorName: json['author_name']?.toString() ?? 'Usuario',
      avgScore: double.tryParse(json['avg_score']?.toString() ?? '0') ?? 0,
      ratingCount: int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class PublicProfileData {
  const PublicProfileData({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.recipeCount,
    required this.avgRating,
    required this.recipes,
  });

  final String userId;
  final String username;
  final String? avatarUrl;
  final int recipeCount;
  final double avgRating;
  final List<PublicRecipeSummary> recipes;
}
