import 'package:employeeos/core/index.dart' show UserInfoService;
import '../../index.dart';

/// Central place to build [FilemanagerBloc] and its dependencies.
/// Use this from the filemanager view (or route) so the UI stays free of wiring.
class FilemanagerInjection {
  FilemanagerInjection._();
  static FilemanagerBloc createBloc({UserInfoService? userInfoService}) {
    final remote =
        FilemanagerRemoteDatasource(userInfoService: userInfoService);
    final repository = FilemanagerRepositoryImpl(remote);
    return FilemanagerBloc(
      fetchFileUsecase: FetchFilesUsecase(repository),
      getRecentFileIdsUsecase: GetRecentFileIdsUsecase(repository),
      fetchUsersUsecase: FetchUsersUsecase(repository),
      toggleFavoritesUsecase: ToggleFavoritesUsecase(repository),
      toggleFolderFavoriteUsecase: ToggleFolderFavoriteUsecase(repository),
      uploadFilesUsecase: UploadFilesUsecase(repository),
      deleteFileUsecase: DeleteFileUsecase(repository),
      deleteFolderUsecase: DeleteFolderUsecase(repository),
      createFolderUsecase: CreateFolderUsecase(repository),
      moveFileToFolderUsecase: MoveFileToFolderUsecase(repository),
      moveFileToRootUsecase: MoveFileToRootUsecase(repository),
      logFileActivityUsecase: LogFileActivityUsecase(repository),
      updateTagsUsecase: UpdateTagsUsecase(repository),
      addTagUsecase: AddTagUsecase(repository),
      deleteTagUsecase: DeleteTagUsecase(repository),
      addShareParticipantUsecase: AddShareParticipantUsecase(repository),
      updateSharePermissionUsecase: UpdateSharePermissionUsecase(repository),
      removeShareParticipantUsecase: RemoveShareParticipantUsecase(repository),
    );
  }
}
