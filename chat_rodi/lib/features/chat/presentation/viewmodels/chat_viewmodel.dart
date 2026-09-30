import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';

/// Immutable state displayed by the conversation screen.
class ChatState {
  const ChatState({
    this.messages = const <MessageModel>[],
    this.isLoading = false,
    this.errorMessage,
    this.selectedModel = 'rodium-chat-v1',
    this.selectedAttachmentPath,
    this.selectedAttachmentType,
  });

  final List<MessageModel> messages;
  final bool isLoading;
  final String? errorMessage;
  final String selectedModel;
  final String? selectedAttachmentPath;
  final String? selectedAttachmentType;

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? errorMessage,
    String? selectedModel,
    String? selectedAttachmentPath,
    String? selectedAttachmentType,
    bool clearError = false,
    bool clearAttachment = false,
  }) => ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        selectedModel: selectedModel ?? this.selectedModel,
        selectedAttachmentPath: clearAttachment ? null : (selectedAttachmentPath ?? this.selectedAttachmentPath),
        selectedAttachmentType: clearAttachment ? null : (selectedAttachmentType ?? this.selectedAttachmentType),
      );
}

/// Coordinates conversation messages and always reads the model selected in Settings.
class ChatViewModel extends StateNotifier<ChatState> {
  ChatViewModel(this._repository, this._ref) : super(const ChatState());
  final ChatRepository _repository;
  final Ref _ref;

  void selectModel(String modelId) => state = state.copyWith(selectedModel: modelId);

  void setAttachment(String path, {String? type}) => state = state.copyWith(
        selectedAttachmentPath: path,
        selectedAttachmentType: type ?? 'file',
      );

  void clearAttachment() => state = state.copyWith(clearAttachment: true);

  void newConversation() => state = ChatState(selectedModel: _ref.read(defaultModelProvider));

  Future<void> sendMessage(String content) async {
    final prompt = content.trim();
    final attachmentPath = state.selectedAttachmentPath;
    final attachmentType = state.selectedAttachmentType;
    final model = _ref.read(defaultModelProvider);
    if ((prompt.isEmpty && attachmentPath == null) || state.isLoading) return;
    final now = DateTime.now();
    final userMessage = MessageModel(
      id: now.microsecondsSinceEpoch.toString(),
      content: prompt,
      role: MessageRole.user,
      timestamp: now,
      attachmentPath: attachmentPath,
      attachmentType: attachmentType,
    );
    final previousMessages = state.messages;
    state = state.copyWith(
      messages: <MessageModel>[...previousMessages, userMessage],
      isLoading: true,
      selectedModel: model,
      clearError: true,
      clearAttachment: true,
    );
    try {
      final answer = await _repository.sendMessage(
        prompt: prompt,
        history: previousMessages,
        model: model,
      );
      state = state.copyWith(messages: <MessageModel>[...state.messages, answer], isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: 'Impossible d\\u2019envoyer le message : $error');
    }
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>(
  (ref) => ChatViewModel(ref.watch(chatRepositoryProvider), ref),
);
