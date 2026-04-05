import 'package:equatable/equatable.dart';

import 'user_info_entity.dart';
import 'user_role.dart';

/// Logged-in user profile (role, info). Built from [UserInfoEntity] + optional auth metadata.
class CurrentUserProfile extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? phoneNumber;
  final UserRole role;
  final bool emailVerified;
  final bool phoneVerified;
  final String? status;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? appMetadata;

  const CurrentUserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    required this.role,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.status,
    this.metadata,
    this.appMetadata,
  });

  factory CurrentUserProfile.fromUserInfo(
    UserInfoEntity entity, {
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? appMetadata,
  }) {
    return CurrentUserProfile(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      phoneNumber: entity.phoneNumber,
      role: UserRole.fromString(entity.role),
      emailVerified: entity.emailVerified,
      phoneVerified: entity.phoneVerified,
      status: entity.status,
      metadata: metadata,
      appMetadata: appMetadata,
    );
  }

  bool get isEmployee => role.isEmployee;
  bool get isHR => role.isHR;
  bool get isAdmin => role.isAdmin;
  bool get canManageOwnJobs => role.canManageOwnJobs;
  bool get canManageGlobalConfig => role.canManageGlobalConfig;
  bool get canManageAnyJob => role.canManageAnyJob;

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatarUrl,
        phoneNumber,
        role,
        emailVerified,
        phoneVerified,
        status,
        metadata,
        appMetadata,
      ];
}
