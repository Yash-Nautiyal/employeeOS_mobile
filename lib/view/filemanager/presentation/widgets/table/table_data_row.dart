// ignore_for_file: deprecated_member_use
import 'package:employeeos/core/common/components/popup/popup.dart';
import 'package:employeeos/core/index.dart'
    show
        AvatarStackItem,
        CustomAvatarStack,
        DestructivePopupItem,
        PopupPreferredPosition,
        ResponsivePopupController,
        ResponsivePopupItem,
        fmtDate,
        fmtTime,
        formatFileSize,
        getFileIcon,
        showCustomToast;
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

import 'package:employeeos/view/filemanager/presentation/widgets/dialogs/delete_confirm_dialog.dart';
import '../../../index.dart'
    show
        FavoriteStarButton,
        FileItem,
        FileRole,
        FilemanagerBloc,
        FilemanagerItem,
        MoveFileToRootEvent,
        ShareFileDialogRunner,
        SharedUser,
        UserPermission;

class TableDataRow extends StatefulWidget {
  const TableDataRow({
    super.key,
    required this.item,
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
    this.folderIconKey,
    this.hideFolderIconForFlyBack = false,
  });

  final FilemanagerItem item;
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

  /// When set (for folder rows), used to read icon position for fly-to-header animation.
  final GlobalKey? folderIconKey;

  /// When true, folder icon is hidden until fly-back animation lands (icon appears to return).
  final bool hideFolderIconForFlyBack;

  @override
  State<TableDataRow> createState() => _TableDataRowState();
}

class _TableDataRowState extends State<TableDataRow> {
  final String? _currentUserId = Supabase.instance.client.auth.currentUser?.id;
  final GlobalKey _popupAnchorKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  final ResponsivePopupController _popupController =
      ResponsivePopupController();

  @override
  void dispose() {
    _popupController.dispose();
    super.dispose();
  }

