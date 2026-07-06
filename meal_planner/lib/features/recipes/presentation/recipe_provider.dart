import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/recipes/data/recipes_repository.dart';
import 'package:meal_planner/features/recipes/domain/recipe_detail.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';

final recipesRepositoryProvider = Provider<RecipesRepository>((ref) {
  return RecipesRepository();
});

/// Used by the planner recipe picker (F7).
final recipesProvider =
    AsyncNotifierProvider<RecipesNotifier, List<Recipe>>(RecipesNotifier.new);

class RecipesNotifier extends AsyncNotifier<List<Recipe>> {
  RecipesRepository get _repository => ref.read(recipesRepositoryProvider);

  @override
  Future<List<Recipe>> build() async {
    ref.watch(authStateProvider);
    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is! AuthAuthenticated) return [];

    return _repository.fetchRecipes();
  }

  Future<List<Recipe>> search(String query) async {
    return _repository.fetchRecipes(search: query);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.fetchRecipes());
  }
}

class RecipeListFilter {
  const RecipeListFilter({this.search = '', this.tag});

  final String search;
  final String? tag;

  RecipeListFilter copyWith({String? search, String? tag, bool clearTag = false}) {
    return RecipeListFilter(
      search: search ?? this.search,
      tag: clearTag ? null : (tag ?? this.tag),
    );
  }
}

final recipeListFilterProvider =
    StateProvider<RecipeListFilter>((ref) => const RecipeListFilter());

final recipeListProvider = FutureProvider<List<Recipe>>((ref) async {
  ref.watch(authStateProvider);
  final authState = ref.read(authStateProvider).valueOrNull;
  if (authState is! AuthAuthenticated) return [];

  final filter = ref.watch(recipeListFilterProvider);
  final repo = ref.watch(recipesRepositoryProvider);
  return repo.fetchRecipes(search: filter.search, tag: filter.tag);
});

final recipeTagsProvider = FutureProvider<Set<String>>((ref) async {
  ref.watch(authStateProvider);
  ref.watch(recipeListProvider);
  return ref.watch(recipesRepositoryProvider).fetchAllTags();
});

final recipeDetailProvider =
    FutureProvider.family<RecipeDetail, String>((ref, recipeId) async {
  ref.watch(authStateProvider);
  final authState = ref.read(authStateProvider).valueOrNull;
  if (authState is! AuthAuthenticated) {
    throw Exception('Not authenticated');
  }

  return ref.watch(recipesRepositoryProvider).fetchRecipeDetail(recipeId);
});

final recipePhotoUrlProvider =
    FutureProvider.family<String?, String?>((ref, photoPath) async {
  if (photoPath == null) return null;
  return ref.watch(recipesRepositoryProvider).resolvePhotoUrl(photoPath);
});

class RecipeFormState {
  const RecipeFormState({
    required this.data,
    this.recipeId,
    this.isSaving = false,
    this.error,
  });

  final RecipeFormData data;
  final String? recipeId;
  final bool isSaving;
  final String? error;

  bool get isEditing => recipeId != null;

  RecipeFormState copyWith({
    RecipeFormData? data,
    String? recipeId,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return RecipeFormState(
      data: data ?? this.data,
      recipeId: recipeId ?? this.recipeId,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RecipeFormNotifier extends AutoDisposeFamilyAsyncNotifier<
    RecipeFormState, String?> {
  @override
  Future<RecipeFormState> build(String? recipeId) async {
    ref.watch(authStateProvider);
    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is! AuthAuthenticated) {
      return RecipeFormState(data: RecipeFormData());
    }

    if (recipeId == null) {
      return RecipeFormState(data: RecipeFormData());
    }

    final detail =
        await ref.read(recipesRepositoryProvider).fetchRecipeDetail(recipeId);
    final data =
        ref.read(recipesRepositoryProvider).formDataFromDetail(detail);
    return RecipeFormState(data: data, recipeId: recipeId);
  }

  void updateData(RecipeFormData data) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(data: data, clearError: true));
  }

  /// Sets the working data without triggering a rebuild-inducing state swap
  /// when the reference is unchanged. Used by the form screen, which mutates
  /// the data in place and only syncs right before saving.
  void setData(RecipeFormData data) {
    final current = state.valueOrNull;
    if (current == null) return;
    if (identical(current.data, data) && current.error == null) return;
    state = AsyncData(current.copyWith(data: data, clearError: true));
  }

  Future<String?> save() async {
    final current = state.valueOrNull;
    if (current == null) return null;

    final validationError = current.data.validate();
    if (validationError != null) {
      state = AsyncData(current.copyWith(error: validationError));
      return null;
    }

    state = AsyncData(current.copyWith(isSaving: true, clearError: true));
    final repo = ref.read(recipesRepositoryProvider);

    try {
      if (current.isEditing) {
        await repo.updateRecipe(current.recipeId!, current.data);
        ref.invalidate(recipeListProvider);
        ref.invalidate(recipeDetailProvider(current.recipeId!));
        ref.invalidate(recipeTagsProvider);
        ref.invalidate(recipesProvider);
        ref.invalidate(exploreRecipesProvider);
        ref.invalidate(publicTagsProvider);
        state = AsyncData(current.copyWith(isSaving: false));
        return current.recipeId;
      }

      final id = await repo.createRecipe(current.data);
      ref.invalidate(recipeListProvider);
      ref.invalidate(recipeTagsProvider);
      ref.invalidate(recipesProvider);
      ref.invalidate(exploreRecipesProvider);
      ref.invalidate(publicTagsProvider);
      state = AsyncData(
        current.copyWith(isSaving: false, recipeId: id),
      );
      return id;
    } catch (e) {
      state = AsyncData(
        current.copyWith(isSaving: false, error: e.toString()),
      );
      return null;
    }
  }

  Future<bool> deleteRecipe() async {
    final current = state.valueOrNull;
    if (current?.recipeId == null) return false;

    state = AsyncData(current!.copyWith(isSaving: true, clearError: true));
    try {
      await ref
          .read(recipesRepositoryProvider)
          .deleteRecipe(current.recipeId!);
      ref.invalidate(recipeListProvider);
      ref.invalidate(recipeTagsProvider);
      ref.invalidate(recipesProvider);
      ref.invalidate(planSlotsProvider);
      ref.invalidate(exploreRecipesProvider);
      ref.invalidate(publicTagsProvider);
      return true;
    } catch (e) {
      state = AsyncData(
        current.copyWith(isSaving: false, error: e.toString()),
      );
      return false;
    }
  }
}

final recipeFormProvider = AutoDisposeAsyncNotifierProviderFamily<
    RecipeFormNotifier, RecipeFormState, String?>(RecipeFormNotifier.new);
