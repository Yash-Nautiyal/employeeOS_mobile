import 'package:employeeos/view/filemanager/index.dart'
    show FilterControllerProvider;
import 'package:flutter/material.dart';

import '../../../../../../core/index.dart'
    show
        PopupPreferredPosition,
        ResponsivePopupContainer,
        ResponsivePopupController;
import 'filter_type/filter_content.dart';
import 'filter_type/trigger.dart';

class FilterFileTypeWidget extends StatefulWidget {
  final GlobalKey anchorKey;
  final ThemeData theme;

  const FilterFileTypeWidget({
    super.key,
    required this.anchorKey,
    required this.theme,
  });

  @override
  State<FilterFileTypeWidget> createState() => _FilterFileTypeWidgetState();
}

class _FilterFileTypeWidgetState extends State<FilterFileTypeWidget> {
  final LayerLink _layerLink = LayerLink();
  final ResponsivePopupController _popupController =
      ResponsivePopupController();

  @override
  void dispose() {
    _popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = FilterControllerProvider.of(context);
    final selectedTypes = controller.filterState.fileTypeFilter.selectedTypes;
    final isActive = controller.filterState.fileTypeFilter.isActive;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          _popupController.show(
            context: context,
            link: _layerLink,
            anchorKey: widget.anchorKey,
            preferredPosition: isMobile
                ? PopupPreferredPosition.top
                : PopupPreferredPosition.left,
            offset:
                isMobile ? const Offset(-180, -280) : const Offset(-300, -100),
            arrowOffsetOverride: isMobile ? 0.8 : 0.4,
            childBuilder: (placement) => ResponsivePopupContainer(
              width: 300,
              arrowSide: placement.arrowSide,
              arrowOffset: placement.arrowOffset,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 380,
                  maxHeight: 250,
                ),
                child: FileTypeFilterContent(
                  popupController: _popupController,
                  selectedTypes: selectedTypes,
                  theme: widget.theme,
                  controller: controller,
                ),
              ),
            ),
          );
        },
        child: FileTypeFilterTrigger(
          selectedTypes: selectedTypes,
          isActive: isActive,
          theme: widget.theme,
        ),
      ),
    );
  }
}
