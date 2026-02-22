import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:employeeos/view/kanban/domain/index.dart';

part 'kanban_event.dart';
part 'kanban_state.dart';
part 'kanban_bloc_load_detail_mixin.dart';
part 'kanban_bloc_columns_mixin.dart';
part 'kanban_bloc_tasks_mixin.dart';
part 'kanban_bloc_subtasks_mixin.dart';
part 'kanban_bloc_cache_mixin.dart';

class KanbanBloc extends Bloc<KanbanEvent, KanbanState> {
  KanbanBloc({
    required KanbanRepository repository,
    LoadBoardUseCase? loadBoardUseCase,
    GetTaskDetailUseCase? getTaskDetailUseCase,
    MoveTaskUseCase? moveTaskUseCase,
    AddSubtaskUseCase? addSubtaskUseCase,
    CreateColumnUseCase? createColumnUseCase,
    RenameColumnUseCase? renameColumnUseCase,
    DeleteColumnUseCase? deleteColumnUseCase,
    ClearColumnUseCase? clearColumnUseCase,
    CreateTaskUseCase? createTaskUseCase,
    DeleteTaskUseCase? deleteTaskUseCase,
    UpdateTaskPriorityUseCase? updateTaskPriorityUseCase,
    UpdateTaskDescriptionUseCase? updateTaskDescriptionUseCase,
    UpdateTaskDueDateUseCase? updateTaskDueDateUseCase,
    FetchAssigneeUsersUseCase? fetchAssigneeUsersUseCase,
    SyncTaskAssigneesUseCase? syncTaskAssigneesUseCase,
    ToggleSubtaskUseCase? toggleSubtaskUseCase,
    RenameSubtaskUseCase? renameSubtaskUseCase,
    DeleteSubtaskUseCase? deleteSubtaskUseCase,
  })  : _loadBoardUseCase = loadBoardUseCase ?? LoadBoardUseCase(repository),
        _getTaskDetailUseCase =
            getTaskDetailUseCase ?? GetTaskDetailUseCase(repository),
        _moveTaskUseCase = moveTaskUseCase ?? MoveTaskUseCase(repository),
        _addSubtaskUseCase = addSubtaskUseCase ?? AddSubtaskUseCase(repository),
        _createColumnUseCase =
            createColumnUseCase ?? CreateColumnUseCase(repository),
        _renameColumnUseCase =
            renameColumnUseCase ?? RenameColumnUseCase(repository),
        _deleteColumnUseCase =
            deleteColumnUseCase ?? DeleteColumnUseCase(repository),
        _clearColumnUseCase =
            clearColumnUseCase ?? ClearColumnUseCase(repository),
        _createTaskUseCase = createTaskUseCase ?? CreateTaskUseCase(repository),
        _deleteTaskUseCase = deleteTaskUseCase ?? DeleteTaskUseCase(repository),
        _updateTaskPriorityUseCase =
            updateTaskPriorityUseCase ?? UpdateTaskPriorityUseCase(repository),
        _updateTaskDescriptionUseCase = updateTaskDescriptionUseCase ??
            UpdateTaskDescriptionUseCase(repository),
        _updateTaskDueDateUseCase =
            updateTaskDueDateUseCase ?? UpdateTaskDueDateUseCase(repository),
        _fetchAssigneeUsersUseCase =
            fetchAssigneeUsersUseCase ?? FetchAssigneeUsersUseCase(repository),
        _syncTaskAssigneesUseCase =
            syncTaskAssigneesUseCase ?? SyncTaskAssigneesUseCase(repository),
        _toggleSubtaskUseCase =
            toggleSubtaskUseCase ?? ToggleSubtaskUseCase(repository),
        _renameSubtaskUseCase =
            renameSubtaskUseCase ?? RenameSubtaskUseCase(repository),
        _deleteSubtaskUseCase =
            deleteSubtaskUseCase ?? DeleteSubtaskUseCase(repository),
        super(KanbanInitial()) {
    on<KanbanLoadRequested>(_onLoad);
    on<KanbanUsersForAssigneesRequested>(_onUsersForAssigneesRequested);
    on<KanbanColumnAdded>(_onAddColumn);
    on<KanbanColumnRenamed>(_onRenameColumn);
    on<KanbanColumnDeleted>(_onDeleteColumn);
    on<KanbanColumnCleared>(_onClearColumn);
    on<KanbanTaskAdded>(_onAddTask);
    on<KanbanTaskDeleted>(_onDeleteTask);
    on<KanbanTaskMoved>(_onMoveTask);
    on<KanbanTaskMovedToColumn>(_onMoveTaskToColumn);
    on<KanbanTaskPriorityChanged>(_onChangePriority);
    on<KanbanTaskDescriptionUpdated>(_onDescriptionUpdated);
    on<KanbanTaskDueDateUpdated>(_onDueDateUpdated);
    on<KanbanTaskAssigneesUpdated>(_onUpdateAssignees);
    on<KanbanSubtaskAdded>(_onSubtaskAdded);
    on<KanbanSubtaskToggled>(_onSubtaskToggled);
    on<KanbanSubtaskRenamed>(_onSubtaskRenamed);
    on<KanbanSubtaskDeleted>(_onSubtaskDeleted);
  }

  final LoadBoardUseCase _loadBoardUseCase;
  final GetTaskDetailUseCase _getTaskDetailUseCase;
  final MoveTaskUseCase _moveTaskUseCase;
  final AddSubtaskUseCase _addSubtaskUseCase;
  final CreateColumnUseCase _createColumnUseCase;
  final RenameColumnUseCase _renameColumnUseCase;
  final DeleteColumnUseCase _deleteColumnUseCase;
  final ClearColumnUseCase _clearColumnUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final UpdateTaskPriorityUseCase _updateTaskPriorityUseCase;
  final UpdateTaskDescriptionUseCase _updateTaskDescriptionUseCase;
  final UpdateTaskDueDateUseCase _updateTaskDueDateUseCase;
  final FetchAssigneeUsersUseCase _fetchAssigneeUsersUseCase;
  final SyncTaskAssigneesUseCase _syncTaskAssigneesUseCase;
  final ToggleSubtaskUseCase _toggleSubtaskUseCase;
  final RenameSubtaskUseCase _renameSubtaskUseCase;
  final DeleteSubtaskUseCase _deleteSubtaskUseCase;
  final Map<String, int> _latestMoveRequestByTask = {};
  int _moveRequestCounter = 0;

  KanbanLoaded get _loaded => state is KanbanLoaded
      ? state as KanbanLoaded
      : throw StateError('Expected KanbanLoaded');
}
