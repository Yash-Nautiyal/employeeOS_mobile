import '../index.dart' show FilemanagerRepository, SharedUser;

class AddShareParticipantUsecase {
  final FilemanagerRepository repository;

  const AddShareParticipantUsecase(this.repository);

  Future<void> call(String fileId, SharedUser user) =>
      repository.addShareParticipant(fileId, user);
}
