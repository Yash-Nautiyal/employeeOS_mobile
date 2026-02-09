import '../../index.dart' show FilemanagerRepository;

class MoveFileToFolderUsecase {
  final FilemanagerRepository repository;

  const MoveFileToFolderUsecase(this.repository);

  Future<void> call(String fileId, String folderId) =>
      repository.moveFileToFolder(fileId, folderId);
}
