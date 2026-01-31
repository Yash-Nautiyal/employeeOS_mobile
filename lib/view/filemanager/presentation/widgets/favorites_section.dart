import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/index.dart'
    show
        AppPallete,
        EmptyContent,
        formatFileSize,
        getFileIcon,
        showRightSideTaskDetails;
import '../../index.dart'
    show FilemanagerBloc, FileManagerSideMenu, FileType, FolderFile;

class FavoritesSection extends StatelessWidget {
  final List<FolderFile> favorites;
  final ThemeData theme;
  final double screenHeight;
  final Function(String) onFavoriteToggle;
  const FavoritesSection({
    super.key,
    required this.screenHeight,
    required this.favorites,
    required this.theme,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 140, minHeight: 140),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: favorites.isEmpty
                ? const Align(
                    alignment: Alignment.center,
                    child: EmptyContent(
                      icon: 'assets/icons/empty/ic-content.svg',
                    ))
                : ListView.builder(
                    physics: const RangeMaintainingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final filename = favorites[index].name;
                      final filesize = favorites[index].size;
                      final filecounts = favorites[index].fileCount;
                      final isfolder = favorites[index].type == FileType.folder;
                      return GestureDetector(
                        onTap: () => showRightSideTaskDetails(
                            context,
                            BlocProvider.value(
                              value: context.read<FilemanagerBloc>(),
                              child:
                                  FileManagerSideMenu(file: favorites[index]),
                            )),
                        child: Stack(
                          children: [
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 170,
                                maxWidth: 180,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: theme.brightness == Brightness.dark
                                        ? AppPallete.grey700
                                        : AppPallete.grey400),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(right: 15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isfolder
                                      ? SvgPicture.asset(
                                          "assets/icons/file/ic-folder.svg",
                                          width: 30,
                                        )
                                      : SvgPicture.asset(
                                          getFileIcon(
                                              favorites[index].fileType ?? ""),
                                          width: 30,
                                        ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    filename,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  filesize != null
                                      ? Text(
                                          formatFileSize(filesize),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        )
                                      : const SizedBox.shrink(),
                                  filecounts != null
                                      ? Text(
                                          'Files: ${filecounts.toString()}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        )
                                      : const SizedBox.shrink()
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 30,
                              child: InkWell(
                                onTap: () =>
                                    onFavoriteToggle(favorites[index].id),
                                splashFactory: InkRipple.splashFactory,
                                customBorder: const CircleBorder(),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SvgPicture.asset(
                                    "assets/icons/common/solid/ic-eva_star-fill.svg",
                                    colorFilter: const ColorFilter.mode(
                                      AppPallete.warningMain,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
