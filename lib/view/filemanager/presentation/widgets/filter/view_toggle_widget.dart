import 'package:employeeos/view/filemanager/domain/entities/filter_models.dart';
import 'package:employeeos/view/filemanager/presentation/controllers/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// UI component for view type toggling
/// This component is now purely UI-focused and uses the controller for state management
class FilterViewToggleWidget extends StatelessWidget {
  final ThemeData theme;

  const FilterViewToggleWidget({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final controller = FilterControllerProvider.of(context);
    final currentViewType = controller.filterState.viewType;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewToggleButton(
            theme: theme,
            viewType: ViewType.grid,
            iconData: Icons.grid_view_rounded,
            tooltip: 'Grid View',
            isSelected: currentViewType == ViewType.grid,
            onTap: () => controller.updateViewType(ViewType.grid),
          ),
          Container(
            width: 1,
            height: 24,
            color: theme.dividerColor.withOpacity(0.3),
          ),
          _ViewToggleButton(
            theme: theme,
            viewType: ViewType.list,
            icon: 'assets/icons/nav/ic-menu-item.svg',
            tooltip: 'List View',
            isSelected: currentViewType == ViewType.list,
            onTap: () => controller.updateViewType(ViewType.list),
          ),
        ],
      ),
    );
  }
}

/// Individual view toggle button widget
class _ViewToggleButton extends StatelessWidget {
  final ThemeData theme;
  final ViewType viewType;
  final bool isSelected;
  final String tooltip;
  final VoidCallback onTap;
  final String? icon;
  final IconData? iconData;

  const _ViewToggleButton({
    required this.theme,
    required this.viewType,
    required this.isSelected,
    required this.tooltip,
    required this.onTap,
    this.icon,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: icon != null
            ? SvgPicture.asset(
                icon!,
                width: 18,
                height: 18,
                color: isSelected ? theme.primaryColor : theme.hintColor,
              )
            : Icon(
                iconData!,
                size: 18,
                color: isSelected ? theme.primaryColor : theme.hintColor,
              ),
        tooltip: tooltip,
      ),
    );
  }
}
