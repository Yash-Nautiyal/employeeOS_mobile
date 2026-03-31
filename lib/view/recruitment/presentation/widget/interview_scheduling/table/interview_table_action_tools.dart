import 'package:employeeos/core/index.dart' show AppPallete, CustomTextButton;
import 'package:flutter/material.dart';

import '../../../../domain/index.dart'
    show InterviewCandidateTab, InterviewRound, InterviewRoundLabel;
import '../../../bloc/interview_scheduling/interview_scheduling_bloc.dart'
    show InterviewSchedulingState;
import '../components/schedule_button.dart';

class InterviewTableActionTools extends StatelessWidget {
  final ThemeData theme;
  final InterviewSchedulingState state;
  final VoidCallback onOnboard;
  final VoidCallback onReject;
  final VoidCallback onSchedule;
  final VoidCallback onSelect;
  final VoidCallback onFlush;
  const InterviewTableActionTools({
    super.key,
    required this.theme,
    required this.state,
    required this.onOnboard,
    required this.onReject,
    required this.onSchedule,
    required this.onSelect,
    required this.onFlush,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = state.selectedIds.isNotEmpty;
    final r = state.activeRound;
    final tab = state.activeTab;

    if (r == InterviewRound.rejected) {
      return const SizedBox.shrink();
    }

    if (r == InterviewRound.selected) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextButton(
            padding: 0,
            backgroundColor: hasSelection
                ? theme.colorScheme.tertiary
                : theme.disabledColor.withAlpha(100),
            onClick: hasSelection ? () => onOnboard.call() : () {},
            child: Text(
              'Onboard',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.scaffoldBackgroundColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CustomTextButton(
            padding: 0,
            backgroundColor: hasSelection
                ? AppPallete.errorMain
                : theme.disabledColor.withAlpha(100),
            onClick: hasSelection ? () => onReject.call() : () {},
            child: Text(
              'Reject',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.scaffoldBackgroundColor,
              ),
            ),
          ),
        ],
      );
    }

    if (r == InterviewRound.onboarding) {
      return CustomTextButton(
        padding: 0,
        backgroundColor: hasSelection
            ? theme.colorScheme.tertiary
            : theme.disabledColor.withAlpha(100),
        onClick: hasSelection ? () => onFlush.call() : () {},
        child: Text(
          'Flush to Employees',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.scaffoldBackgroundColor,
          ),
        ),
      );
    }

    if (r.usesEligibleScheduledTabs) {
      if (tab == InterviewCandidateTab.eligible) {
        return ScheduleButton(
          theme: theme,
          isEnabled: hasSelection,
          isFullWidth: true,
          onPressed: () => onSchedule.call(),
        );
      }
      if (tab == InterviewCandidateTab.scheduled) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextButton(
              padding: 0,
              backgroundColor: hasSelection
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.surface,
              onClick: hasSelection ? () => onSelect.call() : () {},
              child: Text(
                'Select',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: hasSelection
                      ? theme.scaffoldBackgroundColor
                      : theme.disabledColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            CustomTextButton(
              padding: 0,
              backgroundColor: hasSelection
                  ? AppPallete.errorMain
                  : theme.colorScheme.surface,
              onClick: hasSelection ? () => onReject.call() : () {},
              child: Text(
                'Reject',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: hasSelection
                      ? theme.scaffoldBackgroundColor
                      : theme.disabledColor,
                ),
              ),
            ),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }
}
