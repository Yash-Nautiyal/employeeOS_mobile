import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/index.dart'
    show
        AppPallete,
        EmptyContent,
        formatFileSize,
        getFileIcon,
        showRightSideTaskDetails;
import '../../../index.dart'
    show FileEntity, FileItem, FilemanagerBloc, FileManagerSideMenu;
import '../favorite_star_button.dart';

class FavoritesSection extends StatefulWidget {
  final List<FileEntity> favorites;
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
  State<FavoritesSection> createState() => _FavoritesSectionState();
}

class _FavoritesSectionState extends State<FavoritesSection>
    with SingleTickerProviderStateMixin {
  List<FileEntity> _displayList = [];
  final Set<String> _removingIds = {};
  late AnimationController _exitController;
  late Animation<double> _exitAnimation;

  static const Duration _exitDuration = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    _displayList = List.from(widget.favorites);
    _exitController = AnimationController(
      duration: _exitDuration,
      vsync: this,
    );
    _exitAnimation = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeIn,
    );
    _exitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _displayList = List.from(widget.favorites);
          _removingIds.clear();
          _exitController.reset();
        });
      }
    });
  }

  @override
  void dispose() {
    _exitController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FavoritesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIds = widget.favorites.map((e) => e.id).toSet();
    final oldIds = _displayList.map((e) => e.id).toSet();
    final removedIds = oldIds.difference(newIds);
    final addedIds = newIds.difference(oldIds);

    if (removedIds.isNotEmpty) {
      setState(() {
        _removingIds.addAll(removedIds);
        _exitController.forward(from: 0);
      });
    } else if (addedIds.isNotEmpty) {
      setState(() {
        _displayList = List.from(widget.favorites);
      });
    }
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    FileEntity file,
    int index,
    bool isRemoving,
  ) {
    final theme = widget.theme;
    final filename = file.name;
    final filesize = file.size;

    Widget card = GestureDetector(
      onTap: () => showRightSideTaskDetails(
          context,
          BlocProvider.value(
            value: context.read<FilemanagerBloc>(),
            child: FileManagerSideMenu(item: FileItem(file)),
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
                SvgPicture.asset(
                  getFileIcon(file.fileType ?? ""),
                  width: 30,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  filename,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (filesize != null)
                  Text(
                    formatFileSize(filesize),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 30,
            child: FavoriteStarButton(
              isFavorite: true,
              onTap: () => widget.onFavoriteToggle(file.id),
              size: 22,
            ),
          ),
        ],
      ),
    );

    if (isRemoving) {
      card = AnimatedBuilder(
        animation: _exitAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: 1 - _exitAnimation.value,
            child: Transform.translate(
              offset: Offset(-20 * _exitAnimation.value, 0),
              child: child,
            ),
          );
        },
        child: card,
      );
    } else {
      card = card
          .animate(key: ValueKey(file.id))
          .fadeIn(
            duration: 280.ms,
            delay: (index * 50).ms,
            curve: Curves.easeOut,
          )
          .slideX(
            begin: 0.08,
            end: 0,
            duration: 280.ms,
            delay: (index * 50).ms,
            curve: Curves.easeOut,
          );
    }

    return card;
  }

  @override
  Widget build(BuildContext context) {
    if (_displayList.isEmpty && widget.favorites.isEmpty) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 140, minHeight: 140),
        child: const Align(
          alignment: Alignment.center,
          child: EmptyContent(
            icon: 'assets/icons/empty/ic-content.svg',
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 140, minHeight: 140),
      child: ListView.builder(
        physics: const RangeMaintainingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _displayList.length,
        itemBuilder: (context, index) {
          final file = _displayList[index];
          final isRemoving = _removingIds.contains(file.id);
          return _buildFavoriteCard(context, file, index, isRemoving);
        },
      ),
    );
  }
}
