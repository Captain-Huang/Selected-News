import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/source.dart';
import '../../../core/network/api_client.dart';

class SourceRepository {
  SourceRepository(this._dio);

  final Dio _dio;

  Future<List<SourceModel>> fetchSources({int? categoryId}) async {
    final Map<String, dynamic> query = <String, dynamic>{};
    if (categoryId != null) {
      query['category_id'] = categoryId;
    }

    final Response<dynamic> response = await _dio.get(
      '/v1/sources',
      queryParameters: query,
    );
    final List<dynamic> raw =
        (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return raw
        .map(
          (dynamic item) => SourceModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<SourceModel> createSource({
    required int categoryId,
    required String name,
    required String baseUrl,
    required String type,
  }) async {
    final Response<dynamic> response = await _dio.post(
      '/v1/sources',
      data: <String, dynamic>{
        'category_id': categoryId,
        'name': name,
        'base_url': baseUrl,
        'type': type,
        'enabled': true,
        'parser_config': '{}',
      },
    );
    final Map<String, dynamic> raw =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return SourceModel.fromJson(raw);
  }

  Future<SourceModel> updateSource({
    required int sourceId,
    String? name,
    String? baseUrl,
    String? type,
    bool? enabled,
  }) async {
    final Response<dynamic> response = await _dio.put(
      '/v1/sources/$sourceId',
      data: <String, dynamic>{
        ...?name == null ? null : <String, dynamic>{'name': name},
        ...?baseUrl == null ? null : <String, dynamic>{'base_url': baseUrl},
        ...?type == null ? null : <String, dynamic>{'type': type},
        ...?enabled == null ? null : <String, dynamic>{'enabled': enabled},
      },
    );
    final Map<String, dynamic> raw =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return SourceModel.fromJson(raw);
  }

  Future<void> deleteSource(int sourceId) async {
    await _dio.delete('/v1/sources/$sourceId');
  }
}

final sourceRepositoryProvider = Provider<SourceRepository>((Ref ref) {
  return SourceRepository(ref.watch(dioProvider));
});
