import 'package:employeeos/core/index.dart'
    show CustomTextButton, CustomTextfield;
import 'package:employeeos/view/kanban/domain/modals/kanban_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubtasksSideMenu extends StatefulWidget {
  final String taskId;
  final List<KanbanSubtask> initialSubtasks;
  final void Function(String name) onSubtaskAdded;
  final void Function(String subtaskId, bool completed) onSubtaskToggled;
  final void Function(String subtaskId, String name) onSubtaskRenamed;
  final void Function(String subtaskId) onSubtaskDeleted;

  const SubtasksSideMenu({
    super.key,
    required this.taskId,
    required this.initialSubtasks,
    required this.onSubtaskAdded,
    required this.onSubtaskToggled,
    required this.onSubtaskRenamed,
    required this.onSubtaskDeleted,
  });

  @override
  State<SubtasksSideMenu> createState() => _SubtasksSideMenuState();
}

class _SubtasksSideMenuState extends State<SubtasksSideMenu> {
  late List<KanbanSubtask> _subtasks;
  double _progressFrom = 0;
  double _progressTo = 0;

  int get _completedSubtasks => _subtasks.where((s) => s.completed).length;

  int get _totalSubtasks => _subtasks.length;

  double get _subtaskProgress =>
      _totalSubtasks == 0 ? 0 : _completedSubtasks / _totalSubtasks;

  @override
  void initState() {
    super.initState();
    _subtasks = List<KanbanSubtask>.from(widget.initialSubtasks);
    final initial = _subtaskProgress;
    _progressFrom = initial;
    _progressTo = initial;
  }

  @override
  void didUpdateWidget(covariant SubtasksSideMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSubtasks.length != widget.initialSubtasks.length ||
        oldWidget.taskId != widget.taskId) {
      _subtasks = List<KanbanSubtask>.from(widget.initialSubtasks);
      _progressFrom = _subtaskProgress;
      _progressTo = _subtaskProgress;
    }
  }

  void _bumpProgress() {
    _progressFrom = _progressTo;
    _progressTo = _subtaskProgress;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_completedSubtasks of $_totalSubtasks',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(_subtaskProgress * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: _progressFrom, end: _progressTo),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: theme.dividerColor.withOpacity(0.4),
                color: theme.colorScheme.primary,
              ),
            );
          },
        ),
        _subtasks.isEmpty
            ? Text(
                'No subtasks added yet.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subtasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final subtask = _subtasks[index];
                  return Row(
                    children: [
                      Checkbox(
                        value: subtask.completed,
                        onChanged: (checked) {
                          final v = checked ?? false;
                          setState(() {
                            _subtasks = List.from(_subtasks)
                              ..[index] = subtask.copyWith(completed: v);
                            _bumpProgress();
                          });
                          widget.onSubtaskToggled(subtask.id, v);
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
                          color: theme.colorScheme.onSurface,
                          width: 20,
                        ),
                        onPressed: () => _openSubtaskDialog(
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
                          setState(() {
                            _subtasks = _subtasks
                                .where((s) => s.id != subtask.id)
                                .toList();
                            _bumpProgress();
                          });
                          widget.onSubtaskDeleted(subtask.id);
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
                color: theme.colorScheme.onSurface,
                width: 18,
              ),
              const SizedBox(width: 7),
              Text(
                'Add Subtask',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          onClick: () => _openSubtaskDialog(),
        ),
      ],
    );
  }

  Future<void> _openSubtaskDialog({
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
                  widget.onSubtaskRenamed(existingSubtaskId, title);
                  setState(() {
                    final i =
                        _subtasks.indexWhere((s) => s.id == existingSubtaskId);
                    if (i != -1) {
                      _subtasks = List.from(_subtasks)
                        ..[i] = _subtasks[i].copyWith(name: title);
                    }
                  });
                } else {
                  widget.onSubtaskAdded(title);
                  setState(() {
                    _bumpProgress();
                  });
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
