import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/recipes/data/recipe_translation_repository.dart';
import 'package:meal_planner/features/recipes/presentation/list_title_translation_provider.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_targets.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_tag_filter_bar.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';
import 'package:meal_planner/features/social/presentation/widgets/public_recipe_card.dart';
import 'package:meal_planner/features/social/presentation/widgets/social_sort_label.dart';

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
    final sortLabel =
        filter.sort == 'top' ? context.l10n.topRated : context.l10n.recent;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.exploreTitle),
        actions: [
          IconButton(
            key: OnboardingTargets.keyFor(OnboardingTarget.exploreFeedButton),
            icon: const Icon(Icons.rss_feed_outlined),
            tooltip: context.l10n.feedTooltip,
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
              hintText: context.l10n.searchPublicRecipes,
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
                  label: Text(context.l10n.recent),
                  selected: filter.sort == 'recent',
                  onSelected: (_) {
                    ref.read(exploreFilterProvider.notifier).state =
                        filter.copyWith(sort: 'recent');
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(context.l10n.topRated),
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
          SocialSortLabel(label: sortLabel),
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
            Text(context.l10n.errorWithMessage(state.error!)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () =>
                  ref.read(exploreRecipesProvider.notifier).reload(),
              child: Text(context.l10n.retry),
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
            Text(context.l10n.noPublicRecipesYet),
            const SizedBox(height: 8),
            Text(
              context.l10n.publishToExploreHint,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final targetLang = ref.watch(currentLanguageCodeProvider);
    final titles = ref
            .watch(
              listTitleTranslationsProvider(
                TitleTranslationRequest(
                  targetLang: targetLang,
                  ids: state.recipes.map((r) => r.id),
                ),
              ),
            )
            .valueOrNull ??
        const <String, String>{};

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
          final recipe = state.recipes[index];
          return PublicRecipeCard(
            recipe: recipe,
            titleOverride: titles[recipe.id],
          );
        },
      ),
    );
  }
}
