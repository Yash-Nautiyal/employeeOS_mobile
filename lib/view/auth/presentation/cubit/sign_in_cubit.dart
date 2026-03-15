import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/auth/data/auth_repository.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._authRepository) : super(const SignInState.initial());

  final AuthRepository _authRepository;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (state.isLoading || isClosed) return;

    emit(state.copyWith(
      status: SignInStatus.loading,
      errorMessage: null,
    ));

    try {
      await _authRepository.signIn(email: email, password: password);
      if (isClosed) return;
      emit(state.copyWith(
        status: SignInStatus.success,
        errorMessage: null,
      ));
    } on AuthFailure catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: SignInStatus.failure,
        errorMessage: e.message,
      ));
    }
  }
}
