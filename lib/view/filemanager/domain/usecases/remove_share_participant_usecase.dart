import '../index.dart' show FilemanagerRepository;

class RemoveShareParticipantUsecase {
  final FilemanagerRepository repository;

  const RemoveShareParticipantUsecase(this.repository);

  Future<void> call(String fileId, String userId) =>
      repository.removeShareParticipant(fileId, userId);
}
