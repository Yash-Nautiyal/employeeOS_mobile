import 'package:equatable/equatable.dart';
import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';

enum HiringStatus { initial, loading, success, failure }

class HiringState extends Equatable {
  const HiringState({
    this.status = HiringStatus.initial,
    required this.dashboard,
    this.filters = HiringFilterParams.empty,
    this.errorMessage,
    this.jobOptions = const [],
    this.hrOptions = const [],
    this.allJobPipelines = const [],
    this.hasCompletedLoad = false,
  });

  factory HiringState.initial() => HiringState(
        status: HiringStatus.initial,
        dashboard: HiringDashboardModel.empty(),
      );

  final HiringStatus status;
  final HiringDashboardModel dashboard;
  final HiringFilterParams filters;
  final String? errorMessage;
  final List<JobOption> jobOptions;
  final List<HrOption> hrOptions;
  final List<JobPipelineData> allJobPipelines;
  final bool hasCompletedLoad;

  HiringState copyWith({
    HiringStatus? status,
    HiringDashboardModel? dashboard,
    HiringFilterParams? filters,
    String? Function()? errorMessage,
    List<JobOption>? jobOptions,
    List<HrOption>? hrOptions,
    List<JobPipelineData>? allJobPipelines,
    bool? hasCompletedLoad,
  }) {
    return HiringState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      filters: filters ?? this.filters,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      jobOptions: jobOptions ?? this.jobOptions,
      hrOptions: hrOptions ?? this.hrOptions,
      allJobPipelines: allJobPipelines ?? this.allJobPipelines,
      hasCompletedLoad: hasCompletedLoad ?? this.hasCompletedLoad,
    );
  }

  @override
  List<Object?> get props => [
        status,
        dashboard,
        filters,
        errorMessage,
        jobOptions,
        hrOptions,
        allJobPipelines,
        hasCompletedLoad,
      ];
}
