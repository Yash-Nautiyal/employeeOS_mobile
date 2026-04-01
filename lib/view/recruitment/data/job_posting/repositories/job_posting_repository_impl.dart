import '../../../domain/index.dart' show JobPosting, JobPostingRepository;
import '../../../domain/job_posting/entities/job_applications_page.dart';
import '../datasources/job_posting_remote_datasource.dart';
import '../models/job_posting_model.dart';

class JobPostingRepositoryImpl implements JobPostingRepository {
  JobPostingRepositoryImpl(this._remote);

  final JobPostingRemoteDatasource _remote;

  @override
  Future<List<JobPosting>> getAllJobs() => _remote.getAll();

  @override
  Future<JobPosting?> getJobById(String id) => _remote.getById(id);

  @override
  Future<void> addJob(JobPosting job) =>
      _remote.add(JobPostingModel.toModel(job));

  @override
  Future<void> updateJob(JobPosting job) =>
      _remote.update(JobPostingModel.toModel(job));

  @override
  Future<void> deleteJob(String id) => _remote.delete(id);

  @override
  Future<void> setJobActive(String id, bool isActive) =>
      _remote.setJobActive(id, isActive);

  @override
  Future<List<String>> getJobDepartments() => _remote.getJobDepartments();

  @override
  Future<Map<String, int>> getApplicationCountsByJobId() =>
      _remote.getApplicationCountsByJobBusinessId();

  @override
  Future<JobApplicationsPage> getJobApplicationsPage({
    required String jobBusinessId,
    required int offset,
    required int limit,
    required bool sortAscendingByAppliedOn,
  }) {
    return _remote.getJobApplicationsPage(
      jobBusinessId: jobBusinessId,
      offset: offset,
      limit: limit,
      sortAscendingByAppliedOn: sortAscendingByAppliedOn,
    );
  }

  @override
  Future<void> updateApplicationsStatus({
    required List<String> applicationIds,
    required String status,
    String? currentStage,
  }) {
    return _remote.updateApplicationsStatus(
      applicationIds: applicationIds,
      status: status,
      currentStage: currentStage,
    );
  }
}
