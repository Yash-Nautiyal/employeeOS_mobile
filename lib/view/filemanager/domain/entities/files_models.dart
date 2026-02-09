import 'package:equatable/equatable.dart';

enum FileType { file, folder }

enum UserPermission { view, edit }

enum FileRole { owner, editor, viewer }

/// Tag with visibility: canonical (owner/editor, is_personal false) or personal (viewer or personal, is_personal true).
class FileTag extends Equatable {
  final String tagName;
  final bool isPersonal;

  const FileTag({required this.tagName, required this.isPersonal});

  @override
  List<Object> get props => [tagName, isPersonal];
}

class FileEntity extends Equatable {
  final String id;
  final String name;
  final String path;
  final DateTime createdAt;
  final bool isFavorite;
  final int? size;
  final String? fileType;

  /// Tags with metadata (canonical vs personal) for role-based UI.
  final List<FileTag>? tags;
  final String? folderId;
  final String? ownerId;
  final String? ownerName;
  final String? ownerAvatarUrl;

  /// Current user's role: owner, editor, or viewer.
  final FileRole? role;
  final List<SharedUser>? sharedWith;

  const FileEntity({
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

  /// Flattened tag names for backward compatibility and simple display.
  List<String> get tagNames => tags?.map((t) => t.tagName).toList() ?? const [];

  /// Sentinel for copyWith: omit to keep current folderId; pass null to clear (move to root).
  static const _omitFolderId = Object();

  FileEntity copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? createdAt,
    bool? isFavorite,
    int? size,
    String? fileType,
    List<FileTag>? tags,
    Object? folderId = _omitFolderId,
    String? ownerId,
    String? ownerName,
    String? ownerAvatarUrl,
    FileRole? role,
    List<SharedUser>? sharedWith,
  }) {
    return FileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      size: size ?? this.size,
      fileType: fileType ?? this.fileType,
      tags: tags ?? this.tags,
      folderId: identical(folderId, _omitFolderId)
          ? this.folderId
          : folderId as String?,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerAvatarUrl: ownerAvatarUrl ?? this.ownerAvatarUrl,
      role: role ?? this.role,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        path,
        createdAt,
        isFavorite,
        size,
        fileType,
        tags,
        folderId,
        ownerId,
        ownerName,
        ownerAvatarUrl,
        role,
        sharedWith
      ];
}

/// Folder entity. Contains a list of files (and optionally subfolders later).
class FolderEntity extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final int fileCount;
  final String? parentId;
  final bool isFavorite;
  final List<FileEntity> files;

  const FolderEntity({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.fileCount,
    this.parentId,
    this.isFavorite = false,
    this.files = const [],
  });

  FolderEntity copyWith({
    String? id,
    String? name,
    String? parentId,
    DateTime? createdAt,
    bool? isFavorite,
    int? fileCount,
    List<FileEntity>? files,
  }) {
    return FolderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      fileCount: fileCount ?? this.fileCount,
      files: files ?? this.files,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, parentId, createdAt, isFavorite, fileCount, files];
}

/// Union type for table/list: either a file or a folder.
sealed class FilemanagerItem extends Equatable {
  const FilemanagerItem();

  String get id => switch (this) {
        FileItem(:final file) => file.id,
        FolderItem(:final folder) => folder.id,
      };

  String get name => switch (this) {
        FileItem(:final file) => file.name,
        FolderItem(:final folder) => folder.name,
      };

  DateTime get createdAt => switch (this) {
        FileItem(:final file) => file.createdAt,
        FolderItem(:final folder) => folder.createdAt,
      };

  bool get isFile => this is FileItem;
  bool get isFolder => this is FolderItem;

  FileType get type => isFile ? FileType.file : FileType.folder;
}

final class FileItem extends FilemanagerItem {
  final FileEntity file;

  const FileItem(this.file);

  @override
  List<Object?> get props => [file];
}

final class FolderItem extends FilemanagerItem {
  final FolderEntity folder;

  const FolderItem(this.folder);

  @override
  List<Object?> get props => [folder];
}

class StorageInfo {
  final String category;
  final int used;
  final int total;

  StorageInfo({
    required this.category,
    required this.used,
    required this.total,
  });

  double get usagePercentage => total == 0 ? 0 : (used / total) * 100;
}

class SharedUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserPermission? permission;
  final String avatarUrl;

  const SharedUser({
    required this.id,
    required this.name,
    this.email = '',
    this.permission = UserPermission.view,
    this.avatarUrl = '',
  });

  SharedUser copyWith({
    String? id,
    String? name,
    String? email,
    UserPermission? permission,
    String? avatarUrl,
  }) {
    return SharedUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      permission: permission ?? this.permission,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, email, permission, avatarUrl];
}

/// Represents a file picked for upload (e.g. from file_picker).
class PickedFile {
  final String name;
  final int size;
  final String fileType;
  final String? path;

  const PickedFile({
    required this.name,
    required this.size,
    this.fileType = '',
    this.path,
  });
}
