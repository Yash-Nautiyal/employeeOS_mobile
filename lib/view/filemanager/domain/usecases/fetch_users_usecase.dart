import '../index.dart' show FilemanagerRepository, SharedUser;

class FetchUsersUsecase {
  final FilemanagerRepository repository;

  const FetchUsersUsecase(this.repository);

  Future<List<SharedUser>> call() => repository.fetchUsers();
}
