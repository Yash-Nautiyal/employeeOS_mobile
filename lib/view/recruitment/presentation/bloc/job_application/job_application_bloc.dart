import 'package:bloc/bloc.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_applications_list_query.dart';
import 'package:employeeos/view/recruitment/domain/job_application/usecases/get_job_applications_list_page.dart';
import 'package:employeeos/view/recruitment/domain/job_application/usecases/reject_job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/usecases/shortlist_job_application.dart';
import 'package:equatable/equatable.dart';

part 'job_application_event.dart';
part 'job_application_state.dart';

class JobApplicationBloc
    extends Bloc<JobApplicationEvent, JobApplicationState> {
  JobApplicationBloc({
    required GetJobApplicationsListPageUseCase
        getJobApplicationsListPageUseCase,
    required ShortlistJobApplicationUseCase shortlistJobApplicationUseCase,
    required RejectJobApplicationUseCase rejectJobApplicationUseCase,
  })  : _getListPage = getJobApplicationsListPageUseCase,
        _shortlist = shortlistJobApplicationUseCase,
        _reject = rejectJobApplicationUseCase,
        super(JobApplicationInitial()) {
    on<JobApplicationsListFetchRequested>(_onListFetchRequested);
    on<JobApplicationsPageSelected>(_onPageSelected);
    on<JobApplicationShortlistRequested>(_onShortlistRequested);
    on<JobApplicationRejectRequested>(_onRejectRequested);
  }

  final GetJobApplicationsListPageUseCase _getListPage;
  final ShortlistJobApplicationUseCase _shortlist;
  final RejectJobApplicationUseCase _reject;

  /// Filters without current page (page forced to 1 for equality).
  JobApplicationsListQuery? _filterBase;

  final Map<int, List<JobApplication>> _pageCache = {};

  void _setFilterBase(JobApplicationsListQuery q) {
    _filterBase = q.copyWith(page: 1);
    _pageCache.clear();
  }

  bool _sameFilterBase(JobApplicationsListQuery q) {
    final b = _filterBase;
    if (b == null) return false;
    return b == q.copyWith(page: 1);
  }

  Future<void> _onListFetchRequested(
    JobApplicationsListFetchRequested event,
    Emitter<JobApplicationState> emit,
  ) async {
    emit(JobApplicationLoading());
    _setFilterBase(event.query);
    await _fetchPage(emit, event.query, showFullLoader: false);
  }

  Future<void> _onPageSelected(
    JobApplicationsPageSelected event,
    Emitter<JobApplicationState> emit,
  ) async {
    final base = _filterBase;
    if (base == null) return;
    final q = base.copyWith(page: event.page, pageSize: base.pageSize);
    final current = state;
    if (current is JobApplicationsLoaded) {
      final cached = _sameFilterBase(q) && _pageCache.containsKey(q.page);
      if (!cached) {
        emit(current.copyWith(isLoadingPage: true));
      }
    }
    await _fetchPage(emit, q, showFullLoader: false);
  }

  Future<void> _fetchPage(
    Emitter<JobApplicationState> emit,
    JobApplicationsListQuery q, {
    required bool showFullLoader,
  }) async {
    if (_sameFilterBase(q) && _pageCache.containsKey(q.page)) {
      emit(JobApplicationsLoaded(
        applications: _pageCache[q.page]!,
        query: q,
        totalCount: _lastTotalCount,
        isLoadingPage: false,
      ));
      return;
    }

    if (showFullLoader) {
      emit(JobApplicationLoading());
    }

    try {
      final result = await _getListPage(q);
      _pageCache[q.page] = result.items;
      _lastTotalCount = result.totalCount;
      emit(JobApplicationsLoaded(
        applications: result.items,
        query: q,
        totalCount: result.totalCount,
        isLoadingPage: false,
      ));
    } catch (e) {
      emit(JobApplicationError(e.toString()));
    }
  }

  int _lastTotalCount = 0;

  Future<void> _onShortlistRequested(
    JobApplicationShortlistRequested event,
    Emitter<JobApplicationState> emit,
  ) async {
    final loaded =
        state is JobApplicationsLoaded ? state as JobApplicationsLoaded : null;
    final page = loaded?.query.page ?? 1;
    try {
      await _shortlist(event.applicationId);
      _invalidateCache();
      if (_filterBase != null) {
        final q = _filterBase!.copyWith(page: page);
        if (loaded != null) {
          emit(loaded.copyWith(isLoadingPage: true));
        } else {
          emit(JobApplicationLoading());
        }
        await _fetchPage(emit, q, showFullLoader: false);
      }
    } catch (e) {
      emit(JobApplicationError(e.toString()));
    }
  }

  Future<void> _onRejectRequested(
    JobApplicationRejectRequested event,
    Emitter<JobApplicationState> emit,
  ) async {
    final loaded =
        state is JobApplicationsLoaded ? state as JobApplicationsLoaded : null;
    final page = loaded?.query.page ?? 1;
    try {
      await _reject(event.applicationId);
      _invalidateCache();
      if (_filterBase != null) {
        final q = _filterBase!.copyWith(page: page);
        if (loaded != null) {
          emit(loaded.copyWith(isLoadingPage: true));
        } else {
          emit(JobApplicationLoading());
        }
        await _fetchPage(emit, q, showFullLoader: false);
      }
    } catch (e) {
      emit(JobApplicationError(e.toString()));
    }
  }

  void _invalidateCache() {
    _pageCache.clear();
  }
}
