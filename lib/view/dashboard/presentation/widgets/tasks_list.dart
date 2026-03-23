import 'package:employeeos/core/common/components/custom_divider.dart';
import 'package:employeeos/core/common/components/empty_content.dart';
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
    return Scrollbar(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: widget.theme.colorScheme.surfaceContainer,
          boxShadow: AppShadows.card(widget.theme.brightness),
        ),
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0).copyWith(bottom: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Tasks",
                    style: widget.theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${_tasks.length} Pending Tasks",
                    style: widget.theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            _tasks.isNotEmpty
                ? Flexible(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CustomDivider(
                          color: widget.theme.dividerColor,
                        ),
                      ),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Dismissible(
                          key: ValueKey(task["title"]),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            setState(() {
                              _tasks.removeAt(index);
                            });
                          },
                          background: Container(
                            margin: const EdgeInsets.all(16),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: AppPallete.primaryMain,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.check,
                              color: AppPallete.white,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: widget.theme.colorScheme.surfaceDim,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow:
                                  AppShadows.card(widget.theme.brightness),
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
                                          const Duration(milliseconds: 500),
                                          () {
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
                                    style: widget.theme.textTheme.bodyLarge
                                        ?.copyWith(
                                      decoration: task["isCompleted"]
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 6,
                                  backgroundColor: task['status'] == 'overdue'
                                      ? AppPallete.errorMain
                                      : AppPallete.successMain,
                                )
                              ],
                            ),
                          ),
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
    );
  }
}
