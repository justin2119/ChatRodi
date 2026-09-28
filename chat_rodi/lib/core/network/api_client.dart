import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../security/byok_storage_service.dart';

/// Environment-backed API configuration with safe defaults.
class ApiEndpoints {
  static String get baseUrl => _env('RODIUM_BASE_URL', 'https://api.rodiumai.io/v1/');
  static String get chat => _env('RODIUM_CHAT_ENDPOINT', 'chat/completions');
  static String get image => _env('RODIUM_IMAGE_ENDPOINT', 'images/generations');
  static String get video => _env('RODIUM_VIDEO_ENDPOINT', 'videos/generations');
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

/// Client réseau centralisé pour les appels à l'API RodiumAi.
/// Cette classe regroupe la configuration Dio et permet aux couches
/// supérieures de dépendre d'un client unique, facile à remplacer en test.
class ApiClient {
  const ApiClient(this.dio);
  final Dio dio;
}

/// Intercepteur chargé d'ajouter la clé BYOK à chaque requête.
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
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
          type: DioExceptionType.unknown,
          message: 'Impossible de lire la clé API depuis le stockage sécurisé.',
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
