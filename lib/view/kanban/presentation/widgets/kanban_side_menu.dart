import 'package:appflowy_board/appflowy_board.dart' show AppFlowyGroupData;
import 'package:employeeos/core/common/components/custom_dropdown.dart';
import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:employeeos/core/common/components/custom_toggle_button.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KanbanSideMenu extends StatefulWidget {
  final KanbanGroupItem task;
  final AppFlowyGroupData<dynamic> group;

  const KanbanSideMenu({super.key, required this.task, required this.group});

  @override
  _KanbanSideMenuState createState() => _KanbanSideMenuState();
}

class _KanbanSideMenuState extends State<KanbanSideMenu> {
  late String _priority;
  late String _group;
  late TextEditingController _descriptionController;

  bool showOverView = true;

  @override
  void initState() {
    super.initState();
    _group = widget.group.headerData.groupName;
    _priority = widget.task.priority;
    _descriptionController =
        TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row with column dropdown and close button.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              IntrinsicWidth(
                child: CustomDropdown(
                  theme: theme,
                  onChange: (value) {
                    setState(() {
                      _group = value;
                    });
                  },
                  label: '',
                  value: _group,
                  items: ['Pending', 'In progress', 'Testing', 'Done']
                      .map((title) {
                    return DropdownMenuItem(
                      value: title,
                      child: Text(
                        title,
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
        const SizedBox(height: 20),
        CustomToggleButton(
          width: 343 / 2,
          values: const ["Overview", "Subtasks"],
          theme: theme,
          initialIndex: showOverView ? 0 : 1,
          onToggle: (value) {
            setState(() {
              showOverView = value == 0;
            });
          },
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task.title,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
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
                  const CircleAvatar(
                    radius: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.task.assignedBy,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Assigned To: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.task.assignedTo,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Due Date: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    widget.task.dueDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
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
                              color: _priority == level
                                  ? theme.colorScheme.tertiary
                                  : theme.dividerColor,
                              width: _priority == level ? 2 : 1),
                          backgroundColor: Colors.transparent,
                          selectedColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 4,
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
                                style: theme.textTheme.labelLarge,
                              ),
                            ],
                          ),
                          selected: _priority == level,
                          onSelected: (selected) {
                            setState(() {
                              _priority = level;
                            });
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
                controller: _descriptionController,
                theme: theme,
                hintText: 'Add discription here',
                keyboardType: TextInputType.text,
                maxLines: 3,
                onchange: (value) {},
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _descriptionController,
                builder: (context, value, child) {
                  return value.text != widget.task.description
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
                              onClick: () {}),
                        )
                      : const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 20),
              // Attachments placeholder
              GestureDetector(
                onTap: () {
                  // Handle file picking logic here.
                },
                child: Container(
                  height: 100,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainer,
                  alignment: Alignment.center,
                  child: const Text('Drop files here or click to browse'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
