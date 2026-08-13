import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/widgets/horizontal_tag_list.dart';
import 'package:meal_planner/core/widgets/overflow_marquee_text.dart';
import 'package:meal_planner/core/widgets/skeleton.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_targets.dart';
import 'package:meal_planner/features/recipes/data/recipe_assistant_repository.dart';
import 'package:meal_planner/features/recipes/data/recipe_translation_repository.dart';
import 'package:meal_planner/features/recipes/presentation/list_title_translation_provider.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_assistant_prompt_sheet.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_creation_options_sheet.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_tag_filter_bar.dart';
import 'package:meal_planner/features/social/presentation/widgets/social_sort_label.dart';

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(recipeListFilterProvider.notifier).state = ref
          .read(recipeListFilterProvider)
          .copyWith(search: value);
    });
  }

  Future<void> _openCreateRecipeOptions() async {
    final choice = await showRecipeCreationOptionsSheet(context);
    if (!mounted || choice == null) return;

    if (choice == 'manual') {
      context.push('/home/recipes/new');
      return;
    }

    final input = await showRecipeAssistantPromptSheet(context);
    if (!mounted || input == null) return;

    try {
      final result = await runWithRecipeAssistantBlockingOverlay(
        context: context,
        message: context.l10n.recipeAssistantBlockingRecipe,
        task: () =>
            ref.read(recipeAssistantRepositoryProvider).generateRecipe(input),
      );
      ref
          .read(recipeAssistantDraftProvider.notifier)
          .state = RecipeAssistantDraft(
        formData: result.formData,
        sourceLang: result.sourceLang,
      );
      if (!mounted) return;
      context.push('/home/recipes/new');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resolveRecipeAssistantError(
              error.toString().replaceFirst('Exception: ', ''),
              context.l10n,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final recipesAsync = ref.watch(recipeListProvider);
    final filter = ref.watch(recipeListFilterProvider);
    final favoriteIds = ref.watch(recipeFavoritesProvider).valueOrNull ?? {};
    final activeTags = filter.tags;
    final hasActiveFilter =
        filter.search.trim().isNotEmpty ||
        filter.tags.isNotEmpty ||
        filter.favoritesOnly;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recipeBookTitle)),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            key: OnboardingTargets.keyFor(OnboardingTarget.recipesGlossaryFab),
            heroTag: 'cooking-glossary',
            onPressed: () => context.push('/home/recipes/glossary'),
            tooltip: l10n.cookingGlossaryTooltip,
            child: const Icon(Icons.book),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            key: OnboardingTargets.keyFor(OnboardingTarget.recipesFab),
            heroTag: 'new-recipe',
            onPressed: _openCreateRecipeOptions,
            tooltip: l10n.newRecipeTooltip,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBar(
              key: OnboardingTargets.keyFor(OnboardingTarget.recipesSearchBar),
              constraints: const BoxConstraints(
                minWidth: double.infinity,
                minHeight: 56,
              ),
              controller: _searchController,
              hintText: l10n.searchByName,
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
          RecipeTagFilterBar(
            selectedTags: activeTags,
            leading: [
              FilterChip(
                label: Text(l10n.favoritesFilter),
                selected: filter.favoritesOnly,
                onSelected: (selected) {
                  ref.read(recipeListFilterProvider.notifier).state = filter
                      .copyWith(favoritesOnly: selected);
                },
              ),
            ],
            onSelectionChanged: (tags) {
              ref.read(recipeListFilterProvider.notifier).state = ref
                  .read(recipeListFilterProvider)
                  .copyWith(tags: tags);
            },
          ),
          SocialSortLabel<RecipeListSort>(
            label: filter.sort == RecipeListSort.alpha
                ? l10n.alphabeticalOrder
                : l10n.mostRecent,
            value: filter.sort,
            options: [
              SocialSortOption(
                value: RecipeListSort.recent,
                label: l10n.mostRecent,
              ),
              SocialSortOption(
                value: RecipeListSort.alpha,
                label: l10n.alphabeticalOrder,
              ),
            ],
            onSelected: (sort) {
              ref.read(recipeListFilterProvider.notifier).state = filter
                  .copyWith(sort: sort);
            },
          ),
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                var visible = recipes;
                if (filter.favoritesOnly) {
                  visible = visible
                      .where((recipe) => favoriteIds.contains(recipe.id))
                      .toList();
                }

                if (visible.isEmpty) {
                  if (hasActiveFilter) {
                    final emptyMessage =
                        filter.favoritesOnly &&
                            filter.search.trim().isEmpty &&
                            filter.tags.isEmpty
                        ? l10n.noFavoriteRecipes
                        : l10n.noRecipesFoundForSearch;
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filter.favoritesOnly &&
                                      filter.search.trim().isEmpty &&
                                      filter.tags.isEmpty
                                  ? Icons.star_border
                                  : Icons.search_off_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              emptyMessage,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.noRecipesYet),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: _openCreateRecipeOptions,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.createFirstRecipe),
                        ),
                      ],
                    ),
                  );
                }

                final targetLang = ref.watch(currentLanguageCodeProvider);
                final titles =
                    ref
                        .watch(
                          listTitleTranslationsProvider(
                            TitleTranslationRequest(
                              targetLang: targetLang,
                              ids: visible.map((r) => r.id),
                            ),
                          ),
                        )
                        .valueOrNull ??
                    const <String, String>{};

                if (filter.sort == RecipeListSort.alpha) {
                  visible = [...visible]
                    ..sort((a, b) {
                      final titleA = titles[a.id] ?? a.title;
                      final titleB = titles[b.id] ?? b.title;
                      return titleA.toLowerCase().compareTo(
                        titleB.toLowerCase(),
                      );
                    });
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(recipeListProvider);
                    ref.invalidate(recipeTagsProvider);
                    ref.invalidate(recipesProvider);
                    ref.invalidate(recipeFavoritesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final recipe = visible[index];
                      return _RecipeCard(
                        recipe: recipe,
                        titleOverride: titles[recipe.id],
                      );
                    },
                  ),
                );
              },
              loading: () => const SkeletonList(
                item: RecipeCardSkeleton(
                  showVisibilityLine: true,
                  showFavoriteOnPhoto: true,
                ),
              ),
              error: (error, _) =>
                  Center(child: Text(l10n.errorWithMessage('$error'))),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.recipe, this.titleOverride});

  final Recipe recipe;
  final String? titleOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final photoUrlAsync = ref.watch(recipePhotoUrlProvider(recipe.photoUrl));
    final isFavorite =
        ref.watch(recipeFavoritesProvider).valueOrNull?.contains(recipe.id) ??
        false;
    final favoriteBusy = ref
        .watch(favoriteInFlightIdsProvider)
        .contains(recipe.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/home/recipes/${recipe.id}'),
        child: RecipeCardRow(
          photo: Stack(
            fit: StackFit.expand,
            children: [
              photoUrlAsync.when(
                data: (url) {
                  if (url == null) {
                    return const RecipePhotoPlaceholder();
                  }
                  return CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (_, _) => const _RecipePhotoSkeleton(),
                    errorWidget: (_, _, _) => const RecipePhotoPlaceholder(
                      child: Icon(Icons.broken_image),
                    ),
                  );
                },
                loading: () => const _RecipePhotoSkeleton(),
                error: (_, _) => const RecipePhotoPlaceholder(),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Material(
                  type: MaterialType.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.82),
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: isFavorite
                        ? l10n.unfavoriteRecipeTooltip
                        : l10n.favoriteRecipeTooltip,
                    onPressed: favoriteBusy
                        ? null
                        : () {
                            ref
                                .read(recipeFavoritesProvider.notifier)
                                .toggle(recipe.id);
                          },
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      size: 22,
                      color: isFavorite
                          ? Colors.amber
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OverflowMarqueeText(
                  text: titleOverride ?? recipe.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.servingsCount(recipe.servings),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      recipe.isPublic ? Icons.public : Icons.lock_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe.isPublic ? l10n.publicBadge : l10n.privateBadge,
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
      ),
    );
  }
}

class _RecipePhotoSkeleton extends StatelessWidget {
  const _RecipePhotoSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: SkeletonBox(borderRadius: BorderRadius.zero),
    );
  }
}
