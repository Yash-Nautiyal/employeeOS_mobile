import 'package:employeeos/core/network/remote_data_exception.dart';
import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:employeeos/view/hiring/domain/usecases/get_hiring_dashboard.dart';
import 'package:employeeos/view/hiring/domain/usecases/get_hiring_hr_options.dart';
import 'package:employeeos/view/hiring/domain/usecases/get_hiring_job_options.dart';
import 'package:employeeos/view/hiring/presentation/bloc/hiring_event.dart';
import 'package:employeeos/view/hiring/presentation/bloc/hiring_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HiringBloc extends Bloc<HiringEvent, HiringState> {
  HiringBloc({
    required GetHiringDashboard getHiringDashboard,
    required GetHiringJobOptions getHiringJobOptions,
    required GetHiringHrOptions getHiringHrOptions,
  })  : _getHiringDashboard = getHiringDashboard,
        _getHiringJobOptions = getHiringJobOptions,
        _getHiringHrOptions = getHiringHrOptions,
        super(HiringState.initial()) {
    on<HiringLoadRequested>(_onLoadRequested);
    on<HiringFiltersChanged>(_onFiltersChanged);
    on<HiringFiltersClearRequested>(_onFiltersClearRequested);
    on<HiringRefreshRequested>(_onRefreshRequested);
  }

  final GetHiringDashboard _getHiringDashboard;
  final GetHiringJobOptions _getHiringJobOptions;
  final GetHiringHrOptions _getHiringHrOptions;

  static String _messageFor(Object error) {
    if (error is RemoteDataException) return error.message;
    return error.toString();
  }

  Future<void> _onLoadRequested(
    HiringLoadRequested event,
    Emitter<HiringState> emit,
  ) async {
    emit(state.copyWith(status: HiringStatus.loading));
    try {
      final results = await Future.wait([
        _getHiringDashboard(state.filters),
        _getHiringDashboard(HiringFilterParams.empty),
        _getHiringJobOptions(),
        _getHiringHrOptions(),
      ]);
      emit(state.copyWith(
        status: HiringStatus.success,
        dashboard: results[0] as HiringDashboardModel,
        allJobPipelines: (results[1] as HiringDashboardModel).perJobPipelines,
        jobOptions: results[2] as List<JobOption>,
        hrOptions: results[3] as List<HrOption>,
        errorMessage: () => null,
        hasCompletedLoad: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HiringStatus.failure,
        errorMessage: () => _messageFor(e),
        hasCompletedLoad: true,
      ));
    }
  }

  Future<void> _onFiltersChanged(
    HiringFiltersChanged event,
    Emitter<HiringState> emit,
  ) async {
    emit(state.copyWith(status: HiringStatus.loading, filters: event.filters));
    try {
      final dashboard = await _getHiringDashboard(event.filters);
      emit(state.copyWith(
        status: HiringStatus.success,
        dashboard: dashboard,
        errorMessage: () => null,
        hasCompletedLoad: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HiringStatus.failure,
        errorMessage: () => _messageFor(e),
        hasCompletedLoad: true,
      ));
    }
  }

  Future<void> _onFiltersClearRequested(
    HiringFiltersClearRequested event,
    Emitter<HiringState> emit,
  ) async {
    emit(state.copyWith(
      status: HiringStatus.loading,
      filters: HiringFilterParams.empty,
    ));
    try {
      final dashboard = await _getHiringDashboard(HiringFilterParams.empty);
      emit(state.copyWith(
        status: HiringStatus.success,
        dashboard: dashboard,
        errorMessage: () => null,
        hasCompletedLoad: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HiringStatus.failure,
        errorMessage: () => _messageFor(e),
        hasCompletedLoad: true,
      ));
    }
  }

  Future<void> _onRefreshRequested(
    HiringRefreshRequested event,
    Emitter<HiringState> emit,
  ) async {
    try {
      final results = await Future.wait<HiringDashboardModel>([
        _getHiringDashboard(state.filters),
        _getHiringDashboard(HiringFilterParams.empty),
      ]);
      emit(state.copyWith(
        status: HiringStatus.success,
        dashboard: results[0],
        allJobPipelines: results[1].perJobPipelines,
        errorMessage: () => null,
        hasCompletedLoad: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HiringStatus.failure,
        errorMessage: () => _messageFor(e),
        hasCompletedLoad: true,
      ));
    }
  }
}
