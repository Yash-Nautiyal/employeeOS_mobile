import '../repositories/job_posting_repository.dart';

class ToggleJobStatus {
  final JobPostingRepository repository;

  const ToggleJobStatus(this.repository);

  Future<void> call(String id, bool isActive) {
    return repository.setJobActive(id, isActive);
  }
}