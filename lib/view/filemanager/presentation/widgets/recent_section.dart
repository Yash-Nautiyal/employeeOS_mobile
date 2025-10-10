import 'package:employeeos/core/common/actions/file_actions.dart'
    show formatFileSize, getFileIcon;
import 'package:employeeos/core/common/components/custom_divider.dart';
import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;
import 'package:employeeos/view/filemanager/domain/entities/filemanager_models.dart'
    show FileType, FolderFile;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

class RecentSection extends StatelessWidget {
  final ThemeData theme;
  final List<FolderFile> favorites;
  const RecentSection(
      {super.key, required this.theme, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final filename = favorites[index].name;
            final filesize = favorites[index].size;
            final filecounts = favorites[index].fileCount;
            final isfolder = favorites[index].type == FileType.folder;
            final isfavorite = favorites[index].isFavorite;
            return Container(
              padding: const EdgeInsets.all(20).copyWith(right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isfolder
                      ? SvgPicture.asset(
                          "assets/icons/file/ic-folder.svg",
                          width: 26.sp,
                          height: 26.sp,
                        )
                      : SvgPicture.asset(
                          getFileIcon(favorites[index].fileType ?? ""),
                          width: 26.sp,
                          height: 26.sp,
                        ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filename,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontSize: 16.sp),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        filesize != null
                            ? Text(
                                formatFileSize(filesize),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              )
                            : const SizedBox.shrink(),
                        filecounts != null
                            ? Text(
                                'Files: ${filecounts.toString()}',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {},
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
                                  : theme.disabledColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => {},
                        icon: const Icon(Icons.more_vert_rounded),
                      )
                    ],
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return CustomDivider(color: theme.dividerColor, height: 1);
          },
          itemCount: favorites.length > 5 ? 5 : favorites.length),
    );
  }
}
