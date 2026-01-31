import '../../index.dart' show FilemanagerRepository, FolderFile;

class FetchFilesUsecase {
  final FilemanagerRepository repository;

  const FetchFilesUsecase(this.repository);

  Future<List<FolderFile>> fetchFoldersFiles() {
    return repository.fetchFiles();
  }
}
