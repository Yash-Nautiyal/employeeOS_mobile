import '../../index.dart' show FilemanagerRepository;

class AddTagUsecase {
  final FilemanagerRepository repository;

  const AddTagUsecase(this.repository);

  Future<void> call(String fileId, String tagName,
          {required bool isPersonal}) =>
      repository.addTag(fileId, tagName, isPersonal: isPersonal);
}
