import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';

abstract class JobApplicationRepository {
  Future<List<JobApplication>> getApplications({String? jobId});

  Future<JobApplication?> shortlist(String applicationId);

  Future<JobApplication?> reject(String applicationId);
}
