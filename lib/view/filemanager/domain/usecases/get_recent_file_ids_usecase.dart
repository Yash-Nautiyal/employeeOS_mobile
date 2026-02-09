import '../../index.dart' show FilemanagerRepository;

class GetRecentFileIdsUsecase {
  final FilemanagerRepository repository;

  const GetRecentFileIdsUsecase(this.repository);

  Future<List<String>> call() => repository.getRecentFileIds();
}
