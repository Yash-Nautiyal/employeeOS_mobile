import 'package:employeeos/view/filemanager/domain/entities/filemanager_models.dart';

List<FolderFile> mockFiles() {
  return [
    FolderFile(
      id: '0',
      name: 'dgiengineering-sr_council-4162d7d3c21a 2 (1).zip',
      path: '/documents/dgiengineering-sr_council-4162d7d3c21a 2 (1).zip',
      size: (2.75 * 1024 * 1024).round(),
      fileType: 'zip',
      type: FileType.file,
      createdAt: DateTime(2025, 5, 17, 8, 22),
      isFavorite: false,
      sharedWith: [
        SharedUser(
          id: '1',
          name: 'Yash',
          email: 'yash.nautiyal@f13.tech',
          avatarUrl: 'https://avatar.iran.liara.run/public/23',
        ),
        SharedUser(
            id: '1',
            name: 'Yash',
            email: 'yash.nautiyal@f13.tech',
            avatarUrl: 'https://avatar.iran.liara.run/public/6'),
        SharedUser(
            id: '1',
            name: 'Yash',
            email: 'yash.nautiyal@f13.tech',
            avatarUrl: 'https://avatar.iran.liara.run/public/48'),
        SharedUser(
            id: '1',
            name: 'Yash',
            email: 'yash.nautiyal@f13.tech',
            avatarUrl: 'https://avatar.iran.liara.run/public/45'),
        SharedUser(
            id: '1',
            name: 'Yash',
            email: 'yash.nautiyal@f13.tech',
            avatarUrl: 'https://avatar.iran.liara.run/public/19'),
      ],
    ),

    // add more files with different dates for testing date range filtering
    FolderFile(
      id: '1',
      name: 'project_documentation.pdf',
      path: '/documents/project_documentation.pdf',
      size: (1.2 * 1024 * 1024).round(),
      fileType: 'pdf',
      type: FileType.file,
      createdAt: DateTime.now().subtract(const Duration(days: 5)), // 5 days ago
      isFavorite: false,
    ),
    FolderFile(
      id: '2',
      name: 'meeting_notes.docx',
      path: '/documents/meeting_notes.docx',
      size: (256 * 1024).round(),
      fileType: 'word',
      type: FileType.file,
      createdAt: DateTime.now().subtract(const Duration(days: 3)), // 3 days ago
      isFavorite: true,
    ),
    FolderFile(
      id: '3',
      name: 'budget_spreadsheet.xlsx',
      path: '/documents/budget_spreadsheet.xlsx',
      size: (512 * 1024).round(),
      fileType: 'excel',
      type: FileType.file,
      createdAt: DateTime.now().subtract(const Duration(days: 1)), // 1 day ago
      isFavorite: false,
    ),
    FolderFile(
      id: '4',
      name: 'presentation.pptx',
      path: '/documents/presentation.pptx',
      size: (3.5 * 1024 * 1024).round(),
      fileType: 'powerpoint',
      type: FileType.file,
      createdAt: DateTime.now(), // Today
      isFavorite: true,
    ),
    FolderFile(
      id: '5',
      name: 'design_mockups.psd',
      path: '/documents/design_mockups.psd',
      size: (8.2 * 1024 * 1024).round(),
      fileType: 'photoshop',
      type: FileType.file,
      createdAt: DateTime.now().subtract(const Duration(days: 7)), // 7 days ago
      isFavorite: false,
    ),
    FolderFile(
      id: '6',
      name: 'logo_assets.ai',
      path: '/documents/logo_assets.ai',
      size: (2.1 * 1024 * 1024).round(),
      fileType: 'illustrator',
      type: FileType.file,
      createdAt:
          DateTime.now().subtract(const Duration(days: 10)), // 10 days ago
      isFavorite: true,
    ),
    FolderFile(
      id: '7',
      name: 'team_photo.jpg',
      path: '/documents/team_photo.jpg',
      size: (1.8 * 1024 * 1024).round(),
      fileType: 'image',
      type: FileType.file,
      createdAt: DateTime.now().subtract(const Duration(days: 2)), // 2 days ago
      isFavorite: false,
    ),
    FolderFile(
      id: '8',
      name: 'audio_recording.mp3',
      path: '/documents/audio_recording.mp3',
      size: (4.5 * 1024 * 1024).round(),
      fileType: 'audio',
      type: FileType.file,
      createdAt: DateTime.now().subtract(const Duration(days: 4)), // 4 days ago
      isFavorite: true,
    ),
    FolderFile(
      id: '9',
      name: 'video_demo.mp4',
      path: '/documents/video_demo.mp4',
      size: (25.8 * 1024 * 1024).round(),
      fileType: 'video',
      type: FileType.file,
      createdAt: DateTime.now().subtract(const Duration(days: 6)), // 6 days ago
      isFavorite: false,
    ),
    FolderFile(
      id: '10',
      name: 'archive_folder',
      path: '/documents/archive_folder',
      type: FileType.folder,
      createdAt:
          DateTime.now().subtract(const Duration(days: 15)), // 15 days ago
      isFavorite: false,
      fileCount: 12,
    ),
    // Add more files with various dates for comprehensive testing
    for (int i = 11; i < 30; i++)
      FolderFile(
        id: '$i',
        name: "file_$i.txt",
        path: '/documents/file_$i.txt',
        size: (1024 * (i % 5 + 1)).round(),
        fileType: 'txt',
        type: FileType.file,
        createdAt: DateTime.now()
            .subtract(Duration(days: i % 20)), // Spread across 20 days
        isFavorite: i % 3 == 0,
      ),
  ];
}
