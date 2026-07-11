import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_tag_filter_bar.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';
import 'package:meal_planner/features/social/presentation/widgets/public_recipe_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      ref.read(exploreRecipesProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(exploreFilterProvider.notifier).state =
          ref.read(exploreFilterProvider).copyWith(search: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final exploreState = ref.watch(exploreRecipesProvider);
    final filter = ref.watch(exploreFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.rss_feed_outlined),
            tooltip: 'Feed',
            onPressed: () => context.push('/home/explore/feed'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar recetas públicas',
              leading: const Icon(Icons.search),
              onChanged: _onSearchChanged,
              trailing: _searchController.text.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      ),
                    ]
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Recientes'),
                  selected: filter.sort == 'recent',
                  onSelected: (_) {
                    ref.read(exploreFilterProvider.notifier).state =
                        filter.copyWith(sort: 'recent');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Mejor valoradas'),
                  selected: filter.sort == 'top',
                  onSelected: (_) {
                    ref.read(exploreFilterProvider.notifier).state =
                        filter.copyWith(sort: 'top');
                  },
                ),
              ],
            ),
          ),
          PublicTagFilterBar(
            selectedTags: filter.tags,
            onSelectionChanged: (tags) {
              ref.read(exploreFilterProvider.notifier).state =
                  filter.copyWith(tags: tags);
            },
          ),
          Expanded(
            child: _buildBody(context, exploreState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ExploreRecipesState state) {
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
              onPressed: () =>
                  ref.read(exploreRecipesProvider.notifier).reload(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            const Text('No hay recetas públicas todavía'),
            const SizedBox(height: 8),
            const Text(
              'Publica una receta desde tu recetario para que otros la descubran.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(exploreRecipesProvider.notifier).reload(),
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
