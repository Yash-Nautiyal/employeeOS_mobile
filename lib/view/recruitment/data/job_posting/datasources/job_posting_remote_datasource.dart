import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employeeos/view/recruitment/domain/job_posting/entities/job_application_summary.dart';
import 'package:employeeos/view/recruitment/domain/job_posting/entities/job_applications_page.dart';

import '../models/job_posting_model.dart';

class JobPostingRemoteDatasource {
  JobPostingRemoteDatasource() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'jobs';

  Future<List<JobPostingModel>> getAll() async {
    final res = await _client.from(_table).select().order('created_at');
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map(JobPostingModel.fromDbJson).toList();
  }

  Future<JobPostingModel?> getById(String id) async {
    final row =
        await _client.from(_table).select().eq('job_id', id).maybeSingle();
    if (row == null) return null;
    return JobPostingModel.fromDbJson(row);
  }

  Future<void> add(JobPostingModel job) async {
    await _client.from(_table).insert(job.toDbInsertJson());
  }

  Future<void> update(JobPostingModel job) async {
    await _client
        .from(_table)
        .update(job.toDbUpdateJson())
        .eq('job_id', job.id);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('job_id', id);
  }

  Future<void> setJobActive(String id, bool isActive) async {
    await _client.from(_table).update({'is_active': isActive}).eq('job_id', id);
  }

  Future<List<String>> getJobDepartments() async {
    final res =
        await _client.from(_table).select('department').order('department');
    final rows = (res as List).cast<Map<String, dynamic>>();
    final set = <String>{};
    for (final row in rows) {
      final department = (row['department'] as String?)?.trim();
      if (department != null && department.isNotEmpty) set.add(department);
    }
    return set.toList()..sort();
  }

  /// Returns counts keyed by business job id (`jobs.job_id`), while
  /// applications are linked to `jobs.id` (uuid).
  Future<Map<String, int>> getApplicationCountsByJobBusinessId() async {
    final jobsRes = await _client.from(_table).select('id, job_id');
    final jobRows = (jobsRes as List).cast<Map<String, dynamic>>();

    final uuidToBusinessId = <String, String>{};
    for (final row in jobRows) {
      final uuid = row['id']?.toString();
      final businessId = row['job_id']?.toString();
      if (uuid == null ||
          uuid.isEmpty ||
          businessId == null ||
          businessId.isEmpty) {
        continue;
      }
      uuidToBusinessId[uuid] = businessId;
    }

    if (uuidToBusinessId.isEmpty) return const {};

    final appsRes = await _client.from('applications').select('job_id');
    final appRows = (appsRes as List).cast<Map<String, dynamic>>();

    final countsByUuid = <String, int>{};
    for (final row in appRows) {
      final jobUuid = row['job_id']?.toString();
      if (jobUuid == null || jobUuid.isEmpty) continue;
      countsByUuid[jobUuid] = (countsByUuid[jobUuid] ?? 0) + 1;
    }

    final byBusinessId = <String, int>{};
    countsByUuid.forEach((uuid, count) {
      final businessId = uuidToBusinessId[uuid];
      if (businessId == null) return;
      byBusinessId[businessId] = (byBusinessId[businessId] ?? 0) + count;
    });

    return byBusinessId;
  }

  Future<JobApplicationsPage> getJobApplicationsPage({
    required String jobBusinessId,
    required int offset,
    required int limit,
    required bool sortAscendingByAppliedOn,
  }) async {
    final jobUuid = await _resolveJobUuid(jobBusinessId);
    if (jobUuid == null) {
      return JobApplicationsPage(
        items: const [],
        totalCount: 0,
        offset: offset,
        limit: limit,
      );
    }

    final countRes =
        await _client.from('applications').select('id').eq('job_id', jobUuid);
    final totalCount = (countRes as List).length;

    final rowsRes = await _client
        .from('applications')
        .select(
            'id, applicant_name, email, phone_number, status, created_at, resume_url')
        .eq('job_id', jobUuid)
        .order('created_at', ascending: sortAscendingByAppliedOn)
        .range(offset, offset + limit - 1);
    final rows = (rowsRes as List).cast<Map<String, dynamic>>();

    final items = rows.map((row) {
      final appliedOnRaw = row['created_at']?.toString();
      return JobApplicationSummary(
        id: row['id']?.toString() ?? '',
        fullName: row['applicant_name']?.toString() ?? '',
        email: row['email']?.toString() ?? '',
        phone: row['phone_number']?.toString() ?? '',
        status: row['status']?.toString() ?? 'Applied',
        appliedOn: DateTime.tryParse(appliedOnRaw ?? '') ?? DateTime.now(),
        resumeUrl: row['resume_url']?.toString() ?? '',
      );
    }).toList();

    return JobApplicationsPage(
      items: items,
      totalCount: totalCount,
      offset: offset,
      limit: limit,
    );
  }

  Future<String?> _resolveJobUuid(String businessJobId) async {
    final row = await _client
        .from(_table)
        .select('id')
        .eq('job_id', businessJobId)
        .maybeSingle();
    return row?['id']?.toString();
  }

  Future<void> updateApplicationsStatus({
    required List<String> applicationIds,
    required String status,
  }) async {
    if (applicationIds.isEmpty) return;
    await _client
        .from('applications')
        .update({'status': status}).inFilter('id', applicationIds);
  }
}
