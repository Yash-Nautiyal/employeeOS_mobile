import '../../index.dart'
    show
        FilemanagerRemoteDatasource,
        FilemanagerRepository,
        FolderFile,
        PickedFile,
        SharedUser,
        UserPermission;

class FilemanagerRepositoryImpl implements FilemanagerRepository {
  final FilemanagerRemoteDatasource remoteDatasource;

  const FilemanagerRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<FolderFile>> fetchFiles() async {
    return remoteDatasource.fetchFoldersFiles();
  }

  @override
  Future<FolderFile> toggleFavoriteFile(String fileId) {
    return remoteDatasource.toggleFavoriteFile(fileId);
  }

  @override
  Future<List<FolderFile>> uploadFiles(List<PickedFile> files) async {
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
    );
  }

  @override
  Future<void> deleteFile(String fileId) => remoteDatasource.deleteFile(fileId);

  @override
  Future<FolderFile> updateTags(String fileId, List<String> tags) =>
      remoteDatasource.updateTags(fileId, tags);

  @override
  Future<FolderFile> addShareParticipant(String fileId, SharedUser user) =>
      remoteDatasource.addShareParticipant(fileId, user);

  @override
  Future<FolderFile> updateSharePermission(
          String fileId, String userId, UserPermission permission) =>
      remoteDatasource.updateSharePermission(fileId, userId, permission);

  @override
  Future<FolderFile> removeShareParticipant(String fileId, String userId) =>
      remoteDatasource.removeShareParticipant(fileId, userId);
}
