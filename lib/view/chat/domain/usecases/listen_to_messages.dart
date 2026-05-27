import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';

import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class ListenToMessagesUseCase {
  final ChatRepository repository;

  ListenToMessagesUseCase(this.repository);

  Stream<Either<Failure, Conversation>> call(String conversationId) {
    return repository.listenToMessages(conversationId);
  }
}