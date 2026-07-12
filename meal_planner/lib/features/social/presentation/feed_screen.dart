import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_tag_filter_bar.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';
import 'package:meal_planner/features/social/presentation/widgets/public_recipe_card.dart';
import 'package:meal_planner/features/social/presentation/widgets/social_sort_label.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final selectedTags = ref.watch(feedTagsFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PublicTagFilterBar(
            selectedTags: selectedTags,
            onSelectionChanged: (tags) {
              ref.read(feedTagsFilterProvider.notifier).state = tags;
            },
          ),
          const SocialSortLabel(label: 'Más reciente'),
          Expanded(child: _buildBody(context, feedState, selectedTags)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FeedState state,
    Set<String> selectedTags,
  ) {
    if (state.isLoading && state.recipes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: ${state.error}'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.read(feedProvider.notifier).reload(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.recipes.isEmpty) {
      final hasTagFilter = selectedTags.isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasTagFilter ? Icons.label_off_outlined : Icons.rss_feed_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                hasTagFilter
                    ? 'Sin recetas con estas etiquetas'
                    : 'Tu feed está vacío',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                hasTagFilter
                    ? 'Prueba con otras etiquetas o quita el filtro.'
                    : 'Sigue a otros usuarios desde sus perfiles para ver sus recetas públicas aquí.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).reload(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.recipes.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.recipes.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return PublicRecipeCard(recipe: state.recipes[index]);
        },
      ),
    );
  }
}
