import 'package:employeeos/view/kanban/domain/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employeeos/core/index.dart'
    show KanbanDimensions, showRightSideTaskDetails;
import 'package:employeeos/view/kanban/presentation/index.dart'
    show
        ContactDialog,
        KanbanSideMenu,
        KanbanTaskCard,
        TaskDetailCubit,
        TaskDetailState;
import 'package:employeeos/view/kanban/presentation/bloc/kanban_bloc.dart';

class KanbanDraggableTask extends StatelessWidget {
  const KanbanDraggableTask({
    super.key,
    required this.bloc,
    required this.theme,
    required this.task,
    required this.fromColumnId,
    required this.fromSection,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.fromColumn,
    required this.allColumns,
    required this.onMoveToColumn,
    required this.onPriorityChanged,
    required this.onAssigneesChanged,
  });

  final KanbanBloc bloc;
  final ThemeData theme;
  final KanbanGroupItem task;
  final String fromColumnId;
  final KanbanSection fromSection;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final KanbanColumn fromColumn;
  final List<KanbanColumn> allColumns;
  final void Function(
    KanbanGroupItem task,
    String fromColumnId,
    KanbanSection fromSection,
    String toColumnId,
  ) onMoveToColumn;
  final void Function(String priority) onPriorityChanged;
  final void Function(List<KanbanAssignee> assignees) onAssigneesChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KanbanDimensions.kItemGap),
      child: LongPressDraggable<DragPayload>(
        data: DragPayload(
            task: task, fromColumn: fromColumnId, fromSection: fromSection),
        dragAnchorStrategy: pointerDragAnchorStrategy,
        hapticFeedbackOnStart: true,
        onDragStarted: onDragStarted,
        onDragEnd: (_) => onDragEnded(),
        onDragCompleted: onDragEnded,
        onDraggableCanceled: (_, __) => onDragEnded(),
        feedback: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: KanbanDimensions.kColumnWidth),
            child: Opacity(
              opacity: 0.9,
              child: KanbanTaskCard(theme: theme, task: task),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.2,
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: KanbanTaskCard(theme: theme, task: task),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            final taskDetailCubit = context.read<TaskDetailCubit>();
            taskDetailCubit.openTask(task.id);
            var currentColumnId = fromColumnId;
            showRightSideTaskDetails(
              context,
              BlocBuilder<TaskDetailCubit, TaskDetailState>(
                bloc: taskDetailCubit,
                buildWhen: (prev, curr) =>
                    prev.task != curr.task || prev.isLoading != curr.isLoading,
                builder: (context, state) {
                  final selected = state.task;
                  final hasRequestedTask = selected?.id == task.id;
                  final displayTask = hasRequestedTask ? selected! : task;
                  KanbanColumn group = fromColumn;
                  for (final c in allColumns) {
                    if (c.id == displayTask.columnId) {
                      group = c;
                      break;
                    }
                  }
                  return KanbanSideMenu(
                    task: displayTask,
                    group: group,
                    allColumns: allColumns,
                    onMoveColumn: (toColumnId) {
                      if (toColumnId == currentColumnId) return;
                      onMoveToColumn(
                          task, currentColumnId, fromSection, toColumnId);
                      currentColumnId = toColumnId;
                    },
                    onPriorityChanged: onPriorityChanged,
                    onDueDateChanged:
                        (dueStart, dueEnd, columnId, section, taskId) =>
                            bloc.add(KanbanTaskDueDateUpdated(
                      columnId: columnId,
                      section: section,
                      taskId: taskId,
                      dueStart: dueStart,
                      dueEnd: dueEnd,
                    )),
                    onAssigneesChanged: onAssigneesChanged,
                    onSubtaskAdded: (name) => bloc
                        .add(KanbanSubtaskAdded(taskId: task.id, name: name)),
                    onSubtaskToggled: (subtaskId, completed) => bloc.add(
                        KanbanSubtaskToggled(
                            taskId: task.id,
                            subtaskId: subtaskId,
                            completed: completed)),
                    onSubtaskRenamed: (subtaskId, name) => bloc.add(
                        KanbanSubtaskRenamed(
                            taskId: task.id, subtaskId: subtaskId, name: name)),
                    onSubtaskDeleted: (subtaskId) => bloc.add(
                        KanbanSubtaskDeleted(
                            taskId: task.id, subtaskId: subtaskId)),
                    onSaveDescription:
                        (description, columnId, section, taskId) => bloc.add(
                            KanbanTaskDescriptionUpdated(
                                columnId: columnId,
                                section: section,
                                taskId: taskId,
                                description: description)),
                    onOpenAssigneePicker:
                        (pickerContext, currentAssignees, onDone) {
                      bloc.add(const KanbanUsersForAssigneesRequested());
                      showDialog<void>(
                        context: pickerContext,
                        builder: (ctx) => BlocProvider.value(
                          value: bloc,
                          child: BlocBuilder<KanbanBloc, KanbanState>(
                            bloc: bloc,
                            buildWhen: (p, c) =>
                                c is KanbanLoaded &&
                                (p is! KanbanLoaded ||
                                    (p).usersForAssignees !=
                                        (c).usersForAssignees ||
                                    (p).isLoadingUsersForAssignees !=
                                        (c).isLoadingUsersForAssignees),
                            builder: (ctx, s) {
                              if (s is! KanbanLoaded) {
                                return const Center(
                                    child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: CircularProgressIndicator(),
                                ));
                              }
                              if (s.isLoadingUsersForAssignees &&
                                  s.usersForAssignees == null) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final users = s.usersForAssignees ?? [];
                              return _AssigneePickerDialog(
                                users: users,
                                currentAssignees: currentAssignees,
                                onDone: onDone,
                                onClose: () => Navigator.of(ctx).pop(),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    onAttachmentUpload: (taskId, files) {
                      return taskDetailCubit.uploadAttachments(
                        taskId: taskId,
                        files: files,
                      );
                    },
                    onAttachmentDelete: (taskId, attachmentId) {
                      return taskDetailCubit.deleteAttachment(
                        taskId: taskId,
                        attachmentId: attachmentId,
                      );
                    },
                  );
                },
              ),
            ).then((_) => taskDetailCubit.clear());
          },
          child: KanbanTaskCard(theme: theme, task: task),
        ),
      ),
    );
  }
}

