import 'package:employeeos/view/chat/domain/entities/chat_models.dart';
import 'package:employeeos/view/chat/domain/entities/participant_model.dart';

enum ConversationType { oneToOne, group }

class Conversation {
  final String id;
  final List<ParticipantModel> participants;
  final List<ChatMessage> messages;
  final ConversationType type;

  Conversation({
    required this.id,
    required this.participants,
    required this.messages,
    required this.type,
  });
}
