import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.count,
    required this.colorScheme,
    required this.textTheme,
  });

  final int count;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final tt = textTheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/common/solid/ic-material-account-tree.svg',
              width: 16,
              colorFilter:
                  ColorFilter.mode(theme.disabledColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            Text(
              'Hiring pipeline',
              style: tt.labelMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$count',
              style: tt.displayLarge,
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                count == 1 ? 'stage' : 'stages',
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Text('Candidates progress through each stage in sequence.',
            style: tt.bodySmall),
      ],
    );
  }
}
