import 'package:employeeos/core/auth/data/auth_repository.dart';
import 'package:employeeos/core/common/actions/date_time_actions.dart';

import 'user_info_service.dart';

/// Creates an auth user and a matching [user_info] row (admin/HR flows).
class UserCreationService {
  UserCreationService(this._auth, this._userInfo);

  final AuthRepository _auth;
  final UserInfoService _userInfo;

  Future<void> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
    String phone = '',
    String dateOfBirth = '',
    String designation = '',
    String dateOfJoining = '',
    String dateOfRelieving = '',
    List<int>? avatarBytes,
    String? avatarContentType,
  }) async {
    final fn = firstName.trim();
    final ln = lastName.trim();
    final display = '$fn $ln'.trim();

    final meta = <String, dynamic>{
      if (dateOfBirth.trim().isNotEmpty) 'date_of_birth': dateOfBirth.trim(),
      if (designation.trim().isNotEmpty) 'designation': designation.trim(),
      if (dateOfJoining.trim().isNotEmpty) 'date_of_joining': dateOfJoining.trim(),
      if (dateOfRelieving.trim().isNotEmpty)
        'date_of_relieving': dateOfRelieving.trim(),
    };

    final userId = await _auth.signUpNewUserKeepCurrentSession(
      email: email.trim(),
      password: password,
      firstname: fn.isNotEmpty ? fn : null,
      lastname: ln.isNotEmpty ? ln : null,
      additionalUserData: meta.isEmpty ? null : meta,
    );

    String? avatarUrl;
    if (avatarBytes != null &&
        avatarBytes.isNotEmpty &&
        avatarContentType != null &&
        avatarContentType.isNotEmpty) {
      avatarUrl = await _userInfo.uploadAvatarAndGetPublicUrl(
        bytes: avatarBytes,
        contentType: avatarContentType,
        forUserId: userId,
      );
    }

    await _userInfo.insertUserInfoRow(
      id: userId,
      email: email.trim(),
      fullName: display.isEmpty ? email.trim() : display,
      role: role,
      phoneNumber: phone.trim().isEmpty ? null : phone.trim(),
      dateOfBirth: tryParseDobString(dateOfBirth),
      avatarUrl: avatarUrl,
    );
  }
}
