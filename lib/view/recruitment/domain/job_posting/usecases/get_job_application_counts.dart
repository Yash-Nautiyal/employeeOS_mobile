import '../repositories/job_posting_repository.dart';

class GetJobApplicationCounts {
  final JobPostingRepository repository;

  const GetJobApplicationCounts(this.repository);

  Future<Map<String, int>> call() {
    return repository.getApplicationCountsByJobId();
  }
}
