import 'package:dotted_border/dotted_border.dart';
import 'package:employeeos/core/index.dart'
    show AppPallete, CustomTextButton, CustomTextfield;
import 'package:employeeos/view/kanban/index.dart'
    show KanbanGroupItem, KanbanAssignee;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OverviewSideMenu extends StatelessWidget {
  final KanbanGroupItem task;
  final ThemeData theme;
  final TextEditingController descriptionController;
  final Function(String) onPriorityChange;
  final Function(String) onDescriptionChange;
  final Function(String) onAttachmentChange;
  final String currentPriority;
  final List<KanbanAssignee> assignees;
  final VoidCallback onAddAssignees;
  const OverviewSideMenu({
    super.key,
    required this.task,
    required this.theme,
    required this.descriptionController,
    required this.onPriorityChange,
    required this.onDescriptionChange,
    required this.onAttachmentChange,
    required this.currentPriority,
    required this.assignees,
    required this.onAddAssignees,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        // Show assigned details
        Row(
          children: [
            Text(
              'Assigned By: ',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 14,
              // backgroundImage: NetworkImage(task.assignedBy ?? ''),
              child: Text(
                task.assignedBy.characters.take(2).toString().toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: AppPallete.black),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              task.assignedBy,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned To: ',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...assignees.map(
                    (assignee) => Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: assignee.avatarUrl != null &&
                                  assignee.avatarUrl!.isNotEmpty
                              ? NetworkImage(assignee.avatarUrl!)
                              : null,
                          child: assignee.avatarUrl == null ||
                                  assignee.avatarUrl!.isEmpty
                              ? Text(assignee.initials,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppPallete.black))
                              : null,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          assignee.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.tertiary),
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceDim.withAlpha(100),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(Icons.add, color: theme.dividerColor, size: 18),
                    ),
                    onPressed: onAddAssignees,
                    tooltip: 'Assign users',
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Due Date: ',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 30),
            Text(
              task.dueDate,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Priority selection using chips
        Row(
          children: [
            Text(
              'Priority:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: ['Low', 'Medium', 'High'].map((level) {
                  return ChoiceChip(
                    side: BorderSide(
                        color: currentPriority == level
                            ? theme.colorScheme.tertiary
                            : theme.dividerColor,
                        width: currentPriority == level ? 2 : 1),
                    backgroundColor: Colors.transparent,
                    selectedColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    showCheckmark: false,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          level == 'Low'
                              ? 'assets/icons/arrow/ic-solar_double-alt-arrow-down-bold-duotone.svg'
                              : level == 'Medium'
                                  ? 'assets/icons/arrow/ic-solar_double-alt-arrow-right-bold-duotone.svg'
                                  : 'assets/icons/arrow/ic-solar_double-alt-arrow-up-bold-duotone.svg',
                          color: level == 'Low'
                              ? AppPallete.infoMain
                              : level == 'Medium'
                                  ? AppPallete.warningMain
                                  : AppPallete.errorMain,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          level,
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.tertiary),
                        ),
                      ],
                    ),
                    selected: currentPriority == level,
                    onSelected: (selected) {
                      onPriorityChange(level);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Description TextField
        Text(
          'Description',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        CustomTextfield(
          controller: descriptionController,
          theme: theme,
          hintText: 'Add discription here',
          keyboardType: TextInputType.text,
          maxLines: 3,
          onchange: onDescriptionChange,
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: descriptionController,
          builder: (context, value, child) {
            return value.text != task.description
                ? Align(
                    alignment: Alignment.centerRight,
                    child: CustomTextButton(
                        backgroundColor: theme.colorScheme.tertiary,
                        padding: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.save_rounded,
                              color: theme.scaffoldBackgroundColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Save',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.scaffoldBackgroundColor,
                              ),
                            ),
                          ],
                        ),
                        onClick: () => onDescriptionChange(value.text)),
                  )
                : const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 20),
        // Attachments placeholder

        Text(
          'Attachments',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            onAttachmentChange('');
          },
          child: DottedBorder(
            radius: const Radius.circular(15),
            padding: const EdgeInsets.all(3),
            borderType: BorderType.RRect,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 100,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: theme.colorScheme.surfaceContainer,
              ),
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/common/solid/ic-eva_cloud-upload-fill.svg',
                    height: 45,
                    color: theme.colorScheme.primaryFixed,
                  ),
                  Text(
                    'Drop files here or click to browse',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.dividerColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
