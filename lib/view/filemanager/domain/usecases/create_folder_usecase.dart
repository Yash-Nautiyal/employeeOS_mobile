import '../../index.dart' show FilemanagerRepository, FolderEntity;

class CreateFolderUsecase {
  final FilemanagerRepository repository;

  const CreateFolderUsecase(this.repository);

  Future<FolderEntity> call(String folderName, {List<String>? fileIds}) =>
      repository.createFolder(folderName, fileIds: fileIds);
}
