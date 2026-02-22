import 'package:employeeos/core/index.dart' show showCustomToast;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'package:employeeos/view/filemanager/domain/index.dart'
    show FileEntity, FileItem, PickedFile;
import 'package:employeeos/view/filemanager/presentation/index.dart';
import 'package:employeeos/view/filemanager/index.dart'
    show FilemanagerInjection;

class FilemanagerView extends StatefulWidget {
  const FilemanagerView({super.key});

  @override
  State<FilemanagerView> createState() => _FilemanagerViewState();
}

class _FilemanagerViewState extends State<FilemanagerView> {
  final _scrollController = ScrollController();
  bool _showingAllFavorites = false;

  late FilemanagerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = FilemanagerInjection.createBloc();
    _bloc.add(FilemanagerLoadingEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _bloc.close();
    super.dispose();
  }

  /// Runs upload via bloc and completes when the upload finishes (success or error).
  Future<void> _handleUpload(List<PickedFile> picked) async {
    if (picked.isEmpty) return;
    _bloc.add(UploadFilesEvent(picked));
    await _bloc.stream
        .where(
            (s) => s is FilemanagerLoaded || s is FilemanagerErrorActionState)
        .first;
  }

  void _openUploadDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider.value(
        value: _bloc,
        child: UploadFilesDialog(
          onUpload: (picked) async {
            await _handleUpload(picked);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || wideScreen;

    return BlocProvider.value(
      value: _bloc,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10, bottom: 20),
          child: BlocConsumer<FilemanagerBloc, FilemanagerState>(
            listenWhen: (previous, current) =>
                current is FilemanagerActionState,
            buildWhen: (previous, current) =>
                current is! FilemanagerActionState,
            listener: (context, state) {
              if (state is FilemanagerErrorActionState) {
                showCustomToast(
                  context: context,
                  type: ToastificationType.error,
                  title: 'Error',
                  description: state.message,
                );
              } else if (state is FilemanagerSuccessActionState) {
                showCustomToast(
                  context: context,
                  type: ToastificationType.success,
                  title: state.message,
                );
              }
            },
            builder: (context, state) {
              if (state is FilemanagerLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is FilemanagerError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                );
              } else if (state is FilemanagerLoaded) {
                final items = state.items;
                final favorites = items
                    .whereType<FileItem>()
                    .map((i) => i.file)
                    .where((f) => f.isFavorite)
                    .toList();
                final allFiles =
                    items.whereType<FileItem>().map((i) => i.file).toList();
                final recentIds = state.recentFileIds ?? [];
                final recentFiles = recentIds.isEmpty
                    ? allFiles
                    : recentIds
                            .map((id) => allFiles
                                .cast<FileEntity?>()
                                .firstWhere((f) => f?.id == id,
                                    orElse: () => null))
                            .whereType<FileEntity>()
                            .toList() +
                        allFiles
                            .where((f) => !recentIds.contains(f.id))
                            .toList();
                final horizontalPadding =
                    EdgeInsets.symmetric(horizontal: isWideScreen ? 32 : 16.0);

                if (_showingAllFavorites) {
                  return AllFavoritesSection(
                    favorites: favorites,
                    theme: theme,
                    horizontalPadding: horizontalPadding,
                    onBack: () => setState(() => _showingAllFavorites = false),
                    onFavoriteToggle: (fileId) =>
                        _bloc.add(ToggleFavoriteEvent(fileId)),
                    bloc: _bloc,
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWideScreen ? 32 : 16.0),
                      child: FilemanagerHeader(
                        onUploadTap: () => _openUploadDialog(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWideScreen ? 32 : 16.0),
                      child: Row(
                        children: [
                          Text(
                            "Favorites",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showingAllFavorites = true),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("View all",
                                    style: theme.textTheme.labelLarge),
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
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: isWideScreen ? 32 : 16.0),
                      child: FavoritesSection(
                        screenHeight: screenHeight,
                        favorites: favorites,
                        theme: theme,
                        onFavoriteToggle: (fileId) =>
                            _bloc.add(ToggleFavoriteEvent(fileId)),
                      ),
                    ),
                    if (!isWideScreen) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      StorageSection(theme: theme),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Recent Files",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: RecentSection(
                          theme: theme,
                          files: recentFiles,
                          onFavoriteToggle: (fileId) => _bloc.add(
                            ToggleFavoriteEvent(fileId),
                          ),
                        ),
                      ),
                    ],
                    isWideScreen
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0)
                                    .copyWith(right: isWideScreen ? 32 : 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: StorageSection(
                                    theme: theme,
                                    keepExpanded: true,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Recent Files",
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          color: theme.colorScheme.tertiary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      RecentSection(
                                        theme: theme,
                                        files: recentFiles,
                                        onFavoriteToggle: (fileId) => _bloc.add(
                                          ToggleFavoriteEvent(fileId),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWideScreen ? 32 : 16.0),
                      child: FileTableScreen(
                        bloc: _bloc,
                        items: items,
                        verticalScrollController: _scrollController,
                        screenWidth: MediaQuery.of(context).size.width,
                        onFavoriteToggle: (fileId) =>
                            _bloc.add(ToggleFavoriteEvent(fileId)),
                      ),
                    )
                  ],
                );
              }
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                  'No Data Available',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.colorScheme.tertiary),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
