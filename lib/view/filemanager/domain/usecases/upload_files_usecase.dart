import '../../index.dart' show FileEntity, FilemanagerRepository, PickedFile;

class UploadFilesUsecase {
  final FilemanagerRepository repository;

  const UploadFilesUsecase(this.repository);

  Future<List<FileEntity>> call(List<PickedFile> files, {String? folderId}) {
    return repository.uploadFiles(files, folderId: folderId);
  }
}
