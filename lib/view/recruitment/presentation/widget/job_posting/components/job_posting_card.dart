import 'package:employeeos/core/index.dart' show AppPallete, CustomDivider;
import 'package:employeeos/view/recruitment/domain/entities/job_posting.dart';
import 'package:employeeos/view/recruitment/index.dart'
    show JobPostingCardHeader, JobPostingCardFooter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class JobPostingCard extends StatefulWidget {
  final ThemeData theme;
  final VoidCallback onViewTap;
  final VoidCallback onEditTap;
  final JobPosting? job;

  /// When false, Edit and Delete are hidden (Phase 1: HR only for own jobs, Admin for any).
  final bool canEditAndDelete;

  const JobPostingCard({
    super.key,
    required this.theme,
    required this.onViewTap,
    required this.onEditTap,
    this.job,
    this.canEditAndDelete = true,
  });

  @override
  State<JobPostingCard> createState() => _JobPostingCardState();
}

class _JobPostingCardState extends State<JobPostingCard>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 13),
      decoration: BoxDecoration(
        color: widget.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.theme.shadowColor),
        boxShadow: [
          BoxShadow(
            color: widget.theme.shadowColor,
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: JobPostingCardHeader(
              theme: widget.theme,
              onViewTap: widget.onViewTap,
              onEditTap: widget.onEditTap,
              canEditAndDelete: widget.canEditAndDelete,
            ),
          ),
          Text(
            widget.job?.title ?? 'Cloud Internship - AWS',
            style: widget.theme.textTheme.displaySmall?.copyWith(fontSize: 20),
          ),
          Text(
            widget.job?.department ?? 'Tech',
            style: widget.theme.textTheme.bodyMedium
                ?.copyWith(color: widget.theme.disabledColor),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Posted date: ${_formatDate(widget.job?.createdAt)}',
            style: widget.theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Wrap(
              spacing: 20,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/common/solid/ic-solar_users-group-rounded-bold.svg',
                      color: AppPallete.successMain,
                      width: 20,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '${widget.job?.positions ?? 1} position${(widget.job?.positions ?? 1) == 1 ? '' : 's'}',
                      style: widget.theme.textTheme.labelLarge
                          ?.copyWith(color: AppPallete.successMain),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/common/solid/ic-file-bold.svg',
                      color: AppPallete.infoMain,
                      width: 20,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.job != null
                          ? '— applications'
                          : '190 applications',
                      style: widget.theme.textTheme.labelLarge
                          ?.copyWith(color: AppPallete.infoMain),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/common/solid/ic-solar_user-id-bold.svg',
                color: widget.theme.disabledColor,
                width: 20,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                'Posted by: ${widget.job?.postedByName ?? 'Yash Nautiyal'}',
                style: widget.theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: widget.theme.dividerColor,
                ),
              )
            ],
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/common/solid/ic-fluent_mail-24-filled.svg',
                color: widget.theme.disabledColor,
                width: 20,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                widget.job?.postedByEmail ?? 'nautiyalyash4@gmail.com',
                style: widget.theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: widget.theme.dividerColor,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10),
            child: CustomDivider(
              color: widget.theme.dividerColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            child: JobPostingCardFooter(theme: widget.theme),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '23 Jun 2025';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
