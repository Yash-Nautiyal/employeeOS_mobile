import 'package:employeeos/view/filemanager/domain/entities/filemanager_models.dart'
    show FileType, FolderFile;
import 'package:employeeos/view/filemanager/presentation/widgets/favorites_section.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/file_manager_table.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/recent_section.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/storage_section.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/file_manager_header.dart';
import 'package:flutter/material.dart';

class FilemanagerView extends StatelessWidget {
  const FilemanagerView({super.key});

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;
    final List<FolderFile> favorites = [
      FolderFile(
        id: '1',
        name: 'DesignsDesignsDesignsDesignsDesigns',
        path: '/documents/designs',
        type: FileType.folder,
        createdAt: DateTime.now(),
        isFavorite: true,
        fileCount: 2,
      ),
      FolderFile(
        id: '2',
        name: 'Specs.pdf',
        path: '/documents/specs.pdf',
        type: FileType.file,
        createdAt: DateTime.now(),
        size: 204800,
        fileType: 'application/pdf',
        isFavorite: true,
      ),
    ];
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0)
            .copyWith(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FilemanagerHeader(),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  " Favorites",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("View all", style: theme.textTheme.labelLarge),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            FavoritesSection(
              screenHeight: screenHeight,
              favorites: favorites,
              theme: theme,
            ),
            const SizedBox(
              height: 15,
            ),
            StorageSection(theme: theme),
            const SizedBox(
              height: 15,
            ),
            Text(
              " Recent Files",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            RecentSection(theme: theme, favorites: favorites),
            const SizedBox(
              height: 15,
            ),
            FileTableScreen(
              verticalScrollController: _scrollController,
              screenWidth: MediaQuery.of(context).size.width,
            )
          ],
        ),
      ),
    );
  }
}