/// Internal dialog used by parent to show assignee picker; keeps bloc usage in parent.
class _AssigneePickerDialog extends StatefulWidget {
  const _AssigneePickerDialog({
    required this.users,
    required this.currentAssignees,
    required this.onDone,
    required this.onClose,
  });

  final List<KanbanAssignee> users;
  final List<KanbanAssignee> currentAssignees;
  final void Function(List<KanbanAssignee>) onDone;
  final VoidCallback onClose;

  @override
  State<_AssigneePickerDialog> createState() => _AssigneePickerDialogState();
}

class _AssigneePickerDialogState extends State<_AssigneePickerDialog> {
  late Set<String> _selected;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentAssignees.map((a) => a.userId).toSet();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emitDone() {
    final chosen = widget.users
        .where((u) => _selected.contains(u.userId))
        .map((u) => u.copyWith())
        .toList();
    widget.onDone(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _controller.text.toLowerCase();
    final filtered = widget.users.where((a) {
      return a.name.toLowerCase().contains(query) ||
          a.email.toLowerCase().contains(query);
    }).toList();
    return ContactDialog(
      theme: theme,
      ctx: context,
      selected: _selected,
      filtered: filtered,
      kSampleAssignees: widget.users,
      controller: _controller,
      onSearch: () => setState(() {}),
      onAssign: (user) {
        setState(() => _selected.add(user.userId));
        _emitDone();
      },
      onTap: (isSelected, user) {
        setState(() {
          if (isSelected) {
            _selected.remove(user.userId);
          } else {
            _selected.add(user.userId);
          }
        });
        _emitDone();
      },
    );
  }
}
