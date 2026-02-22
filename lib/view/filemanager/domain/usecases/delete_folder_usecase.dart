import '../index.dart' show FilemanagerRepository;

class DeleteFolderUsecase {
  final FilemanagerRepository repository;

  const DeleteFolderUsecase(this.repository);

  Future<void> call(String folderId) => repository.deleteFolder(folderId);
}
