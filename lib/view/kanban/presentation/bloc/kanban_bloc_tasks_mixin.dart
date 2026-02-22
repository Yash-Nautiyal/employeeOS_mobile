part of 'kanban_bloc.dart';

extension KanbanTaskHandlers on KanbanBloc {
  Future<void> _onAddTask(
      KanbanTaskAdded event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    if (event.taskName.trim().isEmpty) return;
    emit(current.copyWith(isActionLoading: true));
    try {
      final newTask = await _createTaskUseCase(
        columnId: event.columnId,
        taskName: event.taskName,
      );
      final newColumns = current.columns.map((c) {
        if (c.id != event.columnId) return c;
        final created = List<KanbanGroupItem>.from(c.createdByMe)
          ..insert(0, newTask);
        return KanbanColumn(
            id: c.id,
            title: c.title,
            position: c.position,
            createdByMe: created,
            assignedToMe: c.assignedToMe);
      }).toList();
      emit(current.copyWith(columns: newColumns, isActionLoading: false));
    } catch (e) {
      emit(KanbanErrorActionState(e.toString()));
      emit(current.copyWith(isActionLoading: false));
    }
  }

  Future<void> _onMoveTask(
      KanbanTaskMoved event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    final fromIndex = KanbanStateHelper.indexOfTaskInSection(
      current.columns,
      event.payload.fromColumn,
      event.payload.fromSection,
      event.payload.task.id,
    );
    final requestId = ++_moveRequestCounter;
    _latestMoveRequestByTask[event.payload.task.id] = requestId;
    final optimisticColumns = KanbanStateHelper.moveTaskInState(
      current.columns,
      event.payload.task.id,
      event.payload.fromColumn,
      event.payload.fromSection,
      event.toColumnId,
      event.toSection,
      event.toIndex,
    );
    emit(current.copyWith(columns: optimisticColumns));
    try {
      final res = await _moveTaskUseCase(
        taskId: event.payload.task.id,
        targetColumnId: event.toColumnId,
      );
      final success = res['success'] as bool? ?? false;
      if (!success) {
        if (!_isLatestMoveRequest(event.payload.task.id, requestId)) return;
        final msg = res['error'] as String? ?? 'Failed to move task';
        if (state is! KanbanLoaded) return;
        final latest = _loaded;
        final rollbackColumns = KanbanStateHelper.moveTaskInState(
          latest.columns,
          event.payload.task.id,
          event.toColumnId,
          event.toSection,
          event.payload.fromColumn,
          event.payload.fromSection,
          fromIndex,
        );
        emit(KanbanErrorActionState(msg));
        emit(latest.copyWith(columns: rollbackColumns));
        return;
      }
      _patchTaskCache(
        event.payload.task.id,
        (t) {
          final destination =
              KanbanStateHelper.findColumn(_loaded.columns, event.toColumnId);
          return t.copyWith(
            columnId: event.toColumnId,
            archivedAt:
                (destination?.isArchive ?? false) ? DateTime.now() : null,
          );
        },
      );
    } catch (e) {
      if (!_isLatestMoveRequest(event.payload.task.id, requestId)) return;
      if (state is! KanbanLoaded) return;
      final latest = _loaded;
      final rollbackColumns = KanbanStateHelper.moveTaskInState(
        latest.columns,
        event.payload.task.id,
        event.toColumnId,
        event.toSection,
        event.payload.fromColumn,
        event.payload.fromSection,
        fromIndex,
      );
      emit(KanbanErrorActionState(e.toString()));
      emit(latest.copyWith(columns: rollbackColumns));
    }
  }

  Future<void> _onMoveTaskToColumn(
      KanbanTaskMovedToColumn event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    if (event.fromColumnId == event.toColumnId) return;
    final fromIndex = KanbanStateHelper.indexOfTaskInSection(
      current.columns,
      event.fromColumnId,
      event.fromSection,
      event.task.id,
    );
    final requestId = ++_moveRequestCounter;
    _latestMoveRequestByTask[event.task.id] = requestId;
    final optimisticColumns = KanbanStateHelper.moveTaskInState(
      current.columns,
      event.task.id,
      event.fromColumnId,
      event.fromSection,
      event.toColumnId,
      event.fromSection,
      null,
    );
    emit(current.copyWith(columns: optimisticColumns));
    try {
      final res = await _moveTaskUseCase(
        taskId: event.task.id,
        targetColumnId: event.toColumnId,
      );
      final success = res['success'] as bool? ?? false;
      if (!success) {
        if (!_isLatestMoveRequest(event.task.id, requestId)) return;
        final msg = res['error'] as String? ?? 'Failed to move task';
        if (state is! KanbanLoaded) return;
        final latest = _loaded;
        final rollbackColumns = KanbanStateHelper.moveTaskInState(
          latest.columns,
          event.task.id,
          event.toColumnId,
          event.fromSection,
          event.fromColumnId,
          event.fromSection,
          fromIndex,
        );
        emit(KanbanErrorActionState(msg));
        emit(latest.copyWith(columns: rollbackColumns));
        return;
      }
      _patchTaskCache(
        event.task.id,
        (t) {
          final destination =
              KanbanStateHelper.findColumn(_loaded.columns, event.toColumnId);
          return t.copyWith(
            columnId: event.toColumnId,
            archivedAt:
                (destination?.isArchive ?? false) ? DateTime.now() : null,
          );
        },
      );
    } catch (e) {
      if (!_isLatestMoveRequest(event.task.id, requestId)) return;
      if (state is! KanbanLoaded) return;
      final latest = _loaded;
      final rollbackColumns = KanbanStateHelper.moveTaskInState(
        latest.columns,
        event.task.id,
        event.toColumnId,
        event.fromSection,
        event.fromColumnId,
        event.fromSection,
        fromIndex,
      );
      emit(KanbanErrorActionState(e.toString()));
      emit(latest.copyWith(columns: rollbackColumns));
    }
  }

