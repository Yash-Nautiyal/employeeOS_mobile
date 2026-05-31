import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';
import '../repositories/chat_repository.dart';

class MarkConversationAsReadUseCase {
  final ChatRepository repository;

  MarkConversationAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String conversationId,
    required String userId,
  }) {
    return repository.markConversationAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }
}