import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/repositories/job_application_repository.dart';

class GetJobApplicationsUseCase {
  final JobApplicationRepository repository;

  const GetJobApplicationsUseCase(this.repository);

  Future<List<JobApplication>> call({String? jobId}) {
    return repository.getApplications(jobId: jobId);
  }
}
