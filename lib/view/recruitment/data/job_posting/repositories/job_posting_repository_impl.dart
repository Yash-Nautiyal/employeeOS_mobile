import '../../../domain/index.dart' show JobPosting, JobPostingRepository;
import '../../../domain/job_posting/entities/job_applications_page.dart';
import '../../../data/index.dart'
    show JobPostingMockDatasource, JobPostingRemoteDatasource, JobPostingModel;

class JobPostingRepositoryImpl implements JobPostingRepository {
  final JobPostingMockDatasource? localDataSource;
  final JobPostingRemoteDatasource? remoteDataSource;

  const JobPostingRepositoryImpl.local(this.localDataSource)
      : remoteDataSource = null;

  const JobPostingRepositoryImpl.remote(this.remoteDataSource)
      : localDataSource = null;

  JobPostingRemoteDatasource get _remote {
    if (remoteDataSource == null) {
      throw Exception('Job posting remote datasource is not configured');
    }
    return remoteDataSource!;
  }

  @override
  Future<List<JobPosting>> getAllJobs() {
    return _remote.getAll();
  }

  @override
  Future<JobPosting?> getJobById(String id) {
    return _remote.getById(id);
  }

  @override
  Future<void> addJob(JobPosting job) {
    return _remote.add(JobPostingModel.toModel(job));
  }

  @override
  Future<void> updateJob(JobPosting job) {
    return _remote.update(JobPostingModel.toModel(job));
  }

  @override
  Future<void> deleteJob(String id) {
    return _remote.delete(id);
  }

  @override
  Future<void> setJobActive(String id, bool isActive) {
    return _remote.setJobActive(id, isActive);
  }

  @override
  Future<List<String>> getJobDepartments() async {
    if (remoteDataSource != null) return _remote.getJobDepartments();
    if (localDataSource == null) return [];
    return localDataSource!.getJobDepartments();
  }

  @override
  Future<Map<String, int>> getApplicationCountsByJobId() async {
    if (remoteDataSource != null) {
      return _remote.getApplicationCountsByJobBusinessId();
    }
    return const {};
  }

  @override
  Future<JobApplicationsPage> getJobApplicationsPage({
    required String jobBusinessId,
    required int offset,
    required int limit,
    required bool sortAscendingByAppliedOn,
  }) async {
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
  }) {
    return _remote.updateApplicationsStatus(
      applicationIds: applicationIds,
      status: status,
    );
  }
}
