import 'dart:io';
import 'dart:typed_data';

import 'package:employeeos/core/index.dart' show UserInfoService;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/files_models.dart'
    show
        FileEntity,
        FileItem,
        FilemanagerItem,
        FileRole,
        FileTag,
        FolderEntity,
        FolderItem,
        SharedUser,
        UserPermission;
import '../models/filemanager_file_model.dart';
import '../models/filemanager_folder_model.dart';

class FilemanagerRemoteDatasource {
  FilemanagerRemoteDatasource({UserInfoService? userInfoService})
      : _client = Supabase.instance.client,
        _userInfoService = userInfoService ?? UserInfoService();

  final SupabaseClient _client;
  final UserInfoService _userInfoService;

  static const String _bucket = 'file_attachments';

  String? get _userId => _client.auth.currentUser?.id;

  void _requireUser() {
    if (_userId == null) {
      throw Exception('File manager requires an authenticated user');
    }
  }

  Future<List<FilemanagerItem>> fetchFoldersFiles() async {
    _requireUser();
    final userId = _userId!;

    final result = await _client.rpc(
      'get_user_files',
      params: {'p_user_id': userId},
    );
    final data = result is List
        ? (result.isNotEmpty ? result.first : null) as Map<String, dynamic>?
        : result as Map<String, dynamic>?;
    if (data == null) return [];

    final list = <FilemanagerItem>[];

    final foldersRaw = data['folders'] as List<dynamic>? ?? [];
    for (final f in foldersRaw) {
      final folder = f as Map<String, dynamic>;
      final folderId = folder['id'] as String? ?? '';
      final folderName = folder['folder_name'] as String? ?? 'Folder';
      final isFolderFavorite = folder['is_favorite'] as bool? ?? false;
      final filesInFolder = folder['files'] as List<dynamic>? ?? [];
      final fileModels = filesInFolder
          .map((fileRaw) => _fileFromRpc(fileRaw as Map<String, dynamic>))
          .map((m) => m.copyWith(folderId: m.folderId ?? folderId))
          .toList();
      final folderModel = FilemanagerFolderModel(
        id: folderId,
        name: folderName,
        parentId: folder['parent_id'] as String?,
        createdAt: DateTime.now(),
        isFavorite: isFolderFavorite,
        fileCount: fileModels.length,
        files: fileModels,
      );
      list.add(FolderItem(folderModel.toEntity()));
      for (final fileModel in fileModels) {
        list.add(FileItem(fileModel.toEntity()));
      }
    }

    final rootFilesRaw = data['root_files'] as List<dynamic>? ?? [];
    for (final fileRaw in rootFilesRaw) {
      final model = _fileFromRpc(fileRaw as Map<String, dynamic>);
      list.add(FileItem(model.toEntity()));
    }

    await _enrichWithUserInfo(list);
    return list;
  }

