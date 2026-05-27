import 'package:employeeos/core/index.dart'
    show CustomTextButton, CustomTextfield;
import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:employeeos/view/kanban/presentation/bloc/kanban_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubtasksSideMenu extends StatelessWidget {
  final String taskId;
  final void Function(String name) onSubtaskAdded;
  final void Function(String subtaskId, bool completed) onSubtaskToggled;
  final void Function(String subtaskId, String name) onSubtaskRenamed;
  final void Function(String subtaskId) onSubtaskDeleted;

  const SubtasksSideMenu({
    super.key,
    required this.taskId,
    required this.onSubtaskAdded,
    required this.onSubtaskToggled,
    required this.onSubtaskRenamed,
    required this.onSubtaskDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<KanbanBloc, KanbanState>(
      builder: (context, state) {
        if (state is! KanbanLoaded) {
          return const SizedBox.shrink();
        }

        final isActionLoading = state.isActionLoading;

        // Find subtasks for the given taskId
        List<KanbanSubtask> getSubtasksForTask(
            List<KanbanColumn> columns, String taskId) {
          for (final column in columns) {
            for (final task in [
              ...column.createdByMe,
              ...column.assignedToMe
            ]) {
              if (task.id == taskId) {
                return task.subtasks;
              }
            }
          }
          return [];
        }

        final subtasks = getSubtasksForTask(state.columns, taskId);
        final completedSubtasks = subtasks.where((s) => s.completed).length;
        final totalSubtasks = subtasks.length;
        final subtaskProgress =
            totalSubtasks == 0 ? 0 : completedSubtasks / totalSubtasks;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedSubtasks of $totalSubtasks',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(subtaskProgress * 100).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: subtaskProgress.toDouble(),
              minHeight: 6,
              backgroundColor: theme.dividerColor.withOpacity(0.4),
              color: theme.colorScheme.primary,
            ),
            subtasks.isEmpty && !isActionLoading
                ? Text(
                    'No subtasks added yet.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subtasks.length + (isActionLoading ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == subtasks.length && isActionLoading) {
                        return Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Adding subtask...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                          ],
                        );
                      }
                      final subtask = subtasks[index];
                      return Row(
                        children: [
                          Checkbox(
                            value: subtask.completed,
                            onChanged: (checked) {
                              final v = checked ?? false;
                              onSubtaskToggled(subtask.id, v);
                            },
                          ),
                          Expanded(
                            child: Text(
                              subtask.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                decoration: subtask.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit',
                            icon: SvgPicture.asset(
                              'assets/icons/common/solid/ic-solar_pen-bold.svg',
                              color: theme.colorScheme.tertiary,
                              width: 20,
                            ),
                            onPressed: () => _openSubtaskDialog(
                              context,
                              existingSubtaskId: subtask.id,
                              existingTitle: subtask.name,
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            tooltip: 'Delete',
                            icon: SvgPicture.asset(
                              'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
                              color: theme.colorScheme.error,
                              width: 20,
                            ),
                            onPressed: () {
                              onSubtaskDeleted(subtask.id);
                            },
                          ),
                        ],
                      );
                    },
                  ),
            const SizedBox(height: 10),
            CustomTextButton(
              padding: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/common/solid/ic-mingcute_add-line.svg',
                    color: theme.colorScheme.tertiary,
                    width: 18,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Add Subtask',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              onClick: () => _openSubtaskDialog(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openSubtaskDialog(
    BuildContext context, {
    String? existingSubtaskId,
    String? existingTitle,
  }) async {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: existingTitle ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existingSubtaskId == null ? 'Add Subtask' : 'Edit Subtask',
            style: theme.textTheme.displaySmall,
          ),
          content: CustomTextfield(
            controller: controller,
            keyboardType: TextInputType.text,
            theme: theme,
            onchange: (_) {},
            hintText: 'Enter subtask title',
          ),
          actions: [
            CustomTextButton(
              onClick: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge,
              ),
            ),
            CustomTextButton(
              backgroundColor: theme.primaryColor,
              onClick: () {
                final title = controller.text.trim();
                if (title.isEmpty) return;
                if (existingSubtaskId != null) {
                  onSubtaskRenamed(existingSubtaskId, title);
                } else {
                  onSubtaskAdded(title);
                }
                Navigator.of(context).pop();
              },
              child: Text(
                existingSubtaskId == null ? 'Add' : 'Save',
                style:
                    theme.textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
