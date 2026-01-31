import '../../index.dart' show FilemanagerRepository, FolderFile;

class UpdateTagsUsecase {
  final FilemanagerRepository repository;

  const UpdateTagsUsecase(this.repository);

  Future<FolderFile> call(String fileId, List<String> tags) =>
      repository.updateTags(fileId, tags);
}
