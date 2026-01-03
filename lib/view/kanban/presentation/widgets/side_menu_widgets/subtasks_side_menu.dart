import 'package:employeeos/core/index.dart'
    show CustomTextButton, CustomTextfield;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubtasksSideMenu extends StatefulWidget {
  final Map<String, bool> initialSubtasks;
  final ValueChanged<Map<String, bool>>? onChanged;

  const SubtasksSideMenu({
    super.key,
    required this.initialSubtasks,
    this.onChanged,
  });

  @override
  State<SubtasksSideMenu> createState() => _SubtasksSideMenuState();
}

class _SubtasksSideMenuState extends State<SubtasksSideMenu> {
  late Map<String, bool> _subtasks;
  double _progressFrom = 0;
  double _progressTo = 0;

  int get _completedSubtasks =>
      _subtasks.values.where((isDone) => isDone).length;

  int get _totalSubtasks => _subtasks.length;

  double get _subtaskProgress =>
      _totalSubtasks == 0 ? 0 : _completedSubtasks / _totalSubtasks;

  @override
  void initState() {
    super.initState();
    _subtasks = Map<String, bool>.from(widget.initialSubtasks);
    final initial = _subtaskProgress;
    _progressFrom = initial;
    _progressTo = initial;
  }

  void _emitChange() {
    widget.onChanged?.call(Map<String, bool>.from(_subtasks));
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
                  final entry = _subtasks.entries.elementAt(index);
                  return Row(
                    children: [
                      Checkbox(
                        value: entry.value,
                        onChanged: (checked) {
                          setState(() {
                            _subtasks[entry.key] = checked ?? false;
                            _bumpProgress();
                          });
                          _emitChange();
                        },
                      ),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration:
                                entry.value ? TextDecoration.lineThrough : null,
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
                        onPressed: () =>
                            _openSubtaskDialog(existingTitle: entry.key),
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
                            _subtasks.remove(entry.key);
                            _bumpProgress();
                          });
                          _emitChange();
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
          onClick: () => _openSubtaskDialog(),
        ),
      ],
    );
  }

  Future<void> _openSubtaskDialog({String? existingTitle}) async {
    final theme = Theme.of(context);
    final controller = TextEditingController(text: existingTitle ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existingTitle == null ? 'Add Subtask' : 'Edit Subtask',
            style: theme.textTheme.displaySmall,
          ),
          content: CustomTextfield(
            controller: controller,
            keyboardType: TextInputType.text,
            theme: theme,
            onchange: (value) {},
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
                setState(() {
                  if (existingTitle != null) {
                    final wasDone = _subtasks[existingTitle] ?? false;
                    _subtasks.remove(existingTitle);
                    _subtasks[title] = wasDone;
                  } else {
                    _subtasks[title] = false;
                  }
                  _bumpProgress();
                });
                _emitChange();
                Navigator.of(context).pop();
              },
              child: Text(
                existingTitle == null ? 'Add' : 'Save',
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
