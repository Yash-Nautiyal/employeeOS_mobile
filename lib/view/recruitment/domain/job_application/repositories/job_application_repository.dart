import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_applications_list_query.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_applications_list_result.dart';

abstract class JobApplicationRepository {
  Future<List<JobApplication>> getApplications({String? jobId});

  Future<JobApplicationsListResult> getApplicationsPage(
    JobApplicationsListQuery query,
  );

  Future<JobApplication?> shortlist(String applicationId);

  Future<JobApplication?> reject(String applicationId);
}
