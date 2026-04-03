import 'package:employeeos/core/network/run_supabase_remote.dart';
import 'package:employeeos/view/recruitment/domain/job_application/application_db_values.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_applications_list_query.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_applications_list_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/job_application_model.dart';

/// Reads and updates [applications] in Supabase (`job_id` → `jobs.id` uuid).
class JobApplicationRemoteDatasource {
  JobApplicationRemoteDatasource() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  static const String _applicationsTable = 'applications';
  static const String _jobsTable = 'jobs';

  static const String _jobColumns =
      'job_id, title, posted_by_name, posted_by_email, joining_type, is_internship';

  String _selectClause(bool innerJob) {
    final hint = innerJob ? 'jobs!inner' : 'jobs';
    return '''
id,
applicant_name,
email,
phone_number,
status,
created_at,
resume_url,
job_id,
$hint($_jobColumns)
''';
  }

  bool _needsInnerJob(JobApplicationsListQuery q) {
    return q.hrQuery.trim().isNotEmpty ||
        q.joinImmediate ||
        q.joinAfterMonths ||
        q.jobType != 'All';
  }

  String _escapeIlike(String raw) {
    return raw
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  /// Filtered list + total count (same filters), one page of rows.
  Future<JobApplicationsListResult> getApplicationsPage(
    JobApplicationsListQuery q,
  ) =>
      runSupabaseRemote(() async {
        final inner = _needsInnerJob(q);
        final select = _selectClause(inner);

        if (q.jobId.trim().isNotEmpty) {
          final uuid = await _resolveJobUuid(q.jobId.trim());
          if (uuid == null) {
            return const JobApplicationsListResult(items: [], totalCount: 0);
          }
        }

        PostgrestFilterBuilder<PostgrestList> filtered =
            _client.from(_applicationsTable).select(select);
        filtered = await _applyFilters(filtered, q);

        final countRes = await filtered.count(CountOption.exact);
        final totalCount = countRes.count;

        if (totalCount == 0) {
          return const JobApplicationsListResult(items: [], totalCount: 0);
        }

        PostgrestFilterBuilder<PostgrestList> dataQuery =
            _client.from(_applicationsTable).select(select);
        dataQuery = await _applyFilters(dataQuery, q);

        final from = q.offset;
        final to = from + q.pageSize - 1;
        final res = await dataQuery
            .order('created_at', ascending: q.sortAscending)
            .range(from, to);
        final rows = (res as List).cast<Map<String, dynamic>>();
        final items = rows.map(JobApplicationModel.fromDbJson).toList();

        return JobApplicationsListResult(items: items, totalCount: totalCount);
      });

  Future<PostgrestFilterBuilder<PostgrestList>> _applyFilters(
    PostgrestFilterBuilder<PostgrestList> b,
    JobApplicationsListQuery q,
  ) async {
    if (q.jobId.trim().isNotEmpty) {
      final uuid = await _resolveJobUuid(q.jobId.trim());
      if (uuid != null) {
        b = b.eq('job_id', uuid);
      }
    }

    final search = q.searchQuery.trim();
    if (search.isNotEmpty) {
      final p = '%${_escapeIlike(search)}%';
      b = b.or('applicant_name.ilike.$p,email.ilike.$p');
    }

    final hr = q.hrQuery.trim();
    if (hr.isNotEmpty) {
      final p = '%${_escapeIlike(hr)}%';
      b = b.or(
        'posted_by_name.ilike.$p,posted_by_email.ilike.$p',
        referencedTable: 'jobs',
      );
    }

    if (q.joinImmediate && q.joinAfterMonths) {
      b = b.or(
        'joining_type.ilike.%immediate%,joining_type.ilike.%notice%,joining_type.ilike.%flexible%,joining_type.ilike.%month%',
        referencedTable: 'jobs',
      );
    } else if (q.joinImmediate) {
      b = b.filter('jobs.joining_type', 'ilike', '%immediate%');
    } else if (q.joinAfterMonths) {
      b = b.or(
        'joining_type.ilike.%notice%,joining_type.ilike.%flexible%,joining_type.ilike.%after_month%,joining_type.ilike.%month%',
        referencedTable: 'jobs',
      );
    }

    if (q.jobType == 'Internship') {
      b = b.eq('jobs.is_internship', true);
    } else if (q.jobType == 'Full-time') {
      b = b.eq('jobs.is_internship', false);
    }

    final st = q.applicationStatus.trim();
    if (st.isNotEmpty) {
      if (st == ApplicationDbStatus.pending) {
        b = b.or('status.eq.pending,status.eq.applied,status.is.null');
      } else {
        b = b.eq('status', st);
      }
    }

    if (q.dateRangeStart != null) {
      b = b.gte('created_at', q.dateRangeStart!.toIso8601String());
    }
    if (q.dateRangeEndExclusive != null) {
      b = b.lt('created_at', q.dateRangeEndExclusive!.toIso8601String());
    }

    return b;
  }

  Future<List<JobApplicationModel>> getApplications({String? jobId}) =>
      runSupabaseRemote(() async {
        var query =
            _client.from(_applicationsTable).select(_selectClause(false));

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
        .select(_selectClause(false))
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
