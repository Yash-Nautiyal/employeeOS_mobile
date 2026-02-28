import 'package:employeeos/core/common/components/popup/popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:toastification/toastification.dart';

import 'package:employeeos/core/index.dart'
    show
        CustomDivider,
        DestructivePopupItem,
        PopupPreferredPosition,
        ResponsivePopupController,
        ResponsivePopupItem,
        formatFileSize,
        getFileIcon,
        showCustomToast,
        showRightSideTaskDetails;
import 'package:employeeos/view/filemanager/index.dart'
    show
        FileEntity,
        FileItem,
        FileManagerSideMenu,
        FileRole,
        FilemanagerBloc,
        ShareFileDialogRunner,
        SharedUser,
        DeleteConfirmDialog;

class RecentSection extends StatefulWidget {
  final ThemeData theme;
  final List<FileEntity> files;
  final Function(String) onFavoriteToggle;
  const RecentSection(
      {super.key,
      required this.theme,
      required this.files,
      required this.onFavoriteToggle});

  @override
  State<RecentSection> createState() => _RecentSectionState();
}

class _RecentSectionState extends State<RecentSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.files.length > 5 ? 5 : widget.files.length,
        separatorBuilder: (context, index) {
          return CustomDivider(
            color: widget.theme.dividerColor.withValues(alpha: .5),
            dashWidth: 2.5,
            height: 1,
          );
        },
        itemBuilder: (context, index) {
          return _RecentSectionRow(
            theme: widget.theme,
            file: widget.files[index],
            onFavoriteToggle: widget.onFavoriteToggle,
          );
        },
      ),
    );
  }
}

/// One row in the recent list; has its own popup key so GlobalKey is not shared.
class _RecentSectionRow extends StatefulWidget {
  final ThemeData theme;
  final FileEntity file;
  final Function(String) onFavoriteToggle;

  const _RecentSectionRow({
    required this.theme,
    required this.file,
    required this.onFavoriteToggle,
  });

  @override
  State<_RecentSectionRow> createState() => _RecentSectionRowState();
}

class _RecentSectionRowState extends State<_RecentSectionRow> {
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
    final filename = widget.file.name;
    final filesize = widget.file.size;

    return GestureDetector(
      onTap: () => showRightSideTaskDetails(
        context,
        BlocProvider.value(
          value: context.read<FilemanagerBloc>(),
          child: FileManagerSideMenu(item: FileItem(widget.file)),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20).copyWith(right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              getFileIcon(widget.file.fileType ?? ""),
              width: 30,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filename,
                    style: widget.theme.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (filesize != null)
                    Text(
                      formatFileSize(filesize),
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Popup(
                  popupAnchorKey: _popupAnchorKey,
                  layerLink: _layerLink,
                  icon: const Icon(Icons.more_vert),
                  popupController: _popupController,
                  manualOffset: Offset(
                      60,
                      widget.file.role == FileRole.owner
                          ? 10
                          : widget.file.role == FileRole.viewer
                              ? 25
                              : 10),
                  arrowOffset: widget.file.role == FileRole.owner ? 0.15 : 0.4,
                  preferredPosition: PopupPreferredPosition.left,
                  items: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: ResponsivePopupItem(
                        title: 'Copy Link',
                        svgIcon:
                            'assets/icons/common/solid/ic-solar-link-bold.svg',
                        onTap: () {
                          _popupController.hide();
                          final link = widget.file.path;
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
                        color: widget.theme.colorScheme.tertiary,
                      ),
                    ),
                    if (widget.file.role != FileRole.viewer)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0)
                            .copyWith(
                                bottom:
                                    widget.file.role == FileRole.owner ? 10 : 0,
                                top: 10),
                        child: ResponsivePopupItem(
                          title: 'Share',
                          svgIcon:
                              'assets/icons/common/solid/ic-solar_share-bold.svg',
                          color: widget.theme.colorScheme.tertiary,
                          onTap: () {
                            _popupController.hide();
                            ShareFileDialogRunner.show(
                              context,
                              bloc: context.read<FilemanagerBloc>(),
                              sharedUsers: widget.file.sharedWith ??
                                  const <SharedUser>[],
                              fileId: widget.file.id,
                              ownerId: widget.file.ownerId,
                            );
                          },
                        ),
                      ),
                    if (widget.file.role == FileRole.owner) ...[
                      DestructivePopupItem(
                        onTap: () {
                          _popupController.hide();
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
                                fileIds: [widget.file.id],
                                folderIds: const [],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
