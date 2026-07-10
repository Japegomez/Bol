import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/features/social/domain/public_recipe_summary.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';
import 'package:meal_planner/features/social/presentation/widgets/star_rating_bar.dart';

class PublicRecipeCard extends ConsumerWidget {
  const PublicRecipeCard({required this.recipe, super.key});

  final PublicRecipeSummary recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrlAsync = ref.watch(socialPhotoUrlProvider(recipe.photoUrl));

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
                      recipe.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () =>
                          context.push('/home/explore/user/${recipe.userId}'),
                      child: Text(
                        recipe.authorName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
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
                          '${recipe.servings} raciones',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (recipe.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _HorizontalTagList(tags: recipe.tags),
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

class _HorizontalTagList extends StatefulWidget {
  const _HorizontalTagList({required this.tags});

  final List<String> tags;

  @override
  State<_HorizontalTagList> createState() => _HorizontalTagListState();
}

class _HorizontalTagListState extends State<_HorizontalTagList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final offset = (_scrollController.offset - delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _scrollController.jumpTo(offset);
  }

  void _fling(DragEndDetails details) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final target = (_scrollController.offset -
            details.velocity.pixelsPerSecond.dx * 0.15)
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => _scrollBy(details.delta.dx),
        onHorizontalDragEnd: _fling,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              for (var index = 0; index < widget.tags.length; index++) ...[
                if (index > 0) const SizedBox(width: 4),
                Chip(
                  label: Text(widget.tags[index]),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