  Future<void> _onChangePriority(
      KanbanTaskPriorityChanged event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    emit(current.copyWith(isActionLoading: true));
    try {
      await _updateTaskPriorityUseCase(
        taskId: event.taskId,
        priority: event.priority,
      );
      final newColumns = KanbanStateHelper.updateTaskInState(
          current.columns,
          event.columnId,
          event.section,
          event.taskId,
          (t) => t.copyWith(priority: event.priority));
      final next =
          current.copyWith(columns: newColumns, isActionLoading: false);
      _patchTaskCache(
        event.taskId,
        (t) => t.copyWith(priority: event.priority),
      );
      emit(next);
    } catch (e) {
      emit(KanbanErrorActionState(e.toString()));
      emit(current.copyWith(isActionLoading: false));
    }
  }

  Future<void> _onDescriptionUpdated(
      KanbanTaskDescriptionUpdated event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    try {
      await _updateTaskDescriptionUseCase(
        taskId: event.taskId,
        description: event.description,
      );
      final newColumns = KanbanStateHelper.updateTaskInState(
          current.columns,
          event.columnId,
          event.section,
          event.taskId,
          (t) => t.copyWith(description: event.description));
      final next = current.copyWith(columns: newColumns);
      _patchTaskCache(
        event.taskId,
        (t) => t.copyWith(description: event.description),
      );
      emit(next);
    } catch (e) {
      emit(KanbanErrorActionState(e.toString()));
    }
  }

  Future<void> _onDueDateUpdated(
      KanbanTaskDueDateUpdated event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    final loc = KanbanStateHelper.findTask(
      current.columns,
      event.columnId,
      event.section,
      event.taskId,
    );
    if (loc == null) return;
    final previousTask = loc.$3;
    final optimisticColumns = KanbanStateHelper.updateTaskInState(
      current.columns,
      event.columnId,
      event.section,
      event.taskId,
      (t) => t.copyWith(
        dueStart: event.dueStart,
        dueEnd: event.dueEnd,
      ),
    );
    final optimistic = current.copyWith(columns: optimisticColumns);
    _patchTaskCache(
      event.taskId,
      (t) => t.copyWith(
        dueStart: event.dueStart,
        dueEnd: event.dueEnd,
      ),
    );
    emit(optimistic);
    try {
      await _updateTaskDueDateUseCase(
        taskId: event.taskId,
        dueStart: event.dueStart,
        dueEnd: event.dueEnd,
      );
    } catch (e) {
      if (state is! KanbanLoaded) return;
      final latest = _loaded;
      final rollbackColumns = KanbanStateHelper.updateTaskInState(
        latest.columns,
        event.columnId,
        event.section,
        event.taskId,
        (t) => t.copyWith(
          dueStart: previousTask.dueStart,
          dueEnd: previousTask.dueEnd,
        ),
      );
      _patchTaskCache(
        event.taskId,
        (t) => t.copyWith(
          dueStart: previousTask.dueStart,
          dueEnd: previousTask.dueEnd,
        ),
      );
      emit(KanbanErrorActionState(e.toString()));
      emit(latest.copyWith(columns: rollbackColumns));
    }
  }

  Future<void> _onUpdateAssignees(
      KanbanTaskAssigneesUpdated event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    final loc = KanbanStateHelper.findTask(
      current.columns,
      event.columnId,
      event.section,
      event.taskId,
    );
    if (loc == null) return;
    final currentAssignees = loc.$3.assignees;
    final newAssignees = event.assignees;
    emit(current.copyWith(isActionLoading: true));
    try {
      await _syncTaskAssigneesUseCase(
        taskId: event.taskId,
        currentAssignees: currentAssignees,
        newAssignees: newAssignees,
      );
      final newColumns = KanbanStateHelper.updateTaskInState(
          current.columns,
          event.columnId,
          event.section,
          event.taskId,
          (t) => t.copyWith(assignees: newAssignees));
      final next =
          current.copyWith(columns: newColumns, isActionLoading: false);
      _patchTaskCache(
        event.taskId,
        (t) => t.copyWith(assignees: newAssignees),
      );
      emit(next);
    } catch (e) {
      emit(KanbanErrorActionState(e.toString()));
      emit(current.copyWith(isActionLoading: false));
    }
  }
}
