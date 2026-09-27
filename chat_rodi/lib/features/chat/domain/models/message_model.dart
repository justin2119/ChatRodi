/// Rôle attribué à chaque message dans une conversation.
enum MessageRole { user, assistant, system }

/// Représente un message immuable échangé au sein d'une conversation.
///
/// [id] identifie le message, [content] contient son texte, [role] indique
/// son origine, [timestamp] conserve sa date de création et [mediaUrls]
/// contient éventuellement les URL des médias associés.
class MessageModel {
  /// Crée un message avec toutes ses propriétés.
  const MessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.mediaUrls,
  });

  /// Identifiant unique du message.
  final String id;

  /// Texte du message.
  final String content;

  /// Auteur logique du message.
  final MessageRole role;

  /// Date et heure de création du message.
  final DateTime timestamp;

  /// URL des médias joints, ou `null` en l'absence de média.
  final List<String>? mediaUrls;

  /// Convertit le message en objet JSON sérialisable.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'content': content,
        'role': role.name,
        'timestamp': timestamp.toIso8601String(),
        'mediaUrls': mediaUrls,
      };

  /// Reconstruit un message depuis un objet JSON.
  ///
  /// Une valeur manquante ou invalide pour le rôle devient `user`, et les
  /// dates sont interprétées au format ISO 8601.
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
    );
  }

  /// Crée une copie en remplaçant uniquement les propriétés fournies.
  ///
  /// Les paramètres nullable possèdent un indicateur dédié afin de permettre
  /// de distinguer une omission d'une demande explicite de mise à `null`.
  MessageModel copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    List<String>? mediaUrls,
    bool clearMediaUrls = false,
  }) =>
      MessageModel(
        id: id ?? this.id,
        content: content ?? this.content,
        role: role ?? this.role,
        timestamp: timestamp ?? this.timestamp,
        mediaUrls: clearMediaUrls ? null : (mediaUrls ?? this.mediaUrls),
      );
}
