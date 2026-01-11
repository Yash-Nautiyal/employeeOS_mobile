import 'package:bloc/bloc.dart';
import 'package:employeeos/view/kanban/domain/repositories/kanban_repository.dart';
import 'kanban_event.dart';
import 'kanban_state.dart';

class KanbanBloc extends Bloc<KanbanEvent, KanbanState> {
  KanbanBloc({required KanbanRepository repository})
      : _repository = repository,
        super(KanbanState.initial()) {
    on<KanbanLoadRequested>(_onLoad);
    on<KanbanColumnAdded>(_onAddColumn);
    on<KanbanColumnRenamed>(_onRenameColumn);
    on<KanbanColumnDeleted>(_onDeleteColumn);
    on<KanbanColumnCleared>(_onClearColumn);
    on<KanbanTaskAdded>(_onAddTask);
    on<KanbanTaskMoved>(_onMoveTask);
    on<KanbanTaskMovedToColumn>(_onMoveTaskToColumn);
    on<KanbanTaskPriorityChanged>(_onChangePriority);
    on<KanbanTaskAssigneesUpdated>(_onUpdateAssignees);
  }

  final KanbanRepository _repository;

  void _onLoad(KanbanLoadRequested event, Emitter<KanbanState> emit) {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = _repository.loadBoard();
      emit(state.copyWith(isLoading: false, columns: data, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onAddColumn(KanbanColumnAdded event, Emitter<KanbanState> emit) {
    emit(state.copyWith(columns: _repository.addColumn(event.title)));
  }

  void _onRenameColumn(KanbanColumnRenamed event, Emitter<KanbanState> emit) {
    emit(state.copyWith(
        columns: _repository.renameColumn(event.columnId, event.newTitle)));
  }

  void _onDeleteColumn(KanbanColumnDeleted event, Emitter<KanbanState> emit) {
    emit(state.copyWith(columns: _repository.deleteColumn(event.columnId)));
  }

  void _onClearColumn(KanbanColumnCleared event, Emitter<KanbanState> emit) {
    emit(state.copyWith(columns: _repository.clearColumn(event.columnId)));
  }

  void _onAddTask(KanbanTaskAdded event, Emitter<KanbanState> emit) {
    emit(state.copyWith(
      columns: _repository.addTask(
        columnId: event.columnId,
        task: event.task,
        section: event.section,
      ),
    ));
  }

  void _onMoveTask(KanbanTaskMoved event, Emitter<KanbanState> emit) {
    emit(state.copyWith(
      columns: _repository.moveTask(
        payload: event.payload,
        toColumnId: event.toColumnId,
        toSection: event.toSection,
        toIndex: event.toIndex,
      ),
    ));
  }

  void _onMoveTaskToColumn(
      KanbanTaskMovedToColumn event, Emitter<KanbanState> emit) {
    emit(state.copyWith(
      columns: _repository.moveTaskToColumn(
        task: event.task,
        fromColumnId: event.fromColumnId,
        fromSection: event.fromSection,
        toColumnId: event.toColumnId,
      ),
    ));
  }

  void _onChangePriority(
      KanbanTaskPriorityChanged event, Emitter<KanbanState> emit) {
    emit(state.copyWith(
      columns: _repository.updatePriority(
        columnId: event.columnId,
        section: event.section,
        taskId: event.taskId,
        priority: event.priority,
      ),
    ));
  }

  void _onUpdateAssignees(
      KanbanTaskAssigneesUpdated event, Emitter<KanbanState> emit) {
    emit(state.copyWith(
      columns: _repository.updateAssignees(
        columnId: event.columnId,
        section: event.section,
        taskId: event.taskId,
        assignees: event.assignees,
      ),
    ));
  }
}
