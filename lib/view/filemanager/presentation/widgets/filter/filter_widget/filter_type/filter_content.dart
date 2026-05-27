import 'package:employeeos/core/index.dart'
    show CustomDivider, CustomTextButton, ResponsivePopupController;
import 'package:flutter/material.dart';

import '../../../../../domain/entities/filter_models.dart';
import '../../../../../index.dart'
    show FileFilterService, FileManagerFilterController;
import 'chip.dart';

class FileTypeFilterContent extends StatefulWidget {
  final Set<FileTypeFilter> selectedTypes;
  final ThemeData theme;
  final FileManagerFilterController controller;
  final ResponsivePopupController popupController;

  const FileTypeFilterContent({
    super.key,
    required this.selectedTypes,
    required this.theme,
    required this.controller,
    required this.popupController,
  });

  @override
  State<FileTypeFilterContent> createState() => _FileTypeFilterContentState();
}

class _FileTypeFilterContentState extends State<FileTypeFilterContent> {
  late Set<FileTypeFilter> _localSelectedTypes;

  @override
  void initState() {
    super.initState();
    _localSelectedTypes = Set.from(widget.selectedTypes);
  }

  @override
  Widget build(BuildContext context) {
    final availableFilters = FileFilterService.getAvailableFileTypeFilters();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 8),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableFilters.map((filter) {
                  final isSelected = _localSelectedTypes.contains(filter);
                  return FileTypeChip(
                    filter: filter,
                    isSelected: isSelected,
                    theme: widget.theme,
                    onTap: () => _toggleFilter(filter),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        CustomDivider(color: widget.theme.dividerColor.withAlpha(110)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomTextButton(
                onClick: _clearSelection,
                child: Text(
                  'Clear',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CustomTextButton(
                onClick: () {
                  widget.popupController.hide();
                  _applySelection();
                },
                backgroundColor: widget.theme.colorScheme.tertiary,
                child: Text(
                  'Apply',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.theme.scaffoldBackgroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleFilter(FileTypeFilter filter) {
    setState(() {
      if (_localSelectedTypes.contains(filter)) {
        _localSelectedTypes.remove(filter);
      } else {
        _localSelectedTypes.add(filter);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _localSelectedTypes.clear();
    });
  }

  void _applySelection() {
    widget.controller.updateFileTypeFilter(_localSelectedTypes);
  }
}