  /// Collects all user ids from sharedWith, ownerId, and current user when viewer; fetches from user_info, enriches list in place.
  Future<void> _enrichWithUserInfo(List<FilemanagerItem> list) async {
    final userId = _userId!;
    final ids = <String>{};
    for (final item in list) {
      if (item is FileItem) {
        final file = item.file;
        for (final u in file.sharedWith ?? []) {
          ids.add(u.id);
        }
        if (file.ownerId != null && file.ownerId!.isNotEmpty) {
          ids.add(file.ownerId!);
        }
        // So we have name/avatar for the viewer's own row and for table shared column
        if (file.role == FileRole.viewer) {
          ids.add(userId);
        }
      }
    }
    if (ids.isEmpty) return;
    final users = await _userInfoService.fetchUsersByIds(ids.toList());
    final map = {for (final u in users) u.id: u};

    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      if (item is! FileItem) continue;
      final file = item.file;
      final sharedWith = file.sharedWith;
      List<SharedUser>? enrichedSharedWith = sharedWith?.map((u) {
        final info = map[u.id];
        return u.copyWith(
          name: info?.fullName ?? u.name,
          email: info?.email ?? u.email,
          avatarUrl: info?.avatarUrl ?? u.avatarUrl,
        );
      }).toList();

      // Viewer: API often returns shared_with null; show current user with name/avatar
      if (file.role == FileRole.viewer &&
          (enrichedSharedWith == null || enrichedSharedWith.isEmpty)) {
        final self = map[userId];
        if (self != null) {
          enrichedSharedWith = [
            SharedUser(
              id: userId,
              name: self.fullName,
              email: self.email,
              permission: UserPermission.view,
              avatarUrl: self.avatarUrl ?? '',
            ),
          ];
        }
      }

      final ownerInfo = file.ownerId != null ? map[file.ownerId!] : null;
      final ownerName = ownerInfo?.fullName ?? file.ownerName;
      final ownerAvatarUrl = ownerInfo?.avatarUrl ?? file.ownerAvatarUrl;

      list[i] = FileItem(file.copyWith(
        sharedWith: enrichedSharedWith,
        ownerName: ownerName,
        ownerAvatarUrl: ownerAvatarUrl,
      ));
    }
  }

  /// Recent file IDs from file_activity (order by activity_at DESC, limit 5).
  /// Map these against loaded files for "Recent" section.
  Future<List<String>> getRecentFileIds() async {
    _requireUser();
    final userId = _userId!;
    final res = await _client
        .from('file_activity')
        .select('file_id')
        .eq('user_id', userId)
        .order('activity_at', ascending: false)
        .limit(5);
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows
        .map((r) => r['file_id'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();
  }

  /// Log view/download activity for a file (calls log_file_activity RPC).
  Future<void> logFileActivity(String fileId) async {
    _requireUser();
    final userId = _userId!;
    await _client.rpc(
      'log_file_activity',
      params: {'p_user_id': userId, 'p_file_id': fileId},
    );
  }

  FilemanagerFileModel _fileFromRpc(Map<String, dynamic> file) {
    final id = file['id'] as String? ?? '';
    final fileName = file['file_name'] as String? ?? '';
    final fileType = file['file_type'] as String?;
    final fileSize = file['file_size'] as int?;
    final storageUrl = file['storage_url'] as String? ?? '';
    final createdAt = file['created_at'];
    final tagsRaw = file['tags'] as List<dynamic>? ?? [];
    final tags = tagsRaw
        .map((t) {
          final m = t as Map<String, dynamic>;
          final name = m['tag_name'] as String? ?? '';
          if (name.isEmpty) return null;
          return FileTag(
            tagName: name,
            isPersonal: m['is_personal'] as bool? ?? false,
          );
        })
        .whereType<FileTag>()
        .toList();
    final ownerId = file['owner_id'] as String?;
    final ownerName = file['owner_name'] as String?;
    final folderId = file['folder_id'] as String?;
    final role = _parseFileRole(file['role']);
    final isFavorite = file['is_favorite'] as bool? ?? false;
    final sharedWithRaw = file['shared_with'];
    final sharedWith = _parseSharedWith(sharedWithRaw);

    final path = storageUrl.isEmpty
        ? ''
        : (storageUrl.startsWith('http') || storageUrl.startsWith('https'))
            ? storageUrl
            : _client.storage.from(_bucket).getPublicUrl(storageUrl);

    return FilemanagerFileModel(
      id: id,
      name: fileName,
      path: path,
      createdAt: _parseDate(createdAt),
      isFavorite: isFavorite,
      size: fileSize,
      fileType: fileType,
      tags: tags.isEmpty ? null : tags,
      folderId: folderId,
      ownerId: ownerId,
      ownerName: ownerName,
      role: role,
      sharedWith: sharedWith,
    );
  }

  FileRole? _parseFileRole(dynamic v) {
    if (v == null) return null;
    switch (v.toString().toLowerCase()) {
      case 'owner':
        return FileRole.owner;
      case 'editor':
        return FileRole.editor;
      case 'viewer':
        return FileRole.viewer;
      default:
        return null;
    }
  }

  List<SharedUser>? _parseSharedWith(dynamic v) {
    if (v == null) return null;
    final list = v is List ? v : null;
    if (list == null || list.isEmpty) return null;
    final result = <SharedUser>[];
    for (final e in list) {
      final m = e as Map<String, dynamic>;
      final userId = m['user_id'] as String? ?? '';
      if (userId.isEmpty) continue;
      final access = m['access'] as String?;
      final permission =
          (access == null || access.toString().toLowerCase() == 'edit')
              ? UserPermission.edit
              : UserPermission.view;
      result.add(SharedUser(
        id: userId,
        name: m['name'] as String? ?? userId,
        permission: permission,
      ));
    }
    return result.isEmpty ? null : result;
  }

  DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  Future<List<FileEntity>> uploadFiles(
    List<({String name, int size, String fileType, String? path})> files, {
    String? folderId,
  }) async {
    _requireUser();
    final userId = _userId!;
    final results = <FilemanagerFileModel>[];

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
            'file_name': f.name,
            'file_type': f.fileType.isEmpty ? 'octet-stream' : f.fileType,
            'file_size': f.size,
            'storage_url': storagePath,
          })
          .select(
              'id, user_id, file_name, file_size, file_type, storage_url, created_at')
          .single();

      final row = insertRes;
      final id = row['id'] as String;
      if (folderId != null && folderId.isNotEmpty) {
        await _client.from('user_file_folders').upsert(
          {'user_id': userId, 'file_id': id, 'folder_id': folderId},
          onConflict: 'user_id,file_id',
        );
      }
      final url = _client.storage.from(_bucket).getPublicUrl(storagePath);
      results.add(FilemanagerFileModel(
        id: id,
        name: f.name,
        path: url,
        createdAt: _parseDate(row['created_at']),
        isFavorite: false,
        size: f.size,
        fileType: f.fileType.isEmpty ? null : f.fileType,
        folderId: folderId,
        role: FileRole.owner,
      ));
    }
    // Map data-layer models to domain entities before returning.
    return results.map((m) => m.toEntity()).toList();
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

  /// Move file into folder (any user — owner or shared). Uses user_file_folders per guide.
  Future<void> moveFileToFolder(String fileId, String folderId) async {
    _requireUser();
    final userId = _userId!;
    await _client.from('user_file_folders').upsert(
      {'user_id': userId, 'file_id': fileId, 'folder_id': folderId},
      onConflict: 'user_id,file_id',
    );
  }

  /// Move file to root for current user. Uses user_file_folders per guide.
  Future<void> moveFileToRoot(String fileId) async {
    _requireUser();
    final userId = _userId!;
    await _client
        .from('user_file_folders')
        .delete()
        .eq('user_id', userId)
        .eq('file_id', fileId);
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

  /// Toggles favorite for a file or folder. Returns the updated item.
  Future<void> toggleFavorite(
      String entityId, bool isFolder, bool currentlyFavorited) async {
    _requireUser();
    final userId = _userId!;
    if (isFolder) {
      if (currentlyFavorited) {
        await _client
            .from('file_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('folder_id', entityId)
            .select()
            .maybeSingle();
      } else {
        await _client
            .from('file_favorites')
            .insert({'user_id': userId, 'folder_id': entityId})
            .select()
            .single();
      }
    } else {
      if (currentlyFavorited) {
        await _client
            .from('file_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('file_id', entityId)
            .select()
            .maybeSingle();
      } else {
        await _client
            .from('file_favorites')
            .insert({'user_id': userId, 'file_id': entityId})
            .select()
            .single();
      }
    }
  }

  Future<void> toggleFavoriteFile(
    String fileId,
    bool currentlyFavorited,
  ) async {
    _requireUser();
    try {
      await toggleFavorite(fileId, false, currentlyFavorited);
    } catch (e) {
      print(e);
      throw Exception(
          'Failed to ${currentlyFavorited ? 'remove' : 'add'} favorite');
    }
  }

  Future<FileEntity> addShareParticipant(String fileId, SharedUser user) async {
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
    await _client.from('file_sharing').upsert(
      {
        'file_id': fileId,
        'shared_with': user.id,
        'access_type': user.permission == UserPermission.edit ? 'edit' : 'view',
        'shared_by': userId,
      },
      onConflict: 'file_id,shared_with',
    );
    final list = await fetchFoldersFiles();
    for (final e in list) {
      if (e is FileItem && e.file.id == fileId) return e.file;
    }
    throw Exception('File not found after share');
  }

  Future<FileEntity> updateSharePermission(
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
      if (e is FileItem && e.file.id == fileId) return e.file;
    }
    throw Exception('File not found after update permission');
  }

  Future<FileEntity> removeShareParticipant(
      String fileId, String userId) async {
    _requireUser();
    await _client
        .from('file_sharing')
        .delete()
        .eq('file_id', fileId)
        .eq('shared_with', userId);
    final list = await fetchFoldersFiles();
    for (final e in list) {
      if (e is FileItem && e.file.id == fileId) return e.file;
    }
    throw Exception('File not found after remove share');
  }

  /// Creates a folder (parent_id = null for root). Optionally moves [fileIds] into it via user_file_folders.
  Future<FolderEntity> createFolder(String folderName,
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
      for (final fileId in fileIds) {
        await _client.from('user_file_folders').upsert(
          {'user_id': userId, 'file_id': fileId, 'folder_id': folderId},
          onConflict: 'user_id,file_id',
        );
      }
    }
    return FolderEntity(
      id: folderId,
      name: row['folder_name'] as String,
      createdAt: _parseDate(row['created_at']),
      isFavorite: false,
      fileCount: 0,
      files: const [],
    );
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

  /// Move multiple files into a folder (uses user_file_folders per guide).
  Future<void> addFilesToFolder(String folderId, List<String> fileIds) async {
    _requireUser();
    final userId = _userId!;
    if (fileIds.isEmpty) return;
    for (final fileId in fileIds) {
      await _client.from('user_file_folders').upsert(
        {'user_id': userId, 'file_id': fileId, 'folder_id': folderId},
        onConflict: 'user_id,file_id',
      );
    }
  }

  /// Move multiple files to root (remove from folder) for current user.
  Future<void> removeFilesFromFolder(
      String folderId, List<String> fileIds) async {
    _requireUser();
    final userId = _userId!;
    if (fileIds.isEmpty) return;
    await _client
        .from('user_file_folders')
        .delete()
        .eq('user_id', userId)
        .inFilter('file_id', fileIds)
        .eq('folder_id', folderId);
  }

  /// Add a tag (canonical: is_personal false; personal: is_personal true). Per guide.
  Future<void> addTag(String fileId, String tagName,
      {required bool isPersonal}) async {
    _requireUser();
    final userId = _userId!;
    await _client.from('file_tags').insert({
      'file_id': fileId,
      'user_id': userId,
      'tag_name': tagName.trim().toLowerCase(),
      'is_personal': isPersonal,
    });
  }

  /// Delete a tag. Canonical: file_id + tag_name + is_personal false; personal: also filter by user_id. Per guide.
  Future<void> deleteTag(String fileId, String tagName,
      {required bool isPersonal}) async {
    _requireUser();
    final userId = _userId!;
    var q = _client
        .from('file_tags')
        .delete()
        .eq('file_id', fileId)
        .eq('tag_name', tagName.trim().toLowerCase())
        .eq('is_personal', isPersonal);
    if (isPersonal) q = q.eq('user_id', userId);
    await q;
  }

  /// Replace/sync tags: not in guide; kept for backward compatibility. Re-fetches file after changes.
  Future<FileEntity> updateTags(String fileId, List<String> tags) async {
    _requireUser();
    final list = await fetchFoldersFiles();
    for (final e in list) {
      if (e is FileItem && e.file.id == fileId) return e.file;
    }
    throw Exception('File not found');
  }

  /// Fetches all users from user_info (via common [UserInfoService]) for share dropdown. Excludes current user.
  Future<List<SharedUser>> fetchUsers() async {
    _requireUser();
    final currentId = _userId!;
    final users = await _userInfoService.fetchAllUsers();
    return users
        .where((u) => u.id != currentId)
        .map((u) => SharedUser(
              id: u.id,
              name: u.fullName,
              email: u.email,
              avatarUrl: u.avatarUrl ?? '',
            ))
        .toList();
  }
}
