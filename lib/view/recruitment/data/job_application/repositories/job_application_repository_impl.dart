import 'package:employeeos/view/recruitment/data/job_application/datasources/job_application_remote_datasource.dart';
import 'package:employeeos/view/recruitment/data/interview_scheduling/datasources/interview_scheduling_local_data_source.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_applications_list_query.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_applications_list_result.dart';
import 'package:employeeos/view/recruitment/domain/job_application/repositories/job_application_repository.dart';

class JobApplicationRepositoryImpl implements JobApplicationRepository {
  JobApplicationRepositoryImpl(this._remote);

  final JobApplicationRemoteDatasource _remote;

  @override
  Future<List<JobApplication>> getApplications({String? jobId}) {
    return _remote.getApplications(jobId: jobId);
  }

  @override
  Future<JobApplicationsListResult> getApplicationsPage(
    JobApplicationsListQuery query,
  ) {
    return _remote.getApplicationsPage(query);
  }

  @override
  Future<JobApplication?> shortlist(String applicationId) async {
    final updated = await _remote.shortlist(applicationId);
    if (updated != null) {
      await InterviewSchedulingLocalDataSource.instance
          .syncEligibleFromShortlistedApplication(
        applicationId: updated.id,
        fullName: updated.fullName,
        email: updated.email,
        jobTitle: updated.jobTitle,
        appliedOn: updated.appliedOn,
        jobId: updated.jobId,
      );
    }
    return updated;
  }

  @override
  Future<JobApplication?> reject(String applicationId) {
    return _remote.reject(applicationId);
  }
}
