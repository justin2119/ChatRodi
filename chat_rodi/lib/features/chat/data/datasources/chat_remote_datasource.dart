import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/models/message_model.dart';

class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  List<Map<String, String>> _messages({
    required String prompt,
    required List<MessageModel> history,
  }) => <Map<String, String>>[
        ...history.map((message) => <String, String>{
              'role': message.role.name,
              'content': message.content,
            }),
        <String, String>{'role': 'user', 'content': prompt},
      ];

  Future<MessageModel> sendMessage({
    required String prompt,
    required List<MessageModel> history,
    String? model,
    List<String>? mediaPaths,
  }) async {
    final client = await _apiClient.rodiumClient;
    final response = await client
        .model(model ?? 'default')
        .temperature(0.7)
        .chat(_messages(prompt: prompt, history: history));
    final dynamic result = response;
    final String? content = result.text as String? ?? result.content as String?;
    if (content == null) {
      throw const FormatException('Contenu assistant absent de la reponse.');
    }
    return MessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );
  }

  /// Streams text deltas from RodiumAI; Dio is intentionally reserved for media.
  Stream<String> streamMessage({
    required String prompt,
    required List<MessageModel> history,
    String? model,
  }) async* {
    final client = await _apiClient.rodiumClient;
    final Stream<dynamic> deltas = client
        .model(model ?? 'default')
        .stream(_messages(prompt: prompt, history: history));
    await for (final delta in deltas) {
      final dynamic value = delta;
      final String? text = value.text as String? ?? value.content as String?;
      if (text != null && text.isNotEmpty) yield text;
    }
  }

  Future<String> generateImage({
    required String prompt,
    String model = 'rodium-image-v1',
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.image,
      data: <String, dynamic>{'prompt': prompt, 'model': model, 'n': 1, 'size': '1024x1024'},
    );
    final data = response.data;
    final entries = data?['data'] as List<dynamic>?;
    final first = entries?.isNotEmpty == true ? entries!.first : null;
    final image = first is Map ? first['url'] as String? : null;
    final url = image ?? data?['url'] as String?;
    if (url == null || url.isEmpty) throw const FormatException('Image URL absente de la reponse.');
    return url;
  }

  Future<String> generateVideo({
    required String prompt,
    String model = 'rodium-video-v1',
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.video,
      data: <String, dynamic>{'prompt': prompt, 'model': model},
    );
    final data = response.data;
    final taskId = data?['taskId'] as String? ?? data?['id'] as String?;
    if (taskId == null || taskId.isEmpty) throw const FormatException('Identifiant de generation video absent.');
    return taskId;
  }
}

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSource(ref.watch(apiClientProvider));
});
