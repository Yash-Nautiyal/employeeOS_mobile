import '../../index.dart' show FilemanagerRepository;

class MoveFileToRootUsecase {
  final FilemanagerRepository repository;

  const MoveFileToRootUsecase(this.repository);

  Future<void> call(String fileId) => repository.moveFileToRoot(fileId);
}
