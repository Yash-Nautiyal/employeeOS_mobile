import '../entities/job_applications_page.dart';
import '../repositories/job_posting_repository.dart';

class GetJobApplicationsPage {
  const GetJobApplicationsPage(this.repository);

  final JobPostingRepository repository;

  Future<JobApplicationsPage> call({
    required String jobBusinessId,
    required int offset,
    required int limit,
    required bool sortAscendingByAppliedOn,
  }) {
    return repository.getJobApplicationsPage(
      jobBusinessId: jobBusinessId,
      offset: offset,
      limit: limit,
      sortAscendingByAppliedOn: sortAscendingByAppliedOn,
    );
  }
}
