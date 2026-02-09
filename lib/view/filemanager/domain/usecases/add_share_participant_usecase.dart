import '../../index.dart' show FileEntity, FilemanagerRepository, SharedUser;

class AddShareParticipantUsecase {
  final FilemanagerRepository repository;

  const AddShareParticipantUsecase(this.repository);

  Future<FileEntity> call(String fileId, SharedUser user) =>
      repository.addShareParticipant(fileId, user);
}
