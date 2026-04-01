import '../repositories/job_posting_repository.dart';

class DeleteJob {
  final JobPostingRepository repository;

  const DeleteJob(this.repository);

  Future<void> call(String id) {
    return repository.deleteJob(id);
  }
}