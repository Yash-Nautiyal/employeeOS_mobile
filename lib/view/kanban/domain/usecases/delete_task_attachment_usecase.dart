import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class DeleteTaskAttachmentUseCase {
  final KanbanRepository _repository;
  const DeleteTaskAttachmentUseCase(this._repository);

  Future<void> call(String attachmentId) {
    return _repository.deleteAttachment(attachmentId);
  }
}
