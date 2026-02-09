import 'package:employeeos/view/filemanager/domain/entities/files_models.dart'
    show FileEntity, FileItem, FilemanagerItem, SharedUser;

List<FilemanagerItem> mockFiles() {
  return [
    FileItem(
      FileEntity(
        id: '0',
        name: 'dgiengineering-sr_council-4162d7d3c21a 2 (1).zip',
        path: '/documents/dgiengineering-sr_council-4162d7d3c21a 2 (1).zip',
        size: (2.75 * 1024 * 1024).round(),
        fileType: 'zip',
        createdAt: DateTime(2025, 5, 17, 8, 22),
        isFavorite: false,
        sharedWith: [
          SharedUser(
            id: '1',
            name: 'Yash',
            email: 'yash.nautiyal@f13.tech',
            avatarUrl: 'https://api.dicebear.com/9.x/adventurer/svg?seed=Eliza',
          ),
        ],
      ),
    ),
  ];
}

List<SharedUser> mockShareUsers() {
  return [
    SharedUser(
      id: 'u1',
      name: 'Diya Mangla',
      email: 'diya.mangla@f13.tech',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
    ),
    SharedUser(
      id: 'u2',
      name: 'Tushar Bhatia',
      email: 'tushar.bhatia@f13.tech',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
    ),
    SharedUser(
      id: 'u3',
      name: 'Jasveen Kaur',
      email: 'jasveen.kaur@f13.tech',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
    ),
    SharedUser(
      id: 'u4',
      name: 'Arunima Dahal',
      email: 'arunima.dahal@f13.tech',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
    ),
    SharedUser(
      id: 'u5',
      name: 'Abhigyan Sadhanidar',
      email: 'abhigyan.sadhanidar@f13.tech',
      avatarUrl: 'https://i.pravatar.cc/150?img=18',
    ),
  ];
}
