import 'package:employeeos/view/chat/domain/entities/chat_models.dart'
    show TextMessage;
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart'
    show Conversation, ConversationType;
import 'package:employeeos/view/chat/domain/entities/participant_model.dart';
import 'package:employeeos/view/chat/domain/entities/reaction_model.dart';

const String _currentUserId = 'user-123'; // replace with real user ID
final now = DateTime.now();

final testConversations = [
  Conversation(
    id: '11',
    type: ConversationType.oneToOne,
    participants: [
      ParticipantModel(
        id: 'user_2',
        name: 'Jane Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/30',
        status: ParticipantStatus.online,
      ),
      ParticipantModel(
        id: _currentUserId,
        name: 'John Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/9',
        status: ParticipantStatus.online,
      ),
    ],
    messages: [
      TextMessage(
          id: '1',
          authorId: _currentUserId,
          createdAt: now.subtract(const Duration(minutes: 5)),
          text: 'Hey there!'),
      TextMessage(
          id: '2',
          authorId: 'user_2',
          createdAt: now.subtract(const Duration(minutes: 4)),
          text: 'Hello, how are you?'),
      TextMessage(
          id: '3',
          authorId: _currentUserId,
          reactions: [
            ReactionModel(emoji: '❤️', userId: 'user_2'),
            ReactionModel(emoji: '😂', userId: _currentUserId),
          ],
          createdAt: now.subtract(const Duration(minutes: 2)),
          text: 'I am fine, thanks!'),
    ],
  ),
  
  Conversation(
    id: '18',
    type: ConversationType.group,
    participants: [
      ParticipantModel(
        id: 'user_2',
        name: 'Jane Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/30',
        status: ParticipantStatus.online,
      ),
      ParticipantModel(
        id: 'user_3',
        name: 'Mia Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/70',
        status: ParticipantStatus.online,
      ),
      ParticipantModel(
        id: _currentUserId,
        name: 'John Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/9',
        status: ParticipantStatus.online,
      ),
    ],
    messages: [
      TextMessage(
          id: '1',
          authorId: _currentUserId,
          createdAt: now.subtract(const Duration(minutes: 5)),
          text: 'Hey there!'),
      TextMessage(
          id: '2',
          authorId: 'user_2',
          createdAt: now.subtract(const Duration(minutes: 4)),
          text: 'Hello, how are you?'),
      TextMessage(
          id: '3',
          authorId: 'user_3',
          createdAt: now.subtract(const Duration(minutes: 2)),
          text: 'I am fine, thanks!'),
    ],
  ),
];
