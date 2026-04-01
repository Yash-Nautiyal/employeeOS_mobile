import '../repositories/job_posting_repository.dart';

class UpdateApplicationsStatus {
  const UpdateApplicationsStatus(this.repository);

  final JobPostingRepository repository;

  Future<void> call({
    required List<String> applicationIds,
    required String status,
  }) {
    return repository.updateApplicationsStatus(
      applicationIds: applicationIds,
      status: status,
    );
  }
}
