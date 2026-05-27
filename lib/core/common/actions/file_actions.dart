import 'package:employeeos/view/filemanager/domain/entities/files_models.dart'
    show UserPermission;

String getFileIcon(String fileType) {
  final extension = fileType.split('/').last.toLowerCase();

  switch (extension) {
    case 'txt':
    case 'text':
    case 'markdown':
    case 'md':
      return 'assets/icons/file/ic-txt.svg';
    case 'zip':
    case 'rar':
      return 'assets/icons/file/ic-zip.svg';
    case 'pdf':
      return 'assets/icons/file/ic-pdf.svg';
    case 'doc':
    case 'docx':
    case 'word':
      return 'assets/icons/file/ic-document.svg';
    case 'xls':
    case 'xlsx':
    case 'csv':
    case 'excel':
      return 'assets/icons/file/ic-excel.svg';
    case 'ppt':
    case 'pptx':
    case 'powerpoint':
      return 'assets/icons/file/ic-power-point.svg';
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'image':
      return 'assets/icons/file/ic-img.svg';
    case 'mp4':
    case 'mkv':
    case 'avi':
    case 'video':
      return 'assets/icons/file/ic-video.svg';
    case 'mp3':
    case 'wav':
    case 'audio':
      return 'assets/icons/file/ic-audio.svg';
    case 'folder':
      return 'assets/icons/file/ic-folder.svg';
    case 'photoshop':
      return 'assets/icons/file/ic-pts.svg';
    case 'illustrator':
      return 'assets/icons/file/ic-ai.svg';
    default:
      return 'assets/icons/file/ic-file.svg';
  }
}

/// A utility function to format file size into human-readable units (MB, KB, Bytes).
String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B'; // Bytes
  } else if (bytes < 1024 * 1024) {
    final kb = (bytes / 1024).toStringAsFixed(2);
    return '$kb KB'; // Kilobytes
  } else {
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
    return '$mb MB'; // Megabytes
  }
}

String formatUserPermission(UserPermission permission) {
  switch (permission) {
    case UserPermission.view:
      return 'View';
    case UserPermission.edit:
      return 'Edit';
  }
}

String getExtensionFromMime(String mimeType) {
  switch (mimeType) {
    // Word Documents
    case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
    case 'application/msword':
      return 'docx';
      
    // Text/Markdown
    case 'text/markdown':
      return 'md';
      
    // PDFs
    case 'application/pdf':
      return 'pdf';
      
    // Images
    case 'image/jpeg':
    case 'image/jpg':
      return 'jpg';
    case 'image/png':
      return 'png';
      
    // Fallback for unknown types (uses your split logic)
    default:
      final parts = mimeType.split('/');
      if (parts.length > 1) {
        final subType = parts.last;
        return subType.split('.').last;
      }
      return 'unknown';
  }
}