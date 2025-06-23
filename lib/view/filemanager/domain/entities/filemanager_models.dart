enum FileType { file, folder }

class FolderFile {
  final String id;
  final String name;
  final String path;
  final FileType type;
  final DateTime createdAt;
  final bool isFavorite;
  final int? size;
  final int? fileCount;
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
    this.fileType,
  });

  bool get isFolder => type == FileType.folder;
}
