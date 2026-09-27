import '../models/message_model.dart';

/// Contrat de la couche domaine pour les opérations de conversation.
///
/// Cette interface masque les détails réseau et permet au ViewModel de
/// dialoguer avec une implémentation remplaçable, notamment lors des tests.
abstract interface class ChatRepository {
  /// Envoie un prompt accompagné de l'historique de conversation.
  ///
  /// [model] sélectionne éventuellement un modèle particulier. [mediaPaths]
  /// contient les chemins locaux de pièces jointes éventuelles. Le résultat
  /// est le message assistant reçu après traitement de la requête.
  Future<MessageModel> sendMessage({
    required String prompt,
    required List<MessageModel> history,
    String? model,
    List<String>? mediaPaths,
  });
}
