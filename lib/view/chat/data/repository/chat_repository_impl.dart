import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/participant.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Conversation>>> getConversations(
      String userId) async {
    try {
      final conversations = await remoteDataSource.getConversations(userId);
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Conversation>>> listenToConversations(
      String userId) {
    return remoteDataSource.listenToConversations(userId).map((models) {
      return Right<Failure, List<Conversation>>(models);
    }).handleError((error) {
      return Left<Failure, List<Conversation>>(
          ServerFailure(message: error.toString()));
    });
  }

  @override
  Future<Either<Failure, Conversation>> getConversationById(String id) async {
    try {
      final conversation = await remoteDataSource.getConversationById(id);
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Conversation>> listenToMessages(
      String conversationId) {
    return remoteDataSource.listenToMessages(conversationId).map((model) {
      return Right<Failure, Conversation>(model);
    }).handleError((error) {
      return Left<Failure, Conversation>(
          ServerFailure(message: error.toString()));
    });
  }

  @override
  Future<Either<Failure, String>> createConversation({
    required List<String> participantIds,
    required String authorId,
    String? firstMessageText,
    List<File>? attachments,
    bool isGroup = false,
    String? groupName,
  }) async {
    try {
      final newConversationId = await remoteDataSource.createConversation(
        participantIds: participantIds,
        authorId: authorId,
        firstMessageText: firstMessageText,
        attachments: attachments,
        isGroup: isGroup,
        groupName: groupName,
      );
      return Right(newConversationId);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String conversationId,
    required String authorId,
    String? text,
    String? replyTo,
    List<File>? attachments,
  }) async {
    try {
      await remoteDataSource.sendMessage(
        conversationId: conversationId,
        authorId: authorId,
        text: text,
        replyTo: replyTo,
        attachments: attachments,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addReaction({
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
  }) async {
    try {
      await remoteDataSource.addReaction(
        conversationId: conversationId,
        messageId: messageId,
        emoji: emoji,
        userId: userId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Participant>>> getAvailableUsers(
      String currentUserId) async {
    try {
      final users = await remoteDataSource.getAvailableUsers(currentUserId);
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
