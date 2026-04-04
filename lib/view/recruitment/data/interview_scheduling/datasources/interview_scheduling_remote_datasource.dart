import 'package:employeeos/core/network/remote_data_exception.dart';
import 'package:employeeos/core/network/run_supabase_remote.dart';
import 'package:employeeos/view/recruitment/domain/index.dart'
    show
        InterviewBatchFailure,
        InterviewBatchMutationResult,
        InterviewDbStage,
        InterviewDbStatus,
        InterviewRound,
        InterviewScheduleDetails,
        interviewDbStageToRound,
        interviewRoundToDbStage;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/interview_candidate_model.dart';

/// Reads and updates `public.interviews` (single row per application, Option B).
///
/// If `.select` fails on nested `applications` / `jobs`, adjust embed names to
/// match your Supabase foreign-key hints (e.g. `jobs!applications_job_id_fkey`).
class InterviewSchedulingRemoteDatasource {
  InterviewSchedulingRemoteDatasource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _table = 'interviews';

  static const String _selectWithApplication = '''
id,
application_id,
stage,
status,
schedule_date,
interviewer,
assigned_by,
applications!inner(
  applicant_name,
  email,
  created_at,
  job_id,
  jobs(
    job_id,
    title
  )
)
''';

  static const String _noMatchingRowMessage =
      'No matching interview row (wrong stage/status, missing row, or no permission).';

  Future<List<InterviewCandidateModel>> fetchPipelineRows() =>
      runSupabaseRemote(() async {
        final res = await _client
            .from(_table)
            .select(_selectWithApplication)
            .order('updated_at', ascending: false);
        final rows = (res as List).cast<Map<String, dynamic>>();
        return rows.map(_mapRow).toList();
      });

  /// Per–application-id updates; failures do not cancel successes.
  Future<InterviewBatchMutationResult> scheduleApplications(
    Set<String> applicationIds,
    InterviewRound round,
    InterviewScheduleDetails details,
  ) async {
    if (applicationIds.isEmpty) return InterviewBatchMutationResult.empty;

    final stage = interviewRoundToDbStage(round);
    final payload = {
      'status': InterviewDbStatus.scheduled,
      'schedule_date': details.scheduleStart.toUtc().toIso8601String(),
      'interviewer': details.interviewerLabel,
      'assigned_by': details.assignedByLabel,
    };

    final succeeded = <String>[];
    final failures = <InterviewBatchFailure>[];

    for (final id in applicationIds) {
      try {
        await runSupabaseRemote(() async {
          final updated = await _client
              .from(_table)
              .update(payload)
              .eq('application_id', id)
              .eq('stage', stage)
              .eq('status', InterviewDbStatus.eligible)
              .select('application_id')
              .maybeSingle();
          if (updated == null) {
            throw RemoteDataException(
              kind: RemoteDataFailureKind.server,
              message:
                  'Could not save this schedule. The applicant may not be Eligible '
                  'for this round in the database, or your account may not have '
                  'permission to update interviews.',
            );
          }
        });
        succeeded.add(id);
      } catch (e) {
        failures.add(
          InterviewBatchFailure(
            applicationId: id,
            message: _batchFailureMessage(e),
          ),
        );
      }
    }

    return InterviewBatchMutationResult(
      succeededApplicationIds: succeeded,
      failures: failures,
    );
  }

