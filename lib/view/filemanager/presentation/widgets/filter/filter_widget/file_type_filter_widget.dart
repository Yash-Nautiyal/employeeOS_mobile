import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart' show CustomPopupState;
import 'package:flutter_svg/svg.dart';

import '../../../../../../core/index.dart'
    show AppPallete, CustomDivider, CustomPopup, CustomTextButton, getFileIcon;
import '../../../../index.dart'
    show
        FileFilterService,
        FileManagerFilterController,
        FileTypeFilter,
        FilterControllerProvider;

/// UI component for file type filtering
/// This component is now purely UI-focused and uses the controller for state management
class FilterFileTypeWidget extends StatelessWidget {
  final GlobalKey<CustomPopupState> anchorKey;
  final ThemeData theme;

  const FilterFileTypeWidget({
    super.key,
    required this.anchorKey,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final controller = FilterControllerProvider.of(context);
    final selectedTypes = controller.filterState.fileTypeFilter.selectedTypes;
    final isActive = controller.filterState.fileTypeFilter.isActive;

    return CustomPopup(
      anchorKey: anchorKey,
      constraints: const BoxConstraints(
        minWidth: 240,
        maxWidth: 380,
        maxHeight: 300,
      ),
      contentPadding: EdgeInsets.zero,
      content: _FileTypeFilterContent(
        selectedTypes: selectedTypes,
        theme: theme,
        controller: controller,
      ),
      child: _FileTypeFilterTrigger(
        selectedTypes: selectedTypes,
        isActive: isActive,
        theme: theme,
      ),
    );
  }
}

/// Content widget for the file type filter popup
class _FileTypeFilterContent extends StatefulWidget {
  final Set<FileTypeFilter> selectedTypes;
  final ThemeData theme;
  final FileManagerFilterController controller;

  const _FileTypeFilterContent({
    required this.selectedTypes,
    required this.theme,
    required this.controller,
  });

  @override
  State<_FileTypeFilterContent> createState() => _FileTypeFilterContentState();
}

class _FileTypeFilterContentState extends State<_FileTypeFilterContent> {
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableFilters.map((filter) {
                  final isSelected = _localSelectedTypes.contains(filter);
                  return _FileTypeChip(
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomTextButton(
                onClick: _clearSelection,
                child: Text(
                  'Clear',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CustomTextButton(
                onClick: _applySelection,
                backgroundColor: widget.theme.colorScheme.onSurface,
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
    Navigator.of(context).pop();
  }
}

/// Individual file type chip widget
class _FileTypeChip extends StatelessWidget {
  final FileTypeFilter filter;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;

  const _FileTypeChip({
    required this.filter,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
            .copyWith(left: isSelected ? 7 : 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.dividerColor.withAlpha(100),
          ),
          color:
              isSelected ? theme.colorScheme.primary.withOpacity(0.08) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              SvgPicture.asset(
                'assets/icons/common/solid/ic-solar_close-circle-bold.svg',
                height: 20,
                width: 20,
                color: theme.colorScheme.primary.withAlpha(200),
              ),
              const SizedBox(width: 5),
            ],
            SvgPicture.asset(
              getFileIcon(filter.name),
              height: 20,
              width: 20,
            ),
            const SizedBox(width: 6),
            Text(
              filter.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trigger widget for the file type filter
class _FileTypeFilterTrigger extends StatelessWidget {
  final Set<FileTypeFilter> selectedTypes;
  final bool isActive;
  final ThemeData theme;

  const _FileTypeFilterTrigger({
    required this.selectedTypes,
    required this.isActive,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: selectedTypes.isEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'All types',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            )
          : _buildSelectedTypesDisplay(),
    );
  }

  Widget _buildSelectedTypesDisplay() {
    const double maxTextWidth = 180;
    final names = selectedTypes.map((ft) => ft.name).toList();
    String display = '';
    int count = 0;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < names.length; i++) {
      final name = names[i];
      final testDisplay = display.isEmpty ? name : '$display, $name';
      final tp = TextPainter(
        text: TextSpan(text: testDisplay, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (tp.width > maxTextWidth && count > 0) {
        break;
      }
      display = testDisplay;
      count++;
    }

    int remaining = names.length - count;
    String finalDisplay = display;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(finalDisplay, style: textStyle),
            if (remaining > 0) ...[
              const SizedBox(width: 6),
              _buildRemainingTypesNumber(remaining),
            ],
          ],
        ),
        Icon(
          Icons.arrow_drop_down_rounded,
          color: theme.colorScheme.onSurface,
        ),
      ],
    );
  }

  Widget _buildRemainingTypesNumber(int remaining) {
    return Container(
      decoration: BoxDecoration(
        color: AppPallete.infoMain.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Text(
          '+$remaining',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppPallete.infoMain,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
