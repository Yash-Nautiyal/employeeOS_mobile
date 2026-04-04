import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../domain/index.dart' show JobPosting;

class JobPostingCardFooter extends StatelessWidget {
  final ThemeData theme;
  final JobPosting? job;
  const JobPostingCardFooter(
      {super.key, required this.theme, required this.job});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildFooterItem(
                  job?.isInternship == null
                      ? ''
                      : job!.isInternship
                          ? 'Internship'
                          : 'Full Time',
                  'assets/icons/common/solid/ic-chart-bar.svg'),
              const SizedBox(
                height: 10,
              ),
              _buildFooterItem(job?.joiningType ?? '',
                  'assets/icons/common/solid/ic-solar_clock-circle-bold.svg'),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildFooterItem(job?.ctcRange ?? '',
                  'assets/icons/common/solid/ic-solar-wad-of-money-bold.svg'),
              const SizedBox(
                height: 10,
              ),
              _buildFooterItem(job?.location ?? '',
                  'assets/icons/common/solid/ic-mingcute_location-fill.svg'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterItem(String value, String iconPath) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SvgPicture.asset(
          iconPath,
          width: 22,
          color: theme.dividerColor,
        ),
        const SizedBox(
          width: 5,
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        )
      ],
    );
  }
}
