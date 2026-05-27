import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';
import 'package:employeeos/view/chat/domain/entities/conversation.dart';
import 'package:employeeos/view/chat/domain/repositories/chat_repository.dart';

class GetConversationByIdUseCase {
  final ChatRepository repository;

  GetConversationByIdUseCase(this.repository);

  Future<Either<Failure, Conversation>> call(String id) {
    return repository.getConversationById(id);
  }
}
