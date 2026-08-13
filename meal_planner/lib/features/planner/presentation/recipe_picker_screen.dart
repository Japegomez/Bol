import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/core/utils/date_utils.dart';
import 'package:meal_planner/core/widgets/skeleton.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/planner/presentation/widgets/past_meal_dialog.dart';
import 'package:meal_planner/features/planner/presentation/widgets/servings_dialog.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_tag_filter_bar.dart';

class RecipePickerSheet extends ConsumerStatefulWidget {
  const RecipePickerSheet({
    required this.dayOfWeek,
    required this.mealType,
    super.key,
  });

  final int dayOfWeek;
  final String mealType;

  @override
  ConsumerState<RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends ConsumerState<RecipePickerSheet> {
  final _searchController = TextEditingController();
  Set<String> _selectedTags = {};
  bool _leftoverMode = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectRecipe(Recipe recipe) async {
    final canEdit = ref.read(canEditOfflineProvider);
    final notifier = ref.read(planSlotsProvider.notifier);
    final dayOfWeek = widget.dayOfWeek;
    final mealType = widget.mealType;
    final weekStart = ref.read(currentWeekProvider);
    final isPast = isPastPlannerDay(
      weekStart: weekStart,
      dayOfWeek: dayOfWeek,
    );

    if (_leftoverMode) {
      if (!canEdit) return;
      Navigator.pop(context);
      await notifier.addSlot(
        dayOfWeek: dayOfWeek,
        mealType: mealType,
        recipeId: recipe.id,
        servings: recipe.servings > 0 ? recipe.servings : 1,
        recipeTitle: recipe.title,
        isLeftover: true,
      );
      return;
    }

    final result = await showServingsDialog(
      context,
      defaultServings: recipe.servings,
      canConfirm: canEdit,
    );

    if (result == null || !mounted) return;

    if (isPast) {
      await showPastMealPlanDialog(context);
      if (!mounted) return;
    }

    Navigator.pop(context);
    await notifier.addSlot(
      dayOfWeek: dayOfWeek,
      mealType: mealType,
      recipeId: recipe.id,
      servings: result.servings,
      recipeTitle: recipe.title,
      isLeftover: false,
      skipShopping: isPast,
    );
  }

  Future<void> _addTextEntry() async {
    final canEdit = ref.read(canEditOfflineProvider);
    final result = await showAddTextDialog(context, canConfirm: canEdit);
    if (result == null || !mounted) return;

    final notifier = ref.read(planSlotsProvider.notifier);
    final dayOfWeek = widget.dayOfWeek;
    final mealType = widget.mealType;
    Navigator.pop(context);
    await notifier.addSlot(
      dayOfWeek: dayOfWeek,
      mealType: mealType,
      recipeId: null,
      servings: result.servings,
      notes: result.notes,
      isLeftover: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);
    final hasActiveFilter =
        _searchController.text.trim().isNotEmpty || _selectedTags.isNotEmpty;
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _leftoverMode ? l10n.leftovers : l10n.chooseRecipe,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchRecipeHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          RecipeTagFilterBar(
            selectedTags: _selectedTags,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            onSelectionChanged: (tags) => setState(() => _selectedTags = tags),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: const Icon(Icons.edit_note),
                  title: Text(l10n.addFreeText),
                  subtitle: Text(l10n.noRecipeExample),
                  onTap: () {
                    if (_leftoverMode) {
                      setState(() => _leftoverMode = false);
                    }
                    _addTextEntry();
                  },
                ),
                ListTile(
                  selected: _leftoverMode,
                  selectedTileColor:
                      colorScheme.tertiaryContainer.withValues(alpha: 0.45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: Icon(
                    Icons.dinner_dining_outlined,
                    color: _leftoverMode
                        ? colorScheme.onTertiaryContainer
                        : null,
                  ),
                  title: Text(l10n.leftovers),
                  subtitle: Text(l10n.leftoversShoppingHint),
                  trailing: _leftoverMode
                      ? Icon(
                          Icons.check_circle,
                          color: colorScheme.tertiary,
                        )
                      : null,
                  onTap: () =>
                      setState(() => _leftoverMode = !_leftoverMode),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: recipesAsync.when(
              loading: () => const SkeletonList(
                item: ListTileSkeleton(),
              ),
              error: (error, _) =>
                  Center(child: Text(l10n.errorWithMessage('$error'))),
              data: (recipes) {
                final displayRecipes = filterRecipesByQueryAndTags(
                  recipes,
                  query: _searchController.text,
                  tags: _selectedTags,
                );

                if (displayRecipes.isEmpty) {
                  return Center(
                    child: Text(
                      hasActiveFilter
                          ? l10n.noResults
                          : l10n.noRecipesCreateInBook,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayRecipes.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final recipe = displayRecipes[index];
                    return ListTile(
                      title: Text(recipe.title),
                      subtitle: _leftoverMode
                          ? null
                          : Text(l10n.servingsCount(recipe.servings)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selectRecipe(recipe),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
