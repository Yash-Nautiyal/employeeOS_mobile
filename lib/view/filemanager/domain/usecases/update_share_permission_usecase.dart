import '../index.dart' show FilemanagerRepository, UserPermission;

class UpdateSharePermissionUsecase {
  final FilemanagerRepository repository;

  const UpdateSharePermissionUsecase(this.repository);

  Future<void> call(String fileId, String userId, UserPermission permission) =>
      repository.updateSharePermission(fileId, userId, permission);
}
