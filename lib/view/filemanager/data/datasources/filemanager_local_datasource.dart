import 'package:uuid/uuid.dart';

import '../../index.dart' show FilemanagerFilesModel, mockFiles;
import '../../domain/entities/files_models.dart'
    show FileType, SharedUser, UserPermission;

class FilemanagerLocalDatasource {
  static List<FilemanagerFilesModel> globalfiles = [];
  const FilemanagerLocalDatasource();

  Future<List<FilemanagerFilesModel>> fetchFoldersFiles() async {
    if (globalfiles.isEmpty) {
      final files = mockFiles();
      final convertedFiles = files
          .map(
            (e) => FilemanagerFilesModel(
              id: e.id,
              name: e.name,
              path: e.path,
              type: e.type,
              createdAt: e.createdAt,
              isFavorite: e.isFavorite,
              sharedWith: e.sharedWith,
              fileCount: e.fileCount,
              size: e.size,
              fileType: e.fileType,
              tags: e.tags,
            ),
          )
          .toList();
      globalfiles.addAll(convertedFiles);
    }
    return List.from(globalfiles);
  }

  /// Adds uploaded files to in-memory list. Replace this with DB call later.
  Future<List<FilemanagerFilesModel>> uploadFiles(
    List<({String name, int size, String fileType})> files,
  ) async {
    const uuid = Uuid();
    final now = DateTime.now();
    final newModels = files
        .map(
          (f) => FilemanagerFilesModel(
            id: uuid.v4(),
            name: f.name,
            path: '/documents/${f.name}',
            type: FileType.file,
            createdAt: now,
            isFavorite: false,
            size: f.size,
            fileType: f.fileType.isEmpty ? null : f.fileType,
            tags: const [],
          ),
        )
        .toList();
    globalfiles.addAll(newModels);
    return newModels;
  }

  Future<FilemanagerFilesModel> toggleFavoriteFile(String fileId) async {
    final index = globalfiles.indexWhere((file) => file.id == fileId);
    if (index == -1) throw Exception('File not found');
    final file = globalfiles[index];
    final updatedFile = file.copyWith(isFavorite: !file.isFavorite);
    globalfiles[index] = updatedFile;

    return updatedFile;
  }

  /// Remove file by id. Replace with DB call later.
  Future<void> deleteFile(String fileId) async {
    globalfiles.removeWhere((f) => f.id == fileId);
  }

  /// Update tags for a file. Replace with DB call later.
  Future<FilemanagerFilesModel> updateTags(
      String fileId, List<String> tags) async {
    final index = globalfiles.indexWhere((f) => f.id == fileId);
    final file = globalfiles[index];
    final updated = file.copyWith(tags: tags);
    globalfiles[index] = updated;
    return updated;
  }

  /// Add a share participant. Replace with DB call later.
  Future<FilemanagerFilesModel> addShareParticipant(
      String fileId, SharedUser user) async {
    final index = globalfiles.indexWhere((f) => f.id == fileId);
    final file = globalfiles[index];
    final current = file.sharedWith ?? [];
    if (current.any((u) => u.id == user.id)) return file;
    final updated = file.copyWith(sharedWith: [...current, user]);
    globalfiles[index] = updated;
    return updated;
  }

  /// Update one participant's permission. Replace with DB call later.
  Future<FilemanagerFilesModel> updateSharePermission(
      String fileId, String userId, UserPermission permission) async {
    final index = globalfiles.indexWhere((f) => f.id == fileId);
    final file = globalfiles[index];
    final current = file.sharedWith ?? [];
    final updatedList = current
        .map((u) => u.id == userId
            ? SharedUser(
                id: u.id,
                name: u.name,
                email: u.email,
                avatarUrl: u.avatarUrl,
                permission: permission,
              )
            : u)
        .toList();
    final updated = file.copyWith(sharedWith: updatedList);
    globalfiles[index] = updated;
    return updated;
  }

  /// Remove a share participant. Replace with DB call later.
  Future<FilemanagerFilesModel> removeShareParticipant(
      String fileId, String userId) async {
    final index = globalfiles.indexWhere((f) => f.id == fileId);
    final file = globalfiles[index];
    final current = file.sharedWith ?? [];
    final updatedList = current.where((u) => u.id != userId).toList();
    final updated = file.copyWith(sharedWith: updatedList);
    globalfiles[index] = updated;
    return updated;
  }
}
