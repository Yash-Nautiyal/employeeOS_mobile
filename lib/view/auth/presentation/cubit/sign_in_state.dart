part of 'sign_in_cubit.dart';

enum SignInStatus { initial, loading, success, failure }

class SignInState extends Equatable {
  final SignInStatus status;
  final String? errorMessage;

  const SignInState({
    required this.status,
    this.errorMessage,
  });

  const SignInState.initial() : this(status: SignInStatus.initial);

  bool get isLoading => status == SignInStatus.loading;

  SignInState copyWith({
    SignInStatus? status,
    String? errorMessage,
  }) {
    return SignInState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
