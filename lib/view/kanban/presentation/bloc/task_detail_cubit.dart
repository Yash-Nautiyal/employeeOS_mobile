import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/domain/usecases/delete_task_attachment_usecase.dart';
import 'package:employeeos/view/kanban/domain/usecases/get_task_detail_usecase.dart';
import 'package:employeeos/view/kanban/domain/usecases/upload_task_attachments_usecase.dart';

class TaskDetailState extends Equatable {
  static const Object _unset = Object();

  final KanbanGroupItem? task;
  final bool isLoading;
  final String? error;

  const TaskDetailState({
    this.task,
    this.isLoading = false,
    this.error,
  });

  TaskDetailState copyWith({
    Object? task = _unset,
    bool? isLoading,
    Object? error = _unset,
  }) {
    return TaskDetailState(
      task: task == _unset ? this.task : task as KanbanGroupItem?,
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [task, isLoading, error];
}

class TaskDetailCubit extends Cubit<TaskDetailState> {
  TaskDetailCubit({
    required GetTaskDetailUseCase getTaskDetailUseCase,
    required UploadTaskAttachmentsUseCase uploadTaskAttachmentsUseCase,
    required DeleteTaskAttachmentUseCase deleteTaskAttachmentUseCase,
  })  : _getTaskDetailUseCase = getTaskDetailUseCase,
        _uploadTaskAttachmentsUseCase = uploadTaskAttachmentsUseCase,
        _deleteTaskAttachmentUseCase = deleteTaskAttachmentUseCase,
        super(const TaskDetailState());

  final GetTaskDetailUseCase _getTaskDetailUseCase;
  final UploadTaskAttachmentsUseCase _uploadTaskAttachmentsUseCase;
  final DeleteTaskAttachmentUseCase _deleteTaskAttachmentUseCase;
  int _requestCounter = 0;
  String? _activeTaskId;
  int _activeRequestId = 0;

  Future<void> openTask(String taskId) async {
    final cached = _getTaskDetailUseCase.getFreshCached(taskId);
    final hasFreshCache = cached != null;

    final requestId = ++_requestCounter;
    _activeTaskId = taskId;
    _activeRequestId = requestId;

    emit(state.copyWith(
      task: cached,
      isLoading: !hasFreshCache,
      error: null,
    ));

    if (hasFreshCache) return;

    try {
      final task = await _getTaskDetailUseCase(taskId);
      if (!_isActiveRequest(taskId, requestId)) return;
      emit(state.copyWith(task: task, isLoading: false, error: null));
    } catch (e) {
      if (!_isActiveRequest(taskId, requestId)) return;
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void clear() {
    _activeTaskId = null;
    _activeRequestId = 0;
    emit(const TaskDetailState());
  }

  Future<List<KanbanAttachment>> uploadAttachments({
    required String taskId,
    required List<KanbanUploadFile> files,
  }) async {
    if (files.isEmpty) return const [];
    final uploaded = await _uploadTaskAttachmentsUseCase(
      taskId: taskId,
      files: files,
    );
    if (uploaded.isEmpty) return uploaded;
    _getTaskDetailUseCase.patchCached(
      taskId,
      (current) => current.copyWith(
        attachments: [...current.attachments, ...uploaded],
      ),
    );
    final currentTask = state.task;
    if (currentTask != null && currentTask.id == taskId) {
      emit(state.copyWith(
        task: currentTask.copyWith(
          attachments: [...currentTask.attachments, ...uploaded],
        ),
      ));
    }
    return uploaded;
  }

  Future<void> deleteAttachment({
    required String taskId,
    required String attachmentId,
  }) async {
    await _deleteTaskAttachmentUseCase(attachmentId);
    _getTaskDetailUseCase.patchCached(
      taskId,
      (current) => current.copyWith(
        attachments:
            current.attachments.where((a) => a.id != attachmentId).toList(),
      ),
    );
    final currentTask = state.task;
    if (currentTask != null && currentTask.id == taskId) {
      emit(state.copyWith(
        task: currentTask.copyWith(
          attachments: currentTask.attachments
              .where((a) => a.id != attachmentId)
              .toList(),
        ),
      ));
    }
  }

  bool _isActiveRequest(String taskId, int requestId) =>
      _activeTaskId == taskId && _activeRequestId == requestId;
}
