enum FileType { file, folder }

enum UserPermission { view, edit }

class FolderFile {
  final String id;
  final String name;
  final String path;
  final FileType type;
  final DateTime createdAt;
  final bool isFavorite;
  final int? size;
  final int? fileCount;
  final List<SharedUser>? sharedWith;
  final String? fileType; // Only for files

  FolderFile({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.createdAt,
    required this.isFavorite,
    this.fileCount,
    this.size,
    this.sharedWith,
    this.fileType,
  });

  bool get isFolder => type == FileType.folder;
}

class StorageInfo {
  final String category;
  final int used; // in bytes
  final int total; // in bytes

  StorageInfo({
    required this.category,
    required this.used,
    required this.total,
  });

  double get usagePercentage => total == 0 ? 0 : (used / total) * 100;
}

class SharedUser {
  final String id;
  final String name;
  final String email;
  final UserPermission? permission;
  final String avatarUrl;

  SharedUser({
    required this.id,
    required this.name,
    required this.email,
    this.permission = UserPermission.view,
    required this.avatarUrl,
  });
}
