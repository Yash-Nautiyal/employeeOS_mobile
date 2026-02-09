import 'package:employeeos/view/filemanager/domain/entities/files_models.dart'
    show FolderEntity;

import 'filemanager_file_model.dart';

/// Data-layer model for a folder + its files as returned from RPC/queries.
/// Converts to domain [FolderEntity] via [toEntity].
class FilemanagerFolderModel {
  final String id;
  final String name;
  final String? parentId;
  final DateTime createdAt;
  final bool isFavorite;
  final int fileCount;
  final List<FilemanagerFileModel> files;

  const FilemanagerFolderModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
    this.isFavorite = false,
    required this.fileCount,
    this.files = const [],
  });

  FolderEntity toEntity() {
    return FolderEntity(
      id: id,
      name: name,
      parentId: parentId,
      createdAt: createdAt,
      isFavorite: isFavorite,
      fileCount: fileCount,
      files: files.map((f) => f.toEntity()).toList(),
    );
  }

  FilemanagerFolderModel copyWith({
    String? id,
    String? name,
    String? parentId,
    DateTime? createdAt,
    bool? isFavorite,
    int? fileCount,
    List<FilemanagerFileModel>? files,
  }) {
    return FilemanagerFolderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      fileCount: fileCount ?? this.fileCount,
      files: files ?? this.files,
    );
  }
}
