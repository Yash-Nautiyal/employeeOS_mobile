import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/repositories/job_application_repository.dart';

class RejectJobApplicationUseCase {
  final JobApplicationRepository repository;

  const RejectJobApplicationUseCase(this.repository);

  Future<JobApplication?> call(String applicationId) {
    return repository.reject(applicationId);
  }
}
