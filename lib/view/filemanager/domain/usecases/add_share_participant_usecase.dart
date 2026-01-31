import '../../index.dart' show FilemanagerRepository, FolderFile, SharedUser;

class AddShareParticipantUsecase {
  final FilemanagerRepository repository;

  const AddShareParticipantUsecase(this.repository);

  Future<FolderFile> call(String fileId, SharedUser user) =>
      repository.addShareParticipant(fileId, user);
}
