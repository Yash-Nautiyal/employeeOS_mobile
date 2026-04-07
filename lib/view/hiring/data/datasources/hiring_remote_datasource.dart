import 'package:employeeos/core/network/run_supabase_remote.dart';
import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HiringRemoteDatasource {
  HiringRemoteDatasource(this._client);

  final SupabaseClient _client;

  /// Calls `get_hiring_dashboard` — full dashboard payload as JSON.
  Future<Map<String, dynamic>> fetchDashboard(HiringFilterParams filters) =>
      runSupabaseRemote(() async {
        final response = await _client.rpc(
          'get_hiring_dashboard',
          params: _toRpcParams(filters),
        );
        if (response == null) {
          return <String, dynamic>{};
        }
        return Map<String, dynamic>.from(response as Map);
      });

  /// Job Position filter — `{ id, title }` rows, `id` matches RPC `p_job_id`.
  Future<List<Map<String, dynamic>>> fetchJobDropdownOptions() =>
      runSupabaseRemote(() async {
        final response = await _client
            .from('jobs')
            .select('id, title')
            .order('title', ascending: true);
        final rows = (response as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        return rows;
      });

  /// HR Manager filter (admin) — `{ id, full_name, email }`.
  /// Uses `user_info.role` values `hr` and `admin` (same idea as scheduling HR pickers).
  Future<List<Map<String, dynamic>>> fetchHrDropdownOptions() =>
      runSupabaseRemote(() async {
        final response = await _client
            .from('user_info')
            .select('id, full_name, email')
            .inFilter('role', ['hr', 'admin']).order('full_name',
                ascending: true);
        final rows = (response as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        return rows;
      });

  Map<String, dynamic> _toRpcParams(HiringFilterParams filters) {
    return {
      if (filters.jobId != null) 'p_job_id': filters.jobId,
      if (filters.hrManagerId != null) 'p_hr_manager_id': filters.hrManagerId,
      if (filters.postingFrom != null)
        'p_posting_from': filters.postingFrom!.toIso8601String(),
      if (filters.postingTo != null)
        'p_posting_to': filters.postingTo!.toIso8601String(),
      if (filters.deadlineFrom != null) 'p_deadline_from': filters.deadlineFrom,
      if (filters.deadlineTo != null) 'p_deadline_to': filters.deadlineTo,
    };
  }
}
