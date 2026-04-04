import 'package:postgrest/postgrest.dart';

/// Categories of remote failures for UI (retry banner vs re-auth vs toast).
enum RemoteDataFailureKind {
  timeout,
  offline,
  unauthorized,
  server,
  unknown,
}

class RemoteDataUserMessages {
  RemoteDataUserMessages._();

  static const genericServer =
      'Something went wrong on our side. Please try again in a moment.';
  static const genericUnknown = 'Something went wrong. Please try again.';
  static const schemaOrConfig =
      'We couldn\'t load this data right now. Please try again in a moment.';
  static const notFound =
      'We couldn\'t find what you\'re looking for. It may have been removed.';
  static const duplicate =
      'This information already exists. Please check and try again.';
  static const constraint =
      'This action couldn\'t be completed. Please refresh and try again.';
  static const invalidInput =
      'Some of the information provided isn\'t valid. Please check and try again.';
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
    final details = (e.details ?? '').toString().toLowerCase();

    if (lower.contains('jwt') ||
        lower.contains('permission denied') ||
        lower.contains('row-level security') ||
        code == '42501' ||
        code == 'PGRST301') {
      return RemoteDataException(
        kind: RemoteDataFailureKind.unauthorized,
        message: 'You do not have permission to perform this action.',
        cause: e,
      );
    }

    final recruitmentRpc = _recruitmentShortlistRpcUserMessage(e.message);
    if (recruitmentRpc != null) {
      return RemoteDataException(
        kind: RemoteDataFailureKind.server,
        message: recruitmentRpc,
        cause: e,
      );
    }

    final combined = '$lower $details';
    final userMessage = _userFacingPostgrestMessage(
      rawMessage: e.message,
      messageLower: lower,
      detailsLower: details,
      combinedLower: combined,
      code: code,
    );

    return RemoteDataException(
      kind: RemoteDataFailureKind.server,
      message: userMessage,
      cause: e,
    );
  }

  @override
  String toString() => message;
}

/// Maps PostgREST / Postgres errors to short, non-technical copy.
String _userFacingPostgrestMessage({
  required String rawMessage,
  required String messageLower,
  required String detailsLower,
  required String combinedLower,
  required String? code,
}) {
  final c = (code ?? '').toUpperCase();

  // PostgREST API / schema / embed hints (never show raw to users).
  if (c.startsWith('PGRST') ||
      combinedLower.contains('schema cache') ||
      combinedLower.contains('relationship between') ||
      combinedLower.contains('could not find a relationship') ||
      combinedLower.contains('could not find relationship') ||
      combinedLower.contains('invalid embedded resource') ||
      combinedLower.contains('no suitable resource')) {
    return RemoteDataUserMessages.schemaOrConfig;
  }

  // Missing table / column / relation (often dev or migration mismatch).
  if (combinedLower.contains('does not exist') ||
      combinedLower.contains('undefined column') ||
      combinedLower.contains('unknown column') ||
      messageLower.contains('relation ') &&
          messageLower.contains('does not exist')) {
    return RemoteDataUserMessages.schemaOrConfig;
  }

  // Postgres SQL / parser noise.
  if (combinedLower.contains('syntax error') ||
      combinedLower.contains('invalid input syntax')) {
    return RemoteDataUserMessages.invalidInput;
  }

  // Common constraint errors (SQLSTATE when exposed in message/details).
  if (combinedLower.contains('23505') ||
      combinedLower.contains('unique violation') ||
      combinedLower.contains('duplicate key') ||
      combinedLower.contains('already exists')) {
    return RemoteDataUserMessages.duplicate;
  }
  if (combinedLower.contains('23503') ||
      combinedLower.contains('foreign key violation') ||
      combinedLower.contains('violates foreign key')) {
    return RemoteDataUserMessages.constraint;
  }

  if (combinedLower.contains('23502') ||
      combinedLower.contains('not-null violation') ||
      combinedLower.contains('null value in column')) {
    return RemoteDataUserMessages.invalidInput;
  }

  // Single row expected but missing.
  if (c == 'PGRST116' ||
      combinedLower
          .contains('json object requested, multiple (or no) rows returned')) {
    return RemoteDataUserMessages.notFound;
  }

  // If the message still looks like infrastructure / SQL, avoid showing it.
  if (_looksTechnical(combinedLower)) {
    return RemoteDataUserMessages.genericServer;
  }

  // Short, plausible user-facing API messages only.
  final trimmed = rawMessage.trim();
  final trimmedLower = trimmed.toLowerCase();
  if (trimmed.isEmpty) {
    return RemoteDataUserMessages.genericUnknown;
  }
  if (trimmed.length > 120 ||
      trimmedLower.contains('select ') ||
      trimmedLower.contains('insert ') ||
      trimmedLower.contains('update ') ||
      trimmedLower.contains('from ') && trimmedLower.contains('where ')) {
    return RemoteDataUserMessages.genericServer;
  }

  return _sentenceCasePreserve(trimmed);
}

/// User-facing copy for `recruitment_shortlist_application` RPC errors.
String? _recruitmentShortlistRpcUserMessage(String raw) {
  final u = raw.toUpperCase();
  if (u.contains('APPLICATION_NOT_FOUND')) {
    return 'This application could not be found.';
  }
  if (u.contains('APPLICATION_NOT_SHORTLISTABLE')) {
    return 'This application cannot be shortlisted in its current status.';
  }
  if (u.contains('INVALID_APPLICATION_ID')) {
    return RemoteDataUserMessages.genericUnknown;
  }
  return null;
}

bool _looksTechnical(String lower) {
  return lower.contains('postgrest') ||
      lower.contains('postgresql') ||
      lower.contains('postgres') ||
      lower.contains('sqlstate') ||
      lower.contains('pgrst') ||
      lower.contains('operator does not exist') ||
      lower.contains('type ') && lower.contains('mismatch');
}

String _sentenceCasePreserve(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}
