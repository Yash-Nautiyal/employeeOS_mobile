import '../../../data/index.dart'
    show JobApplicationMockDatasource, JobApplicationRepositoryImpl;
import '../../../domain/index.dart';
import '../../bloc/job_application/job_application_bloc.dart';

class JobApplicationInjection {
  JobApplicationInjection._();

  static JobApplicationBloc createBloc({JobApplicationRepository? repository}) {
    final repo = repository ??
        JobApplicationRepositoryImpl(JobApplicationMockDatasource.instance);
    final bloc = JobApplicationBloc(
        getJobApplicationsUseCase: GetJobApplicationsUseCase(repo),
        shortlistJobApplicationUseCase: ShortlistJobApplicationUseCase(repo),
        rejectJobApplicationUseCase: RejectJobApplicationUseCase(repo));
    return bloc;
  }
}
