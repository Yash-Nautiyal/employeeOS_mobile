import 'package:employeeos/core/index.dart'
    show CustomDropdown, CustomToggleButton;
import 'package:employeeos/view/kanban/index.dart'
    show KanbanColumn, KanbanGroupItem;
import 'package:employeeos/view/kanban/presentation/widgets/side_menu_widgets/overview_side_menu.dart';
import 'package:employeeos/view/kanban/presentation/widgets/side_menu_widgets/subtasks_side_menu.dart';
import 'package:flutter/material.dart';

class KanbanSideMenu extends StatefulWidget {
  final KanbanGroupItem task;
  final KanbanColumn group;
  final List<KanbanColumn> allColumns;
  final void Function(String toColumnId) onMoveColumn;

  const KanbanSideMenu(
      {super.key,
      required this.task,
      required this.group,
      required this.allColumns,
      required this.onMoveColumn});

  @override
  _KanbanSideMenuState createState() => _KanbanSideMenuState();
}

class _KanbanSideMenuState extends State<KanbanSideMenu> {
  late String _priority;
  late String _group;
  late TextEditingController _descriptionController;
  late List<String> _columnIds;
  late Map<String, String> _columnLabels;
  late Map<String, bool> _subtasks;

  bool showOverView = true;

  @override
  void initState() {
    super.initState();
    _group = widget.group.id;
    _priority = widget.task.priority;
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _columnIds = widget.allColumns.map((c) => c.id).toList();
    _columnLabels = {
      for (final c in widget.allColumns) c.id: c.title,
    };
    _subtasks = Map<String, bool>.from(widget.task.subtasks);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with column dropdown and close button.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0)
                .copyWith(top: MediaQuery.of(context).padding.top + 10),
            child: Row(
              children: [
                IntrinsicWidth(
                  child: CustomDropdown(
                    theme: theme,
                    onChange: (value) {
                      if (value == null || value == _group) return;
                      setState(() {
                        _group = value;
                      });
                      widget.onMoveColumn(value);
                    },
                    label: '',
                    value: _group,
                    items: _columnIds.map((id) {
                      return DropdownMenuItem(
                        value: id,
                        child: Text(
                          _columnLabels[id] ?? id,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          CustomToggleButton(
            values: const ["Overview", "Subtasks"],
            theme: theme,
            initialIndex: showOverView ? 0 : 1,
            onToggle: (value) {
              setState(() {
                showOverView = value == 0;
              });
            },
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0)
                .copyWith(bottom: 10),
            child: showOverView
                ? OverviewSideMenu(
                    task: widget.task,
                    theme: theme,
                    descriptionController: _descriptionController,
                    onPriorityChange: (value) {
                      setState(() {
                        _priority = value;
                      });
                    },
                    onDescriptionChange: (value) {
                      setState(() {
                        _descriptionController.text = value;
                      });
                    },
                    onAttachmentChange: (value) {},
                    currentPriority: _priority,
                  )
                : SubtasksSideMenu(
                    initialSubtasks: _subtasks,
                    onChanged: (value) {
                      setState(() {
                        _subtasks = value;
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
