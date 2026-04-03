import 'package:employeeos/view/recruitment/domain/job_application/entities/job_applications_list_query.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_applications_list_result.dart';
import 'package:employeeos/view/recruitment/domain/job_application/repositories/job_application_repository.dart';

class GetJobApplicationsListPageUseCase {
  final JobApplicationRepository repository;

  const GetJobApplicationsListPageUseCase(this.repository);

  Future<JobApplicationsListResult> call(JobApplicationsListQuery query) {
    return repository.getApplicationsPage(query);
  }
}
