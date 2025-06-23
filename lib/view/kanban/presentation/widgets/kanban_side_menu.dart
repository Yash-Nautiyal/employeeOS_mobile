import 'dart:ui';

import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:cool_dropdown/models/cool_dropdown_item.dart';
import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KanbanSideMenu extends StatefulWidget {
  final KanbanGroupItem task;

  const KanbanSideMenu({super.key, required this.task});

  @override
  _KanbanSideMenuState createState() => _KanbanSideMenuState();
}

class _KanbanSideMenuState extends State<KanbanSideMenu> {
  late String _priority;
  late TextEditingController _descriptionController;
  final dropdownController = DropdownController<String>();
  @override
  void initState() {
    super.initState();
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
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              height: screenHeight,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xff161C23).withOpacity(.9)
                  : Theme.of(context).scaffoldBackgroundColor.withOpacity(.85),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with column dropdown and close button.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CoolDropdown<String>(
                        key: ValueKey(Theme.of(context)),
                        controller: dropdownController,
                        dropdownTriangleOptions: const DropdownTriangleOptions(
                          width: 10,
                          height: 10,
                          align: DropdownTriangleAlign.right,
                        ),
                        isMarquee: false,
                        dropdownOptions: const DropdownOptions(
                          duration: Duration(milliseconds: 100),
                        ),
                        resultOptions: ResultOptions(
                          openBoxDecoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          width: 150,
                          boxDecoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                          ),
                          duration: const Duration(milliseconds: 100),
                          backDuration: const Duration(milliseconds: 100),
                          marqueeDuration: const Duration(milliseconds: 100),
                          isMarquee: true,
                        ),
                        dropdownItemOptions: DropdownItemOptions(
                            pauseDuration: const Duration(milliseconds: 100),
                            isMarquee: true,
                            boxDecoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainer),
                            duration: const Duration(milliseconds: 100),
                            marqueeDuration: const Duration(milliseconds: 100),
                            backDuration: const Duration(milliseconds: 100),
                            selectedBoxDecoration: const BoxDecoration(
                              color: AppPallete.grey400,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            )),
                        dropdownList: [
                          CoolDropdownItem(label: 'Pending', value: 'Pending'),
                          CoolDropdownItem(
                              label: 'In progress', value: 'In progress'),
                          CoolDropdownItem(label: 'Testing', value: 'Testing'),
                          CoolDropdownItem(label: 'Done', value: 'Done'),
                        ],
                        onChange: (newValue) {
                          // Optionally: call a function to move the task to a different column.
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  // Show assigned details
                  Row(
                    children: [
                      Text(
                        'Assigned By: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 10),
                      const CircleAvatar(
                        radius: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.task.assignedBy,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Assigned To: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 10),
                      const CircleAvatar(
                        radius: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.task.assignedTo,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Due Date: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 35),
                      Text(
                        widget.task.dueDate,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.tertiary,
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                                      ? Theme.of(context).colorScheme.tertiary
                                      : Theme.of(context).dividerColor,
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
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 5),
                  CustomTextfield(
                    controller: _descriptionController,
                    theme: Theme.of(context),
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
                                  backgroundColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  padding: 0,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.save_rounded,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Save',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
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
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      alignment: Alignment.center,
                      child: const Text('Drop files here or click to browse'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Image.asset(
            'assets/images/background/cyanblur.png',
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Image.asset('assets/images/background/redblur.png'),
        )
      ],
    );
  }
}
