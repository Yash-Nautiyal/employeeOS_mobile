import '../../index.dart'
    show FilemanagerRepository, FolderFile, UserPermission;

class UpdateSharePermissionUsecase {
  final FilemanagerRepository repository;

  const UpdateSharePermissionUsecase(this.repository);

  Future<FolderFile> call(
          String fileId, String userId, UserPermission permission) =>
      repository.updateSharePermission(fileId, userId, permission);
}
