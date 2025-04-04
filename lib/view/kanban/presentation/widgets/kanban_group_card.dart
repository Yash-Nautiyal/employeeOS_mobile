import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KanbanGroupCard extends StatelessWidget {
  const KanbanGroupCard({
    super.key,
    required this.title,
    required this.date,
    required this.theme,
  });
  final ThemeData theme;
  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge),
                ),
                SvgPicture.asset(
                  'assets/icons/common/ic-solar_double-alt-arrow-down-bold-duotone.svg',
                  color: AppPallete.infoMain,
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ic-calender.svg',
                  color: AppPallete.grey600,
                ),
                const SizedBox(width: 5),
                Text(date,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                const CircleAvatar(
                  radius: 15,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
