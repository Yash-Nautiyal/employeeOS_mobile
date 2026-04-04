import 'package:employeeos/core/index.dart' show CustomDialog, CustomTextButton;
import 'package:employeeos/core/user/user_info_entity.dart';
import 'package:employeeos/core/user/user_info_service.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_enums.dart';
import 'package:flutter/material.dart';

import 'schedule_interview_form_dialog.dart';

/// Result of the pre-calendar scheduling form.
class ScheduleInterviewFormResult {
  const ScheduleInterviewFormResult({
    required this.startLocal,
    required this.endLocal,
    required this.interviewer,
    required this.assignedBy,
  });

  final DateTime startLocal;
  final DateTime endLocal;
  final UserInfoEntity interviewer;
  final UserInfoEntity assignedBy;
}

/// Form: date, time, interviewer, assigned by (HR from [UserInfoService]).
Future<ScheduleInterviewFormResult?> showScheduleInterviewFormDialog({
  required BuildContext context,
  required ThemeData theme,
  required UserInfoService userInfoService,
  required InterviewRound round,
}) async {
  return showDialog<ScheduleInterviewFormResult>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => ScheduleInterviewFormDialog(
      theme: theme,
      userInfoService: userInfoService,
      round: round,
    ),
  );
}

/// Stays open until the user confirms scheduling or cancels.
Future<bool> showMeetingScheduledConfirmationDialog({
  required BuildContext context,
  required ThemeData theme,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => CustomDialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Confirm scheduling',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Have you finished creating and saving the meeting in Google Calendar? '
                'Confirm only after the event is saved.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomTextButton(
                    onClick: () =>
                        Navigator.of(ctx, rootNavigator: true).pop(false),
                    child: Text('Cancel', style: theme.textTheme.labelLarge),
                  ),
                  const SizedBox(width: 8),
                  CustomTextButton(
                    backgroundColor: theme.colorScheme.tertiary,
                    onClick: () =>
                        Navigator.of(ctx, rootNavigator: true).pop(true),
                    child: Text(
                      'Yes, meeting scheduled',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}
