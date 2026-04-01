import 'package:employeeos/view/recruitment/data/index.dart'
    show JobPostingRemoteDatasource, JobPostingRepositoryImpl;
import 'package:employeeos/view/recruitment/domain/index.dart';

import '../../bloc/job_posting/job_posting_bloc.dart';
import '../../bloc/job_posting/job_posting_detail_cubit.dart';

class JobPostingInjection {
  JobPostingInjection._();

  static JobPostingRepository? _jobPostingRepository;

  static JobPostingRepository get jobPostingRepository {
    return _jobPostingRepository ??=
        JobPostingRepositoryImpl(JobPostingRemoteDatasource());
  }

  // —— Use cases (call from blocs / pages; do not construct repos in widgets.) ——

  static GetAllJobs get getAllJobs => GetAllJobs(jobPostingRepository);

  static AddJob get addJob => AddJob(jobPostingRepository);

  static UpdateJob get updateJob => UpdateJob(jobPostingRepository);

  static DeleteJob get deleteJob => DeleteJob(jobPostingRepository);

  static ToggleJobStatus get toggleJobStatus =>
      ToggleJobStatus(jobPostingRepository);

  static GetJobById get getJobById => GetJobById(jobPostingRepository);
  static GetJobApplicationsPage get getJobApplicationsPage =>
      GetJobApplicationsPage(jobPostingRepository);

  static UpdateApplicationsStatus get updateApplicationsStatus =>
      UpdateApplicationsStatus(jobPostingRepository);

  static GetJobDepartmentUseCase get getJobDepartments =>
      GetJobDepartmentUseCase(jobPostingRepository);

  static GetJobApplicationCounts get getJobApplicationCounts =>
      GetJobApplicationCounts(jobPostingRepository);

  static JobPostingBloc createBloc() {
    return JobPostingBloc(
      getAllJobs: getAllJobs,
      getJobApplicationCounts: getJobApplicationCounts,
      toggleJobStatus: toggleJobStatus,
      deleteJob: deleteJob,
    );
  }

  static JobPostingDetailCubit createDetailCubit(
      {required String jobBusinessId}) {
    return JobPostingDetailCubit(
      jobBusinessId: jobBusinessId,
      getJobById: getJobById,
      getJobApplicationsPage: getJobApplicationsPage,
      updateApplicationsStatus: updateApplicationsStatus,
    );
  }
}
