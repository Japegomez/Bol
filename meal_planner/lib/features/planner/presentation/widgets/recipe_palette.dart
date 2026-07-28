import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/features/planner/domain/planner_drag_payload.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_tag_filter_bar.dart';

/// Side panel that lists recipe cards which can be dragged onto planner slots.
class RecipePalette extends ConsumerStatefulWidget {
  const RecipePalette({
    required this.onClose,
    required this.onDragUpdate,
    required this.onDragEnd,
    super.key,
  });

  final VoidCallback onClose;
  final void Function(Offset globalPosition) onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  ConsumerState<RecipePalette> createState() => _RecipePaletteState();
}

class _RecipePaletteState extends ConsumerState<RecipePalette> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  Set<String> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Recipe> _filter(List<Recipe> recipes) {
    return filterRecipesByQueryAndTags(
      recipes,
      query: _query,
      tags: _selectedTags,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Material(
      elevation: 8,
      color: colorScheme.surface,
      child: SafeArea(
        left: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.recipeBookPanel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onClose,
                    tooltip: l10n.closeTooltip,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            RecipeTagFilterBar(
              selectedTags: _selectedTags,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              onSelectionChanged: (tags) => setState(() => _selectedTags = tags),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: recipesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(l10n.errorWithMessage('$error')),
                  ),
                ),
                data: (recipes) {
                  final filtered = _filter(recipes);
                  final hasActiveFilter =
                      _query.isNotEmpty || _selectedTags.isNotEmpty;
                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          hasActiveFilter
                              ? l10n.noResults
                              : l10n.noRecipesCreateInBook,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  }

                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return _DraggableRecipeCard(
                              recipe: filtered[index],
                              onDragUpdate: widget.onDragUpdate,
                              onDragEnd: widget.onDragEnd,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraggableRecipeCard extends ConsumerWidget {
  const _DraggableRecipeCard({
    required this.recipe,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final Recipe recipe;
  final void Function(Offset globalPosition) onDragUpdate;
  final VoidCallback onDragEnd;

  void _finishDrag(WidgetRef ref) {
    ref.read(plannerDragActiveProvider.notifier).state = false;
    onDragEnd();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = _RecipeCardContent(recipe: recipe);

    return Draggable<PlannerDragPayload>(
      data: PlannerRecipeDrag(recipe),
      rootOverlay: true,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _DragFeedback(recipe: recipe),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      onDragStarted: () =>
          ref.read(plannerDragActiveProvider.notifier).state = true,
      onDragUpdate: (details) => onDragUpdate(details.globalPosition),
      onDragEnd: (_) => _finishDrag(ref),
      onDraggableCanceled: (_, _) => _finishDrag(ref),
      child: card,
    );
  }
}

class _RecipeCardContent extends ConsumerWidget {
  const _RecipeCardContent({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoUrlAsync = ref.watch(recipePhotoUrlProvider(recipe.photoUrl));
    final l10n = context.l10n;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 44,
                height: 44,
                child: photoUrlAsync.when(
                  data: (url) {
                    if (url == null) {
                      return const ColoredBox(
                        color: Color(0xFFE0E0E0),
                        child: Icon(Icons.restaurant, size: 22),
                      );
                    }
                    return CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const ColoredBox(
                        color: Color(0xFFE0E0E0),
                      ),
                      errorWidget: (_, _, _) => const Icon(Icons.broken_image),
                    );
                  },
                  loading: () => const ColoredBox(color: Color(0xFFE0E0E0)),
                  error: (_, _) => const ColoredBox(
                    color: Color(0xFFE0E0E0),
                    child: Icon(Icons.restaurant, size: 22),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    l10n.servingsCount(recipe.servings),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.drag_indicator,
              size: 18,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _DragFeedback extends StatelessWidget {
  const _DragFeedback({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                recipe.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
