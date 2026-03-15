import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:employeeos/core/auth/auth_error_handler.dart';
import 'package:employeeos/core/user/current_user_profile.dart';
import 'package:employeeos/core/user/user_info_service.dart';
import 'package:employeeos/core/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository, [UserInfoService? userInfoService])
      : _client = Supabase.instance.client,
        _userInfoService = userInfoService,
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
        AuthErrorHandler.clearRetryableErrorFlag();
        add(AuthLoggedIn());
      } else {
        // Do not sign out on transient session loss (e.g. token refresh failed
        // due to network). Only emit logout when we did not just see a
        // retryable auth/network error.
        if (!AuthErrorHandler.wasRetryableAuthErrorRecently()) {
          add(AuthLoggedOut());
        }
      }
    });
    add(AuthCheckRequested());
  }

  final AuthRepository _authRepository;
  final SupabaseClient _client;
  final UserInfoService? _userInfoService;
  late final StreamSubscription _authSubscription;

  Future<CurrentUserProfile?> _loadProfile(String userId) async {
    final service = _userInfoService;
    if (userId.isEmpty || service == null) return null;
    try {
      final entity = await service.fetchUserById(userId);
      if (entity == null) return null;
      final supabaseUser = _client.auth.currentUser;
      Map<String, dynamic>? metadata;
      if (supabaseUser != null) {
        final meta = <String, dynamic>{
          ...?supabaseUser.userMetadata,
          ...supabaseUser.appMetadata,
        };
        metadata = meta.isEmpty ? null : meta;
      }
      return CurrentUserProfile.fromUserInfo(entity, metadata: metadata);
    } catch (_) {
      return null;
    }
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final session = _client.auth.currentSession;
    if (session != null) {
      final profile = await _loadProfile(session.user.id);
      emit(Authenticated(session.user, profile));
    } else {
      emit(Unauthenticated());
    }
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) async {
    final session = _client.auth.currentSession;
    if (session != null) {
      final profile = await _loadProfile(session.user.id);
      emit(Authenticated(session.user, profile));
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
      await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      final user = _client.auth.currentUser;
      if (user != null) {
        final profile = await _loadProfile(user.id);
        emit(AuthSuccessState('Sign-in successful'));
        emit(Authenticated(user, profile));
      } else {
        emit(AuthError('User not found.'));
        emit(Unauthenticated());
      }
    } on AuthFailure catch (e) {
      emit(AuthError(e.message));
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        firstname: event.firstname,
        lastname: event.lastname,
      );
      final user = _client.auth.currentUser;
      if (user != null) {
        final profile = await _loadProfile(user.id);
        emit(AuthSuccessState('Sign-Up successful'));
        emit(Authenticated(user, profile));
      } else {
        emit(AuthError('Sign-up failed. Please check your details.'));
        emit(Unauthenticated());
      }
    } on AuthFailure catch (e) {
      emit(AuthError(e.message));
      emit(Unauthenticated());
    }
  }

  FutureOr<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    AuthErrorHandler.clearRetryableErrorFlag();
    try {
      await _authRepository.signOut();
    } on AuthFailure catch (e) {
      // Surface the error but still move to an unauthenticated state so the
      // user is not left in a broken "half signed-out" state.
      emit(AuthError(e.message));
    }
    // The listener above will emit the logout state
    emit(Unauthenticated());
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPasswordForEmail(email: event.email);
      emit(AuthSuccessState(
          'If an account exists for ${event.email}, a reset link has been sent.'));
      emit(Unauthenticated());
    } on AuthFailure catch (e) {
      emit(AuthError('Reset password failed: ${e.message}'));
      emit(Unauthenticated());
    }
  }
}
