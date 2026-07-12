import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/core/offline/offline_exceptions.dart';
import 'package:meal_planner/core/offline/supabase_error_utils.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/utils/date_utils.dart';
import 'package:meal_planner/core/widgets/ingredient_bullet.dart';
import 'package:meal_planner/features/recipes/data/recipe_translation_repository.dart';
import 'package:meal_planner/features/recipes/domain/ingredient_label.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_step_text.dart';
import 'package:meal_planner/features/social/domain/public_recipe_detail.dart';
import 'package:meal_planner/features/social/presentation/public_recipe_translation_provider.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';
import 'package:meal_planner/features/social/presentation/widgets/fork_optional_ingredients_dialog.dart';
import 'package:meal_planner/features/social/presentation/widgets/public_recipe_card.dart';
import 'package:meal_planner/features/social/presentation/widgets/star_rating_bar.dart';

class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(userId));
    final followingAsync = ref.watch(isFollowingProvider(userId));
    final currentUserId = supabase.auth.currentUser?.id;
    final isSelf = currentUserId == userId;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.publicProfileTitle)),
      body: profileAsync.when(
        data: (profile) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: profile.avatarUrl != null
                          ? CachedNetworkImageProvider(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? Text(
                              profile.username.isNotEmpty
                                  ? profile.username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(fontSize: 32),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.username,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.publicRecipesCount(profile.recipeCount)),
                        if (profile.avgRating > 0) ...[
                          const SizedBox(width: 16),
                          StarRatingDisplay(rating: profile.avgRating),
                        ],
                      ],
                    ),
                    if (!isSelf) ...[
                      const SizedBox(height: 16),
                      followingAsync.when(
                        data: (isFollowing) => FilledButton.tonal(
                          onPressed: () async {
                            final repo = ref.read(socialRepositoryProvider);
                            if (isFollowing) {
                              await repo.unfollowUser(userId);
                            } else {
                              await repo.followUser(userId);
                            }
                            ref.invalidate(isFollowingProvider(userId));
                            ref.invalidate(feedProvider);
                          },
                          child: Text(isFollowing ? l10n.unfollow : l10n.follow),
                        ),
                        loading: () => const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (profile.recipes.isEmpty)
              SliverFillRemaining(
                child: Center(child: Text(l10n.noPublicRecipes)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        PublicRecipeCard(recipe: profile.recipes[index]),
                    childCount: profile.recipes.length,
                  ),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorWithMessage('$error'))),
      ),
    );
  }
}

class PublicRecipeDetailScreen extends ConsumerStatefulWidget {
  const PublicRecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  ConsumerState<PublicRecipeDetailScreen> createState() =>
      _PublicRecipeDetailScreenState();
}

