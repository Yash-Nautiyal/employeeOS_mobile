import 'package:employeeos/core/index.dart'
    show AppPallete, CustomDivider, fmtDate;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../domain/index.dart' show JobPosting;
import 'job_posting_card_footer.dart';
import 'job_posting_card_header.dart';

class JobPostingCard extends StatefulWidget {
  final ThemeData theme;
  final VoidCallback onViewTap;
  final VoidCallback onEditTap;
  final JobPosting? job;
  final bool canEditAndDelete;
  final Future<void> Function(String jobId, bool isActive)? onJobActiveChanged;
  final Future<void> Function(String jobId)? onCloseJob;
  final Future<void> Function(String jobId)? onDeleteJob;
  final int applicationCount;

  const JobPostingCard({
    super.key,
    required this.theme,
    required this.onViewTap,
    required this.onEditTap,
    this.job,
    this.canEditAndDelete = true,
    this.onJobActiveChanged,
    this.onCloseJob,
    this.onDeleteJob,
    this.applicationCount = 0,
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
              isActive: widget.job?.isActive ?? true,
              onActiveChanged: widget.job != null &&
                      widget.canEditAndDelete &&
                      widget.onJobActiveChanged != null
                  ? (value) {
                      widget.onJobActiveChanged!(widget.job!.id, value);
                    }
                  : null,
              onCloseTap: widget.job != null && widget.onCloseJob != null
                  ? () => widget.onCloseJob!(widget.job!.id)
                  : null,
              onDeleteTap: widget.job != null && widget.onDeleteJob != null
                  ? () => widget.onDeleteJob!(widget.job!.id)
                  : null,
            ),
          ),
          Text(
            widget.job?.title ?? '',
            style: widget.theme.textTheme.displaySmall?.copyWith(fontSize: 20),
          ),
          Text(
            widget.job?.department ?? '',
            style: widget.theme.textTheme.bodyMedium
                ?.copyWith(color: widget.theme.disabledColor),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Posted date: ${fmtDate(widget.job?.createdAt)}',
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
                      colorFilter: const ColorFilter.mode(
                          AppPallete.successMain, BlendMode.srcIn),
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
                      colorFilter: const ColorFilter.mode(
                          AppPallete.infoMain, BlendMode.srcIn),
                      width: 20,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.job != null
                          ? '${widget.applicationCount} application${widget.applicationCount == 1 ? '' : 's'}'
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
                colorFilter: ColorFilter.mode(
                    widget.theme.disabledColor, BlendMode.srcIn),
                width: 20,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                'Posted by: ${widget.job?.postedByName ?? ''}',
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
                colorFilter: ColorFilter.mode(
                    widget.theme.disabledColor, BlendMode.srcIn),
                width: 20,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                widget.job?.postedByEmail ?? '',
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
            child: JobPostingCardFooter(theme: widget.theme, job: widget.job),
          ),
        ],
      ),
    );
  }
}
