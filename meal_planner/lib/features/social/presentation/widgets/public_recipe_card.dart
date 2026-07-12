import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/widgets/horizontal_tag_list.dart';
import 'package:meal_planner/features/social/domain/public_recipe_summary.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';
import 'package:meal_planner/features/social/presentation/widgets/star_rating_bar.dart';

class PublicRecipeCard extends ConsumerWidget {
  const PublicRecipeCard({required this.recipe, this.titleOverride, super.key});

  final PublicRecipeSummary recipe;

  /// Machine-translated title to display instead of [recipe.title], when the
  /// current app language differs from the recipe's source language.
  final String? titleOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrlAsync = ref.watch(socialPhotoUrlProvider(recipe.photoUrl));
    final l10n = context.l10n;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/home/explore/${recipe.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: photoUrlAsync.when(
                data: (url) {
                  if (url == null) {
                    return const ColoredBox(
                      color: Color(0xFFE0E0E0),
                      child: Icon(Icons.restaurant, size: 40),
                    );
                  }
                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (_, _, _) => const Icon(Icons.broken_image),
                  );
                },
                loading: () => const ColoredBox(
                  color: Color(0xFFE0E0E0),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, _) => const ColoredBox(
                  color: Color(0xFFE0E0E0),
                  child: Icon(Icons.restaurant, size: 40),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleOverride ?? recipe.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () =>
                          context.push('/home/explore/user/${recipe.userId}'),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          recipe.authorName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StarRatingDisplay(
                          rating: recipe.avgScore,
                          count: recipe.ratingCount,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.servingsCount(recipe.servings),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (recipe.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      HorizontalTagList(tags: recipe.tags),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
