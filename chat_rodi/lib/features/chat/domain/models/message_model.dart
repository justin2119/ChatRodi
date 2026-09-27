/// Role assigned to each message in a conversation.
enum MessageRole { user, assistant, system }

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
  });

  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final List<String>? mediaUrls;
  final String? attachmentPath;
  final String? attachmentType;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'content': content,
        'role': role.name,
        'timestamp': timestamp.toIso8601String(),
        'mediaUrls': mediaUrls,
        'attachmentPath': attachmentPath,
        'attachmentType': attachmentType,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final roleName = json['role'] as String?;
    final role = MessageRole.values.where((value) => value.name == roleName);
    final rawMedia = json['mediaUrls'] as List<dynamic>?;
    return MessageModel(
      id: json['id'] as String,
      content: json['content'] as String,
      role: role.isEmpty ? MessageRole.user : role.first,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mediaUrls: rawMedia?.cast<String>(),
      attachmentPath: json['attachmentPath'] as String?,
      attachmentType: json['attachmentType'] as String?,
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
    bool clearMediaUrls = false,
    bool clearAttachment = false,
  }) => MessageModel(
        id: id ?? this.id,
        content: content ?? this.content,
        role: role ?? this.role,
        timestamp: timestamp ?? this.timestamp,
        mediaUrls: clearMediaUrls ? null : (mediaUrls ?? this.mediaUrls),
        attachmentPath: clearAttachment ? null : (attachmentPath ?? this.attachmentPath),
        attachmentType: clearAttachment ? null : (attachmentType ?? this.attachmentType),
      );
}
