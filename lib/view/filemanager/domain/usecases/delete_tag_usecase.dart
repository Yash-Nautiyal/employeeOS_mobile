import '../index.dart' show FilemanagerRepository;

class DeleteTagUsecase {
  final FilemanagerRepository repository;

  const DeleteTagUsecase(this.repository);

  Future<void> call(String fileId, String tagName,
          {required bool isPersonal}) =>
      repository.deleteTag(fileId, tagName, isPersonal: isPersonal);
}
