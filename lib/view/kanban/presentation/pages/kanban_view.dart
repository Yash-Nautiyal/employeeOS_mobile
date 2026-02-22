import 'dart:async';

import 'package:employeeos/core/index.dart'
    show EmptyContent, KanbanDimensions, showCustomToast;
import 'package:employeeos/view/kanban/data/index.dart'
    show KanbanRepositoryImpl;
import 'package:employeeos/view/kanban/presentation/index.dart'
    show KanbanColumnView, TaskDetailCubit;

import 'package:employeeos/view/kanban/presentation/bloc/kanban_bloc.dart';
import 'package:employeeos/view/kanban/domain/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class KanbanView extends StatefulWidget {
  const KanbanView({super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  late final KanbanRepositoryImpl _repository;
  late final GetTaskDetailUseCase _taskDetailUseCase;
  late final UploadTaskAttachmentsUseCase _uploadTaskAttachmentsUseCase;
  late final DeleteTaskAttachmentUseCase _deleteTaskAttachmentUseCase;
  late final KanbanBloc _bloc;
  late final TaskDetailCubit _taskDetailCubit;
  bool _fixedColumns = false;

  final GlobalKey _boardKey = GlobalKey();
  final ScrollController _boardScrollController = ScrollController();

  // Hover state for showing ghost preview + section headers on empty sections.
  String? _hoverColumnId;
  KanbanSection? _hoverSection;
  int? _hoverIndex;
  KanbanGroupItem? _hoverTask;

  String? _draggingTaskId;
  Timer? _autoScrollTimer;
  Offset? _lastDragGlobalOffset;

  @override
  void initState() {
    super.initState();
    _repository = KanbanRepositoryImpl();
    _taskDetailUseCase = GetTaskDetailUseCase(_repository);
    _uploadTaskAttachmentsUseCase = UploadTaskAttachmentsUseCase(_repository);
    _deleteTaskAttachmentUseCase = DeleteTaskAttachmentUseCase(_repository);
    _bloc = KanbanBloc(
      repository: _repository,
      getTaskDetailUseCase: _taskDetailUseCase,
    )..add(const KanbanLoadRequested());
    _taskDetailCubit = TaskDetailCubit(
      getTaskDetailUseCase: _taskDetailUseCase,
      uploadTaskAttachmentsUseCase: _uploadTaskAttachmentsUseCase,
      deleteTaskAttachmentUseCase: _deleteTaskAttachmentUseCase,
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _boardScrollController.dispose();
    _taskDetailCubit.close();
    _bloc.close();
    super.dispose();
  }

  void _clearHoverState() {
    _hoverColumnId = null;
    _hoverSection = null;
    _hoverIndex = null;
    _hoverTask = null;
  }

  void _maybeAutoScroll(Offset globalOffset) {
    // Store last pointer position; actual scrolling is timer-driven so it continues
    // even when the pointer is held still at the edge.
    _lastDragGlobalOffset = globalOffset;

    if (_draggingTaskId == null) return;
    _autoScrollTimer ??= Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _autoScrollTick(),
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    _lastDragGlobalOffset = null;
  }

  void _autoScrollTick() {
    if (_draggingTaskId == null) {
      _stopAutoScroll();
      return;
    }
    final globalOffset = _lastDragGlobalOffset;
    if (globalOffset == null) return;
    if (!_boardScrollController.hasClients) return;

    final ctx = _boardKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox) return;

    final local = box.globalToLocal(globalOffset);
    final width = box.size.width;

    // Wider edge zone + speed ramps up as you get closer to the edge.
    const edge = 140.0;
    const maxStep = 44.0; // px per tick (~2750px/s at 60fps)

    final maxScroll = _boardScrollController.position.maxScrollExtent;
    final cur = _boardScrollController.offset;

    double delta = 0;
    if (local.dx < edge) {
      final t = ((edge - local.dx) / edge).clamp(0.0, 1.0);
      delta = -maxStep * (0.25 + 0.75 * t);
    } else if (local.dx > width - edge) {
      final d = (local.dx - (width - edge)).clamp(0.0, edge);
      final t = (d / edge).clamp(0.0, 1.0);
      delta = maxStep * (0.25 + 0.75 * t);
    } else {
      return;
    }

    final next = (cur + delta).clamp(0.0, maxScroll);
    if (next != cur) {
      // jumpTo is more responsive than animateTo for continuous dragging
      _boardScrollController.jumpTo(next);
    }
  }

  void _moveTask({
    required DragPayload payload,
    required String toColumnId,
    required KanbanSection toSection,
    required int toIndex,
  }) {
    _bloc.add(KanbanTaskMoved(
      payload: payload,
      toColumnId: toColumnId,
      toSection: toSection,
      toIndex: toIndex,
    ));
    setState(() {
      _draggingTaskId = null;
      _clearHoverState();
      _stopAutoScroll();
    });
  }

  Future<void> _addColumnDialog() async {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add column'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Column name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: theme.textTheme.labelLarge),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.of(ctx).pop(text);
                }
              },
              child: Text('Add', style: theme.textTheme.labelLarge),
            ),
          ],
        );
      },
    );
    if (name == null || name.isEmpty) return;
    _bloc.add(KanbanColumnAdded(name));
  }

  Future<void> _renameColumn(KanbanColumn column) async {
    if (column.isArchive) return;
    final controller = TextEditingController(text: column.title);
    final theme = Theme.of(context);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Rename column'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Column name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: theme.textTheme.labelLarge),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.of(ctx).pop(text);
                }
              },
              child: Text('Save', style: theme.textTheme.labelLarge),
            ),
          ],
        );
      },
    );
    if (newName == null || newName.isEmpty) return;
    _bloc.add(KanbanColumnRenamed(column.id, newName));
  }

  void _deleteColumn(KanbanColumn column) {
    if (column.isArchive) return;
    _bloc.add(KanbanColumnDeleted(column.id));
  }

  void _clearColumn(String columnId) {
    _bloc.add(KanbanColumnCleared(columnId));
  }

  Future<void> _addTaskToColumn(String columnId) async {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Task title'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: theme.textTheme.labelLarge),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.of(ctx).pop(text);
                }
              },
              child: Text('Add', style: theme.textTheme.labelLarge),
            ),
          ],
        );
      },
    );
    if (title == null || title.isEmpty) return;

    _bloc.add(KanbanTaskAdded(
      columnId: columnId,
      taskName: title,
    ));
  }

  void _moveTaskToColumn(
    KanbanGroupItem task,
    String fromColumnId,
    KanbanSection fromSection,
    String toColumnId,
  ) {
    if (fromColumnId == toColumnId) return;
    _bloc.add(KanbanTaskMovedToColumn(
      task: task,
      fromColumnId: fromColumnId,
      fromSection: fromSection,
      toColumnId: toColumnId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bloc),
        BlocProvider.value(value: _taskDetailCubit),
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Kanban", style: theme.textTheme.displaySmall),
                const Spacer(),
                Text("Fixed column", style: theme.textTheme.bodySmall),
                Transform.scale(
                  scale: 0.65,
                  child: Switch(
                    activeTrackColor: theme.colorScheme.primary,
                    activeColor: Colors.white,
                    value: _fixedColumns,
                    onChanged: (value) => setState(() => _fixedColumns = value),
                  ),
                ),
              ],
            ),
            Expanded(
              child: BlocConsumer<KanbanBloc, KanbanState>(
                bloc: _bloc,
                listenWhen: (previous, current) => current is KanbanActionState,
                buildWhen: (previous, current) => current is! KanbanActionState,
                listener: (context, state) {
                  if (state is KanbanErrorActionState) {
                    showCustomToast(
                      context: context,
                      type: ToastificationType.error,
                      title: 'Error',
                      description: state.message,
                    );
                  } else if (state is KanbanSuccessActionState) {
                    showCustomToast(
                      context: context,
                      type: ToastificationType.success,
                      title: state.message,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is KanbanLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is KanbanError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EmptyContent(
                              icon: 'assets/icons/empty/ic-folder-empty.svg',
                              title: 'Failed to load board',
                              description: state.message),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                _bloc.add(const KanbanLoadRequested()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is! KanbanLoaded) {
                    return const SizedBox.shrink();
                  }
                  final columns = state.columns;
                  return Container(
                    key: _boardKey,
                    child: Scrollbar(
                      controller: _boardScrollController,
                      thumbVisibility: false,
                      child: ScrollConfiguration(
                        behavior:
                            const ScrollBehavior().copyWith(scrollbars: false),
                        child: ListView.separated(
                          controller: _boardScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(
                            right: KanbanDimensions.kColumnGap,
                          ),
                          itemCount: columns.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(
                              width: KanbanDimensions.kColumnGap),
                          itemBuilder: (context, index) {
                            if (index == columns.length) {
                              return _AddColumnCard(onTap: _addColumnDialog);
                            }
                            final col = columns[index];
                            return Stack(
                              children: [
                                KanbanColumnView(
                                  key: ValueKey(col.id),
                                  bloc: _bloc,
                                  theme: theme,
                                  column: col,
                                  allColumns: columns,
                                  fixed: _fixedColumns,
                                  hoverColumnId: _hoverColumnId,
                                  hoverSection: _hoverSection,
                                  hoverIndex: _hoverIndex,
                                  hoverTask: _hoverTask,
                                  draggingTaskId: _draggingTaskId,
                                  onDragMove: _maybeAutoScroll,
                                  onDragStarted: (taskId) => setState(() {
                                    _draggingTaskId = taskId;
                                    _lastDragGlobalOffset = null;
                                    _autoScrollTimer ??= Timer.periodic(
                                      const Duration(milliseconds: 16),
                                      (_) => _autoScrollTick(),
                                    );
                                  }),
                                  onDragEnded: () => setState(() {
                                    _draggingTaskId = null;
                                    _clearHoverState();
                                    _stopAutoScroll();
                                  }),
                                  onHover: (columnId, section, index, task) {
                                    setState(() {
                                      _hoverColumnId = columnId;
                                      _hoverSection = section;
                                      _hoverIndex = index;
                                      _hoverTask = task;
                                    });
                                  },
                                  onHoverExit: _clearHover,
                                  onAccept: (payload, section, index) =>
                                      _moveTask(
                                    payload: payload,
                                    toColumnId: col.id,
                                    toSection: section,
                                    toIndex: index,
                                  ),
                                  onMoveTaskToColumn: _moveTaskToColumn,
                                  onAddTask: () => _addTaskToColumn(col.id),
                                  onDeleteColumn: () => _deleteColumn(col),
                                  onClearColumn: () => _clearColumn(col.id),
                                  onRenameColumn: () => _renameColumn(col),
                                  onPriorityChanged:
                                      (section, columnId, taskId, priority) =>
                                          _bloc.add(KanbanTaskPriorityChanged(
                                              columnId: columnId,
                                              section: section,
                                              taskId: taskId,
                                              priority: priority)),
                                  onAssigneesChanged:
                                      (section, columnId, taskId, assignees) =>
                                          _bloc.add(KanbanTaskAssigneesUpdated(
                                    columnId: columnId,
                                    section: section,
                                    taskId: taskId,
                                    assignees: assignees,
                                  )),
                                ),
                                if (state.isActionLoading)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Container(
                                        color: Colors.black12,
                                        child: const Center(
                                          child: SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearHover() => setState(_clearHoverState);
}

class _AddColumnCard extends StatelessWidget {
  const _AddColumnCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KanbanDimensions.kColumnRadius),
      child: Container(
        width: KanbanDimensions.kColumnWidth,
        padding: KanbanDimensions.kColumnPadding,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(KanbanDimensions.kColumnRadius),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Add column', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
