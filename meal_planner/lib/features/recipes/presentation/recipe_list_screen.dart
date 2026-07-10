import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/widgets/horizontal_tag_list.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';

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
      ref.read(recipeListFilterProvider.notifier).state =
          ref.read(recipeListFilterProvider).copyWith(search: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipeListProvider);
    final tagsAsync = ref.watch(recipeTagsProvider);
    final filter = ref.watch(recipeListFilterProvider);
    final activeTag = filter.tag;
    final hasActiveFilter =
        filter.search.trim().isNotEmpty || filter.tag != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Recetario')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/home/recipes/new'),
        tooltip: 'Nueva receta',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar por nombre',
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
          tagsAsync.when(
            data: (tags) {
              if (tags.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Todas'),
                        selected: activeTag == null,
                        onSelected: (_) {
                          ref.read(recipeListFilterProvider.notifier).state =
                              ref
                                  .read(recipeListFilterProvider)
                                  .copyWith(clearTag: true);
                        },
                      ),
                    ),
                    ...tags.map(
                      (tag) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(tag),
                          selected: activeTag == tag,
                          onSelected: (_) {
                            ref.read(recipeListFilterProvider.notifier).state =
                                ref
                                    .read(recipeListFilterProvider)
                                    .copyWith(tag: tag);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  if (hasActiveFilter) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se ha encontrado ninguna receta relacionada '
                              'con la búsqueda. Créala tú mismo.',
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
                        const Text('No hay recetas todavía'),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () => context.push('/home/recipes/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Crear primera receta'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(recipeListProvider);
                    ref.invalidate(recipeTagsProvider);
                    ref.invalidate(recipesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return _RecipeCard(recipe: recipes[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrlAsync = ref.watch(recipePhotoUrlProvider(recipe.photoUrl));

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/home/recipes/${recipe.id}'),
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
                    Text(
                      '${recipe.servings} raciones',
                      style: Theme.of(context).textTheme.bodySmall,
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
