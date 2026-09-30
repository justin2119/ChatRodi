/// Role assigned to each message in a conversation.
enum MessageRole { user, assistant, system }

enum MessageType { text, image, video }

/// Immutable message exchanged in a conversation.
class MessageModel {
  const MessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.mediaUrls,
    this.attachmentPath,
    this.attachmentType,
    this.type = MessageType.text,
    this.mediaUrl,
    this.mediaType,
  });

  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final List<String>? mediaUrls;
  final String? attachmentPath;
  final String? attachmentType;
  final MessageType type;
  final String? mediaUrl;
  final String? mediaType;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'content': content,
        'role': role.name,
        'timestamp': timestamp.toIso8601String(),
        'mediaUrls': mediaUrls,
        'attachmentPath': attachmentPath,
        'attachmentType': attachmentType,
        'type': type.name,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final roleName = json['role'] as String?;
    final role = MessageRole.values.where((value) => value.name == roleName);
    final rawMedia = json['mediaUrls'] as List<dynamic>?;
    final typeName = json['type'] as String?;
    final types = MessageType.values.where((value) => value.name == typeName);
    return MessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      role: role.isEmpty ? MessageRole.user : role.first,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mediaUrls: rawMedia?.cast<String>(),
      attachmentPath: json['attachmentPath'] as String?,
      attachmentType: json['attachmentType'] as String?,
      type: types.isEmpty ? MessageType.text : types.first,
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
    );
  }

  MessageModel copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    List<String>? mediaUrls,
    String? attachmentPath,
    String? attachmentType,
    MessageType? type,
    String? mediaUrl,
    String? mediaType,
    bool clearMediaUrls = false,
    bool clearAttachment = false,
    bool clearMedia = false,
  }) => MessageModel(
        id: id ?? this.id,
        content: content ?? this.content,
        role: role ?? this.role,
        timestamp: timestamp ?? this.timestamp,
        mediaUrls: clearMediaUrls ? null : (mediaUrls ?? this.mediaUrls),
        attachmentPath: clearAttachment ? null : (attachmentPath ?? this.attachmentPath),
        attachmentType: clearAttachment ? null : (attachmentType ?? this.attachmentType),
        type: type ?? this.type,
        mediaUrl: clearMedia ? null : (mediaUrl ?? this.mediaUrl),
        mediaType: clearMedia ? null : (mediaType ?? this.mediaType),
      );
}
