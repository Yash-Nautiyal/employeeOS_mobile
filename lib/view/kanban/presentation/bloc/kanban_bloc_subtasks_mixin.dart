part of 'kanban_bloc.dart';

extension KanbanSubtaskHandlers on KanbanBloc {
  Future<void> _onSubtaskAdded(
      KanbanSubtaskAdded event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    emit(current.copyWith(isActionLoading: true));
    try {
      final st =
          await _addSubtaskUseCase(taskId: event.taskId, name: event.name);
      final loc =
          KanbanStateHelper.findTaskByTaskId(current.columns, event.taskId);
      if (loc != null) {
        final newColumns = KanbanStateHelper.updateTaskInState(
          current.columns,
          loc.$1,
          loc.$2,
          event.taskId,
          (t) => t.copyWith(subtasks: [...t.subtasks, st]),
        );
        final next =
            current.copyWith(columns: newColumns, isActionLoading: false);
        _patchTaskCache(
          event.taskId,
          (t) => t.copyWith(subtasks: [...t.subtasks, st]),
        );
        emit(next);
      } else {
        emit(current.copyWith(isActionLoading: false));
      }
    } catch (e) {
      emit(KanbanErrorActionState(e.toString()));
      emit(current.copyWith(isActionLoading: false));
    }
  }

  Future<void> _onSubtaskToggled(
      KanbanSubtaskToggled event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    try {
      await _toggleSubtaskUseCase(
        subtaskId: event.subtaskId,
        completed: event.completed,
      );
      final loc =
          KanbanStateHelper.findTaskByTaskId(current.columns, event.taskId);
      if (loc != null) {
        final newSubtasks = loc.$5.subtasks
            .map((s) => s.id == event.subtaskId
                ? s.copyWith(completed: event.completed)
                : s)
            .toList();
        final newColumns = KanbanStateHelper.updateTaskInState(
          current.columns,
          loc.$1,
          loc.$2,
          event.taskId,
          (t) => t.copyWith(subtasks: newSubtasks),
        );
        final next = current.copyWith(columns: newColumns);
        _patchTaskCache(
          event.taskId,
          (t) => t.copyWith(
            subtasks: t.subtasks
                .map((s) => s.id == event.subtaskId
                    ? s.copyWith(completed: event.completed)
                    : s)
                .toList(),
          ),
        );
        emit(next);
      }
    } catch (e) {
      emit(KanbanErrorActionState(e.toString()));
    }
  }

  Future<void> _onSubtaskRenamed(
      KanbanSubtaskRenamed event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    try {
      await _renameSubtaskUseCase(
        subtaskId: event.subtaskId,
        name: event.name,
      );
      final loc =
          KanbanStateHelper.findTaskByTaskId(current.columns, event.taskId);
      if (loc != null) {
        final newSubtasks = loc.$5.subtasks
            .map((s) =>
                s.id == event.subtaskId ? s.copyWith(name: event.name) : s)
            .toList();
        final newColumns = KanbanStateHelper.updateTaskInState(
          current.columns,
          loc.$1,
          loc.$2,
          event.taskId,
          (t) => t.copyWith(subtasks: newSubtasks),
        );
        final next = current.copyWith(columns: newColumns);
        _patchTaskCache(
          event.taskId,
          (t) => t.copyWith(
            subtasks: t.subtasks
                .map((s) =>
                    s.id == event.subtaskId ? s.copyWith(name: event.name) : s)
                .toList(),
          ),
        );
        emit(next);
      }
    } catch (e) {
      emit(KanbanErrorActionState(e.toString()));
    }
  }

  Future<void> _onSubtaskDeleted(
      KanbanSubtaskDeleted event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    try {
      await _deleteSubtaskUseCase(event.subtaskId);
      final loc =
          KanbanStateHelper.findTaskByTaskId(current.columns, event.taskId);
      if (loc != null) {
        final newSubtasks =
            loc.$5.subtasks.where((s) => s.id != event.subtaskId).toList();
        final newColumns = KanbanStateHelper.updateTaskInState(
          current.columns,
          loc.$1,
          loc.$2,
          event.taskId,
          (t) => t.copyWith(subtasks: newSubtasks),
        );
        final next = current.copyWith(columns: newColumns);
        _patchTaskCache(
          event.taskId,
          (t) => t.copyWith(
            subtasks: t.subtasks.where((s) => s.id != event.subtaskId).toList(),
          ),
        );
        emit(next);
      }
    } catch (e) {
      emit(KanbanErrorActionState(e.toString()));
    }
  }
}
