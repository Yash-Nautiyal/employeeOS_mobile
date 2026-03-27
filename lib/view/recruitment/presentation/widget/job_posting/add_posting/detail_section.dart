import 'package:employeeos/core/index.dart'
    show
        CustomDivider,
        CustomTextButton,
        CustomTextfield,
        DepartmentSearchAddField;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../components/quill/tool_bar.dart';

class DetailSection extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController jobTitleController;
  final TextEditingController? departmentController;
  final QuillController descriptionController;
  final VoidCallback openDescriptionFullScreen;
  final bool isFullScreen;
  final bool isDescriptionFullScreenOpen;
  final List<String>? departmentOptions;
  final String? selectedDepartment;
  final ValueChanged<String?>? onDepartmentChanged;
  final bool allowAddNewDepartment;

  const DetailSection({
    super.key,
    required this.theme,
    required this.jobTitleController,
    this.departmentController,
    required this.descriptionController,
    required this.openDescriptionFullScreen,
    required this.isFullScreen,
    this.isDescriptionFullScreenOpen = false,
    this.departmentOptions,
    this.selectedDepartment,
    this.onDepartmentChanged,
    this.allowAddNewDepartment = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: theme.shadowColor, spreadRadius: 1, blurRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Job role information...',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.disabledColor)),
          Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 16),
              child: CustomDivider(color: theme.dividerColor)),
          Text('Job Title',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomTextfield(
            controller: jobTitleController,
            theme: theme,
            hintText: 'Enter job title...',
            keyboardType: TextInputType.text,
            onchange: (_) {},
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Job title is required'
                : null,
          ),
          const SizedBox(height: 16),
          Text('Department',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (departmentOptions != null)
            DepartmentSearchAddField(
              theme: theme,
              options: departmentOptions!,
              selectedValue: selectedDepartment,
              allowAddNewDepartment: allowAddNewDepartment,
              onChanged: onDepartmentChanged,
            )
          else
            CustomTextfield(
              controller: departmentController!,
              theme: theme,
              hintText: 'Enter department...',
              keyboardType: TextInputType.text,
              onchange: (_) {},
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Department is required'
                  : null,
            ),
          const SizedBox(height: 16),
          Text('Description',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isDescriptionFullScreenOpen
                  ? _buildDescriptionPlaceholder(context)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: ToolBar(
                            controller: descriptionController,
                            theme: theme,
                            openDescriptionFullScreen:
                                openDescriptionFullScreen,
                            isFullScreen: isFullScreen,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border(
                              top: BorderSide(
                                color:
                                    theme.dividerColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          constraints: const BoxConstraints(minHeight: 350),
                          child: QuillEditor.basic(
                            controller: descriptionController,
                            config: const QuillEditorConfig(
                              padding: EdgeInsets.all(12),
                              placeholder:
                                  'Enter description (e.g. responsibilities, requirements...)',
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionPlaceholder(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 350),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fullscreen_rounded,
            size: 48,
            color: theme.disabledColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Description is being edited in full screen',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextButton(
            onClick: openDescriptionFullScreen,
            backgroundColor: theme.colorScheme.tertiary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_full,
                    size: 20, color: theme.scaffoldBackgroundColor),
                const SizedBox(width: 8),
                Text('Open full screen',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.scaffoldBackgroundColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
