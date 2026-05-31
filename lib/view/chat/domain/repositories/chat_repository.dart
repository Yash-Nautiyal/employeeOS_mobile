import 'dart:io'; // Needed for File attachments
import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';

import '../entities/participant.dart';
import '../entities/conversation.dart';

abstract class ChatRepository {
  /// Fetches the initial list of conversations
  Future<Either<Failure, List<Conversation>>> getConversations(String userId);

  /// Streams real-time updates for the inbox (new messages, unread counts)
  Stream<Either<Failure, List<Conversation>>> listenToConversations(
      String userId);

  /// Fetches a specific conversation by ID
  Future<Either<Failure, Conversation>> getConversationById(String id);

  /// Streams real-time updates for a specific conversation (new messages, typing status, reactions)
  Stream<Either<Failure, Conversation>> listenToMessages(String conversationId);

  /// Fetches available users to start a new chat with
  Future<Either<Failure, List<Participant>>> getAvailableUsers(String currentUserId);

  /// Creates a new conversation and sends the first message
  Future<Either<Failure, String>> createConversation({
    required List<String> participantIds,
    required String authorId,
    String? firstMessageText,
    List<File>? attachments,
    bool isGroup = false,
    String? groupName,
  });

  /// Send a message (Text, Image, or File)
  Future<Either<Failure, void>> sendMessage({
    required String conversationId,
    required String authorId,
    String? text,
    String? replyTo,
    List<File>? attachments,
  });

  /// Add or update a reaction
  Future<Either<Failure, void>> addReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
  });

  /// Marks a conversation as read by updating the user's last_read_at timestamp
  Future<Either<Failure, void>> markConversationAsRead({
    required String conversationId,
    required String userId,
  });
}
