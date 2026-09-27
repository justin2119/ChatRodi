import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';

/// État immuable affiché par l'écran de conversation.
class ChatState {
  const ChatState({
    this.messages = const <MessageModel>[],
    this.isLoading = false,
    this.errorMessage,
    this.selectedModel = 'Gemini 3.7 Flash',
  });

  final List<MessageModel> messages;
  final bool isLoading;
  final String? errorMessage;
  final String selectedModel;

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? errorMessage,
    String? selectedModel,
    bool clearError = false,
  }) => ChatState(
    messages: messages ?? this.messages,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    selectedModel: selectedModel ?? this.selectedModel,
  );
}

/// Coordonne les messages et le modèle actif.
class ChatViewModel extends StateNotifier<ChatState> {
  ChatViewModel(this._repository) : super(const ChatState());
  final ChatRepository _repository;

  void selectModel(String modelId) => state = state.copyWith(selectedModel: modelId);

  void newConversation() => state = ChatState(selectedModel: state.selectedModel);

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
      state = state.copyWith(messages: <MessageModel>[...state.messages, answer], isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: 'Impossible d’envoyer le message : $error');
    }
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>(
  (ref) => ChatViewModel(ref.watch(chatRepositoryProvider)),
);
