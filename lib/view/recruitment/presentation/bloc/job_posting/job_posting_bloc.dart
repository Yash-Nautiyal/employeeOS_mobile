import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/job_posting/entities/job_posting.dart';
import '../../../domain/job_posting/usecases/delete_job.dart';
import '../../../domain/job_posting/usecases/get_all_jobs.dart';
import '../../../domain/job_posting/usecases/get_job_application_counts.dart';
import '../../../domain/job_posting/usecases/toggle_job_status.dart';

part 'job_posting_event.dart';
part 'job_posting_state.dart';

/// Presentation layer talks to **domain use cases** only, not repositories.
class JobPostingBloc extends Bloc<JobPostingEvent, JobPostingState> {
  JobPostingBloc({
    required GetAllJobs getAllJobs,
    required GetJobApplicationCounts getJobApplicationCounts,
    required ToggleJobStatus toggleJobStatus,
    required DeleteJob deleteJob,
  })  : _getAllJobs = getAllJobs,
        _getJobApplicationCounts = getJobApplicationCounts,
        _toggleJobStatus = toggleJobStatus,
        _deleteJob = deleteJob,
        super(JobPostingInitial()) {
    on<LoadJobPostingsEvent>(_onLoadJobPostings);
    on<RefreshJobPostingsEvent>(_onRefreshJobPostings);
    on<SetJobActiveEvent>(_onSetJobActive);
    on<CloseJobEvent>(_onCloseJob);
    on<DeleteJobEvent>(_onDeleteJob);
    on<ClearTransientErrorEvent>(_onClearTransientError);
  }

  final GetAllJobs _getAllJobs;
  final GetJobApplicationCounts _getJobApplicationCounts;
  final ToggleJobStatus _toggleJobStatus;
  final DeleteJob _deleteJob;

  Future<void> _onLoadJobPostings(
    LoadJobPostingsEvent event,
    Emitter<JobPostingState> emit,
  ) async {
    emit(JobPostingLoading());
    try {
      final loaded = await _fetchLoaded();
      emit(loaded);
    } catch (e) {
      emit(JobPostingLoadError(e.toString()));
    }
  }

  Future<void> _onRefreshJobPostings(
    RefreshJobPostingsEvent event,
    Emitter<JobPostingState> emit,
  ) async {
    final previous = state;
    try {
      emit(await _fetchLoaded());
    } catch (e) {
      if (previous is JobPostingLoaded) {
        emit(previous.copyWith(transientError: e.toString()));
      } else if (previous is JobPostingLoadError) {
        emit(JobPostingLoadError(e.toString()));
      } else {
        emit(JobPostingLoadError(e.toString()));
      }
    }
  }

  Future<void> _onSetJobActive(
    SetJobActiveEvent event,
    Emitter<JobPostingState> emit,
  ) async {
    final previous = state;
    try {
      await _toggleJobStatus(event.jobId, event.isActive);
      await _emitRefreshed(emit);
    } catch (e) {
      _emitMutationFailure(emit, previous, e);
    }
  }

  Future<void> _onCloseJob(
    CloseJobEvent event,
    Emitter<JobPostingState> emit,
  ) async {
    final previous = state;
    try {
      await _toggleJobStatus(event.jobId, false);
      await _emitRefreshed(emit);
    } catch (e) {
      _emitMutationFailure(emit, previous, e);
    }
  }

  Future<void> _onDeleteJob(
    DeleteJobEvent event,
    Emitter<JobPostingState> emit,
  ) async {
    final previous = state;
    try {
      await _deleteJob(event.jobId);
      await _emitRefreshed(emit);
    } catch (e) {
      _emitMutationFailure(emit, previous, e);
    }
  }

  void _onClearTransientError(
    ClearTransientErrorEvent event,
    Emitter<JobPostingState> emit,
  ) {
    final current = state;
    if (current is JobPostingLoaded && current.transientError != null) {
      emit(current.copyWith(clearTransientError: true));
    }
  }

  Future<JobPostingLoaded> _fetchLoaded() async {
    final jobs = await _getAllJobs();
    final counts = await _getJobApplicationCounts();
    return JobPostingLoaded(jobs: jobs, applicationCounts: counts);
  }

  Future<void> _emitRefreshed(Emitter<JobPostingState> emit) async {
    emit(await _fetchLoaded());
  }

  void _emitMutationFailure(
    Emitter<JobPostingState> emit,
    JobPostingState previous,
    Object e,
  ) {
    if (previous is JobPostingLoaded) {
      emit(previous.copyWith(transientError: e.toString()));
    } else {
      emit(JobPostingLoadError(e.toString()));
    }
  }
}
