import 'package:equatable/equatable.dart';

/// Represents a row from [public.user_info].
/// Use across the project for user profile data (avatar, name, email, etc.).
class UserInfoEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? role;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime? createdAt;
  final DateTime? lastActivity;
  final String? status;

  const UserInfoEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.role,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.createdAt,
    this.lastActivity,
    this.status,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatarUrl,
        phoneNumber,
        dateOfBirth,
        role,
        emailVerified,
        phoneVerified,
        createdAt,
        lastActivity,
        status,
      ];
}
