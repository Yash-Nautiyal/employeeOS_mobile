import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'user_info_entity.dart';
import 'user_role.dart';

/// Common service to fetch user info from [public.user_info].
/// Use anywhere in the project when you need user profile data (name, avatar, email, etc.).
class UserInfoService {
  UserInfoService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'user_info';
  static const String _avatarsBucket = 'avatars';

  /// Max avatar file size (matches UI copy ~3.1 MB).
  static const int maxAvatarBytes = 3250586;

  /// HR and Admin users from [user_info] (recruitment scheduling pickers).
  /// Falls back to filtering [fetchAllUsers] if the role filter returns empty.
  Future<List<UserInfoEntity>> fetchHrUsers() async {
    try {
      final res = await _client
          .from(_table)
          .select(
              'id, email, full_name, avatar_url, phone_number, date_of_birth, role, email_verified, phone_verified, created_at, last_activity, status')
          .inFilter('role', ['hr', 'admin']).order('full_name');
      final list = _mapRows(res);
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fall through to client-side filter.
    }
    final all = await fetchAllUsers();
    return all.where((u) {
      final r = UserRole.fromString(u.role);
      return r.isHR || r.isAdmin;
    }).toList();
  }

  /// Fetches all users from user_info, ordered by full_name.
  Future<List<UserInfoEntity>> fetchAllUsers() async {
    final res = await _client
        .from(_table)
        .select(
            'id, email, full_name, avatar_url, phone_number, date_of_birth, role, email_verified, phone_verified, created_at, last_activity, status')
        .order('full_name');
    return _mapRows(res);
  }

  /// Fetches a single user by id. Returns null if not found.
  Future<UserInfoEntity?> fetchUserById(String id) async {
    if (id.isEmpty) return null;
    final res = await _client
        .from(_table)
        .select(
            'id, email, full_name, avatar_url, phone_number, date_of_birth, role, email_verified, phone_verified, created_at, last_activity, status')
        .eq('id', id)
        .maybeSingle();
    if (res == null) return null;
    return _rowToEntity(res);
  }

  /// Fetches multiple users by ids. Returns only found users; missing ids are skipped.
  Future<List<UserInfoEntity>> fetchUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final uniqueIds = ids.toSet().where((id) => id.isNotEmpty).toList();
    if (uniqueIds.isEmpty) return [];
    final res = await _client
        .from(_table)
        .select(
            'id, email, full_name, avatar_url, phone_number, date_of_birth, role, email_verified, phone_verified, created_at, last_activity, status')
        .inFilter('id', uniqueIds);
    return _mapRows(res);
  }

  List<UserInfoEntity> _mapRows(dynamic res) {
    final list = res is List ? res : (res != null ? [res] : <dynamic>[]);
    return list.map((e) => _rowToEntity(e as Map<String, dynamic>)).toList();
  }

  UserInfoEntity _rowToEntity(Map<String, dynamic> row) {
    return UserInfoEntity(
      id: row['id'] as String,
      email: row['email'] as String? ?? '',
      fullName: row['full_name'] as String? ?? '',
      avatarUrl: row['avatar_url'] as String?,
      phoneNumber: row['phone_number'] as String?,
      dateOfBirth: _parseDate(row['date_of_birth']),
      role: row['role'] as String?,
      emailVerified: row['email_verified'] as bool? ?? false,
      phoneVerified: row['phone_verified'] as bool? ?? false,
      createdAt: _parseDate(row['created_at']),
      lastActivity: _parseDate(row['last_activity']),
      status: row['status'] as String?,
    );
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  /// Updates the signed-in user's row in [user_info]. Only non-null fields are sent.
  Future<void> updateOwnProfileRow({
    String? fullName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? avatarUrl,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      throw StateError('Not signed in');
    }
    final data = <String, dynamic>{};
    if (fullName != null) {
      data['full_name'] = fullName.trim();
    }
    if (phoneNumber != null) {
      data['phone_number'] = phoneNumber.trim();
    }
    if (dateOfBirth != null) {
      data['date_of_birth'] = dateOfBirth.toIso8601String().split('T').first;
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      data['avatar_url'] = avatarUrl;
    }
    if (data.isEmpty) return;
    await _client.from(_table).update(data).eq('id', uid);
  }

  /// Uploads image bytes to the [avatars] bucket and returns the public URL.
  Future<String> uploadAvatarAndGetPublicUrl({
    required List<int> bytes,
    required String contentType,
  }) async {
    if (bytes.length > maxAvatarBytes) {
      throw ArgumentError('Image must be at most 3.1 MB.');
    }
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      throw StateError('Not signed in');
    }
    final ext = _extensionForContentType(contentType);
    final path = '$uid/${DateTime.now().millisecondsSinceEpoch}$ext';
    await _client.storage.from(_avatarsBucket).uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: true,
          ),
        );
    return _client.storage.from(_avatarsBucket).getPublicUrl(path);
  }

  static String _extensionForContentType(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'image/jpeg':
      case 'image/jpg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/gif':
        return '.gif';
      case 'image/webp':
        return '.webp';
      default:
        return '.jpg';
    }
  }
}
