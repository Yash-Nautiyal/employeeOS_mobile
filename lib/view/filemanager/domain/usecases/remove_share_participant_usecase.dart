import '../../index.dart' show FileEntity, FilemanagerRepository;

class RemoveShareParticipantUsecase {
  final FilemanagerRepository repository;

  const RemoveShareParticipantUsecase(this.repository);

  Future<FileEntity> call(String fileId, String userId) =>
      repository.removeShareParticipant(fileId, userId);
}
