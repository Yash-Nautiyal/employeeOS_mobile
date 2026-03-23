import 'package:employeeos/core/index.dart'
    show EmptyContent, formatFileSize, getFileIcon, showRightSideTaskDetails;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;

import '../../../domain/index.dart' show FileEntity, FileItem;
import '../../index.dart'
    show FavoriteStarButton, FileManagerSideMenu, FilemanagerBloc;

class AllFavoritesSection extends StatelessWidget {
  const AllFavoritesSection({
    super.key,
    required this.favorites,
    required this.theme,
    required this.horizontalPadding,
    required this.onBack,
    required this.onFavoriteToggle,
    required this.bloc,
  });

  final List<FileEntity> favorites;
  final ThemeData theme;
  final EdgeInsets horizontalPadding;
  final VoidCallback onBack;
  final Function(String) onFavoriteToggle;
  final FilemanagerBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: horizontalPadding,
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: SvgPicture.asset(
                  'assets/icons/arrow/ic-eva_arrow-ios-back-fill.svg',
                  width: 24,
                  height: 24,
                  color: theme.colorScheme.onSurface,
                ),
                tooltip: 'Back',
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'All Favorites',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (favorites.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: Center(
              child: EmptyContent(
                icon: 'assets/icons/empty/ic-content.svg',
                title: 'No favorites yet',
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: horizontalPadding.copyWith(top: 0, bottom: 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _crossAxisCount(context),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final file = favorites[index];
              return _FavoriteCard(
                file: file,
                theme: theme,
                onTap: () => showRightSideTaskDetails(
                  context,
                  BlocProvider.value(
                    value: bloc,
                    child: FileManagerSideMenu(item: FileItem(file)),
                  ),
                ),
                onFavoriteToggle: () => onFavoriteToggle(file.id),
              );
            },
          ),
      ],
    );
  }

  int _crossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 900) return 5;
    if (width > 600) return 4;
    if (width > 400) return 2;
    return 2;
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.file,
    required this.theme,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final FileEntity file;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: const BoxConstraints(
              maxHeight: 150,
              maxWidth: 180,
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? AppPallete.grey700
                    : AppPallete.grey400,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  getFileIcon(file.fileType ?? ''),
                  width: 28,
                ),
                const SizedBox(height: 10),
                Text(
                  file.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                if (file.size != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    formatFileSize(file.size!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: FavoriteStarButton(
              isFavorite: true,
              onTap: onFavoriteToggle,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
