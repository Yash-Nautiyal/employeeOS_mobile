import 'package:employeeos/view/chat/domain/entities/chat_models.dart';

class Conversation {
  final String id;
  final String name;
  final List<ChatMessage> messages;

  Conversation({
    required this.id,
    required this.name,
    required this.messages,
  });
}
