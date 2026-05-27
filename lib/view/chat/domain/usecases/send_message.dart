import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:employeeos/core/error/failures.dart';

import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String conversationId,
    required String authorId,
    String? text,
    String? replyTo,
    List<File>? attachments,
  }) {
    return repository.sendMessage(
      conversationId: conversationId,
      authorId: authorId,
      text: text,
      replyTo: replyTo,
      attachments: attachments,
    );
  }
}