class _PublicRecipeDetailScreenState
    extends ConsumerState<PublicRecipeDetailScreen> {
  bool _isForking = false;
  bool _isRating = false;
  bool _showOriginal = false;

  @override
  void initState() {
    super.initState();
    // Reset "view original" toggle whenever the app language changes so the
    // screen automatically shows the new translation instead of the old one.
    ref.listenManual(currentLanguageCodeProvider, (_, _) {
      if (mounted) setState(() => _showOriginal = false);
    });
  }

  Future<void> _forkRecipe(PublicRecipeDetail detail) async {
    final optionalIngredients =
        detail.ingredients.where((ingredient) => ingredient.isOptional).toList();

    setState(() => _isForking = true);
    try {
      final newId =
          await ref.read(socialRepositoryProvider).forkRecipe(widget.recipeId);
      ref.invalidate(recipeListProvider);
      ref.invalidate(recipesProvider);
      if (!mounted) return;

      if (optionalIngredients.isNotEmpty) {
        final action = await showForkOptionalIngredientsNoticeDialog(
          context,
          optionalIngredients: optionalIngredients,
        );
        if (!mounted) return;
        if (action == ForkOptionalNoticeAction.edit) {
          context.go('/home/recipes/$newId/edit');
        } else {
          context.go('/home/recipes/$newId');
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recipeSavedToBook)),
      );
      context.go('/home/recipes/$newId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorWithMessage('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isForking = false);
    }
  }

  Future<void> _rateRecipe(int score) async {
    setState(() => _isRating = true);
    try {
      await ref.read(socialRepositoryProvider).rateRecipe(widget.recipeId, score);
      ref.invalidate(publicRecipeDetailProvider(widget.recipeId));
      ref.invalidate(exploreRecipesProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorWithMessage('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isRating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayAsync =
        ref.watch(publicRecipeDisplayProvider(widget.recipeId));
    final currentUserId = supabase.auth.currentUser?.id;
    final l10n = context.l10n;
    final appLocale = ref.watch(currentLanguageCodeProvider);

    return Scaffold(
      body: displayAsync.when(
        data: (displayState) {
          final detail = _showOriginal && displayState.originalDetail != null
              ? displayState.originalDetail!
              : displayState.detail;
          final sourceLang =
              displayState.originalDetail?.sourceLang ?? detail.sourceLang;
          final contentLocale = recipeContentLocaleName(
            sourceLang: sourceLang,
            appLocale: appLocale,
            isTranslated: displayState.isTranslated,
            showingOriginal: _showOriginal,
          );
          final isOwn = detail.recipe.userId == currentUserId;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: detail.photoDisplayUrl != null ? 240 : 120,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  if (!isOwn && !_isForking)
                    IconButton(
                      icon: const Icon(Icons.bookmark_add_outlined),
                      tooltip: l10n.saveToMyRecipeBookTooltip,
                      onPressed: () => _forkRecipe(detail),
                    )
                  else if (!isOwn && _isForking)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(detail.recipe.title),
                  background: detail.photoDisplayUrl != null
                      ? CachedNetworkImage(
                          imageUrl: detail.photoDisplayUrl!,
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
                      if (displayState.isTranslated) ...[
                        Card(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.translate,
                                  size: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.autoTranslatedBadge,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => setState(
                                    () => _showOriginal = !_showOriginal,
                                  ),
                                  child: Text(
                                    _showOriginal
                                        ? l10n.viewTranslation
                                        : l10n.viewOriginal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else if (displayState.translationFailed) ...[
                        Text(
                          l10n.translationFailed,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Text(
                            '${l10n.recipeCreatedBy} ',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.onSurface,
                                    ),
                          ),
                          if (isOwn)
                            Text(
                              l10n.you,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                            )
                          else
                            InkWell(
                              onTap: () => context.push(
                                '/home/explore/user/${detail.recipe.userId}',
                              ),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 1,
                                ),
                                child: Text(
                                  detail.authorName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StarRatingDisplay(
                            rating: detail.avgScore,
                            count: detail.ratingCount,
                          ),
                          Text(l10n.servingsCount(detail.recipe.servings)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatRecipeCreatedAt(
                                  detail.recipe.createdAt,
                                  appLocale,
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (!isOwn) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.yourRating,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        _isRating
                            ? const LinearProgressIndicator()
                            : StarRatingBar(
                                rating: (detail.myRating ?? 0).toDouble(),
                                onRatingChanged: _rateRecipe,
                              ),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          if (detail.recipe.prepTime != null)
                            _InfoChip(
                              icon: Icons.timer_outlined,
                              label: l10n.prepTimeMin(detail.recipe.prepTime!),
                            ),
                          if (detail.recipe.cookTime != null)
                            _InfoChip(
                              icon: Icons.local_fire_department_outlined,
                              label: l10n.cookTimeMin(detail.recipe.cookTime!),
                            ),
                        ],
                      ),
                      if (detail.recipe.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: detail.recipe.tags
                              .map(
                                (tag) => Chip(
                                  label: Text(localizedTagLabel(l10n, tag)),
                                ),
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
                      if (detail.ingredients.isEmpty)
                        Text(l10n.noIngredients)
                      else
                        ...detail.ingredients.map(
                              (ingredient) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const IngredientBullet(),
                                    Expanded(
                                      child: Text(
                                        '${formatIngredientLabel(l10n, ingredient, contentLocaleName: contentLocale)}${ingredient.isOptional ? ' ${l10n.optionalIngredientSuffix}' : ''}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.preparationSection,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (detail.steps.isEmpty)
                        Text(l10n.noSteps)
                      else
                        ...detail.steps.asMap().entries.map(
                              (entry) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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
                      if (detail.recipe.tips != null &&
                          detail.recipe.tips!.trim().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.tipsSection,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(detail.recipe.tips!),
                      ],
                      if (detail.nutrition != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.nutritionPerServing,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        _NutritionGrid(nutrition: detail.nutrition!),
                      ],
                      const SizedBox(height: 16),
                      if (!isOwn)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed:
                                _isForking ? null : () => _forkRecipe(detail),
                            icon: const Icon(Icons.bookmark_add_outlined),
                            label: Text(l10n.saveToMyRecipeBook),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          final isOffline = error is OfflinePublicRecipeBlockedException ||
              isTransientNetworkError(error);
          if (isOffline) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.exploreUnavailableOffline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(
                        publicRecipeDisplayProvider(widget.recipeId),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(child: Text(l10n.errorWithMessage('$error')));
        },
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
    final l10n = context.l10n;
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
