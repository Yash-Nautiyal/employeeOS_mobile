part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

abstract class AuthListenState extends AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
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
