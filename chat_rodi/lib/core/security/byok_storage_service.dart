import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage local du secret BYOK (« Bring Your Own Key ») de RodiumAi.
///
/// Le parcours BYOK laisse la personne fournir sa propre clé API : elle est
/// enregistrée sur l'appareil, puis l'application peut la relire au moment
/// d'effectuer les requêtes autorisées. Cette classe ne fait aucun appel
/// réseau, n'envoie aucune télémétrie et ne journalise jamais la clé.
///
/// `flutter_secure_storage` s'appuie sur les mécanismes de stockage sécurisé
/// fournis par la plateforme (Keychain sur Apple et stockage chiffré Android).
/// Cela protège le secret au repos, mais ne le rend pas invulnérable : ne pas
/// l'inclure dans des logs, exceptions affichées, analytics ou paramètres
/// d'URL ; limiter son usage aux requêtes nécessaires et permettre son retrait.
/// Les options de sauvegarde/restauration et l'intégrité de l'appareil restent
/// des considérations spécifiques à la plateforme et au déploiement.
class ByokStorageService {
  ByokStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _apiKeyStorageKey = 'rodium_ai_api_key';
  final FlutterSecureStorage _storage;

  /// Enregistre ou remplace localement la clé API.
  ///
  /// La valeur n'est volontairement ni nettoyée ni écrite ailleurs : la
  /// validation de format doit rester dans la couche métier/API.
  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyStorageKey, value: apiKey);
  }

  /// Récupère la clé locale, ou `null` si aucune clé n'est enregistrée.
  Future<String?> getApiKey() async {
    return _storage.read(key: _apiKeyStorageKey);
  }

  /// Indique si une clé non vide existe, sans exposer son contenu.
  Future<bool> hasApiKey() async {
    final apiKey = await _storage.read(key: _apiKeyStorageKey);
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Supprime définitivement l'entrée locale de la clé BYOK.
  Future<void> deleteApiKey() async {
    await _storage.delete(key: _apiKeyStorageKey);
  }
}

/// Fournisseur Riverpod classique, remplaçable facilement par un stockage
/// factice dans les tests. Aucun secret n'est conservé dans l'état Riverpod.
final byokStorageServiceProvider = Provider<ByokStorageService>((ref) {
  return ByokStorageService();
});
