import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:postgrest/postgrest.dart';

import 'remote_data_exception.dart';

/// Runs a Supabase/PostgREST call with a [timeout] and maps common errors to
/// [RemoteDataException]. Use this from **remote datasources** (one wrapper
/// per public operation) so repositories/blocs get predictable failures.
Future<T> runSupabaseRemote<T>(
  Future<T> Function() operation, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  try {
    return await operation().timeout(timeout);
  } on TimeoutException {
    throw RemoteDataException.timeout();
  } on SocketException {
    throw RemoteDataException.offline();
  } on PostgrestException catch (e) {
    throw RemoteDataException.fromPostgrest(e);
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('[runSupabaseRemote] $e\n$st');
    }
    final str = e.toString().toLowerCase();
    if (str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('network is unreachable') ||
        str.contains('connection reset') ||
        str.contains('connection refused')) {
      throw RemoteDataException.offline();
    }
    throw RemoteDataException(
      kind: RemoteDataFailureKind.unknown,
      message: 'Something went wrong. Please try again.',
      cause: e,
    );
  }
}
