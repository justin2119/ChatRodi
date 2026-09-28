import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../security/byok_storage_service.dart';

/// Client réseau centralisé pour les appels à l'API RodiumAi.
///
/// Cette classe regroupe la configuration Dio et permet aux couches
/// supérieures de dépendre d'un client unique, facile à remplacer en test.
class ApiClient {
  /// Construit le client avec Dio déjà configuré par [dio].
  const ApiClient(this.dio);

  /// Instance Dio utilisée pour effectuer les requêtes HTTP.
  final Dio dio;
}

/// Intercepteur chargé d'ajouter la clé BYOK à chaque requête.
///
/// La clé est relue dans le stockage sécurisé au moment de chaque appel afin
/// de prendre en compte immédiatement une mise à jour ou une suppression.
/// Elle n'est jamais écrite dans les logs ni dans l'URL.
class _ByokAuthInterceptor extends Interceptor {
  /// Le service sécurisé est injecté pour faciliter les tests.
  _ByokAuthInterceptor(this._storageService);

  final ByokStorageService _storageService;

  /// Ajoute l'en-tête Bearer uniquement lorsqu'une clé non vide est disponible.
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
      // Une erreur de lecture ne doit pas laisser la requête bloquée. La
      // requête poursuit son cours sans secret et l'API pourra la refuser.
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

/// Fournisseur Dio classique, configuré pour l'API RodiumAi.
///
/// Riverpod transmet le stockage sécurisé à l'intercepteur ; aucune clé
/// sensible n'est conservée dans la configuration statique du client.
final dioProvider = Provider<Dio>((ref) {
  final storageService = ref.watch(byokStorageServiceProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.rodiumai.io/v1/',
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

  // L'intercepteur est ajouté une seule fois à la construction de Dio.
  dio.interceptors.add(_ByokAuthInterceptor(storageService));
  return dio;
});

/// Fournisseur de la façade réseau utilisée par les fonctionnalités métier.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
