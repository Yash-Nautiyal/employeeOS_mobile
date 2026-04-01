import '../entities/job_posting.dart';
import '../entities/job_applications_page.dart';

abstract class JobPostingRepository {
  Future<List<JobPosting>> getAllJobs();

  Future<JobPosting?> getJobById(String id);

  Future<void> addJob(JobPosting job);

  Future<void> updateJob(JobPosting job);

  Future<void> deleteJob(String id);

  Future<void> setJobActive(String id, bool isActive);

  Future<List<String>> getJobDepartments();

  Future<Map<String, int>> getApplicationCountsByJobId();

  Future<JobApplicationsPage> getJobApplicationsPage({
    required String jobBusinessId,
    required int offset,
    required int limit,
    required bool sortAscendingByAppliedOn,
  });

  Future<void> updateApplicationsStatus({
    required List<String> applicationIds,
    required String status,
  });
}
