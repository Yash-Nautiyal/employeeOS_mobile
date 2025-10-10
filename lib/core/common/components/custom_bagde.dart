import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomBagde extends StatelessWidget {
  final Widget child;
  final String? label;
  final ThemeData theme;
  const CustomBagde(
      {super.key, required this.child, this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return label != null
        ? Badge(
            label: Text(
              label!,
              style: theme.textTheme.labelLarge
                  ?.copyWith(fontSize: 12.sp, color: AppPallete.white),
            ),
            offset: const Offset(-4, 0),
            backgroundColor: AppPallete.errorMain,
            child: child,
          )
        : child;
  }
}
