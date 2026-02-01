import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc()
      : _client = Supabase.instance.client,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);

    _authSubscription = _client.auth.onAuthStateChange.listen((event) {
      final session = _client.auth.currentSession;
      if (session != null) {
        add(AuthLoggedIn());
      } else {
        add(AuthLoggedOut());
      }
    });
    add(AuthCheckRequested());
  }

  final SupabaseClient _client;
  late final StreamSubscription _authSubscription;

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) {
    final session = _client.auth.currentSession;
    if (session != null) {
      emit(Authenticated(session.user));
    } else {
      emit(Unauthenticated());
    }
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    final session = _client.auth.currentSession;
    if (session != null) {
      emit(Authenticated(session.user));
    } else {
      emit(Unauthenticated());
    }
  }

  void _onAuthLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) {
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _client.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      final user = response.user;
      if (user != null) {
        emit(AuthSuccessState('Sign-in successful'));
        emit(Authenticated(user));
        // TEST: one-off in 5 minutes
      } else {
        emit(AuthError('User not found.'));
        emit(Unauthenticated());
      }
    } catch (e) {
      final errorMessage = (e is AuthException) ? e.message : e.toString();
      emit(AuthError('Sign-in failed: $errorMessage'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _client.auth.signUp(
        email: event.email,
        password: event.password,
        data: {
          if (event.firstname != null) 'first_name': event.firstname,
          if (event.lastname != null) 'last_name': event.lastname,
          if (event.firstname != null && event.lastname != null)
            'display_name': '${event.firstname} ${event.lastname}',
        },
      );
      final user = response.user;
      if (user != null) {
        emit(AuthSuccessState('Sign-Up successful'));

        emit(Authenticated(user));
      } else {
        emit(AuthError('Sign-up failed. Please check your details.'));
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError('Sign-up failed: ${e.toString()}'));
      emit(Unauthenticated());
    }
  }

  FutureOr<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _client.auth.signOut();
    // The listener above will emit the logout state
    emit(Unauthenticated());
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _client.auth.resetPasswordForEmail(event.email);
      emit(AuthSuccessState(
          'If an account exists for ${event.email}, a reset link has been sent.'));
      emit(Unauthenticated());
    } catch (e) {
      final errorMessage = (e is AuthException) ? e.message : e.toString();
      emit(AuthError('Reset password failed: $errorMessage'));
      emit(Unauthenticated());
    }
  }
}
