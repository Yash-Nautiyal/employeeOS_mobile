import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/repositories/job_application_repository.dart';

class ShortlistJobApplicationUseCase {
  final JobApplicationRepository repository;

  const ShortlistJobApplicationUseCase(this.repository);

  Future<JobApplication?> call(String applicationId) {
    return repository.shortlist(applicationId);
  }
}
