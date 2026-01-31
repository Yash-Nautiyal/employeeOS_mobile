// ignore_for_file: deprecated_member_use
import 'package:employeeos/core/index.dart'
    show
        AvatarStackItem,
        CustomAvatarStack,
        CustomDivider,
        PopupPreferredPosition,
        ResponsivePopupContainer,
        ResponsivePopupController,
        ResponsivePopupItem,
        fmtDate,
        fmtTime,
        formatFileSize,
        getFileIcon;
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart' show CustomPopupState;
import 'package:flutter_svg/svg.dart';

import '../../../index.dart' show FolderFile;

class TableDataRow extends StatefulWidget {
  const TableDataRow({
    super.key,
    required this.file,
    required this.selected,
    required this.widthName,
    required this.widthSize,
    required this.widthType,
    required this.widthModified,
    required this.widthShared,
    required this.widthActions,
    required this.onChanged,
    required this.onStar,
    required this.onMenu,
  });

  final FolderFile file;
  final bool selected;
  final double widthName,
      widthSize,
      widthType,
      widthModified,
      widthShared,
      widthActions;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onStar;
  final ValueChanged<String> onMenu;

  @override
  State<TableDataRow> createState() => _TableDataRowState();
}

class _TableDataRowState extends State<TableDataRow> {
  final anchorKey = GlobalKey<CustomPopupState>();
  final GlobalKey _popupAnchorKey = GlobalKey();
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
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
        color:
            widget.selected ? theme.colorScheme.primary.withOpacity(.05) : null,
      ),
      child: Row(
        children: [
          // Name cell with checkbox + type badge + file name
          SizedBox(
            width: widget.widthName,
            child: Row(
              children: [
                Checkbox(
                  value: widget.selected,
                  onChanged: widget.onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  getFileIcon(
                      widget.file.isFolder ? 'folder' : widget.file.fileType!),
                  width: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.file.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Size
          SizedBox(
            width: widget.widthSize,
            child: Text(
              formatFileSize(widget.file.size ?? 0),
            ),
          ),

          // Type
          SizedBox(
            width: widget.widthType,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                widget.file.isFolder
                    ? 'Folder'
                    : widget.file.fileType![0].toUpperCase() +
                        widget.file.fileType!.substring(1).toLowerCase(),
              ),
            ),
          ),

          // Modified (date + time stacked)
          SizedBox(
            width: widget.widthModified,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fmtDate(widget.file.createdAt)),
                const SizedBox(height: 2),
                Text(
                  fmtTime(widget.file.createdAt),
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Shared (star)

          Container(
            alignment: Alignment.centerLeft,
            width: widget.widthShared,
            child: widget.file.sharedWith == null ||
                    widget.file.sharedWith!.isEmpty
                ? const Text('-')
                : Align(
                    alignment: Alignment.centerLeft,
                    child: CustomAvatarStack(
                      items: widget.file.sharedWith!
                          .map(
                            (user) => AvatarStackItem(
                              name: user.name,
                              imageUrl: user.avatarUrl,
                            ),
                          )
                          .toList(),
                      size: 36,
                      overlap: 23,
                      maxVisible: 3,
                    ),
                  ),
          ),
          // Actions (kebab)
          SizedBox(
            width: widget.widthActions,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: widget.onStar,
                    icon: SvgPicture.asset(
                      widget.file.isFavorite
                          ? 'assets/icons/common/solid/ic-eva_star-fill.svg'
                          : 'assets/icons/common/solid/ic-eva_star-outline.svg',
                      color: widget.file.isFavorite
                          ? Colors.amber
                          : theme.disabledColor,
                    ),
                  ),
                  CompositedTransformTarget(
                    key: _popupAnchorKey,
                    link: _layerLink,
                    child: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _popupController.show(
                          context: context,
                          link: _layerLink,
                          anchorKey: _popupAnchorKey,
                          preferredPosition: PopupPreferredPosition.left,
                          manualOffset: const Offset(60, 10),
                          // arrowOffsetOverride: 0.5,
                          childBuilder: (placement) => ResponsivePopupContainer(
                            width: 130,
                            arrowSide: placement.arrowSide,
                            arrowOffset: 0.15,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0)
                                        .copyWith(bottom: 10),
                                    child: ResponsivePopupItem(
                                      title: 'Copy Link',
                                      svgIcon:
                                          'assets/icons/common/solid/ic-solar-link-bold.svg',
                                      onTap: () {
                                        _popupController.hide();
                                      },
                                      color: theme.colorScheme.tertiary,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0)
                                        .copyWith(bottom: 10),
                                    child: ResponsivePopupItem(
                                      title: 'Share',
                                      svgIcon:
                                          'assets/icons/common/solid/ic-solar_share-bold.svg',
                                      color: theme.colorScheme.tertiary,
                                      onTap: () {
                                        _popupController.hide();
                                      },
                                    ),
                                  ),
                                  CustomDivider(
                                    color: theme.dividerColor.withAlpha(100),
                                    dashWidth: 2.3,
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: ResponsivePopupItem(
                                      title: 'Delete',
                                      svgIcon:
                                          'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
                                      color: Colors.red,
                                      onTap: () {
                                        _popupController.hide();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
}
