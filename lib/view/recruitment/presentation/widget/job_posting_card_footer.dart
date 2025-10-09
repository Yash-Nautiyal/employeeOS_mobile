import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class JobPostingCardFooter extends StatelessWidget {
  final ThemeData theme;
  const JobPostingCardFooter({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  "Immediate",
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                )
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  "3-5.4 lpa",
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
                  "Mumbai, Maharashtra",
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
