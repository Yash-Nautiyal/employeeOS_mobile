import 'package:employeeos/core/index.dart' show AppPallete;
import 'job_application_full_card.dart';
import 'package:flutter/material.dart';

import 'widgets/action_button.dart';
import 'widgets/status_badge.dart';

class JobApplicationCard extends StatelessWidget {
  const JobApplicationCard({
    super.key,
    required this.theme,
    required this.applicationId,
    required this.candidateName,
    required this.jobTitle, // The job position this person applied TO
    required this.phone,
    required this.email,
    required this.appliedOnText,
    required this.status,
    required this.resumeUrl,
    this.compact = false,
  });

  final ThemeData theme;
  final String applicationId;
  final String candidateName;
  final String
      jobTitle; // e.g. "Senior Flutter Developer" — the role they're applying for
  final String phone;
  final String email;
  final String appliedOnText;
  final String status;
  final String resumeUrl;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final norm = status.toLowerCase().trim();
    final darkColor = switch (norm) {
      'shortlisted' => AppPallete.successDark,
      'applied' => AppPallete.infoDark,
      'rejected' => AppPallete.errorDark,
      'pending' => AppPallete.warningDark,
      _ => AppPallete.infoDark,
    };
    final lightColor = switch (norm) {
      'shortlisted' => AppPallete.successMain,
      'applied' => AppPallete.infoMain,
      'rejected' => AppPallete.errorMain,
      'pending' => AppPallete.warningMain,
      _ => AppPallete.infoMain,
    };

    final statusColor = {'lightColor': lightColor, 'darkColor': darkColor};
    return compact
        ? _buildCompact(context, statusColor)
        : JobApplicationFullCard(
            theme: theme,
            candidateName: candidateName,
            jobTitle: jobTitle,
            status: status,
            statusColor: statusColor,
            appliedOnText: appliedOnText,
            phone: phone,
            email: email,
            applicationId: applicationId,
            resumeUrl: resumeUrl);
  }

  // ---------------------------------------------------------------------------
  // Compact card — single row, shown in grid on wide screens
  // ---------------------------------------------------------------------------

  Widget _buildCompact(BuildContext context, Map<String, Color> statusColor) {
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.shadowColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Name + "Applying for [job]"
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  candidateName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'For  ',
                      style: tt.labelSmall?.copyWith(
                        color: theme.disabledColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        jobTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          StatusBadge(status: status, colors: statusColor, textTheme: tt),
          const SizedBox(width: 8),

          // Resume icon button
          ResumeIconButton(theme: theme, resumeUrl: resumeUrl),
        ],
      ),
    );
  }
}
