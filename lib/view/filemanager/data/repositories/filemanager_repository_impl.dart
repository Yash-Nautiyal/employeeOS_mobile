import '../../index.dart'
    show
        FilemanagerLocalDatasource,
        FilemanagerRepository,
        FolderFile,
        PickedFile,
        SharedUser,
        UserPermission;

class FilemanagerRepositoryImpl implements FilemanagerRepository {
  final FilemanagerLocalDatasource localDatasource;

  const FilemanagerRepositoryImpl(this.localDatasource);

  @override
  Future<List<FolderFile>> fetchFiles() async {
    return localDatasource.fetchFoldersFiles();
  }

  @override
  Future<FolderFile> toggleFavoriteFile(String fileId) {
    return localDatasource.toggleFavoriteFile(fileId);
  }

  @override
  Future<List<FolderFile>> uploadFiles(List<PickedFile> files) async {
    if (files.isEmpty) return [];
    final models = await localDatasource.uploadFiles(
      files
          .map((f) => (name: f.name, size: f.size, fileType: f.fileType))
          .toList(),
    );
    return models;
  }

  @override
  Future<void> deleteFile(String fileId) => localDatasource.deleteFile(fileId);

  @override
  Future<FolderFile> updateTags(String fileId, List<String> tags) =>
      localDatasource.updateTags(fileId, tags);

  @override
  Future<FolderFile> addShareParticipant(String fileId, SharedUser user) =>
      localDatasource.addShareParticipant(fileId, user);

  @override
  Future<FolderFile> updateSharePermission(
          String fileId, String userId, UserPermission permission) =>
      localDatasource.updateSharePermission(fileId, userId, permission);

  @override
  Future<FolderFile> removeShareParticipant(String fileId, String userId) =>
      localDatasource.removeShareParticipant(fileId, userId);
}
