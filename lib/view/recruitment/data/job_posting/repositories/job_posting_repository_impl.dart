import 'package:employeeos/view/recruitment/data/job_posting/datasources/job_posting_mock_datasource.dart';
import 'package:employeeos/view/recruitment/domain/job_posting/repositories/job_posting_repository.dart';

class JobPostingRepositoryImpl implements JobPostingRepository {
  final JobPostingMockDatasource localDataSource;

  const JobPostingRepositoryImpl(this.localDataSource);
  @override
  Future<List<String>> getJobDepartments() {
    return localDataSource.getJobDepartments();
  }
}
