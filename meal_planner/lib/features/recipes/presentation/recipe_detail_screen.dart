import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/core/supabase/models/ingredient.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/models/recipe_step.dart';
import 'package:meal_planner/core/widgets/ingredient_bullet.dart';
import 'package:meal_planner/features/household/presentation/household_provider.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/recipes/data/recipe_translation_repository.dart';
import 'package:meal_planner/features/recipes/data/recipes_repository.dart';
import 'package:meal_planner/features/recipes/domain/ingredient_label.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_display_provider.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_assistant_prompt_sheet.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_step_text.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/translation_status_banner.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  ConsumerState<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  bool _showOriginal = false;
  ProviderSubscription<String>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _languageSubscription = ref.listenManual(currentLanguageCodeProvider, (_, _) {
      if (mounted) setState(() => _showOriginal = false);
    });
  }

  @override
  void dispose() {
    _languageSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayAsync = ref.watch(recipeDisplayProvider(widget.recipeId));

    return Scaffold(
      body: displayAsync.when(
        data: (state) {
          final effective =
              _showOriginal ? state.withShowOriginal(true) : state;
          final detail = effective.detail;
          return _RecipeDetailBody(
            recipeId: widget.recipeId,
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
            sourceLang: state.originalDetail?.sourceLang ?? detail.sourceLang,
            isTranslated: state.isTranslated,
            translationFailed: state.translationFailed,
            showingOriginal: _showOriginal,
            onToggleOriginal: state.isTranslated
                ? () => setState(() => _showOriginal = !_showOriginal)
                : null,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(l10n.errorWithMessage('$error'))),
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
    this.sourceLang = 'es',
    this.isTranslated = false,
    this.translationFailed = false,
    this.showingOriginal = false,
    this.onToggleOriginal,
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
  final String sourceLang;
  final bool isTranslated;
  final bool translationFailed;
  final bool showingOriginal;
  final VoidCallback? onToggleOriginal;

  @override
  ConsumerState<_RecipeDetailBody> createState() => _RecipeDetailBodyState();
}

class _RecipeDetailBodyState extends ConsumerState<_RecipeDetailBody> {
  late bool _isPublic;
  bool _isUpdatingVisibility = false;
  bool _isGeneratingNutrition = false;
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

  Future<void> _completeNutritionWithAssistant() async {
    if (_isGeneratingNutrition) return;

    setState(() => _isGeneratingNutrition = true);
    await generateNutritionWithAssistant(
      ref: ref,
      context: context,
      title: widget.title,
      servings: widget.servings,
      ingredients: widget.ingredients
          .map(
            (ingredient) => IngredientFormItem(
              name: ingredient.name,
              quantity: ingredient.isToTaste ? null : ingredient.quantity,
              unit: ingredient.unit,
              category: normalizeCategoryKey(ingredient.category),
              isOptional: ingredient.isOptional,
              isIncluded: ingredient.isIncluded,
              isToTaste: ingredient.isToTaste,
            ),
          )
          .toList(),
      onSuccess: (nutrition) async {
        await ref.read(recipesRepositoryProvider).saveNutrition(
              widget.recipeId,
              nutrition,
            );
        ref.invalidate(recipeDetailProvider(widget.recipeId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.recipeAssistantNutritionSaved)),
          );
        }
      },
    );
    if (mounted) {
      setState(() => _isGeneratingNutrition = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogL10n = dialogContext.l10n;
        return AlertDialog(
          title: Text(dialogL10n.deleteRecipeTitle),
          content: Text(dialogL10n.deleteRecipeConfirm(widget.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(dialogL10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(dialogL10n.delete),
            ),
          ],
        );
      },
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
        builder: (dialogContext) {
          final dialogL10n = dialogContext.l10n;
          return AlertDialog(
            title: Text(dialogL10n.publishRecipeTitle),
            content: Text(
              dialogL10n.publishRecipeMessage(AppBranding.displayName),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(dialogL10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(dialogL10n.publish),
              ),
            ],
          );
        },
      );
      if (confirmed != true || !mounted) return;
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final dialogL10n = dialogContext.l10n;
          return AlertDialog(
            title: Text(dialogL10n.makeRecipePrivateTitle),
            content: Text(dialogL10n.makeRecipePrivateMessageDetail),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(dialogL10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(dialogL10n.makePrivate),
              ),
            ],
          );
        },
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => _isUpdatingVisibility = true);
    try {
      final household = ref.read(currentHouseholdProvider).valueOrNull;
      await ref
          .read(recipesRepositoryProvider)
          .setRecipeVisibility(
            widget.recipeId,
            value,
            householdId: household?.id,
          );
      ref.invalidate(recipeDetailProvider(widget.recipeId));
      ref.invalidate(recipeListProvider);
      ref.invalidate(exploreRecipesProvider);
      ref.invalidate(publicTagsProvider);
      if (mounted) setState(() => _isPublic = value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.visibilityChangeError('$e'),
          ),
        ),
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
      final household = ref.read(currentHouseholdProvider).valueOrNull;
      await ref.read(recipesRepositoryProvider).updateIngredientIncluded(
            ingredientId: ingredient.id,
            recipeId: widget.recipeId,
            isIncluded: isIncluded,
            householdId: household?.id,
          );
      ref.invalidate(recipeDetailProvider(widget.recipeId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorWithMessage('$e'))),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingIngredientIds.remove(ingredient.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appLocale = ref.watch(currentLanguageCodeProvider);
    final contentLocale = recipeContentLocaleName(
      sourceLang: widget.sourceLang,
      appLocale: appLocale,
      isTranslated: widget.isTranslated,
      showingOriginal: widget.showingOriginal,
    );
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
                TranslationStatusBanner(
                  l10n: l10n,
                  isTranslated: widget.isTranslated,
                  translationFailed: widget.translationFailed,
                  showingOriginal: widget.showingOriginal,
                  onToggleOriginal: widget.onToggleOriginal,
                ),
                if (widget.isTranslated || widget.translationFailed)
                  const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.people_outline,
                      label: l10n.servingsCount(widget.servings),
                    ),
                    if (_isPublic)
                      Chip(
                        avatar: Icon(
                          Icons.public,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(l10n.publicBadge),
                      ),
                    if (widget.prepTime != null)
                      _InfoChip(
                        icon: Icons.timer_outlined,
                        label: l10n.prepTimeMin(widget.prepTime!),
                      ),
                    if (widget.cookTime != null)
                      _InfoChip(
                        icon: Icons.local_fire_department_outlined,
                        label: l10n.cookTimeMin(widget.cookTime!),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.isForked)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.bookmark_added_outlined),
                      title: Text(l10n.forkedRecipeTitle),
                      subtitle: Text(l10n.forkedRecipeCannotPublish),
                    ),
                  )
                else
                  Card(
                    child: SwitchListTile(
                      title: Text(l10n.publicRecipeSwitch),
                      subtitle: Text(
                        _isPublic
                            ? l10n.visibleInExplore
                            : l10n.onlyInRecipeBook,
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
                        .map(
                          (tag) => Chip(label: Text(localizedTagLabel(l10n, tag))),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n.ingredientsSection,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (widget.ingredients.isEmpty)
                  Text(l10n.noIngredients)
                else
                  ...widget.ingredients.map(
                        (ingredient) => _IngredientListTile(
                          key: ValueKey(
                            '${ingredient.id}-$contentLocale-${widget.showingOriginal}',
                          ),
                          ingredient: ingredient,
                          contentLocaleName: contentLocale,
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
                  l10n.preparationSection,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (widget.steps.isEmpty)
                  Text(l10n.noSteps)
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
                    l10n.tipsSection,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.tips!),
                ],
                if (widget.nutrition != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.nutritionPerServing,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _NutritionGrid(nutrition: widget.nutrition!, l10n: l10n),
                ] else ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.nutritionPerServing,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _isGeneratingNutrition
                        ? null
                        : _completeNutritionWithAssistant,
                    icon: _isGeneratingNutrition
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_outlined),
                    label: Text(l10n.completeNutritionWithAssistant),
                  ),
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
    super.key,
    required this.ingredient,
    required this.contentLocaleName,
    required this.isUpdating,
    required this.onIncludedChanged,
  });

  static const _leadingWidth = 40.0;
  static const _textTopPadding = 4.0;

  final Ingredient ingredient;
  final String contentLocaleName;
  final bool isUpdating;
  final ValueChanged<bool>? onIncludedChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                formatIngredientLabel(
                  l10n,
                  ingredient,
                  contentLocaleName: contentLocaleName,
                ),
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
  const _NutritionGrid({required this.nutrition, required this.l10n});

  final NutritionInfo nutrition;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<String, String?>>[
      MapEntry(l10n.calories, _fmt(nutrition.calories, 'kcal')),
      MapEntry(l10n.protein, _fmt(nutrition.protein, 'g')),
      MapEntry(l10n.carbohydrates, _fmt(nutrition.carbohydrates, 'g')),
      MapEntry(l10n.fat, _fmt(nutrition.fat, 'g')),
      MapEntry(l10n.fiber, _fmt(nutrition.fiber, 'g')),
    ].where((e) => e.value != null).toList();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => Chip(
              label: Text(l10n.nutritionChip(item.key, item.value!)),
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
