import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/utils/date_utils.dart';
import 'package:meal_planner/core/supabase/models/nutrition_info.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/widgets/ingredient_bullet.dart';
import 'package:meal_planner/features/recipes/domain/ingredient_label.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_step_text.dart';
import 'package:meal_planner/features/social/domain/public_recipe_detail.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil público')),
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
                        Text('${profile.recipeCount} recetas públicas'),
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
                          child: Text(isFollowing ? 'Dejar de seguir' : 'Seguir'),
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
              const SliverFillRemaining(
                child: Center(child: Text('Sin recetas públicas')),
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
        error: (error, _) => Center(child: Text('Error: $error')),
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
        const SnackBar(content: Text('Receta guardada en tu recetario')),
      );
      context.go('/home/recipes/$newId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isRating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(publicRecipeDetailProvider(widget.recipeId));
    final currentUserId = supabase.auth.currentUser?.id;

    return Scaffold(
      body: detailAsync.when(
        data: (detail) {
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
                      tooltip: 'Guardar en mi recetario',
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
                      Row(
                        children: [
                          Text(
                            'Receta creada por ',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.onSurface,
                                    ),
                          ),
                          if (isOwn)
                            Text(
                              'ti',
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
                          Text('${detail.recipe.servings} raciones'),
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
                                formatRecipeCreatedAt(detail.recipe.createdAt),
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
                          'Tu valoración',
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
                              label: 'Prep: ${detail.recipe.prepTime} min',
                            ),
                          if (detail.recipe.cookTime != null)
                            _InfoChip(
                              icon: Icons.local_fire_department_outlined,
                              label: 'Cocción: ${detail.recipe.cookTime} min',
                            ),
                        ],
                      ),
                      if (detail.recipe.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: detail.recipe.tags
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
                      if (detail.ingredients.isEmpty)
                        const Text('Sin ingredientes')
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
                                        '${formatIngredientLabel(ingredient)}${ingredient.isOptional ? ' (opcional)' : ''}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      const SizedBox(height: 24),
                      Text(
                        'Elaboración',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (detail.steps.isEmpty)
                        const Text('Sin pasos')
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
                          'Consejos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(detail.recipe.tips!),
                      ],
                      if (detail.nutrition != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Nutrición (por ración)',
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
                            label: const Text('Guardar en mi recetario'),
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
        error: (error, _) => Center(child: Text('Error: $error')),
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
          .map((item) => Chip(label: Text('${item.key}: ${item.value}')))
          .toList(),
    );
  }

  String? _fmt(num? value, String unit) {
    if (value == null) return null;
    return '$value $unit';
  }
}