  Future<InterviewBatchMutationResult> advanceAfterInterview(
    Set<String> applicationIds,
    InterviewRound round,
  ) async {
    if (applicationIds.isEmpty) return InterviewBatchMutationResult.empty;

    final succeeded = <String>[];
    final failures = <InterviewBatchFailure>[];

    for (final id in applicationIds) {
      try {
        await runSupabaseRemote(() async {
          if (round == InterviewRound.telephone) {
            final updated = await _client
                .from(_table)
                .update({
                  'stage': InterviewDbStage.technical,
                  'status': InterviewDbStatus.eligible,
                  'schedule_date': null,
                })
                .eq('application_id', id)
                .eq('stage', InterviewDbStage.telephone)
                .eq('status', InterviewDbStatus.scheduled)
                .select('application_id')
                .maybeSingle();
            if (updated == null) {
              throw RemoteDataException(
                kind: RemoteDataFailureKind.server,
                message: _noMatchingRowMessage,
              );
            }
          } else if (round == InterviewRound.technical) {
            final updated = await _client
                .from(_table)
                .update({
                  'stage': InterviewDbStage.selected,
                  'status': InterviewDbStatus.eligible,
                  'schedule_date': null,
                })
                .eq('application_id', id)
                .eq('stage', InterviewDbStage.technical)
                .eq('status', InterviewDbStatus.scheduled)
                .select('application_id')
                .maybeSingle();
            if (updated == null) {
              throw RemoteDataException(
                kind: RemoteDataFailureKind.server,
                message: _noMatchingRowMessage,
              );
            }
          } else {
            throw RemoteDataException(
              kind: RemoteDataFailureKind.server,
              message:
                  'Advance is only supported after telephone or technical.',
            );
          }
        });
        succeeded.add(id);
      } catch (e) {
        failures.add(
          InterviewBatchFailure(
            applicationId: id,
            message: _batchFailureMessage(e),
          ),
        );
      }
    }

    return InterviewBatchMutationResult(
      succeededApplicationIds: succeeded,
      failures: failures,
    );
  }

  Future<InterviewBatchMutationResult> rejectApplications(
    Set<String> applicationIds,
    InterviewRound fromRound,
  ) async {
    if (applicationIds.isEmpty) return InterviewBatchMutationResult.empty;
    if (fromRound == InterviewRound.rejected) {
      return InterviewBatchMutationResult.empty;
    }

    final stage = interviewRoundToDbStage(fromRound);
    final succeeded = <String>[];
    final failures = <InterviewBatchFailure>[];

    for (final id in applicationIds) {
      try {
        await runSupabaseRemote(() async {
          final updated = await _client
              .from(_table)
              .update({'status': InterviewDbStatus.rejected})
              .eq('application_id', id)
              .eq('stage', stage)
              .select('application_id')
              .maybeSingle();
          if (updated == null) {
            throw RemoteDataException(
              kind: RemoteDataFailureKind.server,
              message: _noMatchingRowMessage,
            );
          }
        });
        succeeded.add(id);
      } catch (e) {
        failures.add(
          InterviewBatchFailure(
            applicationId: id,
            message: _batchFailureMessage(e),
          ),
        );
      }
    }

    return InterviewBatchMutationResult(
      succeededApplicationIds: succeeded,
      failures: failures,
    );
  }

  Future<InterviewBatchMutationResult> onboardApplications(
    Set<String> applicationIds,
  ) async {
    if (applicationIds.isEmpty) return InterviewBatchMutationResult.empty;

    final succeeded = <String>[];
    final failures = <InterviewBatchFailure>[];

    for (final id in applicationIds) {
      try {
        await runSupabaseRemote(() async {
          final updated = await _client
              .from(_table)
              .update({
                'stage': InterviewDbStage.onboarding,
                'status': InterviewDbStatus.eligible,
                'schedule_date': null,
              })
              .eq('application_id', id)
              .eq('stage', InterviewDbStage.selected)
              .eq('status', InterviewDbStatus.eligible)
              .select('application_id')
              .maybeSingle();
          if (updated == null) {
            throw RemoteDataException(
              kind: RemoteDataFailureKind.server,
              message: _noMatchingRowMessage,
            );
          }
        });
        succeeded.add(id);
      } catch (e) {
        failures.add(
          InterviewBatchFailure(
            applicationId: id,
            message: _batchFailureMessage(e),
          ),
        );
      }
    }

    return InterviewBatchMutationResult(
      succeededApplicationIds: succeeded,
      failures: failures,
    );
  }

