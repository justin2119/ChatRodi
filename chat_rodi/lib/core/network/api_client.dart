import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../security/byok_storage_service.dart';

/// Environment-backed API configuration with safe defaults.
class ApiEndpoints {
  static String get baseUrl {
    final url = _env('RODIUM_BASE_URL', 'https://api.rodiumai.io/v1/');
    return url.endsWith('/') ? url : '$url/';
  }

  static String get chat => _env('RODIUM_CHAT_ENDPOINT', 'chat/completions');
  static String get image => _env('RODIUM_IMAGE_ENDPOINT', 'images/generations');
  static String get video => _env('RODIUM_VIDEO_ENDPOINT', 'videos/generations');
  static String videoStatus(String taskId) => 'videos/$taskId';
  static String get models => _env('RODIUM_MODELS_ENDPOINT', 'models');

  static String _env(String key, String fallback) {
    try {
      final value = dotenv.env[key]?.trim();
      return value == null || value.isEmpty ? fallback : value;
    } catch (_) {
      return fallback;
    }
  }
}

/// Client re\u0301seau centralise\u0301 pour les appels a\u0300 l'API RodiumAi.
class ApiClient {
  const ApiClient(this._dio);
  final Dio _dio;
  Dio get dio => _dio;

  Future<List<String>> getModels() async {
    final response = await _dio.get(ApiEndpoints.models);
    final data = response.data is Map<String, dynamic>
        ? (response.data as Map<String, dynamic>)['data']
        : null;
    if (data is! List) return const <String>[];
    return data
        .whereType<Map>()
        .map((model) => model['id'])
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
            error: 'Cle\u0301 API manquante. Veuillez configurer votre cle\u0301 BYOK.',
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
          message: 'Impossible de lire la cle\u0301 API depuis le stockage se\u0301curise\u0301.',
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
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print('[DIO REQUEST] ${options.baseUrl}${options.path}');
        return handler.next(options);
      },
    ),
  );
  dio.interceptors.add(_ByokAuthInterceptor(storageService));
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
