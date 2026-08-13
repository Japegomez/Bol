import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/widgets/horizontal_tag_list.dart';
import 'package:meal_planner/core/widgets/skeleton.dart';
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
        child: RecipeCardRow(
          photo: photoUrlAsync.when(
            data: (url) {
              if (url == null) {
                return const _PhotoPlaceholder(
                  child: Icon(Icons.restaurant, size: 40),
                );
              }
              return CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (_, _) => const _PhotoSkeleton(),
                errorWidget: (_, _, _) =>
                    const _PhotoPlaceholder(child: Icon(Icons.broken_image)),
              );
            },
            loading: () => const _PhotoSkeleton(),
            error: (_, _) => const _PhotoPlaceholder(
              child: Icon(Icons.restaurant, size: 40),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleOverride ?? recipe.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      l10n.servingsCount(recipe.servings),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    StarRatingDisplay(rating: recipe.avgScore),
                    const SizedBox(width: 8),
                    Text(
                      l10n.recipeCreatedByName,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: InkWell(
                        onTap: () =>
                            context.push('/home/explore/user/${recipe.userId}'),
                        borderRadius: BorderRadius.circular(4),
                        child: Text(
                          recipe.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
      ),
    );
  }
}

/// Placeholder card matching [PublicRecipeCard] layout while photos load.
class PublicRecipeCardSkeleton extends StatelessWidget {
  const PublicRecipeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: SkeletonPulse(
        child: RecipeCardSkeleton(showTags: true, showAuthorLine: true),
      ),
    );
  }
}

class PublicRecipeCardSkeletonList extends StatelessWidget {
  const PublicRecipeCardSkeletonList({this.itemCount = 6, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonList(
      itemCount: itemCount,
      item: const RecipeCardSkeleton(showTags: true, showAuthorLine: true),
    );
  }
}

/// Keeps a skeleton list visible until the first recipe photos are decoded.
class PublicRecipeListPhotoGate extends ConsumerStatefulWidget {
  const PublicRecipeListPhotoGate({
    required this.recipes,
    required this.child,
    this.firstPageCount = 6,
    super.key,
  });

  final List<PublicRecipeSummary> recipes;
  final Widget child;
  final int firstPageCount;

  @override
  ConsumerState<PublicRecipeListPhotoGate> createState() =>
      _PublicRecipeListPhotoGateState();
}

class _PublicRecipeListPhotoGateState
    extends ConsumerState<PublicRecipeListPhotoGate> {
  static const _precacheTimeout = Duration(seconds: 4);

  bool _revealed = false;
  Object? _precacheToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_precacheFirstPagePhotos());
    });
  }

  @override
  void didUpdateWidget(PublicRecipeListPhotoGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_revealed) return;
    if (!_sameFirstPage(oldWidget.recipes, widget.recipes)) {
      unawaited(_precacheFirstPagePhotos());
    }
  }

  bool _sameFirstPage(
    List<PublicRecipeSummary> a,
    List<PublicRecipeSummary> b,
  ) {
    final firstA = a.take(widget.firstPageCount).map((r) => r.id);
    final firstB = b.take(widget.firstPageCount).map((r) => r.id);
    return firstA.join(',') == firstB.join(',');
  }

  Future<void> _precacheFirstPagePhotos() async {
    final token = Object();
    _precacheToken = token;

    final firstPage = widget.recipes.take(widget.firstPageCount);
    final withPhotos = firstPage
        .where(
          (recipe) => recipe.photoUrl != null && recipe.photoUrl!.isNotEmpty,
        )
        .toList();

    if (withPhotos.isEmpty) {
      _revealIfCurrent(token);
      return;
    }

    try {
      final urls = await Future.wait(
        withPhotos.map(
          (recipe) => ref.read(socialPhotoUrlProvider(recipe.photoUrl).future),
        ),
      ).timeout(_precacheTimeout, onTimeout: () => <String?>[]);
      if (!mounted || _precacheToken != token) return;

      final context = this.context;
      await Future.wait(
        urls.whereType<String>().map(
          (url) => precacheImage(
            CachedNetworkImageProvider(url),
            context,
          ).timeout(_precacheTimeout, onTimeout: () {}),
        ),
      ).timeout(_precacheTimeout, onTimeout: () => <void>[]);
    } catch (_) {
      // Reveal anyway so a failed photo never blocks the list.
    }

    _revealIfCurrent(token);
  }

  void _revealIfCurrent(Object token) {
    if (!mounted || _precacheToken != token || _revealed) return;
    setState(() => _revealed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_revealed) return widget.child;
    return PublicRecipeCardSkeletonList(itemCount: widget.firstPageCount);
  }
}

class _PhotoSkeleton extends StatelessWidget {
  const _PhotoSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: SkeletonBox(borderRadius: BorderRadius.zero),
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
      child: Center(
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.outline),
          child: child,
        ),
      ),
    );
  }
}
