import 'package:equatable/equatable.dart';

enum FileType { file, folder }

enum UserPermission { view, edit }

class FolderFile extends Equatable {
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
  final List<String>? tags;

  const FolderFile({
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
    this.tags,
  });

  bool get isFolder => type == FileType.folder;

  @override
  List<Object?> get props => [
        id,
        name,
        path,
        type,
        createdAt,
        isFavorite,
        size,
        fileCount,
        sharedWith,
        fileType,
        tags,
      ];
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

/// Represents a file picked for upload (e.g. from file_picker). Used by upload use case.
class PickedFile {
  final String name;
  final int size;
  final String fileType;

  const PickedFile({
    required this.name,
    required this.size,
    this.fileType = '',
  });
}
