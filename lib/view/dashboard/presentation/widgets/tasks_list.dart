import 'package:employeeos/core/common/divider/custom_divider.dart';
import 'package:employeeos/core/common/empty/empty_content.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class TasksList extends StatefulWidget {
  final ThemeData theme;
  final double maxHeight;
  const TasksList({super.key, required this.theme, required this.maxHeight});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  final List<Map<String, dynamic>> _tasks = [
    {"title": "Complete the report", "isCompleted": false, "status": "overdue"},
    {"title": "Team meeting at 3 PM", "isCompleted": false, "status": ""},
    {
      "title": "Reply to client emails",
      "isCompleted": false,
      "status": "overdue"
    },
    {
      "title": "Prepare presentation slides",
      "isCompleted": false,
      "status": "overdue"
    },
    {
      "title": "Update project timeline",
      "isCompleted": false,
      "status": "overdue"
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: widget.theme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Scrollbar(
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(25),
          constraints: BoxConstraints(maxHeight: widget.maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Tasks",
                style: widget.theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 7, bottom: 15),
                child: Text(
                  "${_tasks.length} Pending Tasks",
                  style: widget.theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              _tasks.isNotEmpty
                  ? Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Column(
                            children: [
                              Dismissible(
                                key: ValueKey(task["title"]),
                                direction: DismissDirection.startToEnd,
                                onDismissed: (direction) {
                                  setState(() {
                                    _tasks.removeAt(index);
                                  });
                                },
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color: AppPallete.primaryMain,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: const Icon(
                                    Icons.check,
                                    color: AppPallete.white,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: widget
                                        .theme.colorScheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  height: 85,
                                  child: Row(
                                    children: [
                                      Checkbox.adaptive(
                                        value: task["isCompleted"],
                                        onChanged: (value) {
                                          setState(() {
                                            task["isCompleted"] = value!;
                                          });
                                          if (value!) {
                                            // Trigger dismissal animation
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 500), () {
                                              setState(() {
                                                _tasks.removeAt(index);
                                              });
                                            });
                                          }
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          task["title"],
                                          style: widget
                                              .theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            decoration: task["isCompleted"]
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: 6,
                                        backgroundColor:
                                            task['status'] == 'overdue'
                                                ? AppPallete.errorMain
                                                : AppPallete.successMain,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              if (index < _tasks.length - 1)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0, vertical: 10),
                                  child: CustomDivider(
                                    color: widget.theme.disabledColor,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    )
                  : const EmptyContent(
                      icon: 'assets/icons/empty/ic-content.svg',
                      title: 'No Pending Tasks',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
