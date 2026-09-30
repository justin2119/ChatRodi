import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/models/message_model.dart';

class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._dio);
  final Dio _dio;

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
      ApiEndpoints.chat,
      data: <String, dynamic>{
        'model': model ?? 'default',
        'messages': messages,
        'temperature': 0.7,
      },
    );
    final data = response.data;
    if (data == null) throw const FormatException('Reponse de chat vide.');
    final choices = data['choices'] as List<dynamic>?;
    final choice = choices?.isNotEmpty == true
        ? choices!.first as Map<String, dynamic>
        : null;
    final message = choice?['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String? ?? data['content'] as String?;
    if (content == null) throw const FormatException('Contenu assistant absent de la reponse.');
    return MessageModel(
      id: data['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );
  }

  Future<String> generateImage({
    required String prompt,
    String model = 'rodium-image-v1',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
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
    final response = await _dio.post<Map<String, dynamic>>(
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
  return ChatRemoteDataSource(ref.watch(apiClientProvider).dio);
});
