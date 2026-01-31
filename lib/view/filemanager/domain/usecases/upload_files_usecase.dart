import '../../index.dart' show FilemanagerRepository, FolderFile, PickedFile;

class UploadFilesUsecase {
  final FilemanagerRepository repository;

  const UploadFilesUsecase(this.repository);

  Future<List<FolderFile>> call(List<PickedFile> files) {
    return repository.uploadFiles(files);
  }
}
