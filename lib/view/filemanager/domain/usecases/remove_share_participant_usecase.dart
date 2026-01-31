import '../../index.dart' show FilemanagerRepository, FolderFile;

class RemoveShareParticipantUsecase {
  final FilemanagerRepository repository;

  const RemoveShareParticipantUsecase(this.repository);

  Future<FolderFile> call(String fileId, String userId) =>
      repository.removeShareParticipant(fileId, userId);
}
