import '../../index.dart'
    show FileEntity, FilemanagerRepository, UserPermission;

class UpdateSharePermissionUsecase {
  final FilemanagerRepository repository;

  const UpdateSharePermissionUsecase(this.repository);

  Future<FileEntity> call(
          String fileId, String userId, UserPermission permission) =>
      repository.updateSharePermission(fileId, userId, permission);
}
