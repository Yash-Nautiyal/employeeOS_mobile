import 'package:employeeos/core/user/current_user_profile.dart';
import 'package:employeeos/view/recruitment/presentation/bloc/job_posting/job_posting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'job_posting_card.dart';

/// One job card wired to [JobPostingBloc] via [BlocSelector] so only this card
/// rebuilds when its [jobId] row changes (not when other jobs update).
class JobPostingCardSlot extends StatelessWidget {
  const JobPostingCardSlot({
    super.key,
    required this.jobId,
    required this.theme,
    required this.profile,
    required this.onViewTap,
    required this.onEditTap,
    required this.onJobActiveChanged,
    required this.onCloseJob,
    required this.onDeleteJob,
  });

  final String jobId;
  final ThemeData theme;
  final CurrentUserProfile? profile;

  final VoidCallback onViewTap;
  final VoidCallback onEditTap;
  final Future<void> Function(String jobId, bool isActive) onJobActiveChanged;
  final Future<void> Function(String jobId) onCloseJob;
  final Future<void> Function(String jobId) onDeleteJob;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<JobPostingBloc, JobPostingState,
        JobPostingCardViewModel?>(
      selector: (state) {
        if (state is! JobPostingLoaded) return null;
        return state.snapshotFor(jobId);
      },
      builder: (context, vm) {
        if (vm == null) return const SizedBox.shrink();
        final canEditAndDelete = profile != null &&
            (profile!.canManageAnyJob ||
                (profile!.canManageOwnJobs &&
                    vm.job.postedByEmail == profile!.email));
        return JobPostingCard(
          theme: theme,
          job: vm.job,
          applicationCount: vm.applicationCount,
          canEditAndDelete: canEditAndDelete,
          onJobActiveChanged: onJobActiveChanged,
          onCloseJob: onCloseJob,
          onDeleteJob: onDeleteJob,
          onViewTap: onViewTap,
          onEditTap: onEditTap,
        );
      },
    );
  }
}
