import 'package:employeeos/view/filemanager/domain/entities/files_models.dart';

abstract class FilemanagerRepository {
  Future<List<FolderFile>> fetchFiles();

  Future<FolderFile> toggleFavoriteFile(String fileId);

  /// Uploads files. For now appends to test data; replace with DB call later.
  Future<List<FolderFile>> uploadFiles(List<PickedFile> files);

  /// Delete file by id. Replace with DB call later.
  Future<void> deleteFile(String fileId);

  /// Update tags for a file. Replace with DB call later.
  Future<FolderFile> updateTags(String fileId, List<String> tags);

  /// Add share participant. Replace with DB call later.
  Future<FolderFile> addShareParticipant(String fileId, SharedUser user);

  /// Update share permission. Replace with DB call later.
  Future<FolderFile> updateSharePermission(
      String fileId, String userId, UserPermission permission);

  /// Remove share participant. Replace with DB call later.
  Future<FolderFile> removeShareParticipant(String fileId, String userId);
}
