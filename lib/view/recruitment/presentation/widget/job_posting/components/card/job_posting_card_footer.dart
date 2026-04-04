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
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/common/solid/ic-chart-bar.svg',
                    width: 22,
                    color: theme.dividerColor,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    job?.isInternship == null
                        ? ''
                        : job!.isInternship
                            ? 'Internship'
                            : 'Full Time',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/common/solid/ic-solar_clock-circle-bold.svg',
                    width: 22,
                    color: theme.dividerColor,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    job?.joiningType ?? '',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/common/solid/ic-money.svg',
                    width: 22,
                    color: theme.dividerColor,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    job?.ctcRange ?? '',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/common/solid/ic-mingcute_location-fill.svg',
                    width: 22,
                    color: theme.dividerColor,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    job?.location ?? '',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
