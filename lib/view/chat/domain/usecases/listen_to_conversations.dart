import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';

import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class ListenToConversationsUseCase {
  final ChatRepository repository;

  ListenToConversationsUseCase(this.repository);

  Stream<Either<Failure, List<Conversation>>> call(String userId) {
    return repository.listenToConversations(userId);
  }
}