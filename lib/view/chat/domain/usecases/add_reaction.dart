import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';

import '../repositories/chat_repository.dart';

class AddReactionUseCase {
  final ChatRepository repository;

  AddReactionUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String conversationId,
    required String messageId,
    required String emoji,
    required String userId,
  }) {
    return repository.addReaction(
      conversationId: conversationId,
      messageId: messageId,
      emoji: emoji,
      userId: userId,
    );
  }
}