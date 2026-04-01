import 'package:employeeos/view/recruitment/data/job_application/datasources/job_application_remote_datasource.dart';
import 'package:employeeos/view/recruitment/data/job_application/repositories/job_application_repository_impl.dart';
import 'package:employeeos/view/recruitment/domain/index.dart';

import '../../bloc/job_application/job_application_bloc.dart';

class JobApplicationInjection {
  JobApplicationInjection._();

  static JobApplicationRepository? _repository;

  static JobApplicationRepository get repository {
    return _repository ??=
        JobApplicationRepositoryImpl(JobApplicationRemoteDatasource());
  }

  static JobApplicationBloc createBloc({JobApplicationRepository? repository}) {
    final repo = repository ?? JobApplicationInjection.repository;
    return JobApplicationBloc(
      getJobApplicationsUseCase: GetJobApplicationsUseCase(repo),
      shortlistJobApplicationUseCase: ShortlistJobApplicationUseCase(repo),
      rejectJobApplicationUseCase: RejectJobApplicationUseCase(repo),
    );
  }
}
