// import 'package:uuid/uuid.dart';

// import '../../domain/entities/files_models.dart'
//     show
//         FileEntity,
//         FileItem,
//         FilemanagerItem,
//         PickedFile,
//         SharedUser,
//         UserPermission;
// import '../../index.dart' show FilemanagerFileModel, mockFiles;

// class FilemanagerLocalDatasource {
//   static List<FilemanagerItem> globalfiles = [];
//   const FilemanagerLocalDatasource();

//   Future<List<FilemanagerItem>> fetchFoldersFiles() async {
//     if (globalfiles.isEmpty) {
//       globalfiles.addAll(mockFiles());
//     }
//     return List.from(globalfiles);
//   }

//   /// Adds uploaded files to in-memory list. Replace this with DB call later.
//   Future<List<FileEntity>> uploadFiles(List<PickedFile> files) async {
//     const uuid = Uuid();
//     final now = DateTime.now();
//     final newItems = files.map(
//       (f) {
//         final model = FilemanagerFileModel(
//           id: uuid.v4(),
//           name: f.name,
//           path: f.path ?? '/documents/${f.name}',
//           createdAt: now,
//           isFavorite: false,
//           size: f.size,
//           fileType: f.fileType.isEmpty ? null : f.fileType,
//           tags: const [],
//         );
//         return FileItem(model.toEntity());
//       },
//     ).toList();
//     globalfiles.addAll(newItems);
//     return newItems.map((e) => (e).file).toList();
//   }

//   Future<FileEntity> toggleFavoriteFile(String fileId) async {
//     final index = globalfiles.indexWhere((item) => item.id == fileId);
//     if (index == -1) throw Exception('File not found');
//     final item = globalfiles[index];
//     if (item is! FileItem) throw Exception('Not a file');
//     final updated =
//         FileItem(item.file.copyWith(isFavorite: !item.file.isFavorite));
//     globalfiles[index] = updated;
//     return updated.file;
//   }

//   /// Remove file by id. Replace with DB call later.
//   Future<void> deleteFile(String fileId) async {
//     globalfiles.removeWhere((item) => item.id == fileId);
//   }

//   /// Update tags for a file. Replace with DB call later.
//   Future<FileEntity> updateTags(String fileId, List<String> tags) async {
//     final index = globalfiles.indexWhere((item) => item.id == fileId);
//     final item = globalfiles[index];
//     if (item is! FileItem) throw Exception('Not a file'); 
//     final updated = FileItem(item.file.copyWith(tags: tags));
//     globalfiles[index] = updated;
//     return updated.file;
//   }

//   /// Add a share participant. Replace with DB call later.
//   Future<FileEntity> addShareParticipant(String fileId, SharedUser user) async {
//     final index = globalfiles.indexWhere((item) => item.id == fileId);
//     final item = globalfiles[index];
//     if (item is! FileItem) throw Exception('Not a file');
//     final current = item.file.sharedWith ?? [];
//     if (current.any((u) => u.id == user.id)) return item.file;
//     final updated =
//         FileItem(item.file.copyWith(sharedWith: [...current, user]));
//     globalfiles[index] = updated;
//     return updated.file;
//   }

//   /// Update one participant's permission. Replace with DB call later.
//   Future<FileEntity> updateSharePermission(
//       String fileId, String userId, UserPermission permission) async {
//     final index = globalfiles.indexWhere((item) => item.id == fileId);
//     final item = globalfiles[index];
//     if (item is! FileItem) throw Exception('Not a file');
//     final current = item.file.sharedWith ?? [];
//     final updatedList = current
//         .map((u) => u.id == userId
//             ? SharedUser(
//                 id: u.id,
//                 name: u.name,
//                 email: u.email,
//                 avatarUrl: u.avatarUrl,
//                 permission: permission,
//               )
//             : u)
//         .toList();
//     final updated = FileItem(item.file.copyWith(sharedWith: updatedList));
//     globalfiles[index] = updated;
//     return updated.file;
//   }

//   /// Remove a share participant. Replace with DB call later.
//   Future<FileEntity> removeShareParticipant(
//       String fileId, String userId) async {
//     final index = globalfiles.indexWhere((item) => item.id == fileId);
//     final item = globalfiles[index];
//     if (item is! FileItem) throw Exception('Not a file');
//     final current = item.file.sharedWith ?? [];
//     final updatedList = current.where((u) => u.id != userId).toList();
//     final updated = FileItem(
//       item.file.copyWith(sharedWith: updatedList.isEmpty ? null : updatedList),
//     );
//     globalfiles[index] = updated;
//     return updated.file;
//   }
// }
