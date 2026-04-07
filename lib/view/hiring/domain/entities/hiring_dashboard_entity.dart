class HiringDashboardModel {
  final HiringSummary summary;
  final List<JobPositionData> positionsByJob;
  final PipelineOverview pipelineOverview;
  final List<JobPipelineData> perJobPipelines;

  const HiringDashboardModel({
    required this.summary,
    required this.positionsByJob,
    required this.pipelineOverview,
    required this.perJobPipelines,
  });

  factory HiringDashboardModel.empty() {
    return HiringDashboardModel(
      summary: HiringSummary.empty(),
      positionsByJob: const [],
      pipelineOverview: PipelineOverview.empty(),
      perJobPipelines: const [],
    );
  }
}

class HiringSummary {
  final int totalApplications;
  final int totalShortlisted;
  final int totalRejected;
  final int totalPending;
  final int totalJobs;
  final int totalPositions;

  const HiringSummary({
    required this.totalApplications,
    required this.totalShortlisted,
    required this.totalRejected,
    required this.totalPending,
    required this.totalJobs,
    required this.totalPositions,
  });

  factory HiringSummary.empty() => const HiringSummary(
        totalApplications: 0,
        totalShortlisted: 0,
        totalRejected: 0,
        totalPending: 0,
        totalJobs: 0,
        totalPositions: 0,
      );
}

class JobPositionData {
  final String jobTitle;
  final int positions;

  const JobPositionData({
    required this.jobTitle,
    required this.positions,
  });
}

class PipelineOverview {
  final ApplicationProgress applicationProgress;
  final InterviewProgress interviewProgress;

  const PipelineOverview({
    required this.applicationProgress,
    required this.interviewProgress,
  });

  factory PipelineOverview.empty() => PipelineOverview(
        applicationProgress: ApplicationProgress.empty(),
        interviewProgress: InterviewProgress.empty(),
      );
}

class ApplicationProgress {
  final int shortlisted;
  final int pending;
  final int rejected;
  final int total;

  const ApplicationProgress({
    required this.shortlisted,
    required this.pending,
    required this.rejected,
    required this.total,
  });

  factory ApplicationProgress.empty() => const ApplicationProgress(
        shortlisted: 0,
        pending: 0,
        rejected: 0,
        total: 0,
      );
}

class InterviewProgress {
  final StageProgress telephonic;
  final StageProgress technical;
  final StageProgress onboarding;

  const InterviewProgress({
    required this.telephonic,
    required this.technical,
    required this.onboarding,
  });

  factory InterviewProgress.empty() => InterviewProgress(
        telephonic: StageProgress.empty(),
        technical: StageProgress.empty(),
        onboarding: StageProgress.empty(),
      );
}

class StageProgress {
  final int active;
  final int eligible;

  const StageProgress({required this.active, required this.eligible});

  factory StageProgress.empty() => const StageProgress(active: 0, eligible: 0);
}

class JobPipelineData {
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

  const JobPipelineData({
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
}
