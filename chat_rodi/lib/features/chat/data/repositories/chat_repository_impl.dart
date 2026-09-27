import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

/// Implémentation du contrat de conversation reposant sur l'API distante.
class ChatRepositoryImpl implements ChatRepository {
  /// Injecte la source réseau afin de séparer domaine et transport HTTP.
  const ChatRepositoryImpl(this._remoteDataSource);

  final ChatRemoteDataSource _remoteDataSource;

  /// Délègue l'envoi du prompt à la source distante.
  @override
  Future<MessageModel> sendMessage({
    required String prompt,
    required List<MessageModel> history,
    String? model,
    List<String>? mediaPaths,
  }) {
    return _remoteDataSource.sendMessage(
      prompt: prompt,
      history: history,
      model: model,
      mediaPaths: mediaPaths,
    );
  }
}

/// Fournisseur Riverpod de l'implémentation du dépôt de conversation.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(chatRemoteDataSourceProvider));
});
