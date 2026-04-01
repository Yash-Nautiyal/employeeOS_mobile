import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/index.dart'
    show
        ApplicationPipelineStage,
        ApplicationDbStatus,
        GetJobApplicationsPage,
        GetJobById,
        JobApplicationSummary,
        JobApplicationsPage,
        JobPosting,
        UpdateApplicationsStatus;

part 'job_posting_detail_state.dart';

class JobPostingDetailCubit extends Cubit<JobPostingDetailState> {
  JobPostingDetailCubit({
    required String jobBusinessId,
    required GetJobById getJobById,
    required GetJobApplicationsPage getJobApplicationsPage,
    required UpdateApplicationsStatus updateApplicationsStatus,
    this.pageSize = 50,
  })  : _jobBusinessId = jobBusinessId,
        _getJobById = getJobById,
        _getJobApplicationsPage = getJobApplicationsPage,
        _updateApplicationsStatus = updateApplicationsStatus,
        super(const JobPostingDetailState());

  final String _jobBusinessId;
  final GetJobById _getJobById;
  final GetJobApplicationsPage _getJobApplicationsPage;
  final UpdateApplicationsStatus _updateApplicationsStatus;
  final int pageSize;

  void _safeEmit(JobPostingDetailState newState) {
    if (isClosed) return;
    emit(newState);
  }

  Future<void> loadInitial() async {
    _safeEmit(state.copyWith(isJobLoading: true, jobError: null));
    try {
      final job = await _getJobById(_jobBusinessId);
      if (isClosed) return;
      _safeEmit(state.copyWith(isJobLoading: false, job: job));
      await loadApplicationsPage(page: 1);
    } catch (e) {
      if (isClosed) return;
      _safeEmit(state.copyWith(isJobLoading: false, jobError: e.toString()));
    }
  }

  Future<void> loadApplicationsPage({required int page}) async {
    _safeEmit(
      state.copyWith(isApplicationsLoading: true, applicationsError: null),
    );
    try {
      final offset = (page - 1) * pageSize;
      final sortAsc = state.sortAsc;
      final JobApplicationsPage result = await _getJobApplicationsPage(
        jobBusinessId: _jobBusinessId,
        offset: offset,
        limit: pageSize,
        sortAscendingByAppliedOn: sortAsc,
      );
      if (isClosed) return;
      _safeEmit(state.copyWith(
        isApplicationsLoading: false,
        applications: result.items,
        applicationsPage: result.currentPage,
        applicationsTotalPages: result.totalPages,
        selectedApplicationIds: <String>{},
      ));
    } catch (e) {
      if (isClosed) return;
      _safeEmit(state.copyWith(
        isApplicationsLoading: false,
        applicationsError: e.toString(),
      ));
    }
  }

  void toggleSelectApplication(String id) {
    final selected = Set<String>.from(state.selectedApplicationIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    _safeEmit(state.copyWith(selectedApplicationIds: selected));
  }

  void toggleSelectAllApplications() {
    final allSelected = state.applications.isNotEmpty &&
        state.applications
            .every((a) => state.selectedApplicationIds.contains(a.id));
    if (allSelected) {
      _safeEmit(state.copyWith(selectedApplicationIds: <String>{}));
      return;
    }
    _safeEmit(state.copyWith(
      selectedApplicationIds: state.applications.map((e) => e.id).toSet(),
    ));
  }

  Future<void> toggleApplicationsSort() async {
    _safeEmit(state.copyWith(sortAsc: !state.sortAsc));
    await loadApplicationsPage(page: 1);
  }

  Future<void> goPreviousApplicationsPage() async {
    if (state.applicationsPage <= 1) return;
    await loadApplicationsPage(page: state.applicationsPage - 1);
  }

  Future<void> goNextApplicationsPage() async {
    if (state.applicationsPage >= state.applicationsTotalPages) return;
    await loadApplicationsPage(page: state.applicationsPage + 1);
  }

  Future<void> retryApplicationsPage() async {
    await loadApplicationsPage(page: state.applicationsPage);
  }

  Future<int> shortlistSelected() async {
    final ids = state.selectedApplicationIds.toList(growable: false);
    if (ids.isEmpty) return 0;
    await _updateApplicationsStatus(
      applicationIds: ids,
      status: ApplicationDbStatus.shortlisted,
      currentStage: ApplicationPipelineStage.firstInterviewRound,
    );
    await loadApplicationsPage(page: state.applicationsPage);
    return ids.length;
  }

  Future<int> rejectSelected() async {
    final ids = state.selectedApplicationIds.toList(growable: false);
    if (ids.isEmpty) return 0;
    await _updateApplicationsStatus(
      applicationIds: ids,
      status: ApplicationDbStatus.rejected,
      currentStage: ApplicationDbStatus.rejected,
    );
    await loadApplicationsPage(page: state.applicationsPage);
    return ids.length;
  }
}
