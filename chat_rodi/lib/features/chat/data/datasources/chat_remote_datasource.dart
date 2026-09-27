import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/models/message_model.dart';

/// Source distante responsable des requêtes HTTP de conversation.
///
/// Le client Dio provient du client API central afin de réutiliser
/// configuration, délais d'attente et authentification BYOK.
class ChatRemoteDataSource {
  /// Construit la source avec l'instance réseau configurée.
  const ChatRemoteDataSource(this._dio);

  final Dio _dio;

  /// Envoie le prompt et son contexte à l'API de complétion.
  ///
  /// Les médias locaux ne sont pas téléversés par cette implémentation ; le
  /// paramètre est accepté pour respecter le contrat commun de la fonction.
  Future<MessageModel> sendMessage({
    required String prompt,
    required List<MessageModel> history,
    String? model,
    List<String>? mediaPaths,
  }) async {
    final messages = <Map<String, dynamic>>[
      ...history.map((message) => <String, dynamic>{
            'role': message.role.name,
            'content': message.content,
          }),
      <String, dynamic>{'role': 'user', 'content': prompt},
    ];
    final response = await _dio.post<Map<String, dynamic>>(
      'chat/completions',
      data: <String, dynamic>{
        'model': model ?? 'default',
        'messages': messages,
        'temperature': 0.7,
      },
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Réponse de chat vide.');
    }

    // Prend en charge le format usuel compatible OpenAI et un format direct.
    final choices = data['choices'] as List<dynamic>?;
    final choice = choices?.isNotEmpty == true
        ? choices!.first as Map<String, dynamic>
        : null;
    final message = choice?['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String? ?? data['content'] as String?;
    if (content == null) {
      throw const FormatException('Contenu assistant absent de la réponse.');
    }
    return MessageModel(
      id: data['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );
  }
}

/// Fournisseur Riverpod de la source distante de conversation.
final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSource(ref.watch(apiClientProvider).dio);
});
