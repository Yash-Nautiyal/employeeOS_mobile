import '../repositories/job_posting_repository.dart';

class GetJobDepartmentUseCase {
  final JobPostingRepository repository;

  const GetJobDepartmentUseCase(this.repository);

  Future<List<String>> call() {
    return repository.getJobDepartments();
  }
}
