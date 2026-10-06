import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatState {
  const ChatState({
    this.messages = const <MessageModel>[],
    this.isLoading = false,
    this.errorMessage,
    this.selectedModel = 'claude-3-5-sonnet',
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

class ChatViewModel extends StateNotifier<ChatState> {
  ChatViewModel(this._repository, this._mediaDataSource, this._ref)
      : super(ChatState(selectedModel: _ref.read(defaultModelProvider)));
  final ChatRepository _repository;
  final ChatRemoteDataSource _mediaDataSource;
  final Ref _ref;

  void selectModel(String modelId) {
    _ref.read(defaultModelProvider.notifier).state = modelId;
    state = state.copyWith(selectedModel: modelId);
  }
  void setAttachment(String path, {String? type}) => state = state.copyWith(
        selectedAttachmentPath: path,
        selectedAttachmentType: type ?? 'file',
      );
  void clearAttachment() => state = state.copyWith(clearAttachment: true);
  void newConversation() => state = ChatState(selectedModel: _ref.read(defaultModelProvider));

  Future<void> sendMessage(String content) async {
    final rawPrompt = content.trim();
    final attachmentPath = state.selectedAttachmentPath;
    final attachmentType = state.selectedAttachmentType;
    final model = _ref.read(defaultModelProvider);
    if ((rawPrompt.isEmpty && attachmentPath == null) || state.isLoading) return;
    var prompt = rawPrompt;
    var mediaKind = '';
    final lower = rawPrompt.toLowerCase();
    for (final prefix in const ['/image', '/imagine', 'image:']) {
      if (lower.startsWith(prefix)) {
        mediaKind = 'image';
        prompt = rawPrompt.substring(prefix.length).trim();
        break;
      }
    }
    for (final prefix in const ['/video', 'video:']) {
      if (mediaKind.isEmpty && lower.startsWith(prefix)) {
        mediaKind = 'video';
        prompt = rawPrompt.substring(prefix.length).trim();
        break;
      }
    }
    final now = DateTime.now();
    final previousMessages = state.messages;
    final userMessage = MessageModel(
      id: now.microsecondsSinceEpoch.toString(),
      content: rawPrompt,
      role: MessageRole.user,
      timestamp: now,
      attachmentPath: attachmentPath,
      attachmentType: attachmentType,
    );
    state = state.copyWith(
      messages: <MessageModel>[...previousMessages, userMessage],
      isLoading: true,
      selectedModel: model,
      clearError: true,
      clearAttachment: true,
    );
    try {
      if (mediaKind == 'image') {
        final url = await _mediaDataSource.generateImage(prompt: prompt);
        final imageMessage = MessageModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          content: '', role: MessageRole.assistant, timestamp: DateTime.now(),
          type: MessageType.image, mediaUrl: url, mediaType: 'image', mediaUrls: <String>[url],
        );
        state = state.copyWith(messages: <MessageModel>[...state.messages, imageMessage], isLoading: false);
      } else if (mediaKind == 'video') {
        final taskId = await _mediaDataSource.generateVideo(prompt: prompt);
        final videoMessage = MessageModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          content: 'Video generation started. Task: $taskId', role: MessageRole.assistant,
          timestamp: DateTime.now(), type: MessageType.video, mediaType: 'video', mediaUrl: taskId,
        );
        state = state.copyWith(messages: <MessageModel>[...state.messages, videoMessage], isLoading: false);
      } else {
        final answer = await _repository.sendMessage(prompt: prompt, history: previousMessages, model: model);
        state = state.copyWith(messages: <MessageModel>[...state.messages, answer], isLoading: false);
      }
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: 'Impossible d’envoyer le message : $error');
    }
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>(
  (ref) => ChatViewModel(
    ref.watch(chatRepositoryProvider),
    ref.watch(chatRemoteDataSourceProvider),
    ref,
  ),
);
