import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';

/// État immuable affiché par l'écran de conversation.
class ChatState {
  /// Crée l'état de conversation avec des valeurs initiales explicites.
  const ChatState({
    this.messages = const <MessageModel>[],
    this.isLoading = false,
    this.errorMessage,
    this.selectedModel = 'default',
  });

  /// Messages connus, dans leur ordre de présentation.
  final List<MessageModel> messages;

  /// Indique qu'une réponse est attendue.
  final bool isLoading;

  /// Erreur destinée à être présentée à l'utilisateur, le cas échéant.
  final String? errorMessage;

  /// Identifiant du modèle sélectionné pour les prochains envois.
  final String selectedModel;

  /// Produit un nouvel état en conservant les champs non modifiés.
  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? errorMessage,
    String? selectedModel,
    bool clearError = false,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        selectedModel: selectedModel ?? this.selectedModel,
      );
}

/// Coordonne l'envoi de messages et la mise à jour de l'état de l'interface.
class ChatViewModel extends StateNotifier<ChatState> {
  /// Reçoit le dépôt métier pour permettre une substitution lors des tests.
  ChatViewModel(this._repository) : super(const ChatState());

  final ChatRepository _repository;

  /// Ajoute le message utilisateur, puis récupère et ajoute la réponse.
  Future<void> sendMessage(String content) async {
    final prompt = content.trim();
    if (prompt.isEmpty || state.isLoading) return;

    final now = DateTime.now();
    final userMessage = MessageModel(
      id: now.microsecondsSinceEpoch.toString(),
      content: prompt,
      role: MessageRole.user,
      timestamp: now,
    );
    final previousMessages = state.messages;
    state = state.copyWith(
      messages: <MessageModel>[...previousMessages, userMessage],
      isLoading: true,
      clearError: true,
    );
    try {
      final answer = await _repository.sendMessage(
        prompt: prompt,
        history: previousMessages,
        model: state.selectedModel,
      );
      state = state.copyWith(
        messages: <MessageModel>[...state.messages, answer],
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible d’envoyer le message : $error',
      );
    }
  }
}

/// Fournisseur classique Riverpod du ViewModel de conversation.
final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  return ChatViewModel(ref.watch(chatRepositoryProvider));
});
