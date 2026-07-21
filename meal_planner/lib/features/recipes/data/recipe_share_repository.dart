import 'package:meal_planner/core/config/share_urls.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';

class RecipeShareLink {
  const RecipeShareLink({
    required this.token,
    required this.expiresAt,
    required this.url,
  });

  final String token;
  final DateTime expiresAt;
  final String url;
}

class RecipeShareRepository {
  Future<RecipeShareLink> getOrCreatePrivateShareLink(String recipeId) async {
    final data = await supabase.rpc<dynamic>(
      'get_or_create_recipe_share_link',
      params: {'p_recipe_id': recipeId},
    );

    final map = data is Map
        ? Map<String, dynamic>.from(data)
        : Map<String, dynamic>.from((data as List).first as Map);
    final token = map['token'] as String;
    return RecipeShareLink(
      token: token,
      expiresAt: DateTime.parse(map['expires_at'] as String),
      url: ShareUrls.privateLink(token),
    );
  }

  Future<String> resolvePrivateShareToken(String token) async {
    final recipeId = await supabase.rpc<dynamic>(
      'resolve_recipe_share',
      params: {'p_token': token},
    );
    return recipeId.toString();
  }

  String publicShareUrl(String recipeId) => ShareUrls.publicLink(recipeId);
}
