import '../../domain/entities/chat_message.dart';
import '../../domain/entities/reaction.dart';

import 'reaction_model.dart';

class ChatMessageMapper {
  static List<ChatMessage> fromJson(Map<String, dynamic> json) {
    final List<ChatMessage> result = [];
    final String id = json['id']?.toString() ?? '';
    final String authorId = json['sender_id']?.toString() ?? '';
    final DateTime createdAt =
        DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
            DateTime.now();
    final String? replyTo = json['parent_id']?.toString();
    final String bodyText = json['body']?.toString() ?? '';

    // Map Reactions
    final List<dynamic>? reactionsJson =
        json['message_reactions'] ?? json['reactions'];
    final List<Reaction> reactions = reactionsJson
            ?.map((r) => ReactionModel.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    // --- 1. ATTACHMENTS FIRST (Draws them on top) ---
    final List<dynamic>? attachments = json['attachments'];

    if (attachments != null && attachments.isNotEmpty) {
      for (int i = 0; i < attachments.length; i++) {
        final attachment = attachments[i];
        final String fileType = attachment['type']?.toString() ?? '';
        final bool isImage = fileType.startsWith('image/');
        final String url = attachment['preview']?.toString() ?? '';
        final String name = attachment['name']?.toString() ?? 'attachment';
        final int size =
            int.tryParse(attachment['size']?.toString() ?? '0') ?? 0;

        if (isImage) {
          result.add(ImageMessage(
            id: '$id-att-$i',
            authorId: authorId,
            createdAt: createdAt,
            url: url,
            name: name,
            size: size,
            replyTo: replyTo,
            reactions: bodyText.isEmpty && i == 0 ? reactions : [],
          ));
        } else {
          result.add(FileMessage(
            id: '$id-att-$i',
            authorId: authorId,
            createdAt: createdAt,
            url: url,
            name: name,
            size: size,
            fileType: fileType,
            replyTo: replyTo,
            reactions: bodyText.isEmpty && i == 0 ? reactions : [],
          ));
        }
      }
    }

    // --- 2. TEXT SECOND (Snaps the caption to the bottom) ---
    if (bodyText.isNotEmpty) {
      result.add(TextMessage(
        id: '$id-text',
        authorId: authorId,
        createdAt: createdAt,
        text: bodyText,
        replyTo: replyTo,
        reactions: reactions,
      ));
    }

    if (result.isEmpty) {
      result.add(TextMessage(
        id: id,
        authorId: authorId,
        createdAt: createdAt,
        text: '',
        replyTo: replyTo,
        reactions: reactions,
      ));
    }

    return result;
  }

  static Map<String, dynamic> toJSON(ChatMessage message) {
    return {
      'id': message.id,
      'sender_id': message.authorId,
      'created_at': message.createdAt.toLocal().toIso8601String(),
      'body': message is TextMessage ? message.text : '',
      'parent_id': message.replyTo,
      'reactions':
          message.reactions.map((r) => ReactionModel.toJSON(r)).toList(),
      'attachments': message is ImageMessage || message is FileMessage
          ? [
              {
                'type': message is ImageMessage ? 'image' : 'file',
                'url': (message as dynamic).url,
                'name': (message as dynamic).name,
                'size': (message as dynamic).size,
                'fileType': message is FileMessage ? message.fileType : null,
              }
            ]
          : [],
    };
  }
}

extension ChatMessageIdBridge on ChatMessage {
  /// Automatically strips UI suffixes (-text, -att-0) to return the pure Database UUID
  String get dbId {
    return id.replaceAll(RegExp(r'(-text|-att-\d+)$'), '');
  }
}
