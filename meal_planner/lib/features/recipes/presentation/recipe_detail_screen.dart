import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';
import 'package:meal_planner/core/widgets/ingredient_bullet.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/recipes/domain/ingredient_label.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_step_text.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(recipeDetailProvider(recipeId));

    return Scaffold(
      body: detailAsync.when(
        data: (detail) => _RecipeDetailBody(
          recipeId: recipeId,
          photoUrl: detail.photoDisplayUrl,
          title: detail.recipe.title,
          servings: detail.recipe.servings,
          prepTime: detail.recipe.prepTime,
          cookTime: detail.recipe.cookTime,
          tags: detail.recipe.tags,
          isPublic: detail.recipe.isPublic,
          isForked: detail.isForked,
          ingredients: detail.ingredients,
          steps: detail.steps,
          nutrition: detail.nutrition,
          tips: detail.recipe.tips,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _RecipeDetailBody extends ConsumerStatefulWidget {
  const _RecipeDetailBody({
    required this.recipeId,
    required this.photoUrl,
    required this.title,
    required this.servings,
    required this.prepTime,
    required this.cookTime,
    required this.tags,
    required this.isPublic,
    required this.isForked,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    this.tips,
  });

  final String recipeId;
  final String? photoUrl;
  final String title;
  final int servings;
  final int? prepTime;
  final int? cookTime;
  final List<String> tags;
  final bool isPublic;
  final bool isForked;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final NutritionInfo? nutrition;
  final String? tips;

  @override
  ConsumerState<_RecipeDetailBody> createState() => _RecipeDetailBodyState();
}

class _RecipeDetailBodyState extends ConsumerState<_RecipeDetailBody> {
  late bool _isPublic;
  bool _isUpdatingVisibility = false;
  final Set<String> _updatingIngredientIds = {};

  @override
  void initState() {
    super.initState();
    _isPublic = widget.isPublic;
  }

  @override
  void didUpdateWidget(covariant _RecipeDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPublic != widget.isPublic) {
      _isPublic = widget.isPublic;
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar receta'),
        content: Text('¿Seguro que quieres eliminar "${widget.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(recipesRepositoryProvider).deleteRecipe(widget.recipeId);
    ref.invalidate(recipeListProvider);
    ref.invalidate(recipeTagsProvider);
    ref.invalidate(recipesProvider);
    ref.invalidate(planSlotsProvider);
    ref.invalidate(exploreRecipesProvider);
    if (context.mounted) context.pop();
  }

  Future<void> _toggleVisibility(bool value) async {
    if (widget.isForked && value) return;
    if (value == _isPublic || _isUpdatingVisibility) return;

    if (value) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Publicar receta'),
          content: const Text(
            'Esta receta será visible para todos los usuarios de '
            '${AppBranding.displayName}. Podrás despublicarla en cualquier momento.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Publicar'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hacer receta privada'),
          content: const Text(
            'La receta dejará de ser visible en Explorar. '
            'Las valoraciones existentes se conservan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hacer privada'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => _isUpdatingVisibility = true);
    try {
      await ref
          .read(recipesRepositoryProvider)
          .setRecipeVisibility(widget.recipeId, value);
      ref.invalidate(recipeDetailProvider(widget.recipeId));
      ref.invalidate(recipeListProvider);
      ref.invalidate(exploreRecipesProvider);
      ref.invalidate(publicTagsProvider);
      if (mounted) setState(() => _isPublic = value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar visibilidad: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingVisibility = false);
    }
  }

  Future<void> _toggleIngredientIncluded(
    Ingredient ingredient,
    bool isIncluded,
  ) async {
    if (_updatingIngredientIds.contains(ingredient.id)) return;

    setState(() => _updatingIngredientIds.add(ingredient.id));
    try {
      await ref.read(recipesRepositoryProvider).updateIngredientIncluded(
            ingredientId: ingredient.id,
            recipeId: widget.recipeId,
            isIncluded: isIncluded,
          );
      ref.invalidate(recipeDetailProvider(widget.recipeId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingIngredientIds.remove(ingredient.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: widget.photoUrl != null ? 240 : 120,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push('/home/recipes/${widget.recipeId}/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(widget.title),
            background: widget.photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: widget.photoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  )
                : null,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.people_outline,
                      label: '${widget.servings} raciones',
                    ),
                    if (_isPublic)
                      Chip(
                        avatar: Icon(
                          Icons.public,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: const Text('Pública'),
                      ),
                    if (widget.prepTime != null)
                      _InfoChip(
                        icon: Icons.timer_outlined,
                        label: 'Prep: ${widget.prepTime} min',
                      ),
                    if (widget.cookTime != null)
                      _InfoChip(
                        icon: Icons.local_fire_department_outlined,
                        label: 'Cocción: ${widget.cookTime} min',
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.isForked)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.bookmark_added_outlined),
                      title: Text('Receta guardada de otro usuario'),
                      subtitle: Text(
                        'Las recetas forkeadas no se pueden publicar en Explorar.',
                      ),
                    ),
                  )
                else
                  Card(
                    child: SwitchListTile(
                      title: const Text('Receta pública'),
                      subtitle: Text(
                        _isPublic
                            ? 'Visible en Explorar para todos los usuarios'
                            : 'Solo visible en tu recetario',
                      ),
                      secondary: _isUpdatingVisibility
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isPublic ? Icons.public : Icons.lock_outline,
                            ),
                      value: _isPublic,
                      onChanged:
                          _isUpdatingVisibility ? null : _toggleVisibility,
                    ),
                  ),
                if (widget.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.tags
                        .map((tag) => Chip(label: Text(tag)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Ingredientes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (widget.ingredients.isEmpty)
                  const Text('Sin ingredientes')
                else
                  ...widget.ingredients.map(
                        (ingredient) => _IngredientListTile(
                          ingredient: ingredient,
                          isUpdating:
                              _updatingIngredientIds.contains(ingredient.id),
                          onIncludedChanged: ingredient.isOptional &&
                                  !ingredient.isToTaste
                              ? (included) => _toggleIngredientIncluded(
                                    ingredient,
                                    included,
                                  )
                              : null,
                        ),
                      ),
                const SizedBox(height: 24),
                Text(
                  'Elaboración',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (widget.steps.isEmpty)
                  const Text('Sin pasos')
                else
                  ...widget.steps.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                child: Text('${entry.key + 1}'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RecipeStepText(step: entry.value),
                              ),
                            ],
                          ),
                        ),
                      ),
                if (widget.tips != null && widget.tips!.trim().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Consejos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.tips!),
                ],
                if (widget.nutrition != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Nutrición (por ración)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _NutritionGrid(nutrition: widget.nutrition!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IngredientListTile extends StatelessWidget {
  const _IngredientListTile({
    required this.ingredient,
    required this.isUpdating,
    required this.onIncludedChanged,
  });

  static const _leadingWidth = 40.0;
  static const _textTopPadding = 4.0;

  final Ingredient ingredient;
  final bool isUpdating;
  final ValueChanged<bool>? onIncludedChanged;

  @override
  Widget build(BuildContext context) {
    final excluded = ingredient.isOptional && !ingredient.isIncluded;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _leadingWidth,
            child: ingredient.isOptional && !ingredient.isToTaste
                ? _buildOptionalLeading()
                : Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: IngredientBullet(muted: excluded),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: _textTopPadding),
              child: Text(
                formatIngredientLabel(ingredient),
                style: excluded
                    ? TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalLeading() {
    if (isUpdating) {
      return const Padding(
        padding: EdgeInsets.only(top: 2),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Checkbox(
        value: ingredient.isIncluded,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        onChanged: onIncludedChanged == null
            ? null
            : (value) => onIncludedChanged!(value ?? ingredient.isIncluded),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

class _NutritionGrid extends StatelessWidget {
  const _NutritionGrid({required this.nutrition});

  final NutritionInfo nutrition;

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<String, String?>>[
      MapEntry('Calorías', _fmt(nutrition.calories, 'kcal')),
      MapEntry('Proteínas', _fmt(nutrition.protein, 'g')),
      MapEntry('Carbohidratos', _fmt(nutrition.carbohydrates, 'g')),
      MapEntry('Grasas', _fmt(nutrition.fat, 'g')),
      MapEntry('Fibra', _fmt(nutrition.fiber, 'g')),
    ].where((e) => e.value != null).toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => Chip(
              label: Text('${item.key}: ${item.value}'),
            ),
          )
          .toList(),
    );
  }

  String? _fmt(num? value, String unit) {
    if (value == null) return null;
    return '$value $unit';
  }
}
