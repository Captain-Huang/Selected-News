import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category.dart';
import '../../../core/models/news_item.dart';
import '../../../core/network/api_client.dart';

class NewsPageResult {
  NewsPageResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  final List<NewsItemModel> items;
  final int page;
  final int pageSize;
  final int total;
}

class NewsRepository {
  NewsRepository(this._dio);

  final Dio _dio;

  Future<List<CategoryModel>> fetchCategories() async {
    final Response<dynamic> response = await _dio.get('/v1/categories');
    final List<dynamic> data =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map(
          (dynamic item) =>
              CategoryModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<NewsPageResult> fetchNews({
    required String category,
    required int page,
    int pageSize = 20,
    bool refresh = false,
  }) async {
    final Response<dynamic> response = await _dio.get(
      '/v1/news',
      queryParameters: <String, dynamic>{
        'category': category,
        'page': page,
        'page_size': pageSize,
        'refresh': refresh,
      },
    );
    final Map<String, dynamic> data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final List<dynamic> itemsRaw =
        data['items'] as List<dynamic>? ?? <dynamic>[];
    final List<NewsItemModel> items = itemsRaw
        .map(
          (dynamic item) =>
              NewsItemModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return NewsPageResult(
      items: items,
      page: data['page'] as int? ?? page,
      pageSize: data['page_size'] as int? ?? pageSize,
      total: data['total'] as int? ?? 0,
    );
  }
}

final newsRepositoryProvider = Provider<NewsRepository>((Ref ref) {
  return NewsRepository(ref.watch(dioProvider));
});
