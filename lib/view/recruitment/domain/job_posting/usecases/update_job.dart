import '../entities/job_posting.dart';
import '../repositories/job_posting_repository.dart';

class UpdateJob {
  final JobPostingRepository repository;
  const UpdateJob(this.repository);

  Future<void> call(JobPosting job) {
    return repository.updateJob(job);
  }
}
