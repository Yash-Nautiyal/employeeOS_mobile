import 'package:employeeos/view/filemanager/domain/entities/files_models.dart'
    show FileEntity, FileRole, FileTag, SharedUser;

/// Data-layer model for a file row coming from Supabase / RPC.
/// Maps to the domain [FileEntity] via [toEntity].
class FilemanagerFileModel {
  final String id;
  final String name;
  final String path;
  final DateTime createdAt;
  final bool isFavorite;
  final int? size;
  final String? fileType;
  final List<FileTag>? tags;
  final String? folderId;
  final String? ownerId;
  final String? ownerName;
  final String? ownerAvatarUrl;
  final FileRole? role;
  final List<SharedUser>? sharedWith;

  const FilemanagerFileModel({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    required this.isFavorite,
    this.size,
    this.fileType,
    this.tags,
    this.folderId,
    this.ownerId,
    this.ownerName,
    this.ownerAvatarUrl,
    this.role,
    this.sharedWith,
  });

  /// Convert this data model into the pure domain entity.
  FileEntity toEntity() => FileEntity(
        id: id,
        name: name,
        path: path,
        createdAt: createdAt,
        isFavorite: isFavorite,
        size: size,
        fileType: fileType,
        tags: tags,
        folderId: folderId,
        ownerId: ownerId,
        ownerName: ownerName,
        ownerAvatarUrl: ownerAvatarUrl,
        role: role,
        sharedWith: sharedWith,
      );

  factory FilemanagerFileModel.fromMap(Map<String, dynamic> map) {
    return FilemanagerFileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      path: map['path'] as String,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
      isFavorite: map['isFavorite'] as bool? ?? false,
      size: map['size'] as int?,
      fileType: map['fileType'] as String?,
      tags: (map['tags'] as List<dynamic>?)
          ?.map((t) => t is Map<String, dynamic>
              ? FileTag(
                  tagName: t['tag_name'] as String? ?? '',
                  isPersonal: t['is_personal'] as bool? ?? false,
                )
              : null)
          .whereType<FileTag>()
          .toList(),
      folderId: map['folderId'] as String?,
      ownerId: map['ownerId'] as String?,
      ownerName: map['ownerName'] as String?,
      role: _parseRole(map['role']),
      sharedWith: null,
    );
  }

  static FileRole? _parseRole(dynamic v) {
    if (v == null) return null;
    final s = v.toString().toLowerCase();
    switch (s) {
      case 'owner':
        return FileRole.owner;
      case 'editor':
        return FileRole.editor;
      case 'viewer':
        return FileRole.viewer;
      default:
        return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'createdAt': createdAt,
      'isFavorite': isFavorite,
      'size': size,
      'fileType': fileType,
      'tags': tags
          ?.map((t) => {'tag_name': t.tagName, 'is_personal': t.isPersonal})
          .toList(),
      'folderId': folderId,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'role': role?.name,
    };
  }

  FilemanagerFileModel copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? createdAt,
    bool? isFavorite,
    int? size,
    String? fileType,
    List<FileTag>? tags,
    String? folderId,
    String? ownerId,
    String? ownerName,
    String? ownerAvatarUrl,
    FileRole? role,
    List<SharedUser>? sharedWith,
  }) {
    return FilemanagerFileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      size: size ?? this.size,
      fileType: fileType ?? this.fileType,
      tags: tags ?? this.tags,
      folderId: folderId ?? this.folderId,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      role: role ?? this.role,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }
}
