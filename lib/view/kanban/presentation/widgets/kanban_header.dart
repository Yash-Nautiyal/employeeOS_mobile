import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KanbanHeader extends StatelessWidget {
  const KanbanHeader({
    super.key,
    required this.theme,
    required this.title,
    required this.count,
  });

  final ThemeData theme;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceDim,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/common/solid/ic-solar_add-circle-bold.svg',
              color: theme.disabledColor,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz, color: theme.colorScheme.tertiary),
          ),
        ],
      ),
    );
  }
}
