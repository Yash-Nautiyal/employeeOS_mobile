import 'package:employeeos/view/recruitment/data/job_application/datasources/job_application_mock_datasource.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/repositories/job_application_repository.dart';

class JobApplicationRepositoryImpl implements JobApplicationRepository {
  final JobApplicationMockDatasource _local;

  JobApplicationRepositoryImpl(this._local);

  @override
  Future<List<JobApplication>> getApplications({String? jobId}) {
    return _local.getApplications(jobId: jobId);
  }

  @override
  Future<JobApplication?> shortlist(String applicationId) {
    return _local.shortlist(applicationId);
  }

  @override
  Future<JobApplication?> reject(String applicationId) {
    return _local.reject(applicationId);
  }
}
