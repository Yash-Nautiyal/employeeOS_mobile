import 'package:dotted_border/dotted_border.dart';
import 'package:employeeos/view/filemanager/domain/entities/filter_models.dart'
    show FileManagerFilterState;
import 'package:employeeos/view/filemanager/presentation/controllers/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Widget to display active filter status and allow clearing them
class FilterStatusWidget extends StatelessWidget {
  final ThemeData theme;

  const FilterStatusWidget({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final controller = FilterControllerProvider.of(context);
    final filterState = controller.filterState;

    if (!filterState.fileTypeFilter.isActive) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: DottedBorder(
            color: theme.dividerColor.withAlpha(120),
            radius: const Radius.circular(12),
            dashPattern: const [3.5, 1.5],
            borderType: BorderType.RRect,
            strokeWidth: 1,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Types :',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                ..._buildActiveFilterChips(filterState, controller),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => controller.clearAllFilters(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
                color: theme.colorScheme.error,
                width: 20,
              ),
              const SizedBox(width: 3),
              Text(
                'Clear',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActiveFilterChips(
    FileManagerFilterState filterState,
    FileManagerFilterController controller,
  ) {
    final chips = <Widget>[];
    // File type filter chip
    if (filterState.fileTypeFilter.isActive) {
      final types = filterState.fileTypeFilter.selectedTypes;

      for (var type in types) {
        chips.add(_FilterChip(
          label: type.name[0].toUpperCase() + type.name.substring(1),
          theme: theme,
          onRemove: () => controller.removeFileType(type),
        ));
      }
    }

    return chips;
  }
}

/// Individual filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.theme,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 7).copyWith(left: 10, right: 5),
      decoration: BoxDecoration(
        color: theme.dividerColor.withAlpha(60),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 5),
          InkWell(
            onTap: onRemove,
            child: SvgPicture.asset(
              'assets/icons/common/solid/ic-solar_close-circle-bold.svg',
              width: 22,
              color: theme.disabledColor.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}
