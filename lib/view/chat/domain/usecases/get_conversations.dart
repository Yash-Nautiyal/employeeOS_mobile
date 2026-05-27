import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';

import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUseCase {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  Future<Either<Failure, List<Conversation>>> call(String userId) {
    return repository.getConversations(userId);
  }
}
