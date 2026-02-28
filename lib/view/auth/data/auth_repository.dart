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
          'Sign-in timed out. Please check your connection and try again.');
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Sign-in failed. Please try again.');
    }
  }
}
