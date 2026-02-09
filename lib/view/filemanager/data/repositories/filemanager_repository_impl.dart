import '../../index.dart'
    show
        FilemanagerRemoteDatasource,
        FilemanagerRepository,
        FileEntity,
        FilemanagerItem,
        FolderEntity,
        PickedFile,
        SharedUser,
        UserPermission;

class FilemanagerRepositoryImpl implements FilemanagerRepository {
  final FilemanagerRemoteDatasource remoteDatasource;

  const FilemanagerRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<FilemanagerItem>> fetchFiles() async {
    return remoteDatasource.fetchFoldersFiles();
  }

  @override
  Future<List<String>> getRecentFileIds() =>
      remoteDatasource.getRecentFileIds();

  @override
  Future<void> logFileActivity(String fileId) =>
      remoteDatasource.logFileActivity(fileId);

  @override
  Future<void> toggleFavoriteFile(String fileId, bool currentlyFavorited) {
    return remoteDatasource.toggleFavoriteFile(fileId, currentlyFavorited);
  }

  @override
  Future<void> toggleFavoriteFolder(String folderId, bool currentlyFavorited) {
    return remoteDatasource.toggleFavorite(folderId, true, currentlyFavorited);
  }

  @override
  Future<List<FileEntity>> uploadFiles(List<PickedFile> files,
      {String? folderId}) async {
    if (files.isEmpty) return [];
    return remoteDatasource.uploadFiles(
      files
          .map((f) => (
                name: f.name,
                size: f.size,
                fileType: f.fileType,
                path: f.path,
              ))
          .toList(),
      folderId: folderId,
    );
  }

  @override
  Future<void> deleteFile(String fileId) => remoteDatasource.deleteFile(fileId);

  @override
  Future<void> moveFileToFolder(String fileId, String folderId) =>
      remoteDatasource.moveFileToFolder(fileId, folderId);

  @override
  Future<void> moveFileToRoot(String fileId) =>
      remoteDatasource.moveFileToRoot(fileId);

  @override
  Future<FolderEntity> createFolder(String folderName,
          {List<String>? fileIds}) =>
      remoteDatasource.createFolder(folderName, fileIds: fileIds);

  @override
  Future<void> deleteFolder(String folderId) =>
      remoteDatasource.deleteFolder(folderId);

  @override
  Future<FileEntity> updateTags(String fileId, List<String> tags) =>
      remoteDatasource.updateTags(fileId, tags);

  @override
  Future<void> addTag(String fileId, String tagName,
          {required bool isPersonal}) =>
      remoteDatasource.addTag(fileId, tagName, isPersonal: isPersonal);

  @override
  Future<void> deleteTag(String fileId, String tagName,
          {required bool isPersonal}) =>
      remoteDatasource.deleteTag(fileId, tagName, isPersonal: isPersonal);

  @override
  Future<FileEntity> addShareParticipant(String fileId, SharedUser user) =>
      remoteDatasource.addShareParticipant(fileId, user);

  @override
  Future<FileEntity> updateSharePermission(
          String fileId, String userId, UserPermission permission) =>
      remoteDatasource.updateSharePermission(fileId, userId, permission);

  @override
  Future<FileEntity> removeShareParticipant(String fileId, String userId) =>
      remoteDatasource.removeShareParticipant(fileId, userId);

  @override
  Future<List<SharedUser>> fetchUsers() => remoteDatasource.fetchUsers();
}
