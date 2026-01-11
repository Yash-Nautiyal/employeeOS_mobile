import 'package:employeeos/core/index.dart'
    show CustomDropdown, CustomToggleButton;
import 'package:employeeos/view/kanban/index.dart'
    show KanbanColumn, KanbanGroupItem, KanbanAssignee, kSampleAssignees;
import 'package:employeeos/view/kanban/presentation/widgets/side_menu_widgets/contact_dialog.dart';
import 'package:employeeos/view/kanban/presentation/widgets/side_menu_widgets/overview_side_menu.dart';
import 'package:employeeos/view/kanban/presentation/widgets/side_menu_widgets/subtasks_side_menu.dart';
import 'package:flutter/material.dart';

class KanbanSideMenu extends StatefulWidget {
  final KanbanGroupItem task;
  final KanbanColumn group;
  final List<KanbanColumn> allColumns;
  final void Function(String toColumnId) onMoveColumn;
  final void Function(String priority) onPriorityChanged;
  final void Function(List<KanbanAssignee> assignees) onAssigneesChanged;

  const KanbanSideMenu(
      {super.key,
      required this.task,
      required this.group,
      required this.allColumns,
      required this.onMoveColumn,
      required this.onPriorityChanged,
      required this.onAssigneesChanged});

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
  late List<KanbanAssignee> _assignees;

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
    _assignees = widget.task.assignees.map((a) => a.copyWith()).toList();
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
                      widget.onPriorityChanged(value);
                    },
                    onDescriptionChange: (value) {
                      setState(() {
                        _descriptionController.text = value;
                      });
                    },
                    onAttachmentChange: (value) {},
                    currentPriority: _priority,
                    assignees: _assignees,
                    onAddAssignees: _openAssigneePicker,
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

  Future<void> _openAssigneePicker() async {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    final selected = _assignees.map((a) => a.email).toSet();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final query = controller.text.toLowerCase();
            final filtered = kSampleAssignees.where((a) {
              return a.name.toLowerCase().contains(query) ||
                  a.email.toLowerCase().contains(query);
            }).toList();

            void updateAssignees() {
              final chosen = kSampleAssignees
                  .where((u) => selected.contains(u.email))
                  .map((u) => u.copyWith())
                  .toList();
              setState(() {
                _assignees = chosen;
              });
              widget.onAssigneesChanged(chosen);
            }

            return ContactDialog(
              theme: theme,
              ctx: ctx,
              selected: selected,
              filtered: filtered,
              kSampleAssignees: kSampleAssignees,
              controller: controller,
              onSearch: () => setDialogState(() {}),
              onAssign: (user) {
                setDialogState(() {
                  selected.add(user.email);
                });
                updateAssignees();
              },
              onTap: (isSelected, user) {
                setDialogState(() {
                  if (isSelected) {
                    selected.remove(user.email);
                  } else {
                    selected.add(user.email);
                  }
                });
                updateAssignees();
              },
            );
          },
        );
      },
    );
  }
}
