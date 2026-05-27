import 'chat_message.dart';
import 'participant.dart';

enum ConversationType { oneToOne, group }

class Conversation {
  final String id;
  final String? name; // Added for group chats
  final List<Participant> participants;
  final List<ChatMessage> messages;
  final ConversationType type;
  final int unreadCount; // Crucial for the inbox UI

  Conversation({
    required this.id,
    this.name,
    required this.participants,
    required this.messages,
    required this.type,
    this.unreadCount = 0,
  });
}
