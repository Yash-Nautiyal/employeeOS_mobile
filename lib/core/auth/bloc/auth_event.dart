part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {}

class AuthLoggedOut extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? firstname; // Optional, if you collect user name
  final String? lastname; // Optional, if you collect user name

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.firstname,
    this.lastname,
  });

  @override
  List<Object?> get props => [email, password, firstname, lastname];
}

class AuthSignOutRequested extends AuthEvent {}

/// Reload profile and auth user from the server (e.g. after profile edits).
class AuthRefreshProfileRequested extends AuthEvent {}
