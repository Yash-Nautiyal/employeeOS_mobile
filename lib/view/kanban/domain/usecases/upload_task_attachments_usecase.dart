import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';

class UploadTaskAttachmentsUseCase {
  final KanbanRepository _repository;
  const UploadTaskAttachmentsUseCase(this._repository);

  Future<List<KanbanAttachment>> call({
    required String taskId,
    required List<KanbanUploadFile> files,
  }) {
    return _repository.uploadAttachments(
      taskId: taskId,
      files: files,
    );
  }
}
