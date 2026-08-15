import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';

/// Horizontal chips for multi-select tag filtering.
class TagFilterChips extends StatelessWidget {
  const TagFilterChips({
    required this.tags,
    required this.selectedTags,
    required this.onSelectionChanged,
    this.leading = const [],
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    super.key,
  });

  final Iterable<String> tags;
  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onSelectionChanged;
  final List<Widget> leading;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sorted = tags.toList()..sort();
    if (sorted.isEmpty && leading.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        children: [
          for (final child in leading)
            Padding(padding: const EdgeInsets.only(right: 8), child: child),
          if (selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(l10n.clearTags),
                selected: false,
                onSelected: (_) => onSelectionChanged({}),
              ),
            ),
          ...sorted.map(
            (tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(localizedTagLabel(l10n, tag)),
                selected: selectedTags.contains(tag),
                onSelected: (selected) {
                  final next = Set<String>.from(selectedTags);
                  if (selected) {
                    next.add(tag);
                  } else {
                    next.remove(tag);
                  }
                  onSelectionChanged(next);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tag filter for the user's recipe book.
class RecipeTagFilterBar extends ConsumerWidget {
  const RecipeTagFilterBar({
    required this.selectedTags,
    required this.onSelectionChanged,
    this.leading = const [],
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    super.key,
  });

  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onSelectionChanged;
  final List<Widget> leading;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(recipeTagsProvider);

    return TagFilterChips(
      tags: tagsAsync.valueOrNull ?? const [],
      selectedTags: selectedTags,
      onSelectionChanged: onSelectionChanged,
      leading: leading,
      padding: padding,
    );
  }
}

/// Tag filter for public recipes in Explore.
class PublicTagFilterBar extends ConsumerWidget {
  const PublicTagFilterBar({
    required this.selectedTags,
    required this.onSelectionChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    super.key,
  });

  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onSelectionChanged;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(publicTagsProvider);

    return tagsAsync.when(
      data: (tags) => TagFilterChips(
        tags: tags,
        selectedTags: selectedTags,
        onSelectionChanged: onSelectionChanged,
        padding: padding,
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

List<Recipe> filterRecipesByQueryAndTags(
  List<Recipe> recipes, {
  required String query,
  Set<String> tags = const {},
}) {
  var result = recipes;
  final normalizedQuery = query.trim().toLowerCase();

  if (normalizedQuery.isNotEmpty) {
    result = result
        .where((recipe) => recipe.title.toLowerCase().contains(normalizedQuery))
        .toList();
  }
  if (tags.isNotEmpty) {
    result = result
        .where((recipe) => tags.every(recipe.tags.contains))
        .toList();
  }
  return result;
}
