part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

abstract class AuthListenState extends AuthState {}

class AuthInitial extends AuthState {}

/// Authenticated with optional [profile] (loaded from user_info + metadata).
/// When non-null, use [profile] for role and app-wide user data.
class Authenticated extends AuthState {
  final User user;
  final CurrentUserProfile? profile;

  const Authenticated(this.user, [this.profile]);

  @override
  List<Object?> get props => [user, profile];
}

class Unauthenticated extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthListenState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSuccessState extends AuthListenState {
  final String message;
  AuthSuccessState(this.message);
  @override
  List<Object?> get props => [message];
}

/// Extension so any [AuthState] can expose current user profile in one place.
extension AuthStateX on AuthState {
  CurrentUserProfile? get currentProfile =>
      this is Authenticated ? (this as Authenticated).profile : null;
}
