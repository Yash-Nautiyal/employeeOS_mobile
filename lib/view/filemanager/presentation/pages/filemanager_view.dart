import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employeeos/view/filemanager/presentation/bloc/filemanager_bloc.dart';
import '../../index.dart'
    show
        AddShareParticipantUsecase,
        DeleteFileUsecase,
        FavoritesSection,
        FetchFilesUsecase,
        FileTableScreen,
        FilemanagerHeader,
        FilemanagerRemoteDatasource,
        FilemanagerRepositoryImpl,
        RecentSection,
        RemoveShareParticipantUsecase,
        StorageSection,
        ToggleFavoritesUsecase,
        UpdateSharePermissionUsecase,
        UpdateTagsUsecase,
        UploadFilesDialog,
        UploadFilesUsecase;

class FilemanagerView extends StatefulWidget {
  const FilemanagerView({super.key});

  @override
  State<FilemanagerView> createState() => _FilemanagerViewState();
}

class _FilemanagerViewState extends State<FilemanagerView> {
  final _scrollController = ScrollController();

  late FilemanagerBloc _bloc;

  @override
  void initState() {
    super.initState();
    final repository = FilemanagerRepositoryImpl(FilemanagerRemoteDatasource());
    _bloc = FilemanagerBloc(
      fetchFileUsecase: FetchFilesUsecase(repository),
      toggleFavoritesUsecase: ToggleFavoritesUsecase(repository),
      uploadFilesUsecase: UploadFilesUsecase(repository),
      deleteFileUsecase: DeleteFileUsecase(repository),
      updateTagsUsecase: UpdateTagsUsecase(repository),
      addShareParticipantUsecase: AddShareParticipantUsecase(repository),
      updateSharePermissionUsecase: UpdateSharePermissionUsecase(repository),
      removeShareParticipantUsecase: RemoveShareParticipantUsecase(repository),
    );

    _bloc.add(FilemanagerLoadingEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    // final screenWidth = MediaQuery.of(context).size.width;

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
            listener: (context, state) {},
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
                final files = state.files;
                final favorites =
                    files.where((file) => file.isFavorite).toList();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWideScreen ? 32 : 16.0),
                      child: FilemanagerHeader(
                        onUploadTap: () => showDialog<void>(
                          context: context,
                          builder: (ctx) => BlocProvider.value(
                            value: _bloc,
                            child: const UploadFilesDialog(),
                          ),
                        ),
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
                            onTap: () {},
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
                          files: files,
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
                                        files: files,
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
                        files: [...files],
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
