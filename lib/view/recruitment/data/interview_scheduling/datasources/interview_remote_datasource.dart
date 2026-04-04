import 'package:employeeos/core/network/run_supabase_remote.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase RPCs for recruitment shortlist (applications + interviews atomically).
class InterviewRemoteDatasource {
  InterviewRemoteDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Single transaction: shortlisted row + telephone/eligible interview row
  /// (see `recruitment_shortlist_application` migration).
  Future<void> shortlistApplicationTransaction(String applicationId) =>
      runSupabaseRemote(() async {
        await _client.rpc(
          'recruitment_shortlist_application',
          params: {'p_application_id': applicationId},
        );
      });

  /// Same as [shortlistApplicationTransaction] for many IDs; one transaction for all.
  Future<void> shortlistApplicationsTransaction(List<String> applicationIds) =>
      runSupabaseRemote(() async {
        if (applicationIds.isEmpty) return;
        await _client.rpc(
          'recruitment_shortlist_applications',
          params: {'p_application_ids': applicationIds},
        );
      });
}
