import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/files_models.dart'
    show FileType, SharedUser, UserPermission;
import '../models/filemanager_files_model.dart';

/// Remote datasource for file manager using Supabase (files, folders,
/// file_sharing, file_favorites, storage bucket file_attachments).
/// Requires an authenticated user; uses [Supabase.instance.client].
class FilemanagerRemoteDatasource {
  FilemanagerRemoteDatasource() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  static const String _bucket = 'file_attachments';

  String? get _userId => _client.auth.currentUser?.id;

  /// Throws if no authenticated user.
  void _requireUser() {
    if (_userId == null) {
      throw Exception('File manager requires an authenticated user');
    }
  }

  /// Fetches owned files, shared files, folders, favorites, and sharing info,
  /// then returns a merged list of [FilemanagerFilesModel] (folders + files).
  Future<List<FilemanagerFilesModel>> fetchFoldersFiles() async {
    _requireUser();
    final userId = _userId!;

    // 1) Owned files
    final ownedRes = await _client
        .from('files')
        .select(
            'id, user_id, file_name, file_size, file_type, storage_url, created_at, folder_id')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final ownedFiles = (ownedRes as List).cast<Map<String, dynamic>>();

    // 2) Shared files (shared with this user)
    final sharedRes = await _client
        .from('file_sharing')
        .select(
            'file_id, access_type, files(id, user_id, file_name, file_size, file_type, storage_url, created_at, folder_id)')
        .eq('shared_with', userId);
    final sharedRows = (sharedRes as List).cast<Map<String, dynamic>>();

    // 3) All file IDs for sharing data
    final fileIds = <String>{
      ...ownedFiles.map((f) => f['id'] as String),
      ...sharedRows.map((s) => s['file_id'] as String),
    }.toList();

    List<Map<String, dynamic>> sharingData = [];
    if (fileIds.isNotEmpty) {
      final sharingRes = await _client
          .from('file_sharing')
          .select('file_id, shared_with, access_type')
          .inFilter('file_id', fileIds);
      sharingData = (sharingRes as List).cast<Map<String, dynamic>>();
    }

    // 4) User details for shared users
    final sharedUserIds =
        sharingData.map((s) => s['shared_with'] as String).toSet().toList();
    List<Map<String, dynamic>> sharedUsers = [];
    if (sharedUserIds.isNotEmpty) {
      final usersRes = await _client
          .from('user_info')
          .select('id, full_name, email, avatar_url')
          .inFilter('id', sharedUserIds);
      sharedUsers = (usersRes as List).cast<Map<String, dynamic>>();
    }

    final sharedMap = <String, List<SharedUser>>{};
    for (final share in sharingData) {
      final uid = share['shared_with'] as String?;
      Map<String, dynamic>? user;
      for (final u in sharedUsers) {
        if (u['id'] == uid) {
          user = u;
          break;
        }
      }
      final fileId = share['file_id'] as String;
      sharedMap.putIfAbsent(fileId, () => []);
      sharedMap[fileId]!.add(SharedUser(
        id: uid ?? '',
        name: user?['full_name'] as String? ?? 'Unknown',
        email: user?['email'] as String? ?? '',
        avatarUrl: user?['avatar_url'] as String? ?? '',
        permission: (share['access_type'] as String?) == 'edit'
            ? UserPermission.edit
            : UserPermission.view,
      ));
    }

    // 5) Favorites
    final favRes = await _client
        .from('file_favorites')
        .select('file_id, folder_id')
        .eq('user_id', userId);
    final favoritesList = (favRes as List).cast<Map<String, dynamic>>();
    final favoriteFileIds = favoritesList
        .map((f) => f['file_id'] as String?)
        .whereType<String>()
        .toSet();
    final favoriteFolderIds = favoritesList
        .map((f) => f['folder_id'] as String?)
        .whereType<String>()
        .toSet();

    // 6) Folders
    final foldersRes = await _client
        .from('folders')
        .select('id, folder_name, parent_id, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    final foldersData = (foldersRes as List).cast<Map<String, dynamic>>();

    // 7) Folder sizes and file counts
    final folderMap = <String, ({int totalFiles, int totalSize})>{};
    for (final file in ownedFiles) {
      final fid = file['folder_id'] as String?;
      if (fid == null) continue;
      folderMap[fid] = (
        totalFiles: (folderMap[fid]?.totalFiles ?? 0) + 1,
        totalSize:
            (folderMap[fid]?.totalSize ?? 0) + (file['file_size'] as int? ?? 0),
      );
    }

    // 8) Format folders
    final folders = foldersData.map((folder) {
      final id = folder['id'] as String;
      final total = folderMap[id];
      return FilemanagerFilesModel(
        id: id,
        name: folder['folder_name'] as String,
        path: '',
        type: FileType.folder,
        createdAt: _parseDate(folder['created_at']),
        isFavorite: favoriteFolderIds.contains(id),
        size: total?.totalSize,
        fileCount: total?.totalFiles ?? 0,
        sharedWith: null,
        fileType: null,
        tags: null,
      );
    }).toList();

    // 9) Format owned files
    final ownedModels = ownedFiles.map((file) {
      final id = file['id'] as String;
      final storageUrl = file['storage_url'] as String? ?? '';
      final url = storageUrl.isEmpty
          ? ''
          : _client.storage.from(_bucket).getPublicUrl(storageUrl);
      return FilemanagerFilesModel(
        id: id,
        name: file['file_name'] as String,
        path: url,
        type: FileType.file,
        createdAt: _parseDate(file['created_at']),
        isFavorite: favoriteFileIds.contains(id),
        size: file['file_size'] as int?,
        sharedWith: sharedMap[id],
        fileType: file['file_type'] as String?,
        tags: null,
      );
    }).toList();

    // 10) Format shared files
    final sharedModels = sharedRows
        .map((record) {
          final files = record['files'];
          if (files == null || files is! Map<String, dynamic>) return null;
          final file = files;
          final id = file['id'] as String;
          final storageUrl = file['storage_url'] as String? ?? '';
          final url = storageUrl.isEmpty
              ? ''
              : _client.storage.from(_bucket).getPublicUrl(storageUrl);
          return FilemanagerFilesModel(
            id: id,
            name: file['file_name'] as String,
            path: url,
            type: FileType.file,
            createdAt: _parseDate(file['created_at']),
            isFavorite: favoriteFileIds.contains(id),
            size: file['file_size'] as int?,
            sharedWith: sharedMap[id],
            fileType: file['file_type'] as String?,
            tags: null,
          );
        })
        .whereType<FilemanagerFilesModel>()
        .toList();

    return [...folders, ...ownedModels, ...sharedModels];
  }

  DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  /// Uploads files to storage and inserts rows into [files].
  /// [files] should have [PickedFile.path] set so bytes can be read (e.g. from file_picker).
  /// [folderId] optional; uploads to root when null.
  Future<List<FilemanagerFilesModel>> uploadFiles(
    List<({String name, int size, String fileType, String? path})> files, {
    String? folderId,
  }) async {
    _requireUser();
    final userId = _userId!;
    final results = <FilemanagerFilesModel>[];

    for (final f in files) {
      String storagePath;
      if (folderId != null) {
        final folderName = await _getFolderName(folderId);
        storagePath = '$userId/$folderName/${f.name}';
      } else {
        storagePath = '$userId/${f.name}';
      }

      List<int> bytes = [];
      if (f.path != null && f.path!.isNotEmpty) {
        final file = File(f.path!);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        }
      }
      if (bytes.isEmpty) {
        throw Exception('Cannot read file: ${f.name}. Ensure path is set.');
      }

      await _client.storage.from(_bucket).uploadBinary(
            storagePath,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              contentType:
                  'application/${f.fileType.isEmpty ? 'octet-stream' : f.fileType}',
            ),
          );

      final insertRes = await _client
          .from('files')
          .insert({
            'user_id': userId,
            'folder_id': folderId,
            'file_name': f.name,
            'file_type': f.fileType.isEmpty ? 'octet-stream' : f.fileType,
            'file_size': f.size,
            'storage_url': storagePath,
          })
          .select(
              'id, user_id, file_name, file_size, file_type, storage_url, created_at, folder_id')
          .single();

      final row = insertRes;
      final id = row['id'] as String;
      final url = _client.storage.from(_bucket).getPublicUrl(storagePath);
      results.add(FilemanagerFilesModel(
        id: id,
        name: f.name,
        path: url,
        type: FileType.file,
        createdAt: _parseDate(row['created_at']),
        isFavorite: false,
        size: f.size,
        fileType: f.fileType.isEmpty ? null : f.fileType,
        tags: null,
      ));
    }
    return results;
  }

  Future<String> _getFolderName(String folderId) async {
    final map = await _client
        .from('folders')
        .select('folder_name')
        .eq('id', folderId)
        .maybeSingle();
    return map?['folder_name'] as String? ?? 'folder';
  }

  /// Deletes a file: removes from storage then deletes row. Ownership is enforced.
  Future<void> deleteFile(String fileId) async {
    _requireUser();
    final userId = _userId!;
    final row = await _client
        .from('files')
        .select('user_id, storage_url')
        .eq('id', fileId)
        .maybeSingle();
    if (row == null) throw Exception('File not found');
    if (row['user_id'] != userId) throw Exception('You do not own this file');
    final storageUrl = row['storage_url'] as String?;
    if (storageUrl != null && storageUrl.isNotEmpty) {
      await _client.storage.from(_bucket).remove([storageUrl]);
    }
    await _client.from('files').delete().eq('id', fileId).eq('user_id', userId);
  }

  /// Deletes a folder (user must own it). Child files are handled by DB CASCADE or remain; DB uses ON DELETE CASCADE for parent_id.
  Future<void> deleteFolder(String folderId) async {
    _requireUser();
    final userId = _userId!;
    await _client
        .from('folders')
        .delete()
        .eq('id', folderId)
        .eq('user_id', userId);
  }

  /// Toggles favorite for a file or folder. [isFolder] true = folder, false = file.
  Future<FilemanagerFilesModel> toggleFavorite(
      String entityId, bool isFolder, bool currentlyFavorited) async {
    _requireUser();
    final userId = _userId!;
    if (isFolder) {
      if (currentlyFavorited) {
        await _client
            .from('file_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('folder_id', entityId);
      } else {
        await _client
            .from('file_favorites')
            .insert({'user_id': userId, 'folder_id': entityId});
      }
    } else {
      if (currentlyFavorited) {
        await _client
            .from('file_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('file_id', entityId);
      } else {
        await _client
            .from('file_favorites')
            .insert({'user_id': userId, 'file_id': entityId});
      }
    }
    // Refetch full list and return the updated item (caller may replace in list)
    final list = await fetchFoldersFiles();
    for (final e in list) {
      if (e.id == entityId) return e;
    }
    throw Exception('Item not found after toggle favorite');
  }

  Future<FilemanagerFilesModel> toggleFavoriteFile(String fileId) async {
    _requireUser();
    final list = await fetchFoldersFiles();
    for (final e in list) {
      if (e.id == fileId && e.type == FileType.file) {
        return toggleFavorite(fileId, false, e.isFavorite);
      }
    }
    throw Exception('File not found');
  }

  Future<FilemanagerFilesModel> addShareParticipant(
      String fileId, SharedUser user) async {
    _requireUser();
    final userId = _userId!;
    final fileRow = await _client
        .from('files')
        .select('user_id')
        .eq('id', fileId)
        .maybeSingle();
    if (fileRow == null || fileRow['user_id'] != userId) {
      throw Exception('You do not own this file');
    }
    await _client.from('file_sharing').upsert({
      'file_id': fileId,
      'shared_with': user.id,
      'access_type': user.permission == UserPermission.edit ? 'edit' : 'view',
    });
    final list = await fetchFoldersFiles();
    for (final e in list) {
      if (e.id == fileId) return e;
    }
    throw Exception('File not found after share');
  }

  Future<FilemanagerFilesModel> updateSharePermission(
      String fileId, String sharedWithUserId, UserPermission permission) async {
    _requireUser();
    await _client
        .from('file_sharing')
        .update({
          'access_type': permission == UserPermission.edit ? 'edit' : 'view'
        })
        .eq('file_id', fileId)
        .eq('shared_with', sharedWithUserId);
    final list = await fetchFoldersFiles();
    for (final e in list) {
      if (e.id == fileId) return e;
    }
    throw Exception('File not found after update permission');
  }

  Future<FilemanagerFilesModel> removeShareParticipant(
      String fileId, String userId) async {
    _requireUser();
    await _client
        .from('file_sharing')
        .delete()
        .eq('file_id', fileId)
        .eq('shared_with', userId);
    final list = await fetchFoldersFiles();
    for (final e in list) {
      if (e.id == fileId) return e;
    }
    throw Exception('File not found after remove share');
  }

  /// Creates a folder and optionally moves [fileIds] into it.
  Future<FilemanagerFilesModel> createFolder(String folderName,
      {List<String>? fileIds}) async {
    _requireUser();
    final userId = _userId!;
    final insertRes = await _client
        .from('folders')
        .insert({
          'user_id': userId,
          'folder_name': folderName,
        })
        .select('id, folder_name, created_at')
        .single();
    final row = insertRes;
    final folderId = row['id'] as String;
    if (fileIds != null && fileIds.isNotEmpty) {
      await _client
          .from('files')
          .update({'folder_id': folderId})
          .inFilter('id', fileIds)
          .eq('user_id', userId);
    }
    return FilemanagerFilesModel(
      id: folderId,
      name: row['folder_name'] as String,
      path: '',
      type: FileType.folder,
      createdAt: _parseDate(row['created_at']),
      isFavorite: false,
      fileCount: 0,
      sharedWith: null,
      fileType: null,
      tags: null,
    );
  }

  /// Returns contents of a folder (folder row + files inside).
  Future<List<FilemanagerFilesModel>> getFolderContents(String folderId) async {
    _requireUser();
    final userId = _userId!;
    final filesRes = await _client
        .from('files')
        .select(
            'id, user_id, file_name, file_size, file_type, storage_url, created_at, folder_id')
        .eq('folder_id', folderId)
        .order('created_at', ascending: false);
    final files = (filesRes as List).cast<Map<String, dynamic>>();
    final fileIds = files.map((f) => f['id'] as String).toList();
    List<Map<String, dynamic>> sharingData = [];
    if (fileIds.isNotEmpty) {
      final sharingRes = await _client
          .from('file_sharing')
          .select('file_id, shared_with, access_type')
          .inFilter('file_id', fileIds);
      sharingData = (sharingRes as List).cast<Map<String, dynamic>>();
    }
    final sharedUserIds =
        sharingData.map((s) => s['shared_with'] as String).toSet().toList();
    List<Map<String, dynamic>> sharedUsers = [];
    if (sharedUserIds.isNotEmpty) {
      final usersRes = await _client
          .from('user_info')
          .select('id, full_name, email, avatar_url')
          .inFilter('id', sharedUserIds);
      sharedUsers = (usersRes as List).cast<Map<String, dynamic>>();
    }
    final sharedMap = <String, List<SharedUser>>{};
    for (final share in sharingData) {
      final uid = share['shared_with'] as String?;
      Map<String, dynamic>? user;
      for (final u in sharedUsers) {
        if (u['id'] == uid) {
          user = u;
          break;
        }
      }
      final fid = share['file_id'] as String;
      sharedMap.putIfAbsent(fid, () => []);
      sharedMap[fid]!.add(SharedUser(
        id: uid ?? '',
        name: user?['full_name'] as String? ?? 'Unknown',
        email: user?['email'] as String? ?? '',
        avatarUrl: user?['avatar_url'] as String? ?? '',
        permission: (share['access_type'] as String?) == 'edit'
            ? UserPermission.edit
            : UserPermission.view,
      ));
    }
    final favRes = await _client
        .from('file_favorites')
        .select('file_id')
        .eq('user_id', userId);
    final favList = (favRes as List).cast<Map<String, dynamic>>();
    final favoriteFileIds =
        favList.map((f) => f['file_id'] as String?).whereType<String>().toSet();
    final totalSize =
        files.fold<int>(0, (s, f) => s + (f['file_size'] as int? ?? 0));
    final folderRow = await _client
        .from('folders')
        .select('id, folder_name, created_at')
        .eq('id', folderId)
        .single();
    final folderFav = (await _client
            .from('file_favorites')
            .select('folder_id')
            .eq('user_id', userId)
            .eq('folder_id', folderId))
        .isNotEmpty;
    final folderModel = FilemanagerFilesModel(
      id: folderRow['id'] as String,
      name: folderRow['folder_name'] as String,
      path: '',
      type: FileType.folder,
      createdAt: _parseDate(folderRow['created_at']),
      isFavorite: folderFav,
      size: totalSize,
      fileCount: files.length,
      sharedWith: null,
      fileType: null,
      tags: null,
    );
    final fileModels = files.map((file) {
      final id = file['id'] as String;
      final storageUrl = file['storage_url'] as String? ?? '';
      final url = storageUrl.isEmpty
          ? ''
          : _client.storage.from(_bucket).getPublicUrl(storageUrl);
      return FilemanagerFilesModel(
        id: id,
        name: file['file_name'] as String,
        path: url,
        type: FileType.file,
        createdAt: _parseDate(file['created_at']),
        isFavorite: favoriteFileIds.contains(id),
        size: file['file_size'] as int?,
        sharedWith: sharedMap[id],
        fileType: file['file_type'] as String?,
        tags: null,
      );
    }).toList();
    return [folderModel, ...fileModels];
  }

  Future<void> updateFolderName(String folderId, String newName) async {
    _requireUser();
    final userId = _userId!;
    await _client
        .from('folders')
        .update({'folder_name': newName})
        .eq('id', folderId)
        .eq('user_id', userId);
  }

  Future<void> addFilesToFolder(String folderId, List<String> fileIds) async {
    _requireUser();
    final userId = _userId!;
    if (fileIds.isEmpty) return;
    await _client
        .from('files')
        .update({'folder_id': folderId})
        .inFilter('id', fileIds)
        .eq('user_id', userId);
  }

  Future<void> removeFilesFromFolder(
      String folderId, List<String> fileIds) async {
    _requireUser();
    final userId = _userId!;
    if (fileIds.isEmpty) return;
    await _client
        .from('files')
        .update({'folder_id': null})
        .inFilter('id', fileIds)
        .eq('folder_id', folderId)
        .eq('user_id', userId);
  }

  /// Tags are not stored in the current DB schema; override in local or add column later.
  Future<FilemanagerFilesModel> updateTags(
      String fileId, List<String> tags) async {
    _requireUser();
    final list = await fetchFoldersFiles();
    for (final e in list) {
      if (e.id == fileId) return e; // Return unchanged until DB has tags column
    }
    throw Exception('File not found');
  }
}
