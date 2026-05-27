import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';
import '../repositories/chat_repository.dart';

class CreateConversationUseCase {
  final ChatRepository repository;

  CreateConversationUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required List<String> participantIds,
    required String authorId,
    String? firstMessageText,
    List<File>? attachments,
    bool isGroup = false,
    String? groupName,
  }) {
    return repository.createConversation(
      participantIds: participantIds,
      authorId: authorId,
      firstMessageText: firstMessageText,
      attachments: attachments,
      isGroup: isGroup,
      groupName: groupName,
    );
  }
}
