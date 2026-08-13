import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/locale_provider.dart';
import 'package:meal_planner/core/supabase/models/recipe.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/household/presentation/household_provider.dart';
import 'package:meal_planner/features/planner/presentation/planner_provider.dart';
import 'package:meal_planner/features/recipes/data/recipe_assistant_repository.dart';
import 'package:meal_planner/features/recipes/data/recipes_repository.dart';
import 'package:meal_planner/features/recipes/domain/recipe_detail.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/presentation/list_title_translation_provider.dart';
import 'package:meal_planner/features/social/presentation/social_provider.dart';

/// Error message keys resolved to localized strings in the form UI.
const householdLoadErrorKey = 'householdLoadError';

/// Used by the planner recipe picker (F7).
final recipesProvider = AsyncNotifierProvider<RecipesNotifier, List<Recipe>>(
  RecipesNotifier.new,
);

class RecipesNotifier extends AsyncNotifier<List<Recipe>> {
  RecipesRepository get _repository => ref.read(recipesRepositoryProvider);

  Future<List<String>?> _householdMemberIds() async {
    final household = ref.read(currentHouseholdProvider).valueOrNull;
    if (household == null) return null;
    final members = await ref.read(
      householdMembersByIdProvider(household.id).future,
    );
    return members.map((m) => m.userId).toList();
  }

  @override
  Future<List<Recipe>> build() async {
    ref.watch(authStateProvider);
    ref.watch(currentHouseholdProvider);
    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is! AuthAuthenticated) return [];

    final household = ref.watch(currentHouseholdProvider).valueOrNull;
    List<String>? memberIds;
    if (household != null) {
      final members = await ref.watch(
        householdMembersByIdProvider(household.id).future,
      );
      memberIds = members.map((m) => m.userId).toList();
    }
    return _repository.fetchRecipes(memberUserIds: memberIds);
  }

  Future<List<Recipe>> search(String query) async {
    final memberIds = await _householdMemberIds();
    return _repository.fetchRecipes(search: query, memberUserIds: memberIds);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final memberIds = await _householdMemberIds();
    state = await AsyncValue.guard(
      () => _repository.fetchRecipes(memberUserIds: memberIds),
    );
  }
}

class RecipeListFilter {
  const RecipeListFilter({
    this.search = '',
    this.tags = const {},
    this.sort = RecipeListSort.recent,
    this.favoritesOnly = false,
  });

  final String search;
  final Set<String> tags;
  final RecipeListSort sort;
  final bool favoritesOnly;

