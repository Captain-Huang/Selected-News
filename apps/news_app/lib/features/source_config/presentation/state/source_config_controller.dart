import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/source.dart';
import '../../../news/data/news_repository.dart';
import '../../data/source_repository.dart';

class SourceConfigState {
  SourceConfigState({
    required this.categories,
    required this.selectedCategoryId,
    required this.sources,
    required this.saving,
  });

  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final List<SourceModel> sources;
  final bool saving;

  SourceConfigState copyWith({
    List<CategoryModel>? categories,
    int? selectedCategoryId,
    List<SourceModel>? sources,
    bool? saving,
    bool keepSelected = true,
  }) {
    return SourceConfigState(
      categories: categories ?? this.categories,
      selectedCategoryId: keepSelected
          ? (selectedCategoryId ?? this.selectedCategoryId)
          : selectedCategoryId,
      sources: sources ?? this.sources,
      saving: saving ?? this.saving,
    );
  }
}

class SourceConfigController
    extends StateNotifier<AsyncValue<SourceConfigState>> {
  SourceConfigController({
    required NewsRepository newsRepository,
    required SourceRepository sourceRepository,
  }) : _newsRepository = newsRepository,
       _sourceRepository = sourceRepository,
       super(const AsyncValue.loading()) {
    load();
  }

  final NewsRepository _newsRepository;
  final SourceRepository _sourceRepository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final List<CategoryModel> categories = await _newsRepository
          .fetchCategories();
      final int? selected = categories.isNotEmpty ? categories.first.id : null;
      final List<SourceModel> sources = selected == null
          ? const <SourceModel>[]
          : await _sourceRepository.fetchSources(categoryId: selected);
      return SourceConfigState(
        categories: categories,
        selectedCategoryId: selected,
        sources: sources,
        saving: false,
      );
    });
  }

  Future<void> selectCategory(int categoryId) async {
    final SourceConfigState? current = state.valueOrNull;
    if (current == null || current.selectedCategoryId == categoryId) {
      return;
    }
    state = AsyncValue.data(
      current.copyWith(
        selectedCategoryId: categoryId,
        sources: const <SourceModel>[],
      ),
    );
    state = await AsyncValue.guard(() async {
      final List<SourceModel> sources = await _sourceRepository.fetchSources(
        categoryId: categoryId,
      );
      return current.copyWith(selectedCategoryId: categoryId, sources: sources);
    });
  }

  Future<void> refreshSources() async {
    final SourceConfigState? current = state.valueOrNull;
    if (current == null || current.selectedCategoryId == null) {
      return;
    }
    state = AsyncValue.data(current.copyWith(saving: true));
    state = await AsyncValue.guard(() async {
      final List<SourceModel> sources = await _sourceRepository.fetchSources(
        categoryId: current.selectedCategoryId,
      );
      return current.copyWith(sources: sources, saving: false);
    });
  }

  Future<void> addSource({
    required String name,
    required String baseUrl,
    required String type,
  }) async {
    final SourceConfigState? current = state.valueOrNull;
    final int? categoryId = current?.selectedCategoryId;
    if (current == null || categoryId == null) {
      return;
    }
    state = AsyncValue.data(current.copyWith(saving: true));
    state = await AsyncValue.guard(() async {
      await _sourceRepository.createSource(
        categoryId: categoryId,
        name: name,
        baseUrl: baseUrl,
        type: type,
      );
      final List<SourceModel> sources = await _sourceRepository.fetchSources(
        categoryId: categoryId,
      );
      return current.copyWith(sources: sources, saving: false);
    });
  }

  Future<void> toggleEnabled({
    required int sourceId,
    required bool enabled,
  }) async {
    final SourceConfigState? current = state.valueOrNull;
    final int? categoryId = current?.selectedCategoryId;
    if (current == null || categoryId == null) {
      return;
    }
    state = AsyncValue.data(current.copyWith(saving: true));
    state = await AsyncValue.guard(() async {
      await _sourceRepository.updateSource(
        sourceId: sourceId,
        enabled: enabled,
      );
      final List<SourceModel> sources = await _sourceRepository.fetchSources(
        categoryId: categoryId,
      );
      return current.copyWith(sources: sources, saving: false);
    });
  }

  Future<void> deleteSource(int sourceId) async {
    final SourceConfigState? current = state.valueOrNull;
    final int? categoryId = current?.selectedCategoryId;
    if (current == null || categoryId == null) {
      return;
    }
    state = AsyncValue.data(current.copyWith(saving: true));
    state = await AsyncValue.guard(() async {
      await _sourceRepository.deleteSource(sourceId);
      final List<SourceModel> sources = await _sourceRepository.fetchSources(
        categoryId: categoryId,
      );
      return current.copyWith(sources: sources, saving: false);
    });
  }
}

final sourceConfigControllerProvider =
    StateNotifierProvider.autoDispose<
      SourceConfigController,
      AsyncValue<SourceConfigState>
    >((Ref ref) {
      return SourceConfigController(
        newsRepository: ref.watch(newsRepositoryProvider),
        sourceRepository: ref.watch(sourceRepositoryProvider),
      );
    });
