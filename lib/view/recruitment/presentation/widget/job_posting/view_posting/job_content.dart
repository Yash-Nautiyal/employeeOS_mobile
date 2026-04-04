import 'package:employeeos/core/index.dart' show CustomTextButton, formatDate;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../domain/index.dart' show JobPosting;

class JobContent extends StatelessWidget {
  final JobPosting job;
  final QuillController? descriptionController;
  final ThemeData theme;
  final bool includeDescription;

  const JobContent({
    super.key,
    required this.job,
    required this.descriptionController,
    required this.theme,
    this.includeDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF28323D)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.shadowColor.withAlpha(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Application Link:',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.applicationLink ?? '',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CustomTextButton(
                                backgroundColor: theme.colorScheme.onSurface,
                                onClick: () {},
                                padding: 0,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.copy_rounded,
                                        size: 16,
                                        color: theme.scaffoldBackgroundColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Copy',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: theme.scaffoldBackgroundColor,
                                      ),
                                    )
                                  ],
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (includeDescription && descriptionController != null)
                QuillEditor.basic(
                  controller: descriptionController!,
                  config: QuillEditorConfig(
                    padding: EdgeInsets.zero,
                    customStyles: DefaultStyles(
                      lists: DefaultListBlockStyle(
                          theme.textTheme.bodyMedium!.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          HorizontalSpacing.zero,
                          VerticalSpacing.zero,
                          VerticalSpacing.zero,
                          null,
                          null),
                      paragraph: DefaultTextBlockStyle(
                        theme.textTheme.bodyMedium!.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        HorizontalSpacing.zero,
                        VerticalSpacing.zero,
                        VerticalSpacing.zero,
                        null,
                      ),
                      h1: DefaultTextBlockStyle(
                        theme.textTheme.titleLarge!.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                        HorizontalSpacing.zero,
                        VerticalSpacing.zero,
                        VerticalSpacing.zero,
                        null,
                      ),
                      h2: DefaultTextBlockStyle(
                        theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                        ),
                        HorizontalSpacing.zero,
                        VerticalSpacing.zero,
                        VerticalSpacing.zero,
                        null,
                      ),
                      h3: DefaultTextBlockStyle(
                        theme.textTheme.titleSmall!.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                        HorizontalSpacing.zero,
                        VerticalSpacing.zero,
                        VerticalSpacing.zero,
                        null,
                      ),
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24).copyWith(bottom: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor,
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdditionalDetails(
                'Department',
                job.department,
                'assets/icons/common/solid/ic-solar_user-id-bold.svg',
              ),
              if (job.location != null && job.location!.isNotEmpty)
                _buildAdditionalDetails(
                  'Location',
                  job.location!,
                  'assets/icons/common/solid/ic-mingcute_location-fill.svg',
                ),
              if (job.positions > 0)
                _buildAdditionalDetails(
                  'Positions',
                  job.positions.toString(),
                  'assets/icons/common/solid/ic-solar_users-group-rounded-bold.svg',
                ),
              if (job.joiningType.isNotEmpty)
                _buildAdditionalDetails(
                  'Joining Type',
                  job.joiningType,
                  'assets/icons/common/solid/ic-solar_clock-circle-bold.svg',
                ),
              if (job.ctcRange != null && job.ctcRange!.isNotEmpty)
                _buildAdditionalDetails(
                  'CTC',
                  job.ctcRange!,
                  'assets/icons/common/solid/ic-solar-wad-of-money-bold.svg',
                ),
              if (job.lastDateToApply != null)
                _buildAdditionalDetails(
                  'Last date to apply',
                  formatDate(job.lastDateToApply!),
                  'assets/icons/common/solid/ic-solar-calendar-date-bold.svg',
                ),
              if (job.createdAt != null)
                _buildAdditionalDetails(
                  'Posted Date',
                  formatDate(job.createdAt!),
                  'assets/icons/common/solid/ic-solar-calendar-date-bold.svg',
                ),
              if (job.postedByName.isNotEmpty)
                _buildAdditionalDetails(
                  'Posted by',
                  job.postedByName,
                  'assets/icons/common/solid/ic-solar-user-circle-bold.svg',
                ),
              if (job.postedByEmail.isNotEmpty)
                _buildAdditionalDetails(
                  'Contact Email',
                  job.postedByEmail,
                  'assets/icons/common/solid/ic-fluent-mail.svg',
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails(String title, String value, String iconPath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 23,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
