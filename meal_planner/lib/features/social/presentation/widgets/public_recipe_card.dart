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
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/home/explore/${recipe.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: photoUrlAsync.when(
                      data: (url) {
                        if (url == null) {
                          return _PhotoPlaceholder(
                            child: Icon(
                              Icons.restaurant,
                              size: 40,
                              color: theme.colorScheme.outline,
                            ),
                          );
                        }
                        return CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const _PhotoPlaceholder(
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, _, _) => _PhotoPlaceholder(
                            child: Icon(
                              Icons.broken_image,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        );
                      },
                      loading: () => const _PhotoPlaceholder(
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, _) => _PhotoPlaceholder(
                        child: Icon(
                          Icons.restaurant,
                          size: 40,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            titleOverride ?? recipe.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => context
                                .push('/home/explore/user/${recipe.userId}'),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                recipe.authorName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary,
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
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (recipe.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: HorizontalTagList(tags: recipe.tags),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: child,
    );
  }
}
