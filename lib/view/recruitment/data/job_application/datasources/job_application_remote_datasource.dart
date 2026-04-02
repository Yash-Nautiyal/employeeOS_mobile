import 'package:employeeos/core/network/run_supabase_remote.dart';
import 'package:employeeos/view/recruitment/domain/job_application/application_db_values.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/job_application_model.dart';

/// Reads and updates [applications] in Supabase (`job_id` → `jobs.id` uuid).
class JobApplicationRemoteDatasource {
  JobApplicationRemoteDatasource() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  static const String _applicationsTable = 'applications';
  static const String _jobsTable = 'jobs';

  static const String _selectWithJob = '''
id,
applicant_name,
email,
phone_number,
status,
created_at,
resume_url,
job_id,
jobs(job_id, title)
''';

  Future<List<JobApplicationModel>> getApplications({String? jobId}) =>
      runSupabaseRemote(() async {
        var query = _client.from(_applicationsTable).select(_selectWithJob);

        if (jobId != null && jobId.isNotEmpty) {
          final uuid = await _resolveJobUuid(jobId);
          if (uuid == null) return [];
          query = query.eq('job_id', uuid);
        }

        final res = await query.order('created_at', ascending: false);
        final rows = (res as List).cast<Map<String, dynamic>>();
        return rows.map(JobApplicationModel.fromDbJson).toList();
      });

  Future<JobApplicationModel?> shortlist(String applicationId) =>
      runSupabaseRemote(() async {
        final current = await _client
            .from(_applicationsTable)
            .select('id, status')
            .eq('id', applicationId)
            .maybeSingle();
        if (current == null) return null;
        if (!ApplicationStatusActions.canUpdateStatus(
            current['status']?.toString())) {
          return _fetchById(applicationId);
        }

        await _client.from(_applicationsTable).update({
          'status': ApplicationDbStatus.shortlisted,
          'current_stage': ApplicationPipelineStage.firstInterviewRound,
        }).eq('id', applicationId);

        return _fetchById(applicationId);
      });

  Future<JobApplicationModel?> reject(String applicationId) =>
      runSupabaseRemote(() async {
        final current = await _client
            .from(_applicationsTable)
            .select('id, status')
            .eq('id', applicationId)
            .maybeSingle();
        if (current == null) return null;
        if (!ApplicationStatusActions.canUpdateStatus(
            current['status']?.toString())) {
          return _fetchById(applicationId);
        }

        await _client.from(_applicationsTable).update({
          'status': ApplicationDbStatus.rejected,
          'current_stage': ApplicationDbStatus.rejected,
        }).eq('id', applicationId);

        return _fetchById(applicationId);
      });

  Future<JobApplicationModel?> _fetchById(String applicationId) async {
    final row = await _client
        .from(_applicationsTable)
        .select(_selectWithJob)
        .eq('id', applicationId)
        .maybeSingle();
    if (row == null) return null;
    return JobApplicationModel.fromDbJson(Map<String, dynamic>.from(row));
  }

  Future<String?> _resolveJobUuid(String businessJobId) async {
    final row = await _client
        .from(_jobsTable)
        .select('id')
        .eq('job_id', businessJobId)
        .maybeSingle();
    return row?['id']?.toString();
  }
}
