import '../../index.dart' show FilemanagerRepository, FilemanagerItem;

class FetchFilesUsecase {
  final FilemanagerRepository repository;

  const FetchFilesUsecase(this.repository);

  Future<List<FilemanagerItem>> fetchFoldersFiles() {
    return repository.fetchFiles();
  }
}
