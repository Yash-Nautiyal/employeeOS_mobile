import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final StreamSubscription _authSubscription;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);

    // Listen to Supabase auth changes and add events accordingly
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        add(AuthLoggedIn());
      } else {
        add(AuthLoggedOut());
      }
    });
    // Immediately check auth state at startup
    add(AuthCheckRequested());
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      emit(Authenticated(session.user));
    } else {
      emit(Unauthenticated());
    }
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    final session = Supabase.instance.client.auth.currentSession;
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
      final response = await Supabase.instance.client.auth.signInWithPassword(
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
      final response = await Supabase.instance.client.auth.signUp(
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
    await Supabase.instance.client.auth.signOut();
    // The listener above will emit the logout state
    emit(Unauthenticated());
  }

  FutureOr<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthLoading());
    try {} catch (e) {
      emit(AuthError('Reset password failed: ${e.toString()}'));
      emit(Unauthenticated());
    }
  }
}
