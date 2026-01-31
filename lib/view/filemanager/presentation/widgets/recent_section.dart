import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/index.dart'
    show
        AppPallete,
        CustomDivider,
        PopupPreferredPosition,
        ResponsivePopupContainer,
        ResponsivePopupController,
        ResponsivePopupItem,
        formatFileSize,
        getFileIcon,
        showRightSideTaskDetails;
import '../../index.dart'
    show FilemanagerBloc, FileManagerSideMenu, FileType, FolderFile;

class RecentSection extends StatefulWidget {
  final ThemeData theme;
  final List<FolderFile> files;
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
          return CustomDivider(color: widget.theme.dividerColor, height: 1);
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
  final FolderFile file;
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
    final filecounts = widget.file.fileCount;
    final isfolder = widget.file.type == FileType.folder;
    final isfavorite = widget.file.isFavorite;

    return GestureDetector(
      onTap: () => showRightSideTaskDetails(
          context,
          BlocProvider.value(
            value: context.read<FilemanagerBloc>(),
            child: FileManagerSideMenu(file: widget.file),
          )),
      child: Container(
        padding: const EdgeInsets.all(20).copyWith(right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isfolder
                ? SvgPicture.asset(
                    "assets/icons/file/ic-folder.svg",
                    width: 30,
                  )
                : SvgPicture.asset(
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
                  filesize != null
                      ? Text(
                          formatFileSize(filesize),
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      : const SizedBox.shrink(),
                  filecounts != null
                      ? Text(
                          'Files: ${filecounts.toString()}',
                          style: widget.theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => widget.onFavoriteToggle(widget.file.id),
                  splashFactory: InkRipple.splashFactory,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SvgPicture.asset(
                      isfavorite
                          ? "assets/icons/common/solid/ic-eva_star-fill.svg"
                          : "assets/icons/common/solid/ic-eva_star-outline.svg",
                      colorFilter: ColorFilter.mode(
                        isfavorite
                            ? AppPallete.warningMain
                            : widget.theme.disabledColor,
                        BlendMode.srcIn,
                      ),
                    ),
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
                                    color: widget.theme.colorScheme.tertiary,
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
                                    color: widget.theme.colorScheme.tertiary,
                                    onTap: () {
                                      _popupController.hide();
                                    },
                                  ),
                                ),
                                CustomDivider(
                                  color:
                                      widget.theme.dividerColor.withAlpha(100),
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
          ],
        ),
      ),
    );
  }
}
