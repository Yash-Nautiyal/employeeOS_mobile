part of 'kanban_bloc.dart';

extension KanbanColumnHandlers on KanbanBloc {
  Future<void> _onAddColumn(
      KanbanColumnAdded event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    if (event.title.trim().isEmpty) return;
    emit(current.copyWith(isActionLoading: true));
    try {
      final res = await _createColumnUseCase(event.title.trim());
      final id = res['id'] as String? ?? res['id'].toString();
      final position = res['position'] as int? ?? current.columns.length;
      final newColumn = KanbanColumn(
        id: id,
        title: event.title.trim(),
        position: position,
        createdByMe: const [],
        assignedToMe: const [],
      );
      final newColumns = List<KanbanColumn>.from(current.columns)
        ..add(newColumn);
      newColumns.sort((a, b) => a.position.compareTo(b.position));
      emit(current.copyWith(columns: newColumns, isActionLoading: false));
    } catch (e) {
      emit(KanbanErrorActionState('Failed to add column'));
      emit(current.copyWith(isActionLoading: false));
    }
  }

  Future<void> _onRenameColumn(
      KanbanColumnRenamed event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    final col = KanbanStateHelper.findColumn(current.columns, event.columnId);
    if (col == null || col.isArchive) return;
    emit(current.copyWith(isActionLoading: true));
    try {
      await _renameColumnUseCase(
        columnId: event.columnId,
        newTitle: event.newTitle,
      );
      final newColumns = current.columns.map((c) {
        if (c.id != event.columnId) return c;
        return KanbanColumn(
            id: c.id,
            title: event.newTitle,
            position: c.position,
            createdByMe: c.createdByMe,
            assignedToMe: c.assignedToMe);
      }).toList();
      emit(current.copyWith(columns: newColumns, isActionLoading: false));
    } catch (e) {
      emit(KanbanErrorActionState('Failed to rename column'));
      emit(current.copyWith(isActionLoading: false));
    }
  }

  Future<void> _onDeleteColumn(
      KanbanColumnDeleted event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    final col = KanbanStateHelper.findColumn(current.columns, event.columnId);
    if (col == null || col.isArchive) return;
    emit(current.copyWith(isActionLoading: true));
    try {
      await _deleteColumnUseCase(event.columnId);
      final newColumns =
          current.columns.where((c) => c.id != event.columnId).toList();
      emit(current.copyWith(columns: newColumns, isActionLoading: false));
    } catch (e) {
      emit(KanbanErrorActionState('Failed to delete column'));
      emit(current.copyWith(isActionLoading: false));
    }
  }

  Future<void> _onClearColumn(
      KanbanColumnCleared event, Emitter<KanbanState> emit) async {
    if (state is! KanbanLoaded) return;
    final current = _loaded;
    if (KanbanStateHelper.findColumn(current.columns, event.columnId) == null) {
      return;
    }
    emit(current.copyWith(isActionLoading: true));
    try {
      await _clearColumnUseCase(event.columnId);
      final newColumns = current.columns.map((c) {
        if (c.id != event.columnId) return c;
        return KanbanColumn(
            id: c.id,
            title: c.title,
            position: c.position,
            createdByMe: const [],
            assignedToMe: c.assignedToMe);
      }).toList();
      emit(current.copyWith(columns: newColumns, isActionLoading: false));
    } catch (e) {
      emit(KanbanErrorActionState('Failed to clear column'));
      emit(current.copyWith(isActionLoading: false));
    }
  }
}
