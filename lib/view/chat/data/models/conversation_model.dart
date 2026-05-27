import '../../domain/entities/conversation.dart';
import '../../domain/entities/participant.dart';

import 'chat_message_model.dart';
import 'participant_model.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    super.name,
    required super.participants,
    required super.messages,
    required super.type,
    super.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json,
      {int unreadCount = 0}) {
    final String id =
        json['id']?.toString() ?? json['conversation_id']?.toString() ?? '';
    final bool isGroup = json['type'] == 'GROUP' || json['is_group'] == true;

    // Handle group name extraction
    final String? name = json['name'] ??
        (json['groups'] != null ? json['groups']['group_name'] : null);

    // Map Participants
    final List<dynamic> participantsJson = json['participants'] ?? [];
    final List<Participant> participants = participantsJson
        .map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>))
        .toList();

    // Map Messages
    final List<dynamic> messagesJson = json['messages'] ?? [];
    final messages = messagesJson
        .expand((m) => ChatMessageMapper.fromJson(m as Map<String, dynamic>))
        .toList();

    return ConversationModel(
      id: id,
      name: name,
      participants: participants,
      messages: messages,
      type: isGroup ? ConversationType.group : ConversationType.oneToOne,
      unreadCount: json['unreadCount'] ?? unreadCount,
    );
  }

  static Map<String, dynamic> toJSON(Conversation conversation) {
    return {
      'id': conversation.id,
      'name': conversation.name,
      'participants': conversation.participants
          .map((p) => ParticipantModel.toJSON(p))
          .toList(),
      'messages': conversation.messages
          .map((m) => ChatMessageMapper.toJSON(m))
          .toList(),
      'type':
          conversation.type == ConversationType.group ? 'GROUP' : 'ONE_TO_ONE',
      'unreadCount': conversation.unreadCount,
    };
  }
}
