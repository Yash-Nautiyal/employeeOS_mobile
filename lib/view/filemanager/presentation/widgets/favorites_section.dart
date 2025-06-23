import 'package:employeeos/core/common/actions/file_actions.dart'
    show formatFileSize, getFileIcon;
import 'package:employeeos/core/common/components/empty_content.dart'
    show EmptyContent;
import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;
import 'package:employeeos/view/filemanager/domain/entities/filemanager_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FavoritesSection extends StatelessWidget {
  final List<FolderFile> favorites;
  final ThemeData theme;
  final double screenHeight;
  const FavoritesSection(
      {super.key,
      required this.screenHeight,
      required this.favorites,
      required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 230),
      height: screenHeight * .2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: favorites.isEmpty
                ? const Align(
                    alignment: Alignment.center,
                    child: EmptyContent(
                      icon: 'assets/icons/empty/ic-content.svg',
                      title: "No Favorites",
                    ))
                : ListView.builder(
                    physics: const RangeMaintainingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final filename = favorites[index].name;
                      final filesize = favorites[index].size;
                      final filecounts = favorites[index].fileCount;
                      final isfolder = favorites[index].type == FileType.folder;
                      return Stack(
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                                minWidth: 170, maxWidth: 200, minHeight: 140),
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
                                        "assets/icons/file/ic-folder.svg")
                                    : SvgPicture.asset(
                                        getFileIcon(
                                            favorites[index].fileType ?? ""),
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  filename,
                                  style: theme.textTheme.titleMedium,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                filesize != null
                                    ? Text(
                                        formatFileSize(filesize),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      )
                                    : const SizedBox.shrink(),
                                filecounts != null
                                    ? Text(
                                        'Files: ${filecounts.toString()}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
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
                              onTap: () {},
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