  Future<InterviewBatchMutationResult> flushOnboarding(
    Set<String> applicationIds,
  ) async {
    if (applicationIds.isEmpty) return InterviewBatchMutationResult.empty;

    final succeeded = <String>[];
    final failures = <InterviewBatchFailure>[];

    for (final id in applicationIds) {
      try {
        await runSupabaseRemote(() async {
          final deleted = await _client
              .from(_table)
              .delete()
              .eq('application_id', id)
              .eq('stage', InterviewDbStage.onboarding)
              .select('application_id')
              .maybeSingle();
          if (deleted == null) {
            throw RemoteDataException(
              kind: RemoteDataFailureKind.server,
              message: _noMatchingRowMessage,
            );
          }
        });
        succeeded.add(id);
      } catch (e) {
        failures.add(
          InterviewBatchFailure(
            applicationId: id,
            message: _batchFailureMessage(e),
          ),
        );
      }
    }

    return InterviewBatchMutationResult(
      succeededApplicationIds: succeeded,
      failures: failures,
    );
  }

  static String _batchFailureMessage(Object e) {
    if (e is RemoteDataException) return e.message;
    return e.toString();
  }

  static InterviewCandidateModel _mapRow(Map<String, dynamic> row) {
    final app = _asMap(row['applications']);
    final jobs = app != null ? _asMap(app['jobs']) : null;

    final applicationId = row['application_id']?.toString() ?? '';
    final dbStage = row['stage']?.toString() ?? '';
    final dbStatus = row['status']?.toString() ?? '';

    final applicantName = app?['applicant_name']?.toString() ?? '';
    final email = app?['email']?.toString() ?? '';
    final createdAt = _parseDate(app?['created_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final jobBusinessId = jobs?['job_id']?.toString() ?? '';
    final jobTitle = jobs?['title']?.toString() ?? '';

    final scheduleDate = _parseDate(row['schedule_date']);
    final interviewDate = scheduleDate ?? createdAt;

    final interviewer = row['interviewer']?.toString().trim().isNotEmpty == true
        ? row['interviewer'].toString()
        : '—';

    final stageRound = interviewDbStageToRound(dbStage);
    final statusNorm = dbStatus.toLowerCase();

    InterviewRound pipelineRound;
    InterviewRound? rejectedFromRound;

    if (statusNorm == InterviewDbStatus.rejected) {
      pipelineRound = InterviewRound.rejected;
      rejectedFromRound = stageRound ?? InterviewRound.telephone;
    } else {
      pipelineRound = stageRound ?? InterviewRound.telephone;
      rejectedFromRound = null;
    }

    final displayStatus = _displayStatus(statusNorm, dbStage.toLowerCase());

    return InterviewCandidateModel(
      id: applicationId,
      name: applicantName,
      email: email,
      jobTitle: jobTitle,
      applicationDate: createdAt,
      interviewDate: interviewDate,
      jobId: jobBusinessId,
      interviewer: interviewer,
      status: displayStatus,
      pipelineRound: pipelineRound,
      rejectedFromRound: rejectedFromRound,
    );
  }

  static String _displayStatus(String statusNorm, String stageNorm) {
    if (statusNorm == InterviewDbStatus.rejected) return 'Rejected';
    if (stageNorm == InterviewDbStage.selected &&
        statusNorm == InterviewDbStatus.eligible) {
      return 'Selected';
    }
    if (stageNorm == InterviewDbStage.onboarding &&
        statusNorm == InterviewDbStatus.eligible) {
      return 'Onboarding';
    }
    if (statusNorm == InterviewDbStatus.eligible) return 'Eligible';
    if (statusNorm == InterviewDbStatus.scheduled) return 'Scheduled';
    if (statusNorm == InterviewDbStatus.passed) return 'Passed';
    if (statusNorm.isEmpty) return 'Eligible';
    return statusNorm[0].toUpperCase() +
        (statusNorm.length > 1 ? statusNorm.substring(1) : '');
  }

  static Map<String, dynamic>? _asMap(dynamic v) {
    if (v == null) return null;
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}
