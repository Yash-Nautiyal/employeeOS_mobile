import '../entities/files_models.dart';

abstract class FilemanagerRepository {
  Future<List<FilemanagerItem>> fetchFiles();

  /// Recent file IDs from file_activity (order by activity_at DESC). Map against loaded files.
  Future<List<String>> getRecentFileIds();

  Future<void> logFileActivity(String fileId);

  Future<void> toggleFavoriteFile(String fileId, bool currentlyFavorited);

  Future<void> toggleFavoriteFolder(String folderId, bool currentlyFavorited);

  Future<List<FileEntity>> uploadFiles(List<PickedFile> files,
      {String? folderId});

  Future<void> deleteFile(String fileId);

  Future<void> moveFileToFolder(String fileId, String folderId);

  Future<void> moveFileToRoot(String fileId);

  Future<FolderEntity> createFolder(String folderName, {List<String>? fileIds});

  Future<void> deleteFolder(String folderId);

  // Future<FileEntity> updateTags(String fileId, List<String> tags);

  Future<void> addTag(String fileId, String tagName,
      {required bool isPersonal});

  Future<void> deleteTag(String fileId, String tagName,
      {required bool isPersonal});

  Future<void> addShareParticipant(String fileId, SharedUser user);

  Future<void> updateSharePermission(
      String fileId, String userId, UserPermission permission);

  Future<void> removeShareParticipant(String fileId, String userId);

  Future<List<SharedUser>> fetchUsers();
}
