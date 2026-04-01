import '../entities/job_posting.dart';
import '../repositories/job_posting_repository.dart';

class GetJobById {
  final JobPostingRepository repository;

  const GetJobById(this.repository);

  Future<JobPosting?> call(String id) {
    return repository.getJobById(id);
  }
}
