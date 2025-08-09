import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class JobPostingCardFooter extends StatelessWidget {
  final ThemeData theme;
  const JobPostingCardFooter({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GridView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 5),
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
              "Full Time",
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            )
          ],
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
              "Immediate",
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            )
          ],
        ),
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
              "3-5.4 lpa",
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            )
          ],
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
              "Mumbai, Maharashtra",
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            )
          ],
        ),
      ],
    );
  }
}
