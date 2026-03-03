import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Distinguishes **network/retryable** auth errors from **real auth failures**.
///
/// - **Network (timeout, SocketException)**: Do NOT sign out. Keep session.
///   Supabase will retry when the connection is back.
/// - **Auth failure (401, 400 invalid token, revoked)**: Sign out and go to login.
///
/// Use [handleUnhandledError] in [PlatformDispatcher.instance.onError] and
/// [runZonedGuarded]. Use [wasRetryableAuthErrorRecently] in auth state logic
/// to avoid emitting logout when the SDK clears session after a transient
/// refresh failure.
class AuthErrorHandler {
  AuthErrorHandler._();

  static const Duration _retryableErrorTtl = Duration(seconds: 5);

  static DateTime? _lastRetryableErrorAt;

  /// Whether a retryable (network) auth error occurred in the last
  /// [_retryableErrorTtl]. Used to avoid signing the user out when
  /// the SDK clears the session after a failed token refresh due to network.
  static bool wasRetryableAuthErrorRecently() {
    final at = _lastRetryableErrorAt;
    if (at == null) return false;
    return DateTime.now().difference(at) < _retryableErrorTtl;
  }

  /// Clears the "retryable error recently" state. Call when you intentionally
  /// sign out or when the user successfully refreshes.
  static void clearRetryableErrorFlag() {
    _lastRetryableErrorAt = null;
  }

  /// True if this exception is a network/retryable auth error (timeout,
  /// SocketException, etc.). Do NOT sign out for these.
  static bool isRetryableAuthError(Object error, StackTrace? stackTrace) {
    // AuthException with message indicating retryable fetch (SDK uses this for
    // token refresh network failures).
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      final statusCode = error.statusCode;
      // No HTTP response → network/connectivity issue.
      if (statusCode == null) return true;
      // Explicit retryable message from SDK.
      if (message.contains('authretryablefetcherror') ||
          message.contains('authretryablefetchexception')) {
        return true;
      }
      if (message.contains('connection timed out') ||
          message.contains('socketexception') ||
          message.contains('clientexception')) {
        return true;
      }
      // Server explicitly rejected the token → not retryable.
      if (statusCode == 401 || statusCode == 403) return false;
      if (statusCode == 400 &&
          (message.contains('refresh') || message.contains('token'))) {
        return false;
      }
    }

    // Some SDK versions throw a dedicated exception type.
    final name = error.runtimeType.toString().toLowerCase();
    if (name.contains('authretryablefetch')) return true;

    // Dart/Flutter network errors often wrap in the message.
    final str = error.toString().toLowerCase();
    if (str.contains('socketexception') ||
        str.contains('connection timed out') ||
        (str.contains('clientexception') && str.contains('socketexception'))) {
      return true;
    }

    return false;
  }

  /// True if this exception is an explicit auth failure (server rejected token).
  /// Call signOut only for these.
  static bool isExplicitAuthFailure(Object error) {
    if (error is AuthException) {
      final statusCode = error.statusCode;
      if (statusCode == 401 || statusCode == 403) return true;
      if (statusCode == 400) {
        final message = error.message.toLowerCase();
        if (message.contains('refresh') ||
            message.contains('token') ||
            message.contains('invalid') ||
            message.contains('revoked')) {
          return true;
        }
      }
    }
    return false;
  }

  /// Handles an unhandled error from [PlatformDispatcher.instance.onError]
  /// or [runZonedGuarded].
  ///
  /// Returns `true` if the error was handled (e.g. retryable auth error):
  /// the app should not crash / hang. Returns `false` to let the error
  /// propagate (e.g. for reporting to Crashlytics).
  static bool handleUnhandledError(
    Object error,
    StackTrace? stackTrace,
  ) {
    // Retryable (network) auth error: log only, do not sign out, do not crash.
    if (isRetryableAuthError(error, stackTrace)) {
      _lastRetryableErrorAt = DateTime.now();
      if (kDebugMode) {
        // ignore: avoid_print
        print(
          '[AuthErrorHandler] Retryable auth/network error (not signing out): $error',
        );
      }
      // TODO: send to telemetry as non-fatal (e.g. Crashlytics.recordFlutterError
      // or recordError with non-fatal flag).
      return true; // Handled; don't propagate.
    }

    // Explicit auth failure: could trigger sign-out here via a callback if you
    // register one. For now we let it propagate so Crashlytics sees it; the
    // auth stream may also emit signed_out when the SDK clears the session.
    if (isExplicitAuthFailure(error)) {
      if (kDebugMode) {
        // ignore: avoid_print
        print(
            '[AuthErrorHandler] Explicit auth failure (should sign out): $error');
      }
      return false; // Let app handle (e.g. auth state listener).
    }

    return false;
  }
}
