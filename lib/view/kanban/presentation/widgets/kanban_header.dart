import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KanbanHeader extends StatelessWidget {
  const KanbanHeader({
    super.key,
    required this.title,
    required this.stateColor,
    required this.theme,
  });
  final String title;
  final ThemeData theme;
  final Color stateColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20).copyWith(left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceDim, shape: BoxShape.circle),
            child: Text(
              '0',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(title, style: theme.textTheme.displaySmall),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/common/solid/ic-solar_add-circle-bold.svg',
              color: theme.colorScheme.tertiary,
            ),
          )
        ],
      ),
    );
  }
}
