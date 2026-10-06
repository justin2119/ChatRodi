import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodiumai/rodiumai.dart';

import '../security/byok_storage_service.dart';

/// Environment-backed API configuration with safe defaults.
class ApiEndpoints {
  static String get baseUrl {
    final url = _env('RODIUM_BASE_URL', 'https://api.rodiumai.io/v1/');
    return url.endsWith('/') ? url : '$url/';
  }

  static String get image => _env('RODIUM_IMAGE_ENDPOINT', 'images/generations');
  static String get video => _env('RODIUM_VIDEO_ENDPOINT', 'videos/generations');

  static String _env(String key, String fallback) {
    try {
      final value = dotenv.env[key]?.trim();
      return value == null || value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }
}

/// Owns both the SDK client (text/model APIs) and Dio (media generation).
class ApiClient {
  const ApiClient(this._dio, this._storageService);
  final Dio _dio;
  final ByokStorageService _storageService;

  Dio get dio => _dio;

  Future<RodiumAIClient> get rodiumClient async {
    final apiKey = await _storageService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('Cle\\u0301 API manquante. Veuillez configurer votre cle\\u0301 BYOK.');
    }
    return RodiumAIClient(apiKey: apiKey, locale: 'fr');
  }

  Future<List<String>> getModels() async {
    final collection = await (await rodiumClient).models();
    final dynamic entries = (collection as dynamic).data;
    if (entries is! Iterable) return const <String>[];
    return entries
        .map((dynamic model) => (model as dynamic).id)
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toList(growable: false);
  }
}

class _ByokAuthInterceptor extends Interceptor {
  _ByokAuthInterceptor(this._storageService);
  final ByokStorageService _storageService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _storageService.getApiKey();
      if (token == null || token.isEmpty) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: 'Cle\\u0301 API manquante. Veuillez configurer votre cle\\u0301 BYOK.',
          ),
        );
      }
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
          type: DioExceptionType.unknown,
          message: 'Impossible de lire la cle\\u0301 API depuis le stockage se\\u0301curise\\u0301.',
        ),
      );
    }
  }
}

final dioProvider = Provider<Dio>((ref) {
  final storageService = ref.watch(byokStorageServiceProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      headers: const <String, dynamic>{'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(_ByokAuthInterceptor(storageService));
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider), ref.watch(byokStorageServiceProvider));
});
