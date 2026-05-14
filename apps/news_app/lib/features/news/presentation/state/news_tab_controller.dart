import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/news_item.dart';
import '../../data/news_repository.dart';

class NewsTabState {
  NewsTabState({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.isLoadingMore,
  });

  factory NewsTabState.initial() {
    return NewsTabState(
      items: const <NewsItemModel>[],
      page: 1,
      pageSize: 20,
      total: 0,
      isLoadingMore: false,
    );
  }

  final List<NewsItemModel> items;
  final int page;
  final int pageSize;
  final int total;
  final bool isLoadingMore;

  bool get hasMore => items.length < total;

  NewsTabState copyWith({
    List<NewsItemModel>? items,
    int? page,
    int? pageSize,
    int? total,
    bool? isLoadingMore,
  }) {
    return NewsTabState(
      items: items ?? this.items,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class NewsTabController extends StateNotifier<AsyncValue<NewsTabState>> {
  NewsTabController({
    required this.category,
    required NewsRepository repository,
  }) : _repository = repository,
       super(const AsyncValue.loading()) {
    loadInitial();
  }

  final String category;
  final NewsRepository _repository;

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final NewsPageResult result = await _repository.fetchNews(
        category: category,
        page: 1,
        refresh: true,
      );
      return NewsTabState(
        items: result.items,
        page: result.page,
        pageSize: result.pageSize,
        total: result.total,
        isLoadingMore: false,
      );
    });
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    final NewsTabState? current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    final AsyncValue<NewsTabState> nextState = await AsyncValue.guard(() async {
      final int nextPage = current.page + 1;
      final NewsPageResult result = await _repository.fetchNews(
        category: category,
        page: nextPage,
        pageSize: current.pageSize,
        refresh: false,
      );
      return current.copyWith(
        items: <NewsItemModel>[...current.items, ...result.items],
        page: result.page,
        total: result.total,
        isLoadingMore: false,
      );
    });

    state = nextState.whenData(
      (NewsTabState value) => value.copyWith(isLoadingMore: false),
    );
  }
}

final categoriesProvider = FutureProvider<List<String>>((Ref ref) async {
  final NewsRepository repository = ref.watch(newsRepositoryProvider);
  final categories = await repository.fetchCategories();
  return categories.map((category) => category.name).toList();
});

final newsTabControllerProvider = StateNotifierProvider.autoDispose
    .family<NewsTabController, AsyncValue<NewsTabState>, String>((
      Ref ref,
      String category,
    ) {
      final NewsRepository repository = ref.watch(newsRepositoryProvider);
      return NewsTabController(category: category, repository: repository);
    });
