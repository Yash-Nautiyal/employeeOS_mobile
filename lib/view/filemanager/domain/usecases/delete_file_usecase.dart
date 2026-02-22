import '../index.dart' show FilemanagerRepository;

class DeleteFileUsecase {
  final FilemanagerRepository repository;

  const DeleteFileUsecase(this.repository);

  Future<void> call(String fileId) => repository.deleteFile(fileId);
}
