import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class JobPostingCardHeader extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onSelect;
  const JobPostingCardHeader(
      {super.key, required this.theme, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppPallete.successMain.withOpacity(.2),
          ),
          child: Text(
            'Active',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppPallete.successMain,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Transform.scale(
          scale: .65,
          child: Switch(
            value: false,
            onChanged: (value) {},
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => onSelect.call(),
          icon: const Icon(Icons.more_vert_rounded),
        )
      ],
    );
  }
}
