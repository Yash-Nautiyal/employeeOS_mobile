import 'package:employeeos/view/filemanager/domain/entities/files_models.dart'
    show FolderFile, FileType, SharedUser;

class FilemanagerFilesModel extends FolderFile {
  const FilemanagerFilesModel({
    required super.id,
    required super.name,
    required super.path,
    required super.type,
    required super.createdAt,
    required super.isFavorite,
    super.size,
    super.fileCount,
    super.sharedWith,
    super.fileType,
    super.tags,
  });

  factory FilemanagerFilesModel.fromMap(Map<String, dynamic> map) {
    return FilemanagerFilesModel(
      id: map["id"] as String,
      name: map["name"] as String,
      path: map["path"] as String,
      type: map["type"] as FileType,
      createdAt: map["createdAt"] as DateTime,
      isFavorite: map["isFavorite"] as bool,
      size: map["size"] as int?,
      fileCount: map["fileCount"] as int?,
      sharedWith: map["sharedWith"] as List<SharedUser>?,
      fileType: map["fileType"] as String?,
      tags: (map["tags"] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "path": path,
      "type": type,
      "createdAt": createdAt,
      "isFavorite": isFavorite,
      "size": size,
      "fileCount": fileCount,
      "sharedWith": sharedWith,
      "fileType": fileType,
      "tags": tags,
    };
  }

  FilemanagerFilesModel copyWith({
    String? id,
    String? name,
    String? path,
    FileType? type,
    DateTime? createdAt,
    bool? isFavorite,
    int? size,
    int? fileCount,
    List<SharedUser>? sharedWith,
    String? fileType,
    List<String>? tags,
  }) {
    return FilemanagerFilesModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      size: size ?? this.size,
      fileCount: fileCount ?? this.fileCount,
      sharedWith: sharedWith ?? this.sharedWith,
      fileType: fileType ?? this.fileType,
      tags: tags ?? this.tags,
    );
  }
}