  Widget _buildIcon() {
    final icon = SvgPicture.asset(
      getFileIcon(widget.item.isFolder
          ? 'folder'
          : (widget.item as FileItem).file.fileType ?? ''),
      width: 32,
    );
    if (widget.item.isFolder && widget.folderIconKey != null) {
      final child = widget.hideFolderIconForFlyBack
          ? Opacity(opacity: 0, child: icon)
          : icon;
      return KeyedSubtree(
        key: widget.folderIconKey,
        child: child,
      );
    }
    return icon;
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
                _buildIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.name,
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
              widget.item.isFile
                  ? formatFileSize((widget.item as FileItem).file.size ?? 0)
                  : '${(widget.item as dynamic).folder.fileCount}',
            ),
          ),

          // Type
          SizedBox(
            width: widget.widthType,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                widget.item.isFolder
                    ? 'Folder'
                    : () {
                        final ft =
                            (widget.item as FileItem).file.fileType ?? '';
                        if (ft.isEmpty) return ft;
                        return ft[0].toUpperCase() +
                            ft.substring(1).toLowerCase();
                      }(),
              ),
            ),
          ),

          // Modified
          SizedBox(
            width: widget.widthModified,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fmtDate(widget.item.createdAt),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fmtTime(widget.item.createdAt),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Shared
          Container(
            alignment: Alignment.centerLeft,
            width: widget.widthShared,
            child: () {
              final sharedWith = widget.item is FileItem
                  ? (widget.item as FileItem).file.sharedWith
                  : null;
              if (sharedWith == null || sharedWith.isEmpty) {
                return const Text('-');
              }
              return Align(
                alignment: Alignment.centerLeft,
                child: CustomAvatarStack(
                  items: sharedWith
                      .map(
                        (user) => AvatarStackItem(
                          name: user.name,
                          imageUrl: user.avatarUrl,
                          isCurrentUser: user.id == _currentUserId,
                          headerInitials: user.permission == UserPermission.view
                              ? 'V'
                              : 'E',
                        ),
                      )
                      .toList(),
                  size: 36,
                  overlap: 23,
                  maxVisible: 3,
                ),
              );
            }(),
          ),
          // Actions
          SizedBox(
            width: widget.widthActions,
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.item is FileItem) ...[
                    Padding(
                      padding:
                          EdgeInsets.only(right: widget.item.isFolder ? 34 : 0),
                      child: FavoriteStarButton(
                        isFavorite: (widget.item as FileItem).file.isFavorite,
                        onTap: widget.onStar,
                        size: 22,
                        activeColor: Colors.amber,
                        inactiveColor: theme.disabledColor,
                      ),
                    ),
                    Popup(
                      popupAnchorKey: _popupAnchorKey,
                      layerLink: _layerLink,
                      popupController: _popupController,
                      icon: const Icon(Icons.more_vert),
                      preferredPosition: PopupPreferredPosition.left,
                      manualOffset: Offset(
                          10,
                          (widget.item as FileItem).file.folderId != null
                              ? (widget.item as FileItem).file.role ==
                                      FileRole.owner
                                  ? -35
                                  : (widget.item as FileItem).file.role ==
                                          FileRole.editor
                                      ? -10
                                      : 10
                              : (widget.item as FileItem).file.role ==
                                      FileRole.viewer
                                  ? 25
                                  : (widget.item as FileItem).file.role ==
                                          FileRole.editor
                                      ? 20
                                      : 10),
                      arrowOffset:
                          (widget.item as FileItem).file.folderId != null
                              ? null
                              : 0.2,
                      items: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: ResponsivePopupItem(
                            title: 'Copy Link',
                            svgIcon:
                                'assets/icons/common/solid/ic-solar-link-bold.svg',
                            onTap: () {
                              _popupController.hide();
                              final link = (widget.item as FileItem).file.path;
                              if (link.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: link));
                              } else {
                                showCustomToast(
                                  context: context,
                                  type: ToastificationType.error,
                                  title: 'No link available',
                                );
                              }
                            },
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                        if ((widget.item as FileItem).file.role !=
                            FileRole.viewer)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0)
                                .copyWith(top: 10),
                            child: ResponsivePopupItem(
                              title: 'Share',
                              svgIcon:
                                  'assets/icons/common/solid/ic-solar_share-bold.svg',
                              color: theme.colorScheme.tertiary,
                              onTap: () {
                                _popupController.hide();
                                final fileItem = widget.item as FileItem;
                                final bloc = context.read<FilemanagerBloc>();
                                final sharedUsers = fileItem.file.sharedWith ??
                                    const <SharedUser>[];
                                ShareFileDialogRunner.show(
                                  context,
                                  bloc: bloc,
                                  sharedUsers: sharedUsers,
                                  fileId: fileItem.file.id,
                                  ownerId: fileItem.file.ownerId,
                                );
                              },
                            ),
                          ),
                        if ((widget.item as FileItem).file.folderId != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0)
                                .copyWith(top: 10),
                            child: ResponsivePopupItem(
                              title: 'Remove',
                              svgIcon:
                                  'assets/icons/common/solid/ic-lets-icons-out.svg',
                              color: theme.colorScheme.tertiary,
                              onTap: () {
                                _popupController.hide();
                                context.read<FilemanagerBloc>().add(
                                      MoveFileToRootEvent(
                                        (widget.item as FileItem).file.id,
                                      ),
                                    );
                              },
                            ),
                          ),
                        if ((widget.item as FileItem).file.role ==
                            FileRole.owner) ...[
                          DestructivePopupItem(
                            onTap: () {
                              _popupController.hide();
                              final fileItem = widget.item as FileItem;
                              final bloc = context.read<FilemanagerBloc>();
                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) =>
                                    BlocProvider<FilemanagerBloc>.value(
                                  value: bloc,
                                  child: DeleteConfirmDialog(
                                    fileCount: 1,
                                    folderCount: 0,
                                    filesInsideFoldersCount: 0,
                                    fileIds: [fileItem.file.id],
                                    folderIds: const [],
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
