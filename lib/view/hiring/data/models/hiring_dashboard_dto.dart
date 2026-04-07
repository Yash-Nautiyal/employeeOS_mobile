import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';

class HiringDashboardDto {
  final HiringSummaryDto summary;
  final List<JobPositionDto> positionsByJob;
  final PipelineOverviewDto pipelineOverview;
  final List<JobPipelineDto> perJobPipelines;

  const HiringDashboardDto({
    required this.summary,
    required this.positionsByJob,
    required this.pipelineOverview,
    required this.perJobPipelines,
  });

  factory HiringDashboardDto.fromJson(Map<String, dynamic> json) {
    return HiringDashboardDto(
      summary: HiringSummaryDto.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
      positionsByJob: (json['positions_by_job'] as List<dynamic>? ?? const [])
          .map((e) => JobPositionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      pipelineOverview: PipelineOverviewDto.fromJson(
        json['pipeline_overview'] as Map<String, dynamic>? ?? const {},
      ),
      perJobPipelines: (json['per_job_pipelines'] as List<dynamic>? ?? const [])
          .map((e) => JobPipelineDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  HiringDashboardModel toEntity() {
    return HiringDashboardModel(
      summary: summary.toEntity(),
      positionsByJob: positionsByJob.map((e) => e.toEntity()).toList(),
      pipelineOverview: pipelineOverview.toEntity(),
      perJobPipelines: perJobPipelines.map((e) => e.toEntity()).toList(),
    );
  }
}

class HiringSummaryDto {
  final int totalApplications;
  final int totalShortlisted;
  final int totalRejected;
  final int totalPending;
  final int totalJobs;
  final int totalPositions;

  const HiringSummaryDto({
    required this.totalApplications,
    required this.totalShortlisted,
    required this.totalRejected,
    required this.totalPending,
    required this.totalJobs,
    required this.totalPositions,
  });

  factory HiringSummaryDto.fromJson(Map<String, dynamic> json) {
    return HiringSummaryDto(
      totalApplications: _parseInt(json['total_applications']),
      totalShortlisted: _parseInt(json['total_shortlisted']),
      totalRejected: _parseInt(json['total_rejected']),
      totalPending: _parseInt(json['total_pending']),
      totalJobs: _parseInt(json['total_jobs']),
      totalPositions: _parseInt(json['total_positions']),
    );
  }

  HiringSummary toEntity() {
    return HiringSummary(
      totalApplications: totalApplications,
      totalShortlisted: totalShortlisted,
      totalRejected: totalRejected,
      totalPending: totalPending,
      totalJobs: totalJobs,
      totalPositions: totalPositions,
    );
  }
}

class JobPositionDto {
  final String jobTitle;
  final int positions;

  const JobPositionDto({required this.jobTitle, required this.positions});

  factory JobPositionDto.fromJson(Map<String, dynamic> json) {
    return JobPositionDto(
      jobTitle: json['job_title'] as String? ?? '',
      positions: _parseInt(json['positions']),
    );
  }

  JobPositionData toEntity() {
    return JobPositionData(jobTitle: jobTitle, positions: positions);
  }
}

class PipelineOverviewDto {
  final ApplicationProgressDto applicationProgress;
  final InterviewProgressDto interviewProgress;

  const PipelineOverviewDto({
    required this.applicationProgress,
    required this.interviewProgress,
  });

  factory PipelineOverviewDto.fromJson(Map<String, dynamic> json) {
    return PipelineOverviewDto(
      applicationProgress: ApplicationProgressDto.fromJson(
        json['application_progress'] as Map<String, dynamic>? ?? const {},
      ),
      interviewProgress: InterviewProgressDto.fromJson(
        json['interview_progress'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  PipelineOverview toEntity() {
    return PipelineOverview(
      applicationProgress: applicationProgress.toEntity(),
      interviewProgress: interviewProgress.toEntity(),
    );
  }
}

class ApplicationProgressDto {
  final int shortlisted;
  final int pending;
  final int rejected;
  final int total;

  const ApplicationProgressDto({
    required this.shortlisted,
    required this.pending,
    required this.rejected,
    required this.total,
  });

  factory ApplicationProgressDto.fromJson(Map<String, dynamic> json) {
    return ApplicationProgressDto(
      shortlisted: _parseInt(json['shortlisted']),
      pending: _parseInt(json['pending']),
      rejected: _parseInt(json['rejected']),
      total: _parseInt(json['total']),
    );
  }

  ApplicationProgress toEntity() {
    return ApplicationProgress(
      shortlisted: shortlisted,
      pending: pending,
      rejected: rejected,
      total: total,
    );
  }
}

class InterviewProgressDto {
  final StageProgressDto telephonic;
  final StageProgressDto technical;
  final StageProgressDto onboarding;

  const InterviewProgressDto({
    required this.telephonic,
    required this.technical,
    required this.onboarding,
  });

  factory InterviewProgressDto.fromJson(Map<String, dynamic> json) {
    return InterviewProgressDto(
      telephonic: StageProgressDto.fromJson(
        json['telephonic'] as Map<String, dynamic>? ?? const {},
      ),
      technical: StageProgressDto.fromJson(
        json['technical'] as Map<String, dynamic>? ?? const {},
      ),
      onboarding: StageProgressDto.fromJson(
        json['onboarding'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  InterviewProgress toEntity() {
    return InterviewProgress(
      telephonic: telephonic.toEntity(),
      technical: technical.toEntity(),
      onboarding: onboarding.toEntity(),
    );
  }
}

class StageProgressDto {
  final int active;
  final int eligible;

  const StageProgressDto({required this.active, required this.eligible});

  factory StageProgressDto.fromJson(Map<String, dynamic> json) {
    return StageProgressDto(
      active: _parseInt(json['active']),
      eligible: _parseInt(json['eligible']),
    );
  }

  StageProgress toEntity() {
    return StageProgress(active: active, eligible: eligible);
  }
}

class JobPipelineDto {
  final String jobTitle;
  final int totalApplications;
  final int shortlisted;
  final int rejected;
  final int pending;
  final int telephonicActive;
  final int telephonicEligible;
  final int technicalActive;
  final int technicalEligible;
  final int onboardingActive;
  final int onboardingEligible;

  const JobPipelineDto({
    required this.jobTitle,
    required this.totalApplications,
    required this.shortlisted,
    required this.rejected,
    required this.pending,
    required this.telephonicActive,
    required this.telephonicEligible,
    required this.technicalActive,
    required this.technicalEligible,
    required this.onboardingActive,
    required this.onboardingEligible,
  });

  factory JobPipelineDto.fromJson(Map<String, dynamic> json) {
    return JobPipelineDto(
      jobTitle: json['job_title'] as String? ?? '',
      totalApplications: _parseInt(json['total_applications']),
      shortlisted: _parseInt(json['shortlisted']),
      rejected: _parseInt(json['rejected']),
      pending: _parseInt(json['pending']),
      telephonicActive: _parseInt(json['telephonic_active']),
      telephonicEligible: _parseInt(json['telephonic_eligible']),
      technicalActive: _parseInt(json['technical_active']),
      technicalEligible: _parseInt(json['technical_eligible']),
      onboardingActive: _parseInt(json['onboarding_active']),
      onboardingEligible: _parseInt(json['onboarding_eligible']),
    );
  }

  JobPipelineData toEntity() {
    return JobPipelineData(
      jobTitle: jobTitle,
      totalApplications: totalApplications,
      shortlisted: shortlisted,
      rejected: rejected,
      pending: pending,
      telephonicActive: telephonicActive,
      telephonicEligible: telephonicEligible,
      technicalActive: technicalActive,
      technicalEligible: technicalEligible,
      onboardingActive: onboardingActive,
      onboardingEligible: onboardingEligible,
    );
  }
}

int _parseInt(Object? value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString()) ?? 0;
}
