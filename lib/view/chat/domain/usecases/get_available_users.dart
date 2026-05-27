import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';
import '../../domain/entities/participant.dart';
import '../../domain/repositories/chat_repository.dart';

class GetAvailableUsersUseCase {
  final ChatRepository repository;

  GetAvailableUsersUseCase(this.repository);

  Future<Either<Failure, List<Participant>>> call(String currentUserId) {
    return repository.getAvailableUsers(currentUserId);
  }
}