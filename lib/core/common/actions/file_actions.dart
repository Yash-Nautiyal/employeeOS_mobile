String getFileIcon(String fileType) {
  final extension = fileType.split('/').last.toLowerCase();

  switch (extension) {
    case 'txt':
      return 'assets/icons/file/ic-txt.svg';
    case 'zip':
    case 'rar':
      return 'assets/icons/file/ic-zip.svg';
    case 'pdf':
      return 'assets/icons/file/ic-pdf.svg';
    case 'doc':
    case 'docx':
      return 'assets/icons/file/ic-doc.svg';
    case 'xls':
    case 'xlsx':
      return 'assets/icons/file/ic-excel.svg';
    case 'ppt':
    case 'pptx':
      return 'assets/icons/file/ic-power-point.svg';
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return 'assets/icons/file/ic-img.svg';
    case 'mp4':
    case 'mkv':
    case 'avi':
      return 'assets/icons/file/ic-video.svg';
    case 'mp3':
    case 'wav':
      return 'assets/icons/file/ic-audio.svg';
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
