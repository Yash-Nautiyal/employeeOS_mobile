import 'package:postgrest/postgrest.dart';

/// Categories of remote failures for UI (retry banner vs re-auth vs toast).
enum RemoteDataFailureKind {
  timeout,
  offline,
  unauthorized,
  server,
  unknown,
}

/// Thrown by [runSupabaseRemote] so blocs/UI can show consistent messages.
class RemoteDataException implements Exception {
  const RemoteDataException({
    required this.kind,
    required this.message,
    this.cause,
  });

  final RemoteDataFailureKind kind;
  final String message;
  final Object? cause;

  factory RemoteDataException.timeout() => const RemoteDataException(
        kind: RemoteDataFailureKind.timeout,
        message: 'Request timed out. Check your connection and try again.',
      );

  factory RemoteDataException.offline() => const RemoteDataException(
        kind: RemoteDataFailureKind.offline,
        message: 'No network connection. Check your internet and try again.',
      );

  factory RemoteDataException.fromPostgrest(PostgrestException e) {
    final lower = e.message.toLowerCase();
    final code = e.code;
    if (lower.contains('jwt') ||
        lower.contains('permission denied') ||
        code == '42501' ||
        code == 'PGRST301') {
      return RemoteDataException(
        kind: RemoteDataFailureKind.unauthorized,
        message: 'You do not have permission to perform this action.',
        cause: e,
      );
    }
    return RemoteDataException(
      kind: RemoteDataFailureKind.server,
      message: e.message.isNotEmpty
          ? e.message
          : 'Something went wrong. Please try again.',
      cause: e,
    );
  }

  @override
  String toString() => message;
}
