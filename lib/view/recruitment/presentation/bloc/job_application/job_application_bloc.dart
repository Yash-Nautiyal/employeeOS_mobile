import 'package:bloc/bloc.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/usecases/get_job_applications.dart';
import 'package:employeeos/view/recruitment/domain/job_application/usecases/reject_job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/usecases/shortlist_job_application.dart';
import 'package:equatable/equatable.dart';

part 'job_application_event.dart';
part 'job_application_state.dart';

class JobApplicationBloc
    extends Bloc<JobApplicationEvent, JobApplicationState> {
  final GetJobApplicationsUseCase getJobApplicationsUseCase;
  final ShortlistJobApplicationUseCase shortlistJobApplicationUseCase;
  final RejectJobApplicationUseCase rejectJobApplicationUseCase;

  /// Last successful list filter (for reload after shortlist / reject).
  String? _filterJobId;

  JobApplicationBloc({
    required this.getJobApplicationsUseCase,
    required this.shortlistJobApplicationUseCase,
    required this.rejectJobApplicationUseCase,
  }) : super(JobApplicationInitial()) {
    on<JobApplicationsLoadRequested>(_onLoadRequested);
    on<JobApplicationShortlistRequested>(_onShortlistRequested);
    on<JobApplicationRejectRequested>(_onRejectRequested);
  }

  Future<void> _onLoadRequested(
    JobApplicationsLoadRequested event,
    Emitter<JobApplicationState> emit,
  ) async {
    emit(JobApplicationLoading());
    try {
      _filterJobId = event.jobId;
      final list = await getJobApplicationsUseCase.call(jobId: event.jobId);
      emit(JobApplicationsLoaded(
        applications: list,
        filterJobId: event.jobId,
      ));
    } catch (e) {
      emit(JobApplicationError(e.toString()));
    }
  }

  Future<void> _onShortlistRequested(
    JobApplicationShortlistRequested event,
    Emitter<JobApplicationState> emit,
  ) async {
    try {
      await shortlistJobApplicationUseCase.call(event.applicationId);
      final list = await getJobApplicationsUseCase.call(
        jobId: _filterJobId,
      );
      emit(JobApplicationsLoaded(
        applications: list,
        filterJobId: _filterJobId,
      ));
    } catch (e) {
      emit(JobApplicationError(e.toString()));
    }
  }

  Future<void> _onRejectRequested(
    JobApplicationRejectRequested event,
    Emitter<JobApplicationState> emit,
  ) async {
    try {
      await rejectJobApplicationUseCase.call(event.applicationId);
      final list = await getJobApplicationsUseCase.call(
        jobId: _filterJobId,
      );
      emit(JobApplicationsLoaded(
        applications: list,
        filterJobId: _filterJobId,
      ));
    } catch (e) {
      emit(JobApplicationError(e.toString()));
    }
  }
}
