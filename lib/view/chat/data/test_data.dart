import 'package:employeeos/view/chat/domain/entities/chat_message.dart'
    show TextMessage;
import 'package:employeeos/view/chat/domain/entities/conversation.dart'
    show Conversation, ConversationType;
import 'package:employeeos/view/chat/domain/entities/participant.dart';
import 'package:employeeos/view/chat/domain/entities/reaction.dart';

const String _currentUserId = 'user-123'; // replace with real user ID
final now = DateTime.now();

final testConversations = [
  Conversation(
    id: '11',
    type: ConversationType.oneToOne,
    participants: [
      Participant(
        id: 'user_2',
        name: 'Jane Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/30',
        status: ParticipantStatus.online,
      ),
      Participant(
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
            Reaction(emoji: '❤️', userId: 'user_2'),
            Reaction(emoji: '😂', userId: _currentUserId),
          ],
          createdAt: now.subtract(const Duration(minutes: 2)),
          text: 'I am fine, thanks!'),
    ],
  ),
  Conversation(
    id: '10',
    type: ConversationType.group,
    participants: [
      Participant(
        id: 'user_1',
        name: 'Alex Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/10',
        status: ParticipantStatus.online,
      ),
      Participant(
        id: 'user_2',
        name: 'Jane Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/30',
        status: ParticipantStatus.online,
      ),
      Participant(
        id: 'user_3',
        name: 'Mia Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/70',
        status: ParticipantStatus.online,
      ),
      Participant(
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
  Conversation(
    id: '12',
    type: ConversationType.oneToOne,
    participants: [
      Participant(
        id: 'user_2',
        name: 'Jane Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/30',
        status: ParticipantStatus.online,
      ),
      Participant(
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
            Reaction(emoji: '❤️', userId: 'user_2'),
            Reaction(emoji: '😂', userId: _currentUserId),
          ],
          createdAt: now.subtract(const Duration(minutes: 2)),
          text: 'I am fine, thanks!'),
    ],
  ),
  Conversation(
    id: '13',
    type: ConversationType.group,
    participants: [
      Participant(
        id: 'user_2',
        name: 'Jane Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/30',
        status: ParticipantStatus.online,
      ),
      Participant(
        id: 'user_3',
        name: 'Mia Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/70',
        status: ParticipantStatus.online,
      ),
      Participant(
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
  Conversation(
    id: '14',
    type: ConversationType.oneToOne,
    participants: [
      Participant(
        id: 'user_2',
        name: 'Jane Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/30',
        status: ParticipantStatus.online,
      ),
      Participant(
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
            Reaction(emoji: '❤️', userId: 'user_2'),
            Reaction(emoji: '😂', userId: _currentUserId),
          ],
          createdAt: now.subtract(const Duration(minutes: 2)),
          text: 'I am fine, thanks!'),
    ],
  ),
  Conversation(
    id: '14',
    type: ConversationType.oneToOne,
    participants: [
      Participant(
        id: 'user_2',
        name: 'Jane Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/30',
        status: ParticipantStatus.online,
      ),
      Participant(
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
            Reaction(emoji: '❤️', userId: 'user_2'),
            Reaction(emoji: '😂', userId: _currentUserId),
          ],
          createdAt: now.subtract(const Duration(minutes: 2)),
          text: 'I am fine, thanks!'),
    ],
  ),
  Conversation(
    id: '18',
    type: ConversationType.group,
    participants: [
      Participant(
        id: 'user_2',
        name: 'Jane Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/30',
        status: ParticipantStatus.online,
      ),
      Participant(
        id: 'user_3',
        name: 'Mia Doe',
        avatarUrl: 'https://avatar.iran.liara.run/public/70',
        status: ParticipantStatus.online,
      ),
      Participant(
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
