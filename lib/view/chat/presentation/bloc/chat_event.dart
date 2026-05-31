part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

// ---------------- Inbox Events ----------------

final class StartListeningConversationsEvent extends ChatEvent {
  final String userId;
  const StartListeningConversationsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

final class _ConversationsUpdatedEvent extends ChatEvent {
  final Either<Failure, List<Conversation>> result;
  const _ConversationsUpdatedEvent(this.result);
}

final class ResetChatEvent extends ChatEvent {
  const ResetChatEvent();

  @override
  List<Object?> get props => [];
}

final class ClearSelectedConversationEvent extends ChatEvent {
  const ClearSelectedConversationEvent();

  @override
  List<Object?> get props => [];
}

// ---------------- Thread Events ----------------

final class SelectConversationEvent extends ChatEvent {
  final String conversationId;
  final String currentUserId;
  const SelectConversationEvent(
      {required this.conversationId, required this.currentUserId});

  @override
  List<Object> get props => [conversationId, currentUserId];
}

final class _ThreadUpdatedEvent extends ChatEvent {
  final Either<Failure, Conversation> result;
  const _ThreadUpdatedEvent(this.result);
}

final class LoadAvailableUsersEvent extends ChatEvent {
  final String currentUserId;

  const LoadAvailableUsersEvent({required this.currentUserId});

  @override
  List<Object?> get props => [currentUserId];
}

// ---------------- Action Events ----------------

final class CreateConversationEvent extends ChatEvent {
  final List<String> participantIds;
  final String authorId;
  final String? firstMessageText;
  final List<File>? attachments;

  const CreateConversationEvent({
    required this.participantIds,
    required this.authorId,
    this.firstMessageText,
    this.attachments,
  });

  @override
  List<Object?> get props =>
      [participantIds, authorId, firstMessageText, attachments];
}

final class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String authorId;
  final String? text;
  final String? replyTo;
  final List<File>? attachments;

  const SendMessageEvent({
    required this.conversationId,
    required this.authorId,
    this.text,
    this.replyTo,
    this.attachments,
  });

  @override
  List<Object?> get props =>
      [conversationId, authorId, text, replyTo, attachments];
}

final class AddReactionEvent extends ChatEvent {
  final String conversationId;
  final String messageId;
  final String emoji;
  final String userId;

  const AddReactionEvent({
    required this.conversationId,
    required this.messageId,
    required this.emoji,
    required this.userId,
  });

  @override
  List<Object> get props => [conversationId, messageId, emoji, userId];
}
