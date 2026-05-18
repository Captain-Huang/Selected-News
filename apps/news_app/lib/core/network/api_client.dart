import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String resolveBaseUrl() {
  const fromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (fromDefine.isNotEmpty) {
    return fromDefine;
  }

  if (kIsWeb) {
    return 'http://127.0.0.1:8000';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';
  }
  return 'http://127.0.0.1:8000';
}

final dioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: resolveBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  if (!kIsWeb && dio.httpClientAdapter is IOHttpClientAdapter) {
    final IOHttpClientAdapter adapter =
        dio.httpClientAdapter as IOHttpClientAdapter;
    adapter.createHttpClient = () {
      final HttpClient client = HttpClient();
      // Use direct connection for local API, avoid broken system proxy settings.
      client.findProxy = (Uri _) => 'DIRECT';
      return client;
    };
  }
  return dio;
});