  RecipeListFilter copyWith({
    String? search,
    Set<String>? tags,
    bool clearTags = false,
    RecipeListSort? sort,
    bool? favoritesOnly,
  }) {
    return RecipeListFilter(
      search: search ?? this.search,
      tags: clearTags ? {} : (tags ?? this.tags),
      sort: sort ?? this.sort,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}

enum RecipeListSort { recent, alpha }

final recipeListFilterProvider = StateProvider<RecipeListFilter>(
  (ref) => const RecipeListFilter(),
);

final recipeFavoritesProvider =
    AsyncNotifierProvider<RecipeFavoritesNotifier, Set<String>>(
      RecipeFavoritesNotifier.new,
    );

final favoriteInFlightIdsProvider = StateProvider<Set<String>>((ref) => {});

class RecipeFavoritesNotifier extends AsyncNotifier<Set<String>> {
  final _inFlight = <String, Future<void>>{};

  @override
  Future<Set<String>> build() async {
    ref.watch(authStateProvider);
    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is! AuthAuthenticated) return {};
    return ref.read(recipesRepositoryProvider).fetchFavoriteIds();
  }

  void _setInFlight(String recipeId, bool busy) {
    final current = ref.read(favoriteInFlightIdsProvider);
    if (busy == current.contains(recipeId)) return;
    final next = Set<String>.from(current);
    if (busy) {
      next.add(recipeId);
    } else {
      next.remove(recipeId);
    }
    ref.read(favoriteInFlightIdsProvider.notifier).state = next;
  }

  Future<void> toggle(String recipeId) {
    _setInFlight(recipeId, true);
    final previous = _inFlight[recipeId] ?? Future<void>.value();
    late final Future<void> current;
    current = previous.catchError((_) {}).then((_) => _toggleOnce(recipeId));
    _inFlight[recipeId] = current;
    return current.whenComplete(() {
      if (identical(_inFlight[recipeId], current)) {
        _inFlight.remove(recipeId);
        _setInFlight(recipeId, false);
      }
    });
  }

  Future<void> _toggleOnce(String recipeId) async {
    final current = state.valueOrNull ?? {};
    final adding = !current.contains(recipeId);
    final next = Set<String>.from(current);
    if (adding) {
      next.add(recipeId);
    } else {
      next.remove(recipeId);
    }
    state = AsyncData(next);
    try {
      await ref.read(recipesRepositoryProvider).setFavorite(recipeId, adding);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

final recipeListProvider = FutureProvider<List<Recipe>>((ref) async {
  ref.watch(authStateProvider);
  ref.watch(currentHouseholdProvider);
  final authState = ref.read(authStateProvider).valueOrNull;
  if (authState is! AuthAuthenticated) return [];

  final filter = ref.watch(recipeListFilterProvider);
  final repo = ref.watch(recipesRepositoryProvider);

  List<String>? memberIds;
  final household = ref.watch(currentHouseholdProvider).valueOrNull;
  if (household != null) {
    final members = await ref.watch(
      householdMembersByIdProvider(household.id).future,
    );
    memberIds = members.map((m) => m.userId).toList();
  }

  return repo.fetchRecipes(
    search: filter.search,
    tags: filter.tags,
    memberUserIds: memberIds,
  );
});

final recipeTagsProvider = FutureProvider<Set<String>>((ref) async {
  ref.watch(authStateProvider);
  ref.watch(recipeListProvider);
  ref.watch(currentHouseholdProvider);

  final authState = ref.read(authStateProvider).valueOrNull;
  if (authState is! AuthAuthenticated) return <String>{};

  List<String>? memberIds;
  final household = ref.watch(currentHouseholdProvider).valueOrNull;
  if (household != null) {
    final members = await ref.watch(
      householdMembersByIdProvider(household.id).future,
    );
    memberIds = members.map((m) => m.userId).toList();
  }

  return ref
      .watch(recipesRepositoryProvider)
      .fetchAllTags(memberUserIds: memberIds);
});

final recipeDetailProvider = FutureProvider.family<RecipeDetail, String>((
  ref,
  recipeId,
) async {
  ref.watch(authStateProvider);
  final authState = ref.read(authStateProvider).valueOrNull;
  if (authState is! AuthAuthenticated) {
    throw Exception('Not authenticated');
  }

  return ref.watch(recipesRepositoryProvider).fetchRecipeDetail(recipeId);
});

final recipePhotoUrlProvider = FutureProvider.family<String?, String?>((
  ref,
  photoPath,
) async {
  if (photoPath == null) return null;
  return ref.watch(recipesRepositoryProvider).resolvePhotoUrl(photoPath);
});

class RecipeFormState {
  const RecipeFormState({
    required this.data,
    this.recipeId,
    this.isSaving = false,
    this.error,
    this.sourceLang,
  });

  final RecipeFormData data;
  final String? recipeId;
  final bool isSaving;
  final String? error;
  final String? sourceLang;

  bool get isEditing => recipeId != null;

  RecipeFormState copyWith({
    RecipeFormData? data,
    String? recipeId,
    bool? isSaving,
    String? error,
    String? sourceLang,
    bool clearError = false,
    bool clearSourceLang = false,
  }) {
    return RecipeFormState(
      data: data ?? this.data,
      recipeId: recipeId ?? this.recipeId,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      sourceLang: clearSourceLang ? null : (sourceLang ?? this.sourceLang),
    );
  }
}

class RecipeFormNotifier
    extends AutoDisposeFamilyAsyncNotifier<RecipeFormState, String?> {
  @override
  Future<RecipeFormState> build(String? recipeId) async {
    ref.watch(authStateProvider);
    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is! AuthAuthenticated) {
      return RecipeFormState(data: RecipeFormData());
    }

    if (recipeId == null) {
      final draft = ref.read(recipeAssistantDraftProvider);
      if (draft != null) {
        Future.microtask(
          () => ref.read(recipeAssistantDraftProvider.notifier).state = null,
        );
        return RecipeFormState(
          data: draft.formData,
          sourceLang: draft.sourceLang,
        );
      }
      return RecipeFormState(data: RecipeFormData());
    }

    final detail = await ref
        .read(recipesRepositoryProvider)
        .fetchRecipeDetail(recipeId);
    final data = ref.read(recipesRepositoryProvider).formDataFromDetail(detail);
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

  Future<String?> _resolveHouseholdId() async {
    try {
      final household = await ref.read(currentHouseholdProvider.future);
      return household?.id;
    } catch (_) {
      rethrow;
    }
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

    String? householdId;
    try {
      householdId = await _resolveHouseholdId();
    } catch (_) {
      state = AsyncData(
        current.copyWith(isSaving: false, error: householdLoadErrorKey),
      );
      return null;
    }

    final sourceLang =
        current.sourceLang ??
        ref.read(localeProvider.notifier).currentLanguageCode;

    try {
      if (current.isEditing) {
        await repo.updateRecipe(
          current.recipeId!,
          current.data,
          householdId: householdId,
        );
        ref.invalidate(recipeListProvider);
        ref.invalidate(recipeDetailProvider(current.recipeId!));
        ref.invalidate(recipeTagsProvider);
        ref.invalidate(recipesProvider);
        ref.invalidate(exploreRecipesProvider);
        ref.invalidate(publicTagsProvider);
        ref.invalidate(listTitleTranslationsProvider);
        state = AsyncData(current.copyWith(isSaving: false));
        return current.recipeId;
      }

      final id = await repo.createRecipe(
        current.data,
        householdId: householdId,
        sourceLang: sourceLang,
      );
      ref.invalidate(recipeListProvider);
      ref.invalidate(recipeTagsProvider);
      ref.invalidate(recipesProvider);
      ref.invalidate(exploreRecipesProvider);
      ref.invalidate(publicTagsProvider);
      state = AsyncData(current.copyWith(isSaving: false, recipeId: id));
      return id;
    } catch (e) {
      state = AsyncData(current.copyWith(isSaving: false, error: e.toString()));
      return null;
    }
  }

  Future<bool> deleteRecipe() async {
    final current = state.valueOrNull;
    if (current?.recipeId == null) return false;

    state = AsyncData(current!.copyWith(isSaving: true, clearError: true));
    try {
      String? householdId;
      try {
        householdId = await _resolveHouseholdId();
      } catch (_) {
        state = AsyncData(
          current.copyWith(isSaving: false, error: householdLoadErrorKey),
        );
        return false;
      }

      await ref
          .read(recipesRepositoryProvider)
          .deleteRecipe(current.recipeId!, householdId: householdId);
      state = AsyncData(current.copyWith(isSaving: false));
      ref.invalidate(recipeListProvider);
      ref.invalidate(recipeTagsProvider);
      ref.invalidate(recipesProvider);
      ref.invalidate(planSlotsProvider);
      ref.invalidate(exploreRecipesProvider);
      ref.invalidate(publicTagsProvider);
      return true;
    } catch (e) {
      state = AsyncData(current.copyWith(isSaving: false, error: e.toString()));
      return false;
    }
  }
}

final recipeFormProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      RecipeFormNotifier,
      RecipeFormState,
      String?
    >(RecipeFormNotifier.new);
