import 'package:employeeos/core/index.dart' show CustomDivider;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'widgets/action_row.dart';
import 'widgets/status_badge.dart';

class JobApplicationFullCard extends StatelessWidget {
  const JobApplicationFullCard({
    super.key,
    required this.theme,
    required this.candidateName,
    required this.jobTitle,
    required this.status,
    required this.statusColor,
    required this.appliedOnText,
    required this.phone,
    required this.email,
    required this.applicationId,
    required this.resumeUrl,
  });

  final ThemeData theme;
  final String candidateName;
  final String jobTitle;
  final String status;
  final Map<String, Color> statusColor;
  final String appliedOnText;
  final String phone;
  final String email;
  final String applicationId;
  final String resumeUrl;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + name + status ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidateName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // "Applying for" label — makes clear this is a job position
                    Row(
                      children: [
                        Text(
                          'Applied for  ',
                          style: tt.labelSmall?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            jobTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
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
            ],
          ),

          const SizedBox(height: 12),
          CustomDivider(
              height: 1, color: theme.dividerColor.withValues(alpha: 0.25)),
          const SizedBox(height: 10),

          // ── Contact info ────────────────────────────────────────────────
          _infoRow(
            icon: 'assets/icons/common/solid/ic-solar_phone-bold.svg',
            value: phone,
          ),
          _infoRow(
            icon: 'assets/icons/common/solid/ic-fluent_mail-24-filled.svg',
            value: email,
          ),
          _infoRow(
            icon: 'assets/icons/ic-calender.svg',
            value: appliedOnText,
          ),

          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 2),
            child: Text(
              'ID: $applicationId',
              style: tt.labelMedium?.copyWith(
                color: theme.disabledColor.withValues(alpha: 0.55),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Actions ─────────────────────────────────────────────────────
          ActionRow(
            theme: theme,
            status: status,
            resumeUrl: resumeUrl,
          ),
        ],
      ),
    );
  }

  Widget _infoRow({required String icon, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            colorFilter: ColorFilter.mode(theme.disabledColor, BlendMode.srcIn),
            width: 17,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
