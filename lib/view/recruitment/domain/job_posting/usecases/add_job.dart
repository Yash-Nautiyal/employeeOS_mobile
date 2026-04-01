import '../entities/job_posting.dart';
import '../repositories/job_posting_repository.dart';

class AddJob {
  final JobPostingRepository repository;

  const AddJob(this.repository);

  Future<void> call(JobPosting job) {
    return repository.addJob(job);
  }
}
