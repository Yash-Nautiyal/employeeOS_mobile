import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthFailure implements Exception {
  final String message;

  AuthFailure(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Sign in with email & password with a sane timeout and error mapping.
  Future<void> signIn({
    required String email,
    required String password,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password)
          .timeout(timeout);

      if (response.user == null) {
        throw AuthFailure('User not found. Please check your credentials.');
      }
    } on TimeoutException {
      throw AuthFailure(
        'Sign-in timed out. Please check your connection and try again.',
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Sign-in failed. Please try again.');
    }
  }

  /// Sign up with email & password and optional profile data.
  ///
  /// Mirrors [signIn] behaviour: applies a timeout and maps all errors to
  /// [AuthFailure] so that callers never see raw Supabase exceptions.
  Future<void> signUp({
    required String email,
    required String password,
    String? firstname,
    String? lastname,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (firstname != null) 'first_name': firstname,
          if (lastname != null) 'last_name': lastname,
          if (firstname != null && lastname != null)
            'display_name': '$firstname $lastname',
        },
      ).timeout(timeout);

      if (response.user == null) {
        throw AuthFailure(
          'Sign-up failed. Please check your details and try again.',
        );
      }
    } on TimeoutException {
      throw AuthFailure(
        'Sign-up timed out. Please check your connection and try again.',
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Sign-up failed. Please try again.');
    }
  }

  /// Request a password reset email for the given address.
  Future<void> resetPasswordForEmail({
    required String email,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email).timeout(timeout);
    } on TimeoutException {
      throw AuthFailure(
        'Reset password request timed out. Please check your connection and try again.',
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Reset password failed. Please try again.');
    }
  }

  /// Verifies [currentPassword], then sets the account password to [newPassword].
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    if (newPassword.length < 6) {
      throw AuthFailure('New password must be at least 6 characters.');
    }
    try {
      await _client.auth
          .signInWithPassword(email: email, password: currentPassword)
          .timeout(timeout);
    } on TimeoutException {
      throw AuthFailure(
        'Request timed out. Please check your connection and try again.',
      );
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid') ||
          msg.contains('credential') ||
          msg.contains('password')) {
        throw AuthFailure('Current password is incorrect.');
      }
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Could not verify your current password.');
    }

    try {
      await _client.auth
          .updateUser(UserAttributes(password: newPassword))
          .timeout(timeout);
    } on TimeoutException {
      throw AuthFailure(
        'Update timed out. Please check your connection and try again.',
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Could not update password. Please try again.');
    }
  }

  /// Merges [patch] into the current user's [User.userMetadata] via Supabase.
  Future<void> mergeUserMetadata(
    Map<String, dynamic> patch, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw AuthFailure('Not signed in.');
    }
    if (patch.isEmpty) return;
    try {
      final merged = Map<String, dynamic>.from(user.userMetadata ?? {});
      merged.addAll(patch);
      await _client.auth
          .updateUser(UserAttributes(data: merged))
          .timeout(timeout);
    } on TimeoutException {
      throw AuthFailure(
        'Profile update timed out. Please check your connection and try again.',
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Could not update profile. Please try again.');
    }
  }

  /// Sign out the current user.
  Future<void> signOut({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      await _client.auth.signOut().timeout(timeout);
    } on TimeoutException {
      throw AuthFailure(
        'Sign-out timed out. Please check your connection and try again.',
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Sign-out failed. Please try again.');
    }
  }
}
