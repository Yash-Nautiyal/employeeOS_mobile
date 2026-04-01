import '../entities/job_posting.dart';
import '../repositories/job_posting_repository.dart';

class GetAllJobs {
  final JobPostingRepository repository;

  const GetAllJobs(this.repository);

  Future<List<JobPosting>> call() {
    return repository.getAllJobs();
  }
}