import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/social/data/social_repository.dart';
import 'package:meal_planner/features/social/domain/public_recipe_detail.dart';
import 'package:meal_planner/features/social/domain/public_recipe_summary.dart';

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository();
});

class ExploreFilter {
  const ExploreFilter({
    this.search = '',
    this.tags = const {},
    this.sort = 'recent',
  });

  final String search;
  final Set<String> tags;
  final String sort;

  ExploreFilter copyWith({
    String? search,
    Set<String>? tags,
    bool clearTags = false,
    String? sort,
  }) {
    return ExploreFilter(
      search: search ?? this.search,
      tags: clearTags ? {} : (tags ?? this.tags),
      sort: sort ?? this.sort,
    );
  }
}

final exploreFilterProvider =
    StateProvider<ExploreFilter>((ref) => const ExploreFilter());

final feedTagsFilterProvider = StateProvider<Set<String>>((ref) => {});

String exploreSortLabel(String sort) =>
    sort == 'top' ? 'Mejor valoradas' : 'Más reciente';

final publicTagsProvider = FutureProvider<Set<String>>((ref) async {
  return ref.watch(socialRepositoryProvider).fetchPublicTags();
});

class ExploreRecipesState {
  const ExploreRecipesState({
    this.recipes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
  });

  final List<PublicRecipeSummary> recipes;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  ExploreRecipesState copyWith({
    List<PublicRecipeSummary>? recipes,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
    bool clearError = false,
  }) {
    return ExploreRecipesState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ExploreRecipesNotifier extends Notifier<ExploreRecipesState> {
  SocialRepository get _repo => ref.read(socialRepositoryProvider);

  @override
  ExploreRecipesState build() {
    ref.listen(exploreFilterProvider, (_, _) => reload());
    Future.microtask(reload);
    return const ExploreRecipesState(isLoading: true);
  }

  Future<void> reload() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final filter = ref.read(exploreFilterProvider);
      final recipes = await _repo.fetchPublicRecipes(
        search: filter.search,
        tags: filter.tags,
        sort: filter.sort,
        page: 0,
      );
      state = ExploreRecipesState(
        recipes: recipes,
        hasMore: recipes.length >= SocialRepository.pageSize,
        page: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final filter = ref.read(exploreFilterProvider);
      final nextPage = state.page + 1;
      final recipes = await _repo.fetchPublicRecipes(
        search: filter.search,
        tags: filter.tags,
        sort: filter.sort,
        page: nextPage,
      );
      state = state.copyWith(
        recipes: [...state.recipes, ...recipes],
        page: nextPage,
        hasMore: recipes.length >= SocialRepository.pageSize,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final exploreRecipesProvider =
    NotifierProvider<ExploreRecipesNotifier, ExploreRecipesState>(
  ExploreRecipesNotifier.new,
);

final publicRecipeDetailProvider =
    FutureProvider.family<PublicRecipeDetail, String>((ref, recipeId) async {
  return ref.watch(socialRepositoryProvider).fetchPublicRecipeDetail(recipeId);
});

final socialPhotoUrlProvider =
    FutureProvider.family<String?, String?>((ref, photoPath) async {
  if (photoPath == null) return null;
  return ref.watch(socialRepositoryProvider).resolvePhotoUrl(photoPath);
});

class FeedState {
  const FeedState({
    this.recipes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
  });

  final List<PublicRecipeSummary> recipes;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  FeedState copyWith({
    List<PublicRecipeSummary>? recipes,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
    bool clearError = false,
  }) {
    return FeedState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FeedNotifier extends Notifier<FeedState> {
  SocialRepository get _repo => ref.read(socialRepositoryProvider);

  @override
  FeedState build() {
    ref.listen(feedTagsFilterProvider, (_, _) => reload());
    Future.microtask(reload);
    return const FeedState(isLoading: true);
  }

  Future<void> reload() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tags = ref.read(feedTagsFilterProvider);
      final recipes = await _repo.fetchFeed(page: 0, tags: tags);
      state = FeedState(
        recipes: recipes,
        hasMore: recipes.length >= SocialRepository.pageSize,
        page: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final nextPage = state.page + 1;
      final tags = ref.read(feedTagsFilterProvider);
      final recipes = await _repo.fetchFeed(page: nextPage, tags: tags);
      state = state.copyWith(
        recipes: [...state.recipes, ...recipes],
        page: nextPage,
        hasMore: recipes.length >= SocialRepository.pageSize,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final feedProvider = NotifierProvider<FeedNotifier, FeedState>(
  FeedNotifier.new,
);

final publicProfileProvider =
    FutureProvider.family<PublicProfileData, String>((ref, userId) async {
  return ref.watch(socialRepositoryProvider).fetchPublicProfile(userId);
});

final isFollowingProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  return ref.watch(socialRepositoryProvider).isFollowing(userId);
});
