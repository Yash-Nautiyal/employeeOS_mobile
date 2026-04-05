import 'package:employeeos/core/auth/data/auth_repository.dart';

import 'user_info_service.dart';

class UserAccountSyncException implements Exception {
  UserAccountSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Persists account general tab + avatar to Supabase auth metadata and [user_info].
class UserAccountSyncService {
  UserAccountSyncService(this._auth, this._userInfo);

  final AuthRepository _auth;
  final UserInfoService _userInfo;

  /// Parses DOB from ISO or from `d/m/y` (matches app date picker output).
  static DateTime? tryParseDateOfBirth(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final iso = DateTime.tryParse(s);
    if (iso != null) return DateTime(iso.year, iso.month, iso.day);
    final parts = s.split(RegExp(r'[/.\-]'));
    if (parts.length == 3) {
      final d = int.tryParse(parts[0].trim());
      final m = int.tryParse(parts[1].trim());
      final y = int.tryParse(parts[2].trim());
      if (d != null && m != null && y != null && y > 31) {
        return DateTime(y, m, d);
      }
    }
    return null;
  }

  Future<void> saveGeneralProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String dateOfBirth,
    required String designation,
    required String dateOfJoining,
    required String dateOfRelieving,
  }) async {
    final fn = firstName.trim();
    final ln = lastName.trim();
    final display = '$fn $ln'.trim();

    await _auth.mergeUserMetadata(<String, dynamic>{
      'first_name': fn,
      'last_name': ln,
      'date_of_birth': dateOfBirth.trim(),
      'designation': designation.trim(),
      'date_of_joining': dateOfJoining.trim(),
      'date_of_relieving': dateOfRelieving.trim(),
      if (display.isNotEmpty) 'display_name': display,
    });

    await _userInfo.updateOwnProfileRow(
      fullName: display,
      phoneNumber: phone.trim(),
      dateOfBirth: tryParseDateOfBirth(dateOfBirth),
    );
  }

  /// Stores social URLs under `userMetadata.social_links` (facebook, instagram, twitter, linkedin).
  Future<void> saveSocialLinks({
    required String facebook,
    required String instagram,
    required String twitter,
    required String linkedin,
  }) async {
    await _auth.mergeUserMetadata(<String, dynamic>{
      'social_links': <String, dynamic>{
        'facebook': facebook.trim(),
        'instagram': instagram.trim(),
        'twitter': twitter.trim(),
        'linkedin': linkedin.trim(),
      },
    });
  }

  Future<String> uploadAvatar({
    required List<int> bytes,
    required String contentType,
  }) async {
    final url = await _userInfo.uploadAvatarAndGetPublicUrl(
      bytes: bytes,
      contentType: contentType,
    );
    await _auth.mergeUserMetadata(<String, dynamic>{'avatar_url': url});
    await _userInfo.updateOwnProfileRow(avatarUrl: url);
    return url;
  }
}
